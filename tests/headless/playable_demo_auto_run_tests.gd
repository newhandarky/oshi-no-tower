extends SceneTree

const MainScene := preload("res://scenes/main.tscn")
const CombatEngineScript := preload("res://scripts/core/CombatEngine.gd")
const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")

const MAX_NODE_VISITS := 16
const MAX_RUN_STEPS := 80
const MAX_COMBAT_TURNS := 80

var failures: Array[String] = []
var run_logs: Array[Dictionary] = []
var database = RuntimeDatabaseScript.new()
var combat_engine = CombatEngineScript.new()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var cases := [
		{ "id": "subaru", "seed": 2026051341, "required_result": "boss_reward_reached" },
		{ "id": "botan", "seed": 2026051342, "required_result": "boss_reward_reached" },
		{ "id": "azki", "seed": 2026051343, "required_result": "boss_reward_reached" }
	]
	for character_case in cases:
		await _run_auto_case(str(character_case["id"]), int(character_case["seed"]), str(character_case["required_result"]))

	await _test_chapter_2_transition_auto_proxy()
	await _test_azki_forced_laplus_actions()
	await _test_azki_marker_fallback_proxy()
	_test_boss_warning_proxy()

	for log_entry in run_logs:
		print("playable_demo_auto_run_log: %s" % JSON.stringify(log_entry))

	if failures.is_empty():
		print("playable_demo_auto_run_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("playable_demo_auto_run_tests: failed (%d)" % failures.size())
		quit(1)

func _run_auto_case(character_id: String, run_seed: int, required_result: String = "") -> void:
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
		"qa_report": {},
		"qa_report_text": "",
		"azki_actions_seen": [],
		"energy_summary": _empty_energy_summary(),
		"combat_summaries": [],
		"boss_pacing_summary": _empty_boss_pacing_summary(),
		"route_risk_summary": _empty_route_risk_summary(),
		"route_risk_events": [],
		"run_health_flags": [],
		"result": "failed"
	}

	_expect_eq(str(app.current_screen), "map", "%s auto-run 應可進入 random map" % character_id)
	_expect_true(app.run_state.has_active_map(), "%s auto-run 應建立 active_map" % character_id)
	_expect_false(_screen_text(app).contains("Boss 提示："), "%s map UI 不應顯示 Boss 提示" % character_id)

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
	_validate_run_log(log, required_result)
	app.queue_free()

func _advance_current_screen(app: Node, log: Dictionary, step_seed: int) -> bool:
	match str(app.current_screen):
		"map":
			return await _enter_next_available_node(app, step_seed)
		"combat":
			return await _resolve_combat_screen(app, log)
		"reward":
			return await _resolve_reward_screen(app)
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
			_fail("auto-run 不應卡在選牌子畫面：%s" % str(app.current_screen))
			return false
		_:
			_fail("auto-run 遇到未知 screen：%s" % str(app.current_screen))
			return false

func _enter_next_available_node(app: Node, step_seed: int) -> bool:
	if app.run_state.available_node_ids.is_empty():
		_fail("%s map 沒有可進入節點" % str(app.run_state.character_id))
		return false
	var node_id := str(app.run_state.available_node_ids[0])
	if not app.run_state.set_current_node(node_id):
		_fail("%s 無法選取可用節點：%s" % [str(app.run_state.character_id), node_id])
		return false
	seed(step_seed)
	app.enter_current_node()
	await process_frame
	if str(app.current_screen) == "combat":
		_expect_true(_screen_text(app).contains("玩法："), "%s combat UI 應顯示玩法提示" % str(app.run_state.character_id))
	return true

func _resolve_combat_screen(app: Node, log: Dictionary) -> bool:
	if app.combat == null:
		_fail("%s combat screen 沒有 CombatState" % str(app.run_state.character_id))
		return false
	_expect_true(_screen_text(app).contains("玩法："), "%s combat UI 應保留玩法提示" % str(app.run_state.character_id))
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
			played_this_turn = _play_first_affordable_non_curse_card(app, log, turn_energy)
		turn_energy["turn_end_energy"] = int(app.combat.player_energy)
		_record_energy_turn(log, turn_energy)
		if str(app.combat.outcome) != "ongoing":
			break
		app.combat_engine.end_player_turn(app.combat)

	if str(app.combat.outcome) == "ongoing":
		_fail("%s combat 超過 guardrail 仍未結束：%s" % [str(app.run_state.character_id), str(app.combat.enemy.get("id", ""))])
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

