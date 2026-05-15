extends SceneTree

const MainScene := preload("res://scenes/main.tscn")
const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")
const RandomMapGeneratorScript := preload("res://scripts/data/RandomMapGenerator.gd")

var database = RuntimeDatabaseScript.new()
var generator = RandomMapGeneratorScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_chapter_2_content_contracts_are_runtime_ready()
	_test_chapter_2_balance_pass_one_pressure_guardrails()
	_test_chapter_2_random_map_uses_chapter_2_pools()
	await _test_boss_reward_routes_to_chapter_start_event()
	await _test_chapter_start_event_generates_chapter_2_map()
	await _test_chapter_start_event_outcomes_are_applied()

	if failures.is_empty():
		print("chapter_2_runtime_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("chapter_2_runtime_tests: failed (%d)" % failures.size())
		quit(1)

func _test_chapter_2_content_contracts_are_runtime_ready() -> void:
	for enemy_id in ["recommendation-watcher", "buffering-wall", "comment-flood", "bitrate-phantom", "archive-sentinel"]:
		var enemy := database.get_enemy(enemy_id)
		_expect_eq(str(enemy.get("chapter_id", "")), "chapter_2_algorithm_depths", "%s 應標記 Chapter 2" % enemy_id)
		_expect_true(enemy.get("pressure_tags", []).size() >= 1, "%s 應保留 pressure_tags" % enemy_id)
		_expect_not_empty(str(enemy.get("counterplay_hint", "")), "%s 應提供 counterplay_hint" % enemy_id)
	for elite_id in ["algorithm-auditor"]:
		var elite := database.get_enemy(elite_id)
		_expect_eq(str(elite.get("tier", "")), "elite", "%s 應是 elite" % elite_id)
		_expect_eq(str(elite.get("chapter_id", "")), "chapter_2_algorithm_depths", "%s 應標記 Chapter 2" % elite_id)
	for boss_id in ["algorithm-core", "archive-phantom", "notification-storm"]:
		var boss := database.get_enemy(boss_id)
		_expect_true(bool(boss.get("is_boss", false)), "%s 應是 Boss" % boss_id)
		_expect_eq(str(boss.get("chapter_id", "")), "chapter_2_algorithm_depths", "%s 應標記 Chapter 2" % boss_id)
		_expect_eq(str(boss.get("boss_hint", "")), "", "%s 不應保留 map hint 文案" % boss_id)
		_expect_not_empty(str(boss.get("boss_counterplay", "")), "%s 應提供 combat counterplay" % boss_id)

	var support_event := database.get_chapter_start_event("chapter_2_algorithm_depths")
	_expect_eq(str(support_event.get("id", "")), "chapter-2-support-desk", "Chapter 2 start event id")
	_expect_true(support_event.get("options", []).size() >= 6, "Chapter 2 start event 至少應有 6 個選項")

func _test_chapter_2_balance_pass_one_pressure_guardrails() -> void:
	_expect_enemy_action_cap("recommendation-watcher", "attack", "damage", 12, "Chapter 2 early anti-cycle 起手傷害不可過高")
	_expect_enemy_action_cap("recommendation-watcher", "attack_block", "damage", 9, "Chapter 2 early anti-cycle 攻防回合需留出防守窗口")
	_expect_enemy_action_cap("recommendation-watcher", "attack_block", "block", 8, "Chapter 2 early anti-cycle 攻防回合不可同時高防")
	_expect_enemy_action_cap("buffering-wall", "block", "block", 20, "Chapter 2 early block puzzle 不應讓未成形 deck 完全空轉")
	_expect_enemy_action_cap("buffering-wall", "attack", "damage", 14, "Chapter 2 early block puzzle 反擊傷害需給 AZKi 入口 deck 防守空間")
	_expect_enemy_action_cap("comment-flood", "attack", "damage", 5, "Chapter 2 mid multi-hit 單段傷害需讓 Laplus/tempo block 有管理空間")
	_expect_enemy_action_cap("comment-flood", "attack_block", "damage", 12, "Chapter 2 mid attack_block 不可和易傷形成過高尖峰")
	_expect_enemy_action_cap("comment-flood", "attack_block", "block", 8, "Chapter 2 mid attack_block 防禦不應拖慢 AZKi/Laplus 收束")
	_expect_enemy_action_cap("clip-mirror", "attack", "damage", 16, "Chapter 2 mid anti-cycle 普攻需避免過度懲罰未成形 marker deck")
	_expect_enemy_action_cap("bitrate-phantom", "attack", "damage", 26, "Chapter 2 mid delayed burst 要可被 warning / 防守接住")
	_expect_enemy_action_cap("archive-sentinel", "block", "block", 24, "Chapter 2 late block puzzle 不應完全封死非 Botan deck")
	_expect_enemy_action_cap("archive-sentinel", "attack_block", "damage", 22, "Chapter 2 late attack_block 需保留反打窗口")

func _test_chapter_2_random_map_uses_chapter_2_pools() -> void:
	var generated := generator.generate_map(database, 2026051401, "chapter_2_algorithm_depths")
	_expect_eq(str(generated.get("chapter_id", "")), "chapter_2_algorithm_depths", "Chapter 2 map 應標記 chapter_id")
	_expect_eq(int(generated.get("boss_floor", 0)), 16, "Chapter 2 仍使用 16 floor")
	var seen_common := {}
	var seen_elite := {}
	var boss_id := ""
	for node_variant in generated.get("nodes", []):
		var node: Dictionary = node_variant
		match str(node.get("type", "")):
			"battle":
				var enemy := database.get_enemy(str(node.get("enemy_id", "")))
				_expect_eq(str(enemy.get("chapter_id", "")), "chapter_2_algorithm_depths", "%s battle 應使用 Chapter 2 enemy" % str(node.get("id", "")))
				seen_common[str(enemy.get("id", ""))] = true
			"elite":
				var elite := database.get_enemy(str(node.get("enemy_id", "")))
				_expect_eq(str(elite.get("chapter_id", "")), "chapter_2_algorithm_depths", "%s elite 應使用 Chapter 2 elite" % str(node.get("id", "")))
				seen_elite[str(elite.get("id", ""))] = true
			"event":
				var event_def := database.get_event(str(node.get("event_id", "")))
				_expect_eq(str(event_def.get("chapter_id", "")), "chapter_2_algorithm_depths", "%s event 應使用 Chapter 2 event" % str(node.get("id", "")))
			"boss":
				boss_id = str(node.get("selected_boss_enemy_id", ""))
				var boss := database.get_enemy(boss_id)
				_expect_eq(str(boss.get("chapter_id", "")), "chapter_2_algorithm_depths", "Chapter 2 Boss pool 應只選第二章 Boss")
	_expect_true(seen_common.size() >= 3, "Chapter 2 map 應涵蓋多種 common enemy")
	_expect_true(seen_elite.size() >= 1, "Chapter 2 map 應涵蓋 elite enemy")
	_expect_not_empty(boss_id, "Chapter 2 map 應保存 selected Boss")

func _test_boss_reward_routes_to_chapter_start_event() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame
	app.run_state.start_random_run(app.database, "subaru", 2026051402)
	app.run_state.hp = 7
	app.show_boss_reward()
	await process_frame
	app._continue_after_boss_reward()
	await process_frame
	_expect_eq(str(app.current_screen), "chapter_start_event", "Chapter 1 Boss reward 後應進 chapter_start_event")
	_expect_eq(str(app.run_state.current_chapter_id), "mvp_single_act_tower", "進開場事件前仍應記錄剛完成 Chapter 1")
	_expect_eq(int(app.run_state.hp), int(app.run_state.max_hp), "進 Chapter 2 開場事件前 HP 應回滿")
	_expect_true(_screen_text(app).contains("Holo Support Desk"), "chapter_start_event UI 應顯示支援台")
	app.queue_free()

func _test_chapter_start_event_generates_chapter_2_map() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame
	app.run_state.start_random_run(app.database, "botan", 2026051403)
	app.show_chapter_start_event()
	await process_frame
	var options: Array = app.chapter_start_options
	_expect_eq(options.size(), 3, "Chapter start event 應 draft 3 個選項")
	_expect_true(_options_have_low_risk(options), "Chapter start event 至少要有 1 個 low risk")
	_expect_true(_options_have_resource_heavy(options), "Chapter start event 至少要有 1 個 resource-heavy option")
	app._resolve_chapter_start_option(options[0])
	await process_frame
	_expect_eq(str(app.current_screen), "map", "選完 Chapter start option 應進 Chapter 2 map")
	_expect_eq(str(app.run_state.current_chapter_id), "chapter_2_algorithm_depths", "RunState 應切到 Chapter 2")
	_expect_eq(str(app.run_state.active_map.get("chapter_id", "")), "chapter_2_algorithm_depths", "active_map 應是 Chapter 2")
	_expect_true(_screen_text(app).contains("演算法深層"), "Chapter 2 map UI 應顯示章節名稱")
	app.queue_free()

func _test_chapter_start_event_outcomes_are_applied() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame
	app.run_state.start_random_run(app.database, "subaru", 2026051404)
	app.run_state.gold = 10
	var options: Array = app.database.draft_chapter_start_options("chapter_2_algorithm_depths", 2026051404, app.run_state.gold, 0)
	for option in options:
		_expect_false(str(option.get("option_id", "")) == "support-gold-for-hp-cap", "Gold 不足時不應 draft support-gold-for-hp-cap")

	var original_max_hp := int(app.run_state.max_hp)
	app.run_state.gold = 100
	app._apply_event_outcome({ "action": "increase_max_hp", "amount": 6 })
	_expect_eq(int(app.run_state.max_hp), original_max_hp + 6, "increase_max_hp 應提高 Max HP")

	var original_deck_size: int = app.run_state.deck_ids.size()
	app._apply_event_outcome({ "action": "add_random_curse", "amount": 1 })
	_expect_eq(app.run_state.deck_ids.size(), original_deck_size + 1, "add_random_curse 應加入 1 張 curse")
	_expect_true(str(app.run_state.deck_ids.back()).begins_with("curse-"), "add_random_curse 加入的卡應是 curse")
	app.queue_free()

func _options_have_low_risk(options: Array) -> bool:
	for option_variant in options:
		var option: Dictionary = option_variant
		if str(option.get("risk_tier", "")) == "low":
			return true
	return false

func _options_have_resource_heavy(options: Array) -> bool:
	for option_variant in options:
		var option: Dictionary = option_variant
		if option.get("tags", []).has("resource") or str(option.get("risk_tier", "")) == "high":
			return true
	return false

func _expect_enemy_action_cap(enemy_id: String, action_type: String, field: String, cap: int, message: String) -> void:
	var enemy := database.get_enemy(enemy_id)
	for action_variant in enemy.get("actions", []):
		var action: Dictionary = action_variant
		if str(action.get("type", "")) == action_type:
			_expect_true(int(action.get(field, 0)) <= cap, "%s：%s %s.%s <= %d" % [message, enemy_id, action_type, field, cap])

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

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_false(actual: bool, message: String) -> void:
	if actual:
		failures.append("%s：expected false, got true" % message)

func _expect_not_empty(actual: String, message: String) -> void:
	if actual == "":
		failures.append("%s：expected non-empty string" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
