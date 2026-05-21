extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

const MAX_NODE_VISITS := 16
const MAX_RUN_STEPS := 80
const MAX_COMBAT_TURNS := 80
const SEEDS_PER_CHARACTER := 10

var failures: Array[String] = []
var run_logs: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_auto_play_proxy_scores_card_depth_v1_effects()
	if not failures.is_empty():
		for failure in failures:
			push_error(failure)
		print("multiseed_balance_probe_tests: failed (%d)" % failures.size())
		quit(1)
		return

	var character_seed_bases := {
		"subaru": 2026052100,
		"botan": 2026052200,
		"azki": 2026052300
	}
	for character_id in character_seed_bases.keys():
		var base_seed := int(character_seed_bases[character_id])
		for seed_offset in range(1, SEEDS_PER_CHARACTER + 1):
			await _run_auto_case(str(character_id), base_seed + seed_offset)

	for log_entry in run_logs:
		print("multiseed_balance_probe_log: %s" % JSON.stringify(log_entry))
	var summary := _build_summary()
	print("multiseed_balance_probe_summary: %s" % JSON.stringify(summary))
	var failure_cases := _build_failure_cases()
	print("multiseed_balance_probe_failure_cases: %s" % JSON.stringify(failure_cases))
	var failure_analysis := _build_failure_analysis(failure_cases)
	print("multiseed_balance_probe_failure_analysis: %s" % JSON.stringify(failure_analysis))
	_validate_probe_summary(summary)
	_validate_failure_cases(failure_cases)
	_validate_failure_analysis(failure_analysis)

	if failures.is_empty():
		print("multiseed_balance_probe_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("multiseed_balance_probe_tests: failed (%d)" % failures.size())
		quit(1)

func _run_auto_case(character_id: String, run_seed: int) -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	seed(run_seed)
	app.run_state.start_random_run(app.database, character_id, run_seed)
	app.show_map()
	await process_frame

	var log := {
		"character_id": character_id,
		"seed": run_seed,
		"final_screen": "",
		"final_floor": 0,
		"boss_id": _selected_boss_id(app),
		"hp": 0,
		"gold": 0,
		"deck_count": 0,
		"relic_count": 0,
		"event_battle_count": 0,
		"combat_count": 0,
		"elite_count": 0,
		"visited_node_count": 0,
		"defeat_enemy_id": "",
		"defeat_floor": 0,
		"combat_start_hp": 0,
		"combat_start_deck_ids": [],
		"combat_start_relic_ids": [],
		"route_node_ids": [],
		"route_node_types": [],
		"qa_report": {},
		"qa_report_text": "",
		"energy_summary": _empty_energy_summary(),
		"combat_summaries": [],
		"boss_pacing_summary": _empty_boss_pacing_summary(),
		"route_risk_summary": _empty_route_risk_summary(),
		"route_risk_events": [],
		"reward_choice_summaries": [],
		"deck_archetype_timeline": [],
		"key_pickup_floors": {},
		"run_health_flags": [],
		"result": "failed"
	}

	if str(app.current_screen) != "map":
		_fail("%s seed %d 未進入 map：%s" % [character_id, run_seed, str(app.current_screen)])
	if not app.run_state.has_active_map():
		_fail("%s seed %d 未建立 active_map" % [character_id, run_seed])

	var run_steps := 0
	while run_steps < MAX_RUN_STEPS:
		run_steps += 1
		_update_log_from_app(log, app)

		if str(app.current_screen) == "boss_reward":
			log["result"] = "boss_reward_reached"
			break
		if str(app.current_screen) == "run_end":
			log["result"] = "boss_reward_reached" if bool(app.last_run_end_cleared) else "defeated"
			break
		if int(app.run_state.hp) <= 0:
			app.show_run_end(false)
			await process_frame
			log["result"] = "defeated"
			break
		if int(log["visited_node_count"]) >= MAX_NODE_VISITS:
			log["result"] = "stopped_by_guardrail"
			break

		var handled := await _advance_current_screen(app, log, run_seed + run_steps)
		if not handled:
			log["result"] = "failed"
			break

	if str(log["result"]) == "failed" and run_steps >= MAX_RUN_STEPS:
		log["result"] = "stopped_by_guardrail"

	_update_log_from_app(log, app)
	_apply_economy_flags(log)
	run_logs.append(log.duplicate(true))
	_validate_probe_log(log)
	app.queue_free()

func _advance_current_screen(app: Node, log: Dictionary, step_seed: int) -> bool:
	match str(app.current_screen):
		"map":
			return await _enter_next_available_node(app, log, step_seed)
		"combat":
			return await _resolve_combat_screen(app, log)
		"reward":
			return await _resolve_reward_screen(app, log)
		"chest_reward":
			app._continue_after_chest_reward()
			await process_frame
			return true
		"shop":
			app._complete_node()
			app.show_map()
			await process_frame
			return true
		"event":
			return await _resolve_event_screen(app, log)
		"chapter_start_event":
			return await _resolve_chapter_start_event_screen(app, log)
		"event_remove_selection":
			var removed: bool = app._event_remove_card_at_index(_first_removable_card_index(app), 1)
			await process_frame
			return removed
		"campfire":
			app.run_state.hp = min(app.run_state.max_hp, app.run_state.hp + 22)
			app._complete_node()
			app.show_map()
			await process_frame
			return true
		"shop_remove_selection", "campfire_upgrade_selection":
			_fail("probe 不應卡在選牌畫面：%s" % str(app.current_screen))
			return false
		_:
			_fail("probe 遇到未知 screen：%s" % str(app.current_screen))
			return false

func _enter_next_available_node(app: Node, log: Dictionary, step_seed: int) -> bool:
	if app.run_state.available_node_ids.is_empty():
		_fail("%s seed %d map 沒有可進入節點" % [str(app.run_state.character_id), int(log.get("seed", 0))])
		return false
	var node_id := str(app.run_state.available_node_ids[0])
	if not app.run_state.set_current_node(node_id):
		_fail("%s seed %d 無法選取節點：%s" % [str(app.run_state.character_id), int(log.get("seed", 0)), node_id])
		return false
	var node: Dictionary = app.run_state.get_current_node(app.database)
	var node_ids: Array = log.get("route_node_ids", [])
	var node_types: Array = log.get("route_node_types", [])
	node_ids.append(node_id)
	node_types.append(str(node.get("type", "")))
	log["route_node_ids"] = node_ids
	log["route_node_types"] = node_types
	seed(step_seed)
	app.enter_current_node()
	await process_frame
	return true

func _resolve_combat_screen(app: Node, log: Dictionary) -> bool:
	if app.combat == null:
		_fail("%s seed %d combat screen 沒有 CombatState" % [str(app.run_state.character_id), int(log.get("seed", 0))])
		return false
	log["combat_count"] = int(log.get("combat_count", 0)) + 1
	if bool(app.event_battle_pending):
		log["event_battle_count"] = int(log.get("event_battle_count", 0)) + 1
	if str(app.combat.enemy.get("tier", "")) == "elite":
		log["elite_count"] = int(log.get("elite_count", 0)) + 1
	log["combat_start_hp"] = int(app.run_state.hp)
	log["combat_start_deck_ids"] = app.run_state.deck_ids.duplicate()
	log["combat_start_relic_ids"] = app.run_state.relic_ids.duplicate()
	_start_energy_combat(log)
	var combat_energy_start: Dictionary = (log.get("energy_summary", {}) as Dictionary).duplicate(true)
	var current_node: Dictionary = app.run_state.get_current_node(app.database)
	var combat_floor := int(current_node.get("floor", 0))
	var combat_node_type := str(current_node.get("type", "combat"))
	var enemy_id := str(app.combat.enemy.get("id", ""))
	var combat_start_hp := int(app.run_state.hp)

	var turns := 0
	while turns < MAX_COMBAT_TURNS and str(app.combat.outcome) == "ongoing":
		turns += 1
		var turn_energy := _new_energy_turn(app)
		var played_this_turn := true
		while played_this_turn and str(app.combat.outcome) == "ongoing":
			played_this_turn = _play_first_affordable_non_curse_card(app, turn_energy)
		turn_energy["turn_end_energy"] = int(app.combat.player_energy)
		_record_energy_turn(log, turn_energy)
		if str(app.combat.outcome) != "ongoing":
			break
		app.combat_engine.end_player_turn(app.combat)

	if str(app.combat.outcome) == "ongoing":
		_fail("%s seed %d combat 超過 guardrail：%s" % [str(app.run_state.character_id), int(log.get("seed", 0)), str(app.combat.enemy.get("id", ""))])
		return false
	_record_combat_summary(log, app, enemy_id, combat_floor, combat_node_type, turns, combat_start_hp, combat_energy_start)
	if str(app.combat.outcome) == "defeat":
		log["defeat_enemy_id"] = str(app.combat.enemy.get("id", ""))
		log["defeat_floor"] = int(app.run_state.get_current_node(app.database).get("floor", 0))
		app.run_state.hp = 0
		app.show_run_end(false)
		await process_frame
		return true

	app.run_state.hp = app.combat.player_hp
	app.run_state.gold += int(app.combat.enemy.get("gold", 0)) + app._battle_reward_gold_bonus()
	app._grant_combat_relic_reward(app.combat.enemy)
	if bool(app.event_battle_pending):
		app.show_reward("事件戰鬥獎勵", app._combat_reward_subtitle(app.combat.enemy), true)
	elif bool(app.combat.enemy.get("is_boss", false)):
		app._complete_node()
		app.show_boss_reward()
	else:
		app.show_reward("戰鬥獎勵", app._combat_reward_subtitle(app.combat.enemy), true)
	await process_frame
	return true

func _resolve_reward_screen(app: Node, log: Dictionary) -> bool:
	if app.reward_card_ids.is_empty():
		app._skip_reward()
	else:
		var current_node: Dictionary = app.run_state.get_current_node(app.database)
		var floor := int(current_node.get("floor", 0))
		var choices: Array[String] = []
		for card_id_variant in app.reward_card_ids:
			choices.append(str(card_id_variant))
		var selected_card_id := str(app.reward_card_ids[0])
		var before := _deck_archetype_snapshot(app)
		app._take_reward_card(selected_card_id)
		_record_reward_choice(log, app, floor, choices, selected_card_id, before)
	await process_frame
	return true

func _resolve_event_screen(app: Node, log: Dictionary) -> bool:
	var node: Dictionary = app.run_state.get_current_node(app.database)
	var event_id := str(node.get("event_id", "holostar-sponsor"))
	var event_def: Dictionary = app.database.get_event(event_id)
	var options: Array = event_def.get("options", [])
	for option_variant in options:
		var option: Dictionary = option_variant
		if not app._event_option_available(option):
			continue
		var before := _route_snapshot(app)
		var starts_battle := _option_starts_battle(option)
		if not _option_starts_battle(option):
			var resolved: bool = app._resolve_event_option(option.duplicate(true))
			await process_frame
			_record_route_risk_delta(log, before, _route_snapshot(app), true, starts_battle, event_id, int(node.get("floor", 0)), option)
			return resolved
	for option_variant in options:
		var option: Dictionary = option_variant
		if app._event_option_available(option):
			var before := _route_snapshot(app)
			var starts_battle := _option_starts_battle(option)
			var resolved: bool = app._resolve_event_option(option.duplicate(true))
			await process_frame
			_record_route_risk_delta(log, before, _route_snapshot(app), true, starts_battle, event_id, int(node.get("floor", 0)), option)
			return resolved
	_fail("%s seed %d event 沒有可用選項：%s" % [str(app.run_state.character_id), int(node.get("seed", 0)), event_id])
	return false

func _resolve_chapter_start_event_screen(app: Node, log: Dictionary) -> bool:
	var options: Array = app.chapter_start_options
	if options.is_empty():
		_fail("chapter_start_event 沒有 draft option")
		return false
	var before := _route_snapshot(app)
	var selected_option: Dictionary = options[0]
	var resolved: bool = app._resolve_chapter_start_option(selected_option.duplicate(true))
	await process_frame
	_record_route_risk_delta(log, before, _route_snapshot(app), true, false, "chapter_start_event", 0, selected_option)
	return resolved

func _play_first_affordable_non_curse_card(app: Node, turn_energy: Dictionary) -> bool:
	var best_index := -1
	var best_score := -99999.0
	for hand_index in range(app.combat.hand.size()):
		var card: Dictionary = app.combat.hand[hand_index]
		if _is_curse_or_unplayable(card):
			continue
		if int(app.combat.player_energy) < int(card.get("cost", 0)):
			continue
		var score := _auto_play_card_score(app, card)
		if score > best_score:
			best_score = score
			best_index = hand_index
	if best_index < 0:
		return false
	var selected_card: Dictionary = app.combat.hand[best_index]
	var cost := int(selected_card.get("cost", 0))
	var energy_before := int(app.combat.player_energy)
	var played: bool = app.combat_engine.try_play_card(app.combat, best_index)
	if played:
		var energy_after := int(app.combat.player_energy)
		var expected_after_cost := energy_before - cost
		turn_energy["energy_spent"] = int(turn_energy.get("energy_spent", 0)) + cost
		turn_energy["energy_gained"] = int(turn_energy.get("energy_gained", 0)) + max(0, energy_after - expected_after_cost)
		turn_energy["cards_played"] = int(turn_energy.get("cards_played", 0)) + 1
	return played

func _auto_play_card_score(app: Node, card: Dictionary) -> float:
	var score := 0.0
	var intent_type := str(app.combat.current_intent.get("type", ""))
	var enemy_attacking := intent_type in ["attack", "attack_block"]
	for effect_variant in card.get("effects", []):
		var effect: Dictionary = effect_variant
		score += _auto_play_effect_score(effect, enemy_attacking)
	if int(app.combat.next_attack_bonus) > 0 and str(card.get("kind", "")) == "attack":
		score += float(int(app.combat.next_attack_bonus)) * 5.5
	if str(card.get("kind", "")) == "attack":
		score += 4.0
	if str(card.get("kind", "")) == "support":
		score += 1.5
	score -= float(int(card.get("cost", 0))) * 0.25
	return score

func _auto_play_effect_score(effect: Dictionary, enemy_attacking: bool) -> float:
	match str(effect.get("type", "")):
		"damage":
			return float(int(effect.get("amount", 0)) * max(1, int(effect.get("hits", 1)))) * 3.0
		"block":
			return float(int(effect.get("amount", 0))) * (2.0 if enemy_attacking else 0.35)
		"draw":
			return float(int(effect.get("amount", 0))) * 4.0
		"draw_from_discard":
			return float(int(effect.get("amount", 1))) * 6.5
		"next_attack_bonus":
			return float(int(effect.get("amount", 0))) * 5.0
		"temporary_card":
			var temp_card: Dictionary = effect.get("card", {})
			var temp_score := 6.0
			for nested_variant in temp_card.get("effects", []):
				var nested: Dictionary = nested_variant
				temp_score += _auto_play_effect_score(nested, enemy_attacking) * 0.65
			return temp_score
		"draw_if_status":
			return float(int(effect.get("amount", 0))) * 3.0
		"energy":
			return float(int(effect.get("amount", 0))) * 5.0
		"status":
			var status_id := str(effect.get("status_id", ""))
			if status_id in ["vulnerable", "weak", "marker"]:
				return 9.0
			if status_id in ["strength", "regen"]:
				return 7.0
		"conditional":
			var nested_score := 0.0
			for nested_variant in effect.get("effects", []):
				var nested: Dictionary = nested_variant
				nested_score += _auto_play_effect_score(nested, enemy_attacking)
			return nested_score * 0.75
		"summon_heal":
			return float(int(effect.get("amount", 0))) * 2.0
		"summon_hp_damage":
			return float(int(effect.get("base", 0)) + int(effect.get("per_hp", 1)) * 8) * 2.4
	return 0.0

func _test_auto_play_proxy_scores_card_depth_v1_effects() -> void:
	_expect_true(_auto_play_effect_score({ "type": "next_attack_bonus", "amount": 8 }, true) > 0.0, "auto-play proxy 需評價 next_attack_bonus，避免低估 setup 爆發牌")
	_expect_true(_auto_play_effect_score({ "type": "draw_from_discard", "amount": 1, "kind": "attack" }, true) > 0.0, "auto-play proxy 需評價 draw_from_discard，避免低估回收橋接牌")
	_expect_true(_auto_play_effect_score({
		"type": "temporary_card",
		"amount": 1,
		"card": { "effects": [{ "type": "damage", "amount": 4, "hits": 1 }, { "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }] }
	}, true) > 0.0, "auto-play proxy 需評價 temporary_card，避免低估臨時牌 setup")

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _empty_energy_summary() -> Dictionary:
	return {
		"combat_count": 0,
		"turns_total": 0,
		"total_turn_end_energy": 0,
		"average_unspent_energy": 0.0,
		"max_turn_end_energy": 0,
		"high_unspent_energy_turns": 0,
		"energy_spent": 0,
		"energy_gained": 0,
		"cards_played": 0,
		"economy_flags": []
	}

func _new_energy_turn(app: Node) -> Dictionary:
	return {
		"turn_start_energy": int(app.combat.player_energy),
		"energy_spent": 0,
		"energy_gained": 0,
		"turn_end_energy": 0,
		"cards_played": 0
	}

func _start_energy_combat(log: Dictionary) -> void:
	var summary: Dictionary = log.get("energy_summary", {})
	if summary.is_empty():
		summary = _empty_energy_summary()
	summary["combat_count"] = int(summary.get("combat_count", 0)) + 1
	log["energy_summary"] = summary

func _record_energy_turn(log: Dictionary, turn_energy: Dictionary) -> void:
	var summary: Dictionary = log.get("energy_summary", {})
	if summary.is_empty():
		summary = _empty_energy_summary()
	var turn_end_energy := int(turn_energy.get("turn_end_energy", 0))
	summary["turns_total"] = int(summary.get("turns_total", 0)) + 1
	summary["total_turn_end_energy"] = int(summary.get("total_turn_end_energy", 0)) + turn_end_energy
	summary["average_unspent_energy"] = float(summary["total_turn_end_energy"]) / float(max(1, int(summary["turns_total"])))
	summary["max_turn_end_energy"] = max(int(summary.get("max_turn_end_energy", 0)), turn_end_energy)
	if turn_end_energy >= 2:
		summary["high_unspent_energy_turns"] = int(summary.get("high_unspent_energy_turns", 0)) + 1
	summary["energy_spent"] = int(summary.get("energy_spent", 0)) + int(turn_energy.get("energy_spent", 0))
	summary["energy_gained"] = int(summary.get("energy_gained", 0)) + int(turn_energy.get("energy_gained", 0))
	summary["cards_played"] = int(summary.get("cards_played", 0)) + int(turn_energy.get("cards_played", 0))
	log["energy_summary"] = summary

func _merge_energy_summary(left: Dictionary, right: Dictionary) -> Dictionary:
	var result := left.duplicate(true)
	if result.is_empty():
		result = _empty_energy_summary()
	result["combat_count"] = int(result.get("combat_count", 0)) + int(right.get("combat_count", 0))
	result["turns_total"] = int(result.get("turns_total", 0)) + int(right.get("turns_total", 0))
	result["total_turn_end_energy"] = int(result.get("total_turn_end_energy", 0)) + int(right.get("total_turn_end_energy", 0))
	result["average_unspent_energy"] = float(result["total_turn_end_energy"]) / float(max(1, int(result["turns_total"])))
	result["max_turn_end_energy"] = max(int(result.get("max_turn_end_energy", 0)), int(right.get("max_turn_end_energy", 0)))
	result["high_unspent_energy_turns"] = int(result.get("high_unspent_energy_turns", 0)) + int(right.get("high_unspent_energy_turns", 0))
	result["energy_spent"] = int(result.get("energy_spent", 0)) + int(right.get("energy_spent", 0))
	result["energy_gained"] = int(result.get("energy_gained", 0)) + int(right.get("energy_gained", 0))
	result["cards_played"] = int(result.get("cards_played", 0)) + int(right.get("cards_played", 0))
	var flags: Array = result.get("economy_flags", [])
	for flag_variant in right.get("economy_flags", []):
		var flag := str(flag_variant)
		if not flags.has(flag):
			flags.append(flag)
	result["economy_flags"] = flags
	return result

func _apply_economy_flags(log: Dictionary) -> void:
	var summary: Dictionary = log.get("energy_summary", {})
	if summary.is_empty():
		summary = _empty_energy_summary()
	var flags: Array = summary.get("economy_flags", [])
	if str(log.get("character_id", "")) == "subaru":
		if float(summary.get("average_unspent_energy", 0.0)) >= 1.5 and int(summary.get("high_unspent_energy_turns", 0)) >= 8:
			if not flags.has("subaru_energy_overflow_watch"):
				flags.append("subaru_energy_overflow_watch")
	summary["economy_flags"] = flags
	log["energy_summary"] = summary

func _empty_boss_pacing_summary() -> Dictionary:
	return {
		"boss_id": "",
		"turns": 0,
		"start_hp": 0,
		"end_hp": 0,
		"over_threshold": false
	}

func _empty_route_risk_summary() -> Dictionary:
	return {
		"event_count": 0,
		"event_battle_count": 0,
		"curse_added_count": 0,
		"event_hp_lost": 0,
		"event_gold_spent": 0,
		"event_relics_gained": 0
	}

func _empty_character_pacing_summary() -> Dictionary:
	return {
		"boss_combat_count": 0,
		"total_boss_turns": 0,
		"average_boss_turns": 0.0,
		"max_boss_turns": 0,
		"boss_over_threshold_count": 0,
		"route_risk_summary": _empty_route_risk_summary(),
		"run_health_flags": {}
	}

func _route_snapshot(app: Node) -> Dictionary:
	return {
		"hp": int(app.run_state.hp),
		"gold": int(app.run_state.gold),
		"deck_count": app.run_state.deck_ids.size(),
		"curse_count": _count_curses(app.run_state.deck_ids),
		"relic_count": app.run_state.relic_ids.size()
	}

func _count_curses(deck_ids: Array) -> int:
	var count := 0
	for card_id_variant in deck_ids:
		if str(card_id_variant).begins_with("curse-"):
			count += 1
	return count

func _record_route_risk_delta(log: Dictionary, before: Dictionary, after: Dictionary, count_event: bool, starts_battle: bool, event_id: String = "", floor: int = 0, option: Dictionary = {}) -> void:
	var summary: Dictionary = log.get("route_risk_summary", {})
	if summary.is_empty():
		summary = _empty_route_risk_summary()
	if count_event:
		summary["event_count"] = int(summary.get("event_count", 0)) + 1
	if starts_battle:
		summary["event_battle_count"] = int(summary.get("event_battle_count", 0)) + 1
	var hp_delta := int(after.get("hp", 0)) - int(before.get("hp", 0))
	var gold_delta := int(after.get("gold", 0)) - int(before.get("gold", 0))
	var curse_delta := int(after.get("curse_count", 0)) - int(before.get("curse_count", 0))
	var relic_delta := int(after.get("relic_count", 0)) - int(before.get("relic_count", 0))
	if hp_delta < 0:
		summary["event_hp_lost"] = int(summary.get("event_hp_lost", 0)) + abs(hp_delta)
	if gold_delta < 0:
		summary["event_gold_spent"] = int(summary.get("event_gold_spent", 0)) + abs(gold_delta)
	if curse_delta > 0:
		summary["curse_added_count"] = int(summary.get("curse_added_count", 0)) + curse_delta
	if relic_delta > 0:
		summary["event_relics_gained"] = int(summary.get("event_relics_gained", 0)) + relic_delta
	log["route_risk_summary"] = summary
	if count_event:
		var route_events: Array = log.get("route_risk_events", [])
		route_events.append({
			"event_id": event_id,
			"floor": floor,
			"option_label": str(option.get("label", option.get("title", ""))),
			"hp_delta": hp_delta,
			"gold_delta": gold_delta,
			"curse_delta": curse_delta,
			"relic_delta": relic_delta,
			"starts_battle": starts_battle,
			"risk_tags": _route_risk_tags(hp_delta, gold_delta, curse_delta, relic_delta, starts_battle)
		})
		log["route_risk_events"] = route_events

func _route_risk_tags(hp_delta: int, gold_delta: int, curse_delta: int, relic_delta: int, starts_battle: bool) -> Array[String]:
	var tags: Array[String] = []
	if hp_delta < 0:
		tags.append("hp_loss")
	if gold_delta < 0:
		tags.append("gold_spend")
	if curse_delta > 0:
		tags.append("curse_added")
	if relic_delta > 0:
		tags.append("relic_gain")
	if starts_battle:
		tags.append("event_battle")
	if tags.is_empty():
		tags.append("low_risk")
	return tags

func _record_reward_choice(log: Dictionary, app: Node, floor: int, choices: Array[String], selected_card_id: String, before_snapshot: Dictionary) -> void:
	var selected_card: Dictionary = app.database.get_card(selected_card_id)
	var after_snapshot := _deck_archetype_snapshot(app)
	var summaries: Array = log.get("reward_choice_summaries", [])
	summaries.append({
		"floor": floor,
		"choices": choices,
		"selected_card_id": selected_card_id,
		"selected_roles": selected_card.get("role_tags", []),
		"selected_archetypes": selected_card.get("archetype_tags", []),
		"before": before_snapshot,
		"after": after_snapshot
	})
	log["reward_choice_summaries"] = summaries
	var timeline: Array = log.get("deck_archetype_timeline", [])
	timeline.append({
		"floor": floor,
		"selected_card_id": selected_card_id,
		"snapshot": after_snapshot
	})
	log["deck_archetype_timeline"] = timeline
	_record_key_pickup_floor(log, str(app.run_state.character_id), selected_card, floor)

func _deck_archetype_snapshot(app: Node) -> Dictionary:
	var snapshot := {}
	for card_id_variant in app.run_state.deck_ids:
		var card: Dictionary = app.database.get_card(str(card_id_variant))
		for tag_variant in card.get("archetype_tags", []):
			var tag := str(tag_variant)
			snapshot[tag] = int(snapshot.get(tag, 0)) + 1
		for role_variant in card.get("role_tags", []):
			var role_key := "role:%s" % str(role_variant)
			snapshot[role_key] = int(snapshot.get(role_key, 0)) + 1
	return snapshot

func _record_key_pickup_floor(log: Dictionary, character_id: String, card: Dictionary, floor: int) -> void:
	var key_map: Dictionary = log.get("key_pickup_floors", {})
	for key in _key_pickup_tags(character_id, card):
		if not key_map.has(key):
			key_map[key] = floor
	log["key_pickup_floors"] = key_map

func _key_pickup_tags(character_id: String, card: Dictionary) -> Array[String]:
	var result: Array[String] = []
	var archetypes: Array = card.get("archetype_tags", [])
	var roles: Array = card.get("role_tags", [])
	match character_id:
		"subaru":
			if archetypes.has("cheap_chain"):
				result.append("cheap_chain")
			if archetypes.has("tempo_block"):
				result.append("tempo_block")
			if roles.has("defense"):
				result.append("mid_defense")
			if roles.has("payoff"):
				result.append("payoff")
		"botan":
			if archetypes.has("two_cost_burst"):
				result.append("two_cost_burst")
			if roles.has("setup") or roles.has("bridge"):
				result.append("setup_control")
			if roles.has("defense"):
				result.append("defense")
			if roles.has("payoff"):
				result.append("payoff")
		"azki":
			if archetypes.has("marker_loop"):
				result.append("marker")
			if archetypes.has("laplus_guard") and (roles.has("bridge") or roles.has("defense")):
				result.append("laplus_bridge")
			if archetypes.has("laplus_guard") and roles.has("payoff"):
				result.append("laplus_payoff")
			if roles.has("scaling"):
				result.append("scaling")
	return result

func _record_combat_summary(log: Dictionary, app: Node, enemy_id: String, floor: int, node_type: String, turns: int, start_hp: int, energy_start: Dictionary) -> void:
	var energy_now: Dictionary = log.get("energy_summary", {})
	var combat_turns: int = max(1, int(energy_now.get("turns_total", 0)) - int(energy_start.get("turns_total", 0)))
	var combat_turn_end_energy := int(energy_now.get("total_turn_end_energy", 0)) - int(energy_start.get("total_turn_end_energy", 0))
	var combat_cards_played := int(energy_now.get("cards_played", 0)) - int(energy_start.get("cards_played", 0))
	var end_hp := int(app.combat.player_hp) if str(app.combat.outcome) == "victory" else 0
	var combat_summary := {
		"enemy_id": enemy_id,
		"floor": floor,
		"node_type": node_type,
		"turns": turns,
		"start_hp": start_hp,
		"end_hp": end_hp,
		"damage_taken": max(0, start_hp - end_hp),
		"cards_played": combat_cards_played,
		"average_unspent_energy": float(combat_turn_end_energy) / float(combat_turns),
		"result": str(app.combat.outcome)
	}
	var combat_summaries: Array = log.get("combat_summaries", [])
	combat_summaries.append(combat_summary)
	log["combat_summaries"] = combat_summaries
	if bool(app.combat.enemy.get("is_boss", false)):
		var over_threshold := str(log.get("character_id", "")) == "azki" and turns >= 12
		log["boss_pacing_summary"] = {
			"boss_id": enemy_id,
			"turns": turns,
			"start_hp": start_hp,
			"end_hp": end_hp,
			"over_threshold": over_threshold
		}
		if over_threshold:
			_append_run_health_flag(log, "azki_boss_pacing_watch")
		var route_summary: Dictionary = log.get("route_risk_summary", {})
		if start_hp < 18 and int(route_summary.get("event_hp_lost", 0)) >= 14:
			_append_run_health_flag(log, "event_risk_compounding_watch")
	if str(log.get("character_id", "")) == "subaru" and floor >= 7 and floor <= 11 and (str(app.combat.outcome) == "defeat" or end_hp <= 10):
		_append_run_health_flag(log, "subaru_midrun_hp_pressure_watch")

func _append_run_health_flag(log: Dictionary, flag: String) -> void:
	var flags: Array = log.get("run_health_flags", [])
	if not flags.has(flag):
		flags.append(flag)
	log["run_health_flags"] = flags

func _merge_route_risk_summary(left: Dictionary, right: Dictionary) -> Dictionary:
	var result := left.duplicate(true)
	if result.is_empty():
		result = _empty_route_risk_summary()
	for key in ["event_count", "event_battle_count", "curse_added_count", "event_hp_lost", "event_gold_spent", "event_relics_gained"]:
		result[key] = int(result.get(key, 0)) + int(right.get(key, 0))
	return result

func _merge_character_pacing_summary(left: Dictionary, log: Dictionary) -> Dictionary:
	var result := left.duplicate(true)
	if result.is_empty():
		result = _empty_character_pacing_summary()
	var boss_summary: Dictionary = log.get("boss_pacing_summary", {})
	if int(boss_summary.get("turns", 0)) > 0:
		result["boss_combat_count"] = int(result.get("boss_combat_count", 0)) + 1
		result["total_boss_turns"] = int(result.get("total_boss_turns", 0)) + int(boss_summary.get("turns", 0))
		result["average_boss_turns"] = float(result["total_boss_turns"]) / float(max(1, int(result["boss_combat_count"])))
		result["max_boss_turns"] = max(int(result.get("max_boss_turns", 0)), int(boss_summary.get("turns", 0)))
		if bool(boss_summary.get("over_threshold", false)):
			result["boss_over_threshold_count"] = int(result.get("boss_over_threshold_count", 0)) + 1
	result["route_risk_summary"] = _merge_route_risk_summary(result.get("route_risk_summary", {}), log.get("route_risk_summary", {}))
	var flag_counts: Dictionary = result.get("run_health_flags", {})
	for flag_variant in log.get("run_health_flags", []):
		_increment_count(flag_counts, str(flag_variant))
	result["run_health_flags"] = flag_counts
	return result

func _build_summary() -> Dictionary:
	var summary := {}
	for log in run_logs:
		var character_id := str(log.get("character_id", ""))
		if not summary.has(character_id):
			summary[character_id] = {
				"total": 0,
				"boss_reward_reached": 0,
				"defeated": 0,
				"failed": 0,
				"boss_reward_rate": 0.0,
				"average_win_hp": 0.0,
				"min_win_hp": 99999,
				"max_win_hp": 0,
				"average_final_floor": 0.0,
				"boss_ids": {},
				"defeat_enemy_ids": {},
				"defeat_floors": {},
				"energy_summary": _empty_energy_summary(),
				"pacing_summary": _empty_character_pacing_summary(),
				"key_pickup_floor_totals": {},
				"reward_choice_count": 0,
				"failure_cases": []
			}
		var stats: Dictionary = summary[character_id]
		var result := str(log.get("result", ""))
		stats["total"] = int(stats["total"]) + 1
		stats[result] = int(stats.get(result, 0)) + 1
		stats["average_final_floor"] = float(stats["average_final_floor"]) + float(int(log.get("final_floor", 0)))
		stats["energy_summary"] = _merge_energy_summary(stats.get("energy_summary", {}), log.get("energy_summary", {}))
		stats["pacing_summary"] = _merge_character_pacing_summary(stats.get("pacing_summary", {}), log)
		stats["key_pickup_floor_totals"] = _merge_key_pickup_floor_totals(stats.get("key_pickup_floor_totals", {}), log.get("key_pickup_floors", {}))
		stats["reward_choice_count"] = int(stats.get("reward_choice_count", 0)) + (log.get("reward_choice_summaries", []) as Array).size()
		_increment_count(stats["boss_ids"], str(log.get("boss_id", "")))
		if result == "boss_reward_reached":
			var hp := int(log.get("hp", 0))
			stats["average_win_hp"] = float(stats["average_win_hp"]) + float(hp)
			stats["min_win_hp"] = min(int(stats["min_win_hp"]), hp)
			stats["max_win_hp"] = max(int(stats["max_win_hp"]), hp)
		elif result == "defeated":
			_increment_count(stats["defeat_enemy_ids"], str(log.get("defeat_enemy_id", "")))
			_increment_count(stats["defeat_floors"], str(log.get("defeat_floor", 0)))
			var cases: Array = stats.get("failure_cases", [])
			cases.append(_failure_case_from_log(log))
			stats["failure_cases"] = cases
	for character_id in summary.keys():
		var stats: Dictionary = summary[character_id]
		var total: int = max(1, int(stats["total"]))
		var wins := int(stats.get("boss_reward_reached", 0))
		stats["boss_reward_rate"] = float(wins) / float(total)
		stats["average_final_floor"] = float(stats["average_final_floor"]) / float(total)
		var win_divisor: int = max(1, wins)
		stats["average_win_hp"] = float(stats["average_win_hp"]) / float(win_divisor)
		if wins == 0:
			stats["min_win_hp"] = 0
	return summary

func _merge_key_pickup_floor_totals(left: Dictionary, right: Dictionary) -> Dictionary:
	var result := left.duplicate(true)
	for key_variant in right.keys():
		var key := str(key_variant)
		result[key] = int(result.get(key, 0)) + int(right.get(key_variant, 0))
	return result

func _build_failure_cases() -> Array[Dictionary]:
	var cases: Array[Dictionary] = []
	for log in run_logs:
		if str(log.get("result", "")) == "defeated":
			cases.append(_failure_case_from_log(log))
	return cases

func _build_failure_analysis(cases: Array[Dictionary]) -> Dictionary:
	var analysis := {}
	for character_id in ["subaru", "botan", "azki"]:
		analysis[character_id] = _empty_failure_analysis_stats()
	for failure_case in cases:
		var character_id := str(failure_case.get("character_id", ""))
		if not analysis.has(character_id):
			analysis[character_id] = _empty_failure_analysis_stats()
		var stats: Dictionary = analysis[character_id]
		stats["total_failures"] = int(stats["total_failures"]) + 1
		var defeat_floor := int(failure_case.get("defeat_floor", 0))
		_increment_count(stats["defeat_floors"], str(defeat_floor))
		_increment_count(stats["defeat_enemy_ids"], str(failure_case.get("defeat_enemy_id", "")))
		if defeat_floor >= 16:
			stats["boss_failures"] = int(stats["boss_failures"]) + 1
		elif defeat_floor > 0:
			stats["midrun_failures"] = int(stats["midrun_failures"]) + 1
		if _failure_case_has_curse(failure_case):
			stats["curse_seen"] = int(stats["curse_seen"]) + 1
	for character_id in analysis.keys():
		var stats: Dictionary = analysis[character_id]
		stats["repeated_defeat_floors"] = _counts_at_least(stats["defeat_floors"], 2)
		stats["repeated_defeat_enemy_ids"] = _counts_at_least(stats["defeat_enemy_ids"], 2)
		stats["likely_issues"] = _likely_issues_for_failure_stats(str(character_id), stats)
	return analysis

func _empty_failure_analysis_stats() -> Dictionary:
	return {
		"total_failures": 0,
		"defeat_floors": {},
		"defeat_enemy_ids": {},
		"boss_failures": 0,
		"midrun_failures": 0,
		"curse_seen": 0,
		"repeated_defeat_floors": {},
		"repeated_defeat_enemy_ids": {},
		"likely_issues": []
	}

func _failure_case_from_log(log: Dictionary) -> Dictionary:
	var report: Dictionary = log.get("qa_report", {})
	return {
		"character_id": str(log.get("character_id", "")),
		"seed": int(log.get("seed", 0)),
		"boss_id": str(log.get("boss_id", "")),
		"defeat_floor": int(log.get("defeat_floor", 0)),
		"defeat_enemy_id": str(log.get("defeat_enemy_id", "")),
		"defeat_hp": int(report.get("defeat_hp", 0)),
		"deck_summary": str(report.get("deck_summary", "")),
		"relic_summary": str(report.get("relic_summary", "")),
		"qa_report_text": str(log.get("qa_report_text", ""))
	}

func _validate_probe_summary(summary: Dictionary) -> void:
	var minimum_boss_reward_reached := {
		"subaru": 5,
		"botan": 5,
		"azki": 5
	}
	for character_id in minimum_boss_reward_reached.keys():
		var stats: Dictionary = summary.get(str(character_id), {})
		var reached := int(stats.get("boss_reward_reached", 0))
		var required := int(minimum_boss_reward_reached[character_id])
		_expect_true(reached >= required, "%s multiseed 至少應有 %d/%d 抵達 boss_reward，目前 %d/%d" % [str(character_id), required, SEEDS_PER_CHARACTER, reached, SEEDS_PER_CHARACTER])
		_expect_true(float(stats.get("average_final_floor", 0.0)) >= 12.0, "%s multiseed 平均結束樓層應至少 12，目前 %.2f" % [str(character_id), float(stats.get("average_final_floor", 0.0))])
		var failure_cases: Array = stats.get("failure_cases", [])
		_expect_true(failure_cases.size() == int(stats.get("defeated", 0)), "%s summary failure_cases 數量需等於 defeated 數量" % str(character_id))
		var energy_summary: Dictionary = stats.get("energy_summary", {})
		_validate_energy_summary({
			"character_id": character_id,
			"seed": 0,
			"combat_count": int(energy_summary.get("combat_count", 0)),
			"energy_summary": energy_summary
		})
		_validate_character_pacing_summary(str(character_id), stats.get("pacing_summary", {}))
		_expect_true(stats.has("key_pickup_floor_totals"), "%s summary 需包含 key_pickup_floor_totals" % str(character_id))
		_expect_true(stats.has("reward_choice_count"), "%s summary 需包含 reward_choice_count" % str(character_id))

func _validate_failure_cases(cases: Array[Dictionary]) -> void:
	_expect_true(not cases.is_empty(), "multiseed 應輸出失敗 seed triage cases，方便後續分群分析")
	for failure_case in cases:
		_expect_true(str(failure_case.get("character_id", "")) != "", "failure case 需包含 character_id")
		_expect_true(int(failure_case.get("seed", 0)) > 0, "failure case 需包含 seed")
		_expect_true(int(failure_case.get("defeat_floor", 0)) > 0, "failure case 需包含死亡樓層")
		_expect_true(str(failure_case.get("defeat_enemy_id", "")) != "", "failure case 需包含死亡敵人 id")
		_expect_true(str(failure_case.get("deck_summary", "")) != "", "failure case 需包含中文 deck 摘要")
		_expect_true(str(failure_case.get("relic_summary", "")) != "", "failure case 需包含中文 relic 摘要")
		_expect_true(str(failure_case.get("qa_report_text", "")).contains("QA 回報摘要"), "failure case 需保留可複製 QA report text")

func _validate_failure_analysis(analysis: Dictionary) -> void:
	_expect_true(not analysis.is_empty(), "multiseed 需輸出 failure analysis，方便後續判斷是否要調平衡")
	for character_id in ["subaru", "botan", "azki"]:
		var stats: Dictionary = analysis.get(character_id, {})
		_expect_true(int(stats.get("total_failures", 0)) >= 0, "%s failure analysis 需包含 total_failures" % character_id)
		_expect_true(stats.has("repeated_defeat_floors"), "%s failure analysis 需包含 repeated_defeat_floors" % character_id)
		_expect_true(stats.has("repeated_defeat_enemy_ids"), "%s failure analysis 需包含 repeated_defeat_enemy_ids" % character_id)
		_expect_true(stats.has("likely_issues"), "%s failure analysis 需包含 likely_issues" % character_id)
		var defeat_enemy_ids: Dictionary = stats.get("defeat_enemy_ids", {})
		if character_id == "azki":
			_expect_true(int(defeat_enemy_ids.get("ssrb-giant-camouflage", 0)) <= 2, "015 AZKi 不應反覆死於 ssrb-giant-camouflage boss")
		if character_id == "subaru":
			_expect_true(int(defeat_enemy_ids.get("ssrb-debuff-check", 0)) <= 1, "015 Subaru 不應反覆死於 ssrb-debuff-check 中段壓力")

func _increment_count(counts: Dictionary, key: String) -> void:
	if key == "":
		key = "__empty__"
	counts[key] = int(counts.get(key, 0)) + 1

func _counts_at_least(counts: Dictionary, threshold: int) -> Dictionary:
	var result := {}
	for key in counts.keys():
		var count := int(counts[key])
		if count >= threshold:
			result[str(key)] = count
	return result

func _failure_case_has_curse(failure_case: Dictionary) -> bool:
	var deck_summary := str(failure_case.get("deck_summary", ""))
	return deck_summary.contains("Dead Air") or deck_summary.contains("Bad Connection") or deck_summary.contains("Comment Fire")

func _likely_issues_for_failure_stats(character_id: String, stats: Dictionary) -> Array[String]:
	var issues: Array[String] = []
	if int(stats.get("boss_failures", 0)) >= 2:
		issues.append("late_boss_pressure")
	if int(stats.get("midrun_failures", 0)) >= 2:
		issues.append("midrun_stability")
	if not (stats.get("repeated_defeat_enemy_ids", {}) as Dictionary).is_empty():
		issues.append("repeated_enemy_pattern")
	if int(stats.get("curse_seen", 0)) >= 2:
		issues.append("curse_risk_compounding")
	if character_id == "azki" and int(stats.get("boss_failures", 0)) >= 2:
		issues.append("azki_late_closing_or_guard_pressure")
	if character_id == "subaru" and int(stats.get("midrun_failures", 0)) >= 2:
		issues.append("subaru_mid_elite_defense_pressure")
	if character_id == "botan" and int(stats.get("boss_failures", 0)) >= 1:
		issues.append("botan_boss_pressure_watch_only")
	if issues.is_empty() and int(stats.get("total_failures", 0)) > 0:
		issues.append("single_seed_variance")
	return issues

func _validate_probe_log(log: Dictionary) -> void:
	var result := str(log.get("result", ""))
	if not result in ["boss_reward_reached", "defeated"]:
		_fail("%s seed %d probe 遇到非收束結果：%s" % [str(log.get("character_id", "")), int(log.get("seed", 0)), result])
	if int(log.get("combat_count", 0)) < 1:
		_fail("%s seed %d probe 沒有完成任何戰鬥流程" % [str(log.get("character_id", "")), int(log.get("seed", 0))])
	if not str(log.get("final_screen", "")) in ["map", "reward", "boss_reward", "run_end"]:
		_fail("%s seed %d probe 停在 blocking screen：%s" % [str(log.get("character_id", "")), int(log.get("seed", 0)), str(log.get("final_screen", ""))])
	if not (log.get("qa_report", {}) as Dictionary).has("deck_ids"):
		_fail("%s seed %d probe 需輸出結構化 QA report" % [str(log.get("character_id", "")), int(log.get("seed", 0))])
	if not str(log.get("qa_report_text", "")).contains("QA 回報摘要"):
		_fail("%s seed %d probe 需輸出可複製 QA report text" % [str(log.get("character_id", "")), int(log.get("seed", 0))])
	_validate_energy_summary(log)
	_validate_pacing_and_risk_schema(log)

func _validate_energy_summary(log: Dictionary) -> void:
	var character_id := str(log.get("character_id", ""))
	var seed_value := int(log.get("seed", 0))
	var summary: Dictionary = log.get("energy_summary", {})
	_expect_true(not summary.is_empty(), "%s seed %d 需包含 energy_summary" % [character_id, seed_value])
	for key in ["combat_count", "turns_total", "average_unspent_energy", "max_turn_end_energy", "high_unspent_energy_turns"]:
		_expect_true(summary.has(key), "%s seed %d energy_summary 需包含 %s" % [character_id, seed_value, str(key)])
	_expect_true(int(summary.get("combat_count", 0)) == int(log.get("combat_count", 0)), "%s seed %d energy_summary combat_count 需等於 combat_count" % [character_id, seed_value])
	_expect_true(int(summary.get("turns_total", 0)) >= int(summary.get("combat_count", 0)), "%s seed %d energy_summary turns_total 需至少涵蓋 combat_count" % [character_id, seed_value])
	_expect_true(summary.has("economy_flags"), "%s seed %d energy_summary 需包含 economy_flags" % [character_id, seed_value])

func _validate_pacing_and_risk_schema(log: Dictionary) -> void:
	var character_id := str(log.get("character_id", ""))
	var seed_value := int(log.get("seed", 0))
	_expect_true(log.has("combat_summaries"), "%s seed %d log 需包含 combat_summaries" % [character_id, seed_value])
	_expect_true(log.has("boss_pacing_summary"), "%s seed %d log 需包含 boss_pacing_summary" % [character_id, seed_value])
	_expect_true(log.has("route_risk_summary"), "%s seed %d log 需包含 route_risk_summary" % [character_id, seed_value])
	_expect_true(log.has("route_risk_events"), "%s seed %d log 需包含 route_risk_events" % [character_id, seed_value])
	_expect_true(log.has("reward_choice_summaries"), "%s seed %d log 需包含 reward_choice_summaries" % [character_id, seed_value])
	_expect_true(log.has("deck_archetype_timeline"), "%s seed %d log 需包含 deck_archetype_timeline" % [character_id, seed_value])
	_expect_true(log.has("key_pickup_floors"), "%s seed %d log 需包含 key_pickup_floors" % [character_id, seed_value])
	_expect_true(log.has("run_health_flags"), "%s seed %d log 需包含 run_health_flags" % [character_id, seed_value])
	var combat_summaries: Array = log.get("combat_summaries", [])
	_expect_true(combat_summaries.size() == int(log.get("combat_count", 0)), "%s seed %d combat_summaries 數量需等於 combat_count" % [character_id, seed_value])
	if not combat_summaries.is_empty():
		var first_combat: Dictionary = combat_summaries[0]
		for key in ["enemy_id", "floor", "node_type", "turns", "start_hp", "end_hp", "damage_taken", "cards_played", "average_unspent_energy", "result"]:
			_expect_true(first_combat.has(key), "%s seed %d combat summary 需包含 %s" % [character_id, seed_value, str(key)])
	var boss_summary: Dictionary = log.get("boss_pacing_summary", {})
	for key in ["boss_id", "turns", "start_hp", "end_hp", "over_threshold"]:
		_expect_true(boss_summary.has(key), "%s seed %d boss_pacing_summary 需包含 %s" % [character_id, seed_value, str(key)])
	var route_summary: Dictionary = log.get("route_risk_summary", {})
	for key in ["event_count", "event_battle_count", "curse_added_count", "event_hp_lost", "event_gold_spent", "event_relics_gained"]:
		_expect_true(route_summary.has(key), "%s seed %d route_risk_summary 需包含 %s" % [character_id, seed_value, str(key)])
	var route_events: Array = log.get("route_risk_events", [])
	_expect_true(route_events.size() == int(route_summary.get("event_count", 0)), "%s seed %d route_risk_events 數量需等於 event_count" % [character_id, seed_value])
	if not route_events.is_empty():
		var first_event: Dictionary = route_events[0]
		for key in ["event_id", "floor", "option_label", "hp_delta", "gold_delta", "curse_delta", "relic_delta", "starts_battle", "risk_tags"]:
			_expect_true(first_event.has(key), "%s seed %d route_risk_events 需包含 %s" % [character_id, seed_value, str(key)])
	var reward_summaries: Array = log.get("reward_choice_summaries", [])
	if not reward_summaries.is_empty():
		var first_reward: Dictionary = reward_summaries[0]
		for key in ["floor", "choices", "selected_card_id", "selected_roles", "selected_archetypes", "before", "after"]:
			_expect_true(first_reward.has(key), "%s seed %d reward_choice_summaries 需包含 %s" % [character_id, seed_value, str(key)])

func _validate_character_pacing_summary(character_id: String, pacing_summary: Dictionary) -> void:
	_expect_true(pacing_summary.has("average_boss_turns"), "%s summary 需包含 average_boss_turns" % character_id)
	_expect_true(pacing_summary.has("max_boss_turns"), "%s summary 需包含 max_boss_turns" % character_id)
	_expect_true(pacing_summary.has("route_risk_summary"), "%s summary 需包含 route_risk_summary" % character_id)
	_expect_true(pacing_summary.has("run_health_flags"), "%s summary 需包含 run_health_flags" % character_id)

func _update_log_from_app(log: Dictionary, app: Node) -> void:
	var current_node: Dictionary = app.run_state.get_current_node(app.database)
	log["final_screen"] = str(app.current_screen)
	log["final_floor"] = int(current_node.get("floor", 0))
	log["boss_id"] = _selected_boss_id(app)
	log["hp"] = int(app.run_state.hp)
	log["gold"] = int(app.run_state.gold)
	log["deck_count"] = app.run_state.deck_ids.size()
	log["relic_count"] = app.run_state.relic_ids.size()
	log["visited_node_count"] = app.run_state.visited_node_ids.size()
	_update_qa_report_from_app(log, app)

func _update_qa_report_from_app(log: Dictionary, app: Node) -> void:
	var cleared := str(app.current_screen) == "boss_reward" or (str(app.current_screen) == "run_end" and bool(app.last_run_end_cleared))
	var snapshot: Dictionary = app._manual_qa_report_snapshot(cleared)
	snapshot["boss_pacing_summary"] = log.get("boss_pacing_summary", _empty_boss_pacing_summary())
	snapshot["route_risk_summary"] = log.get("route_risk_summary", _empty_route_risk_summary())
	snapshot["route_risk_events"] = log.get("route_risk_events", [])
	snapshot["reward_choice_summaries"] = log.get("reward_choice_summaries", [])
	snapshot["deck_archetype_timeline"] = log.get("deck_archetype_timeline", [])
	snapshot["key_pickup_floors"] = log.get("key_pickup_floors", {})
	snapshot["run_health_flags"] = log.get("run_health_flags", [])
	log["qa_report"] = snapshot
	log["qa_report_text"] = app._manual_qa_report_text_from_snapshot(snapshot)

func _selected_boss_id(app: Node) -> String:
	for node_variant in app.run_state.active_map.get("nodes", []):
		var node: Dictionary = node_variant
		if str(node.get("type", "")) == "boss":
			return str(node.get("selected_boss_enemy_id", ""))
	return ""

func _option_starts_battle(option: Dictionary) -> bool:
	for outcome_variant in option.get("outcomes", []):
		var outcome: Dictionary = outcome_variant
		if str(outcome.get("action", "")) == "start_battle":
			return true
	return false

func _first_removable_card_index(app: Node) -> int:
	for index in range(app.run_state.deck_ids.size()):
		if not str(app.run_state.deck_ids[index]).ends_with("+"):
			return index
	return 0

func _is_curse_or_unplayable(card: Dictionary) -> bool:
	return bool(card.get("unplayable", false)) or str(card.get("kind", "")) == "curse" or str(card.get("curse_hook", "")) != ""

func _fail(message: String) -> void:
	failures.append(message)