func _play_first_affordable_non_curse_card(app: Node, log: Dictionary, turn_energy: Dictionary) -> bool:
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
	var animation := str(selected_card.get("animation", "idle"))
	var cost := int(selected_card.get("cost", 0))
	var energy_before := int(app.combat.player_energy)
	var played: bool = app.combat_engine.try_play_card(app.combat, best_index)
	if played:
		var energy_after := int(app.combat.player_energy)
		var expected_after_cost := energy_before - cost
		turn_energy["energy_spent"] = int(turn_energy.get("energy_spent", 0)) + cost
		turn_energy["energy_gained"] = int(turn_energy.get("energy_gained", 0)) + max(0, energy_after - expected_after_cost)
		turn_energy["cards_played"] = int(turn_energy.get("cards_played", 0)) + 1
	if played and str(app.run_state.character_id) == "azki" and animation in ["laplus_dash", "laplus_crash"]:
		var actions: Array = log.get("azki_actions_seen", [])
		if not actions.has(animation):
			actions.append(animation)
		log["azki_actions_seen"] = actions
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

func _resolve_reward_screen(app: Node) -> bool:
	if app.reward_card_ids.is_empty():
		app._skip_reward()
	else:
		app._take_reward_card(str(app.reward_card_ids[0]))
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
	_fail("%s event 沒有可用選項：%s" % [str(app.run_state.character_id), event_id])
	return false

func _first_removable_card_index(app: Node) -> int:
	for index in range(app.run_state.deck_ids.size()):
		if not str(app.run_state.deck_ids[index]).ends_with("+"):
			return index
	return 0

func _test_chapter_2_transition_auto_proxy() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_random_run(app.database, "botan", 2026051460)
	app.run_state.hp = app.run_state.max_hp
	app.run_state.gold = 180
	app.run_state.deck_ids.clear()
	for card_id in [
		"botan-shot+", "botan-shot+", "botan-cover+", "botan-cover+",
		"botan-funds-prepared+", "botan-heavy-shot+", "botan-counter-line+",
		"botan-perfect-line+", "botan-overwatch+", "botan-piercing-round+"
	]:
		app.run_state.deck_ids.append(str(card_id))
	app.show_boss_reward()
	await process_frame
	app._continue_after_boss_reward()
	await process_frame
	_expect_eq(str(app.current_screen), "chapter_start_event", "強化 auto proxy 應能從 Boss reward 進 Chapter start event")
	await _resolve_chapter_start_event_screen(app, { "route_risk_summary": _empty_route_risk_summary() })
	_expect_eq(str(app.run_state.current_chapter_id), "chapter_2_algorithm_depths", "強化 auto proxy 應切到 Chapter 2")
	_expect_eq(str(app.current_screen), "map", "強化 auto proxy 選完支援後應進 Chapter 2 map")

	var log := {
		"character_id": "botan_chapter_2_proxy",
		"seed": 2026051460,
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
		"azki_actions_seen": [],
		"result": "failed"
	}
	var steps := 0
	while steps < 18 and str(app.current_screen) != "run_end":
		steps += 1
		_update_log_from_app(log, app)
		if int(app.run_state.visited_node_ids.size()) >= 3:
			log["result"] = "chapter_2_nodes_resolved"
			break
		var handled := await _advance_current_screen(app, log, 2026051460 + steps)
		if not handled:
			break
	_update_log_from_app(log, app)
	_expect_eq(str(log.get("result", "")), "chapter_2_nodes_resolved", "強化 auto proxy 應能處理至少 3 個 Chapter 2 節點")
	_expect_true(int(log.get("combat_count", 0)) >= 1, "強化 auto proxy 應至少完成 1 場 Chapter 2 戰鬥")
	app.queue_free()

func _test_azki_forced_laplus_actions() -> void:
	for action in ["laplus_dash", "laplus_crash"]:
		var app = MainScene.instantiate()
		root.add_child(app)
		await process_frame

		app.run_state.start_random_run(app.database, "azki", 2026051350)
		var battle_node := _first_available_node_of_type(app, "battle")
		if battle_node.is_empty():
			_fail("AZKi forced action 無法找到普通戰節點")
			app.queue_free()
			continue
		app.run_state.set_current_node(str(battle_node["id"]))
		app.enter_current_node()
		app.show_combat(action, "idle")
		await process_frame

		_expect_true(_find_child_by_name(app.screen_host, "AZKiBodySprite") != null, "%s 應顯示 AZKiBodySprite" % action)
		_expect_true(_find_child_by_name(app.screen_host, "LaplusSummonSprite") != null, "%s 應顯示 LaplusSummonSprite" % action)
		_expect_true(_find_child_by_name(app.screen_host, "PlayerActionFxSprite") != null, "%s 應顯示 PlayerActionFxSprite" % action)
		_expect_true(_find_child_by_name(app.screen_host, "LaplusSummonHpLabel") != null, "%s 應顯示 LaplusSummonHpLabel" % action)
		app.queue_free()

