extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_run_end_screen_includes_manual_qa_report_fields()

	if failures.is_empty():
		print("manual_qa_reporting_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("manual_qa_reporting_tests: failed (%d)" % failures.size())
		quit(1)

func _test_run_end_screen_includes_manual_qa_report_fields() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_random_run(app.database, "subaru", 2026052010)
	var first_battle_id := _first_available_battle_node_id(app)
	_expect_true(app.run_state.set_current_node(first_battle_id), "測試應能進入第一個戰鬥節點")
	app.start_combat(app.run_state.get_current_node(app.database))
	app.run_state.deck_ids.append("subaru-combo-boost")
	app.run_state.relic_ids.append("duck-whistle")
	app.combat.player_hp = 0
	app.show_run_end(false)
	await process_frame

	var text := _screen_text(app)
	for expected in [
		"QA 回報摘要",
		"角色：Subaru",
		"結果：死亡",
		"Seed：2026052010",
		"Boss：",
		"死亡樓層：",
		"死亡敵人：",
		"死亡前 HP：0",
		"Deck：",
		"subaru-combo-boost",
		"Relic：duck-whistle"
	]:
		_expect_true(text.contains(expected), "結算畫面應包含可回報欄位：%s" % expected)
	app.queue_free()

func _first_available_battle_node_id(app: Node) -> String:
	for node_id in app.run_state.available_node_ids:
		var node: Dictionary = app.run_state.get_node_by_id(str(node_id))
		if str(node.get("type", "")) == "battle":
			return str(node_id)
	for node in app.run_state.active_map.get("nodes", []):
		if str(node.get("type", "")) == "battle":
			return str(node.get("id", ""))
	return ""

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
