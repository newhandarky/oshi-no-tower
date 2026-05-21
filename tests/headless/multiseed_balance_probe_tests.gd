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
			return await _resolve_event_screen(app)
		"chapter_start_event":
			return await _resolve_chapter_start_event_screen(app)
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

	var turns := 0
	while turns < MAX_COMBAT_TURNS and str(app.combat.outcome) == "ongoing":
		turns += 1
		var played_this_turn := true
		while played_this_turn and str(app.combat.outcome) == "ongoing":
			played_this_turn = _play_first_affordable_non_curse_card(app)
		if str(app.combat.outcome) != "ongoing":
			break
		app.combat_engine.end_player_turn(app.combat)

	if str(app.combat.outcome) == "ongoing":
		_fail("%s seed %d combat 超過 guardrail：%s" % [str(app.run_state.character_id), int(log.get("seed", 0)), str(app.combat.enemy.get("id", ""))])
		return false
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

func _resolve_reward_screen(app: Node) -> bool:
	if app.reward_card_ids.is_empty():
		app._skip_reward()
	else:
		app._take_reward_card(str(app.reward_card_ids[0]))
	await process_frame
	return true

func _resolve_event_screen(app: Node) -> bool:
	var node: Dictionary = app.run_state.get_current_node(app.database)
	var event_id := str(node.get("event_id", "holostar-sponsor"))
	var event_def: Dictionary = app.database.get_event(event_id)
	var options: Array = event_def.get("options", [])
	for option_variant in options:
		var option: Dictionary = option_variant
		if not app._event_option_available(option):
			continue
		if not _option_starts_battle(option):
			var resolved: bool = app._resolve_event_option(option.duplicate(true))
			await process_frame
			return resolved
	for option_variant in options:
		var option: Dictionary = option_variant
		if app._event_option_available(option):
			var resolved: bool = app._resolve_event_option(option.duplicate(true))
			await process_frame
			return resolved
	_fail("%s seed %d event 沒有可用選項：%s" % [str(app.run_state.character_id), int(node.get("seed", 0)), event_id])
	return false

func _resolve_chapter_start_event_screen(app: Node) -> bool:
	var options: Array = app.chapter_start_options
	if options.is_empty():
		_fail("chapter_start_event 沒有 draft option")
		return false
	var resolved: bool = app._resolve_chapter_start_option(options[0].duplicate(true))
	await process_frame
	return resolved

func _play_first_affordable_non_curse_card(app: Node) -> bool:
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
	return app.combat_engine.try_play_card(app.combat, best_index)

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
				"failure_cases": []
			}
		var stats: Dictionary = summary[character_id]
		var result := str(log.get("result", ""))
		stats["total"] = int(stats["total"]) + 1
		stats[result] = int(stats.get(result, 0)) + 1
		stats["average_final_floor"] = float(stats["average_final_floor"]) + float(int(log.get("final_floor", 0)))
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