func _test_azki_marker_fallback_proxy() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_random_run(app.database, "azki", 2026051351)
	var battle_node := _first_available_node_of_type(app, "battle")
	if battle_node.is_empty():
		_fail("AZKi marker fallback 無法找到普通戰節點")
		app.queue_free()
		return
	app.run_state.set_current_node(str(battle_node["id"]))
	app.enter_current_node()
	app.combat.enemy_statuses["marker"] = { "id": "marker", "value": 2, "duration": 1 }
	app.show_combat()
	await process_frame

	_expect_true(_screen_text(app).contains("標記"), "AZKi marker fallback screen text 應包含繁中「標記」")
	app.queue_free()

func _test_boss_warning_proxy() -> void:
	var boss := database.get_enemy("important-announcement")
	var deck := database.resolve_cards(["subaru-guard"])
	var state = combat_engine.start_combat(80, 80, deck, boss)
	combat_engine.end_player_turn(state)
	_expect_eq(state.turn_events.size(), 0, "Boss 非高傷下一意圖時不應提早推 warning")
	combat_engine.end_player_turn(state)
	_expect_true(state.turn_events.size() > 0, "Boss 高傷 intent 應產生 turn_events")
	if state.turn_events.size() > 0:
		_expect_eq(str(state.turn_events[0].get("id", "")), "boss-warning", "Boss warning event id 應存在於 turn_events")

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

func _validate_run_log(log: Dictionary, required_result: String = "") -> void:
	var character_id := str(log.get("character_id", ""))
	var result := str(log.get("result", ""))
	_expect_true(result in ["boss_reward_reached", "defeated"], "%s auto-run 應抵達 Boss reward 或死亡收束，實際：%s" % [character_id, result])
	if required_result != "":
		_expect_eq(result, required_result, "%s fixed-seed balance proxy 應達成 %s" % [character_id, required_result])
	_expect_true(int(log.get("visited_node_count", 0)) >= 2 or result == "defeated", "%s auto-run 應至少完成多個節點或死亡收束" % character_id)
	_expect_true(int(log.get("combat_count", 0)) >= 1, "%s auto-run 應至少完成一場戰鬥流程" % character_id)
	_expect_true(str(log.get("final_screen", "")) in ["map", "reward", "boss_reward", "run_end"], "%s auto-run 不應停在 blocking screen：%s" % [character_id, str(log.get("final_screen", ""))])
	_expect_true((log.get("qa_report", {}) as Dictionary).has("deck_ids"), "%s auto-run log 應包含結構化 QA report" % character_id)
	_expect_true(str(log.get("qa_report_text", "")).contains("QA 回報摘要"), "%s auto-run log 應包含可複製 QA report text" % character_id)
	_validate_energy_summary(log)
	_validate_pacing_and_risk_schema(log)
	if result == "defeated":
		_expect_true(str(log.get("defeat_enemy_id", "")) != "", "%s auto-run 死亡時需記錄 defeat_enemy_id" % character_id)
		_expect_true(int(log.get("defeat_floor", 0)) > 0, "%s auto-run 死亡時需記錄 defeat_floor" % character_id)
		_expect_true(int(log.get("combat_start_hp", 0)) > 0, "%s auto-run 死亡時需記錄 combat_start_hp" % character_id)
		_expect_true((log.get("combat_start_deck_ids", []) as Array).size() > 0, "%s auto-run 死亡時需記錄 combat_start_deck_ids" % character_id)
		_expect_true(log.has("combat_start_relic_ids"), "%s auto-run 死亡時需記錄 combat_start_relic_ids" % character_id)

func _validate_energy_summary(log: Dictionary) -> void:
	var character_id := str(log.get("character_id", ""))
	var summary: Dictionary = log.get("energy_summary", {})
	_expect_true(not summary.is_empty(), "%s auto-run log 需包含 energy_summary" % character_id)
	for key in ["combat_count", "turns_total", "average_unspent_energy", "max_turn_end_energy", "high_unspent_energy_turns"]:
		_expect_true(summary.has(key), "%s energy_summary 需包含 %s" % [character_id, str(key)])
	_expect_eq(int(summary.get("combat_count", 0)), int(log.get("combat_count", 0)), "%s energy_summary combat_count 應等於 combat_count" % character_id)
	_expect_true(int(summary.get("turns_total", 0)) >= int(summary.get("combat_count", 0)), "%s energy_summary turns_total 需至少涵蓋 combat_count" % character_id)
	_expect_true(summary.has("economy_flags"), "%s energy_summary 需包含 economy_flags" % character_id)

