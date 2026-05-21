extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")
const RandomMapGeneratorScript := preload("res://scripts/data/RandomMapGenerator.gd")

var database = RuntimeDatabaseScript.new()
var generator = RandomMapGeneratorScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_same_seed_generates_same_map()
	_test_different_seed_changes_map()
	_test_generated_map_has_required_room_types()
	_test_generated_map_is_connected_to_boss()
	_test_generated_map_references_valid_content()
	_test_random_map_events_are_not_floor_locked()
	_test_event_route_risk_score_is_available_for_route_tuning()
	_test_generated_map_applies_late_floor_pressure_curve()
	_test_runtime_database_entrypoint_matches_generator()

	if failures.is_empty():
		print("random_map_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("random_map_tests: failed (%d)" % failures.size())
		quit(1)

func _test_same_seed_generates_same_map() -> void:
	var first := generator.generate_map(database, 20260509)
	var second := generator.generate_map(database, 20260509)
	_expect_eq(var_to_str(first), var_to_str(second), "同一 seed 必須產生相同地圖")

func _test_different_seed_changes_map() -> void:
	var first := generator.generate_map(database, 20260509)
	var second := generator.generate_map(database, 20260510)
	_expect_false(var_to_str(first) == var_to_str(second), "不同 seed 應產生不同地圖配置")

func _test_generated_map_has_required_room_types() -> void:
	var generated := generator.generate_map(database, 20260509)
	var nodes: Array = generated["nodes"]
	_expect_eq(str(generated["start_node_id"]), "start", "隨機地圖起點 id")
	_expect_eq(str(generated["boss_node_id"]), "boss", "隨機地圖 Boss id")
	_expect_eq(int(generated["boss_floor"]), 16, "隨機地圖 Boss floor 應拉長到 16")
	_expect_true(nodes.size() >= 30, "長版隨機地圖節點數至少要支援完整單 Act 路線")
	_expect_true(nodes.size() <= 36, "長版隨機地圖節點數仍應維持單 Act 範圍")
	var counts := _count_node_types(nodes)
	_expect_eq(int(counts.get("start", 0)), 1, "隨機地圖必須有 1 個 start")
	_expect_eq(int(counts.get("boss", 0)), 1, "隨機地圖必須有 1 個 boss")
	_expect_true(int(counts.get("battle", 0)) >= 8, "隨機地圖至少要有 8 個普通戰候選")
	_expect_true(int(counts.get("elite", 0)) >= 2, "隨機地圖至少要有 2 個菁英候選")
	_expect_true(int(counts.get("event", 0)) >= 4, "隨機地圖至少要有 4 個事件候選")
	_expect_true(int(counts.get("chest", 0)) >= 1, "隨機地圖至少要有 1 個寶箱候選")
	_expect_true(int(counts.get("shop", 0)) >= 2, "隨機地圖至少要有 2 個商店候選")
	_expect_true(int(counts.get("campfire", 0)) >= 2, "隨機地圖至少要有 2 個篝火候選")
	for node in nodes:
		if str(node["type"]) == "elite":
			_expect_true(int(node["floor"]) > 1, "菁英不可出現在第 1 層")
			_expect_true(int(node["floor"]) >= 6, "菁英不可早於第 6 層，避免角色尚未成形就遇到高壓牆")
			_expect_true(int(node["floor"]) < int(generated["boss_floor"]) - 1, "菁英不可出現在 Boss 前最後 1 層")

func _test_generated_map_is_connected_to_boss() -> void:
	var generated := generator.generate_map(database, 20260509)
	var nodes_by_id := _nodes_by_id(generated["nodes"])
	_expect_true(_can_reach_boss(nodes_by_id, str(generated["start_node_id"]), str(generated["boss_node_id"])), "起點必須能走到 Boss")
	for node_id in nodes_by_id.keys():
		_expect_true(_can_reach_boss(nodes_by_id, str(node_id), str(generated["boss_node_id"])), "%s 必須能走到 Boss" % str(node_id))

func _test_generated_map_references_valid_content() -> void:
	var generated := generator.generate_map(database, 20260509)
	var event_ids := {}
	var normal_tiers := {}
	for node in generated["nodes"]:
		match str(node["type"]):
			"battle":
				_expect_true(_enemy_exists(str(node.get("enemy_id", ""))), "%s battle enemy 必須存在" % str(node["id"]))
				if _enemy_exists(str(node.get("enemy_id", ""))):
					var enemy := database.get_enemy(str(node["enemy_id"]))
					normal_tiers[str(enemy.get("encounter_tier", ""))] = true
			"elite":
				_expect_true(_enemy_exists(str(node.get("enemy_id", ""))), "%s elite enemy 必須存在" % str(node["id"]))
				var enemy := database.get_enemy(str(node["enemy_id"]))
				_expect_eq(str(enemy.get("tier", "")), "elite", "%s 必須參照 elite enemy" % str(node["id"]))
			"event":
				var event_id := str(node.get("event_id", ""))
				event_ids[event_id] = true
				_expect_true(not database.get_event(event_id).is_empty(), "%s event_id 必須來自 V2 事件池" % str(node["id"]))
			"boss":
				_expect_true(str(node.get("boss_enemy_ids", "")).contains("subaruto-duck"), "Boss pool 必須保留 Subaruto Duck")
				_expect_not_empty(str(node.get("selected_boss_enemy_id", "")), "Boss node 必須保存本局預告 Boss")
	_expect_true(event_ids.size() >= 3, "隨機地圖事件候選至少涵蓋 3 種事件")
	_expect_true(normal_tiers.has("early"), "隨機地圖普通敵人需包含 early pool")
	_expect_true(normal_tiers.has("mid"), "隨機地圖普通敵人需包含 mid pool")
	_expect_true(normal_tiers.has("late"), "隨機地圖普通敵人需包含 late pool")

func _test_random_map_events_are_not_floor_locked() -> void:
	var floor_two_event_ids := {}
	for seed in range(20260509, 20260529):
		var generated := generator.generate_map(database, seed)
		for node in generated["nodes"]:
			if int(node.get("floor", -1)) == 2 and str(node.get("type", "")) == "event":
				floor_two_event_ids[str(node.get("event_id", ""))] = true
	_expect_true(floor_two_event_ids.size() >= 2, "第 2 層事件不可固定為同一個指定事件")

func _test_event_route_risk_score_is_available_for_route_tuning() -> void:
	var high_risk_event := database.get_event("important-announcement-countdown")
	var low_risk_event := database.get_event("superchat-time")
	_expect_true(generator._event_route_risk_score(high_risk_event) >= 3, "高失血 / relic 事件需被標成高 route risk")
	_expect_true(generator._event_route_risk_score(low_risk_event) <= 2, "純 Gold / 整理型事件不應被標成高 route risk")

func _test_generated_map_applies_late_floor_pressure_curve() -> void:
	var late_battle_ids := {
		"announcement-shadow": true,
		"ssrb-debuff-check": true
	}
	var late_elite_ids := {
		"ssrb-duo-camouflage-white": true,
		"ssrb-duo-gold-glitch": true,
		"ssrb-scaling-clock": true,
		"ak-idol-unit": true,
		"kedama-elite": true
	}
	for seed in range(20260509, 20260529):
		var generated := generator.generate_map(database, seed)
		for node in generated["nodes"]:
			var node_type := str(node.get("type", ""))
			var floor := int(node.get("floor", -1))
			if node_type == "battle":
				var enemy_id := str(node.get("enemy_id", ""))
				if floor <= 3:
					var enemy := database.get_enemy(enemy_id)
					_expect_eq(str(enemy.get("encounter_tier", "")), "early", "前 3 層普通戰應只抽 early pool")
				elif floor >= 13 and floor < int(generated.get("boss_floor", 16)):
					_expect_true(late_battle_ids.has(enemy_id), "13-15 層普通戰應只抽後段高壓 enemy")
			elif node_type == "elite" and floor >= 11:
				_expect_true(late_elite_ids.has(str(node.get("enemy_id", ""))), "第 11 層後的菁英應使用後段 elite pool")

func _test_runtime_database_entrypoint_matches_generator() -> void:
	var from_database := database.generate_random_map(20260509)
	var from_generator := generator.generate_map(database, 20260509)
	_expect_eq(var_to_str(from_database), var_to_str(from_generator), "RuntimeDatabase.generate_random_map 必須委派到相同生成器規則")

func _count_node_types(nodes: Array) -> Dictionary:
	var counts := {}
	for node in nodes:
		var node_type := str(node["type"])
		counts[node_type] = int(counts.get(node_type, 0)) + 1
	return counts

func _nodes_by_id(nodes: Array) -> Dictionary:
	var result := {}
	for node in nodes:
		result[str(node["id"])] = node
	return result

func _can_reach_boss(nodes_by_id: Dictionary, start_id: String, boss_id: String) -> bool:
	var frontier := [start_id]
	var seen := {}
	while not frontier.is_empty():
		var current := str(frontier.pop_front())
		if current == boss_id:
			return true
		if seen.has(current):
			continue
		seen[current] = true
		var node: Dictionary = nodes_by_id.get(current, {})
		for next_id in node.get("outgoing", []):
			frontier.append(str(next_id))
	return false

func _enemy_exists(enemy_id: String) -> bool:
	for enemy in database.enemies:
		if str(enemy["id"]) == enemy_id:
			return true
	return false

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
