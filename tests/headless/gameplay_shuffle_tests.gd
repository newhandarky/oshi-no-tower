extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_gameplay_combat_shuffles_deck_before_drawing()

	if failures.is_empty():
		print("gameplay_shuffle_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("gameplay_shuffle_tests: failed (%d)" % failures.size())
		quit(1)

func _test_gameplay_combat_shuffles_deck_before_drawing() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	var fixed_first_hand: Array = app.run_state.deck_ids.slice(0, 5)
	var saw_different_order := false
	for _i in range(12):
		app.start_combat(app.database.map_nodes[1])
		await process_frame
		var hand_ids: Array[String] = []
		for card in app.combat.hand:
			hand_ids.append(str(card["id"]))
		if var_to_str(hand_ids) != var_to_str(fixed_first_hand):
			saw_different_order = true
			break
	_expect_true(saw_different_order, "遊戲流程進戰鬥前必須洗牌，不能永遠抽固定前五張")
	app.queue_free()

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)