func _validate_pacing_and_risk_schema(log: Dictionary) -> void:
	var character_id := str(log.get("character_id", ""))
	_expect_true(log.has("combat_summaries"), "%s auto-run log 需包含 combat_summaries" % character_id)
	_expect_true(log.has("boss_pacing_summary"), "%s auto-run log 需包含 boss_pacing_summary" % character_id)
	_expect_true(log.has("route_risk_summary"), "%s auto-run log 需包含 route_risk_summary" % character_id)
	_expect_true(log.has("route_risk_events"), "%s auto-run log 需包含 route_risk_events" % character_id)
	_expect_true(log.has("run_health_flags"), "%s auto-run log 需包含 run_health_flags" % character_id)
	var combat_summaries: Array = log.get("combat_summaries", [])
	_expect_eq(combat_summaries.size(), int(log.get("combat_count", 0)), "%s combat_summaries 數量應等於 combat_count" % character_id)
	if not combat_summaries.is_empty():
		var first_combat: Dictionary = combat_summaries[0]
		for key in ["enemy_id", "floor", "node_type", "turns", "start_hp", "end_hp", "damage_taken", "cards_played", "average_unspent_energy", "result"]:
			_expect_true(first_combat.has(key), "%s combat summary 需包含 %s" % [character_id, str(key)])
	var boss_summary: Dictionary = log.get("boss_pacing_summary", {})
	for key in ["boss_id", "turns", "start_hp", "end_hp", "over_threshold"]:
		_expect_true(boss_summary.has(key), "%s boss_pacing_summary 需包含 %s" % [character_id, str(key)])
	var route_summary: Dictionary = log.get("route_risk_summary", {})
	for key in ["event_count", "event_battle_count", "curse_added_count", "event_hp_lost", "event_gold_spent", "event_relics_gained"]:
		_expect_true(route_summary.has(key), "%s route_risk_summary 需包含 %s" % [character_id, str(key)])
	var route_events: Array = log.get("route_risk_events", [])
	_expect_eq(route_events.size(), int(route_summary.get("event_count", 0)), "%s route_risk_events 數量應等於 event_count" % character_id)
	if not route_events.is_empty():
		var first_event: Dictionary = route_events[0]
		for key in ["event_id", "floor", "option_label", "hp_delta", "gold_delta", "curse_delta", "relic_delta", "starts_battle", "risk_tags"]:
			_expect_true(first_event.has(key), "%s route_risk_events 需包含 %s" % [character_id, str(key)])

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
	snapshot["run_health_flags"] = log.get("run_health_flags", [])
	log["qa_report"] = snapshot
	log["qa_report_text"] = app._manual_qa_report_text_from_snapshot(snapshot)

func _selected_boss_id(app: Node) -> String:
	for node_variant in app.run_state.active_map.get("nodes", []):
		var node: Dictionary = node_variant
		if str(node.get("type", "")) == "boss":
			return str(node.get("selected_boss_enemy_id", ""))
	return ""

func _first_available_node_of_type(app: Node, node_type: String) -> Dictionary:
	for node_id in app.run_state.available_node_ids:
		var node: Dictionary = app.run_state.get_node_by_id(str(node_id))
		if str(node.get("type", "")) == node_type:
			return node
	return {}

func _option_starts_battle(option: Dictionary) -> bool:
	for outcome_variant in option.get("outcomes", []):
		var outcome: Dictionary = outcome_variant
		if str(outcome.get("action", "")) == "start_battle":
			return true
	return false

func _is_curse_or_unplayable(card: Dictionary) -> bool:
	return bool(card.get("unplayable", false)) or str(card.get("kind", "")) == "curse" or str(card.get("curse_hook", "")) != ""

func _find_child_by_name(node: Node, target_name: String) -> Node:
	if str(node.name).begins_with(target_name):
		return node
	for child in node.get_children():
		var found := _find_child_by_name(child, target_name)
		if found != null:
			return found
	return null

func _screen_text(app: Node) -> String:
	return _node_text(app.screen_host)

func _node_text(node: Node) -> String:
	var text := ""
	for child in node.get_children():
		if child is Label:
			text += " " + str((child as Label).text)
		elif child is Button:
			text += " " + str((child as Button).text)
		text += _node_text(child)
	return text

func _fail(message: String) -> void:
	failures.append(message)

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_false(actual: bool, message: String) -> void:
	if actual:
		failures.append("%s：expected false, got true" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
