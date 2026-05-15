extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_relic_grant_message_clears_after_timeout()
	await _test_reward_screen_keeps_context_when_message_clears()

	if failures.is_empty():
		print("debug_message_timeout_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("debug_message_timeout_tests: failed (%d)" % failures.size())
		quit(1)

func _test_relic_grant_message_clears_after_timeout() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app._grant_next_relic_or_gold(25)
	_expect_true(str(app.debug_message).contains("取得 relic"), "取得 relic 訊息必須先顯示")

	await create_timer(2.2).timeout

	_expect_eq(app.debug_message, "", "取得 relic 訊息必須自動消失")
	app.queue_free()

func _test_reward_screen_keeps_context_when_message_clears() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app._set_debug_message("取得 relic：測試")
	app.show_reward("戰鬥獎勵", "菁英戰獎勵：獲得 Gold 55 與 relic。選一張卡加入牌組，或跳過。", true)
	await process_frame

	_expect_eq(app.current_screen, "reward", "測試需停在一般卡牌獎勵畫面")
	_expect_true(_screen_text(app).contains("戰鬥獎勵"), "訊息清除前應顯示戰鬥獎勵標題")
	_expect_false(_screen_text(app).contains("寶箱獎勵"), "戰鬥獎勵畫面不應使用寶箱標題")

	await create_timer(2.2).timeout

	_expect_eq(app.debug_message, "", "訊息清除後 debug message 應為空")
	_expect_eq(app.current_screen, "reward", "訊息清除後仍應停在卡牌獎勵畫面")
	_expect_true(_screen_text(app).contains("戰鬥獎勵"), "訊息清除後必須保留原本戰鬥獎勵標題")
	_expect_false(_screen_text(app).contains("寶箱獎勵"), "訊息清除後不可退回 show_reward 預設寶箱標題")
	app.queue_free()

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

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
