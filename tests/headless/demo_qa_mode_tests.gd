extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_demo_qa_screen_is_reachable()
	await _test_azki_showcase_actions_are_directly_visible()
	await _test_boss_warning_showcase_is_directly_visible()

	if failures.is_empty():
		print("demo_qa_mode_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("demo_qa_mode_tests: failed (%d)" % failures.size())
		quit(1)

func _test_demo_qa_screen_is_reachable() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	_expect_eq(str(app.current_screen), "character_select", "啟動後應在角色選擇")
	_expect_true(_screen_text(app).contains("Demo QA"), "角色選擇應提供 Demo QA 入口")

	app.show_demo_qa()
	await process_frame

	var text := _screen_text(app)
	_expect_eq(str(app.current_screen), "demo_qa", "Demo QA button 應進入 demo_qa screen")
	_expect_true(text.contains("Subaru random run"), "Demo QA 應提供 Subaru 快速起跑")
	_expect_true(text.contains("Botan random run"), "Demo QA 應提供 Botan 快速起跑")
	_expect_true(text.contains("AZKi random run"), "Demo QA 應提供 AZKi 快速起跑")
	_expect_true(text.contains("Laplus Dash"), "Demo QA 應提供 Laplus Dash 展示")
	_expect_true(text.contains("Boss warning"), "Demo QA 應提供 Boss warning 展示")
	app.queue_free()

func _test_azki_showcase_actions_are_directly_visible() -> void:
	for action in ["map_marker_attack", "kiss_attack", "laplus_dash", "laplus_crash"]:
		var app = MainScene.instantiate()
		root.add_child(app)
		await process_frame

		app._demo_start_azki_showcase(action)
		await process_frame

		_expect_eq(str(app.current_screen), "combat", "%s showcase 應直接進戰鬥畫面" % action)
		_expect_true(_find_child_by_name(app.screen_host, "AZKiBodySprite") != null, "%s showcase 應顯示 AZKiBodySprite" % action)
		_expect_true(_find_child_by_name(app.screen_host, "LaplusSummonSprite") != null, "%s showcase 應顯示 LaplusSummonSprite" % action)
		_expect_true(_find_child_by_name(app.screen_host, "PlayerActionFxSprite") != null, "%s showcase 應顯示 PlayerActionFxSprite" % action)
		_expect_true(_find_child_by_name(app.screen_host, "LaplusSummonHpLabel") != null, "%s showcase 應顯示 LaplusSummonHpLabel" % action)
		_expect_true(_screen_text(app).contains("標記"), "%s showcase 應讓 marker fallback 可見" % action)
		app.queue_free()

func _test_boss_warning_showcase_is_directly_visible() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app._demo_start_boss_warning_showcase()
	await process_frame

	_expect_eq(str(app.current_screen), "combat", "Boss warning showcase 應直接進戰鬥畫面")
	_expect_true(_screen_text(app).contains("Boss 警告"), "Boss warning showcase 應直接顯示 Boss 警告提示")
	_expect_true(app.combat != null and app.combat.turn_events.size() > 0, "Boss warning showcase 應建立 turn_events")
	if app.combat != null and app.combat.turn_events.size() > 0:
		_expect_eq(str(app.combat.turn_events[0].get("id", "")), "boss-warning", "Boss warning event id 應固定")
	app.queue_free()

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

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
