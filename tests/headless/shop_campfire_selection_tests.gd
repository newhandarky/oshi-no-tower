extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_shop_can_remove_selected_card()
	await _test_event_remove_card_opens_selection_before_completing_node()
	await _test_campfire_can_upgrade_selected_card()
	await _test_shop_and_campfire_selection_screens_are_scrollable()
	await _test_upgraded_cards_are_hidden_from_campfire_upgrade_selection()
	await _test_curse_cards_are_hidden_from_campfire_upgrade_selection()
	await _test_shop_inventory_persists_for_same_node()

	if failures.is_empty():
		print("shop_campfire_selection_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("shop_campfire_selection_tests: failed (%d)" % failures.size())
		quit(1)

func _test_shop_can_remove_selected_card() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.run_state.gold = 200
	var target_card := str(app.run_state.deck_ids[3])
	_expect_true(app.has_method("_remove_card_at_index"), "Game 需提供依 index 移除卡的流程")
	if app.has_method("_remove_card_at_index"):
		var removed: bool = app._remove_card_at_index(3)
		_expect_true(removed, "指定 index 的卡應可被移除")
		_expect_false(app.run_state.deck_ids.has(target_card) and _card_count(app.run_state.deck_ids, target_card) == 4, "指定卡數量應下降，不可只移除第一張")
	app.queue_free()

func _test_event_remove_card_opens_selection_before_completing_node() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.run_state.current_node_index = 2
	app.run_state.gold = 100
	var before_index := int(app.run_state.current_node_index)
	var before_size: int = app.run_state.deck_ids.size()
	var target_card := str(app.run_state.deck_ids[3])
	var resolved: bool = app._resolve_event_option({
		"label": "測試移除",
		"outcomes": [{ "action": "gain_gold", "amount": -10 }, { "action": "remove_card", "amount": 1 }]
	})

	_expect_true(resolved, "事件 remove_card option 應可進入後續流程")
	_expect_eq(str(app.current_screen), "event_remove_selection", "事件 remove_card 應先開啟選牌畫面")
	_expect_true(_has_scroll_container(app), "事件移除卡應使用可捲動牌組選擇")
	_expect_eq(app.run_state.gold, 90, "事件選項中 remove_card 前的其他 outcome 應先結算")
	_expect_eq(app.run_state.deck_ids.size(), before_size, "尚未選牌前不應直接移除第一張卡")
	_expect_eq(app.run_state.current_node_index, before_index, "尚未選牌前不應完成事件節點")
	_expect_true(app.has_method("_event_remove_card_at_index"), "Game 需提供事件指定移除卡 helper")
	if app.has_method("_event_remove_card_at_index"):
		var removed: bool = app._event_remove_card_at_index(3, 1)
		_expect_true(removed, "事件移除卡應可移除玩家指定 index")
		_expect_eq(app.run_state.deck_ids.size(), before_size - 1, "事件指定移除後牌組數量應下降")
		_expect_false(app.run_state.deck_ids.has(target_card) and _card_count(app.run_state.deck_ids, target_card) == 4, "事件移除指定卡時不可只移除第一張")
		_expect_eq(str(app.current_screen), "map", "事件移除完成後應回地圖")
		_expect_eq(app.run_state.current_node_index, before_index + 1, "事件移除完成後才應完成節點")
	app.queue_free()

func _test_campfire_can_upgrade_selected_card() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "botan")
	var target_index := 7
	var target_card := str(app.run_state.deck_ids[target_index])
	_expect_true(app.has_method("_upgrade_card_at_index"), "Game 需提供依 index 升級卡的流程")
	if app.has_method("_upgrade_card_at_index"):
		var upgraded: bool = app._upgrade_card_at_index(target_index)
		_expect_true(upgraded, "指定 index 的卡應可被升級")
		_expect_eq(str(app.run_state.deck_ids[target_index]), "%s+" % target_card, "升級應套用到玩家選擇的卡")
		_expect_false(str(app.run_state.deck_ids[0]).ends_with("+"), "升級指定卡時不可自動升級第一張")
	app.queue_free()

func _test_shop_and_campfire_selection_screens_are_scrollable() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	_expect_true(app.has_method("show_shop_remove_selection"), "商店需有移除卡選擇畫面")
	if app.has_method("show_shop_remove_selection"):
		app.show_shop_remove_selection()
		await process_frame
		_expect_true(_has_scroll_container(app), "商店移除卡選擇應使用 ScrollContainer")
	_expect_true(app.has_method("show_campfire_upgrade_selection"), "篝火需有升級卡選擇畫面")
	if app.has_method("show_campfire_upgrade_selection"):
		app.show_campfire_upgrade_selection()
		await process_frame
		_expect_true(_has_scroll_container(app), "篝火升級卡選擇應使用 ScrollContainer")
	app.queue_free()

func _test_upgraded_cards_are_hidden_from_campfire_upgrade_selection() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.run_state.deck_ids[0] = "subaru-strike+"
	app.show_campfire_upgrade_selection()
	await process_frame

	var visible_text := _screen_text(app)
	_expect_false(visible_text.contains("節奏拳+"), "已升級卡不應出現在篝火可升級清單")
	_expect_true(visible_text.contains("團隊防守"), "未升級卡仍應出現在篝火升級清單")
	app.queue_free()

func _test_curse_cards_are_hidden_from_campfire_upgrade_selection() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.run_state.deck_ids.append("curse-dead-air")
	app.show_campfire_upgrade_selection()
	await process_frame

	var visible_text := _screen_text(app)
	_expect_false(visible_text.contains("Dead Air"), "curse / unplayable 卡不應出現在篝火可升級清單")
	_expect_false(app._upgrade_card_at_index(app.run_state.deck_ids.size() - 1), "curse / unplayable 卡不可透過 helper 被升級")
	app.queue_free()

func _test_shop_inventory_persists_for_same_node() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.run_state.current_node_index = 6
	_expect_true(app.has_method("_shop_inventory"), "Game 需提供同一商店節點的庫存狀態")
	_expect_true(app.has_method("_buy_shop_card"), "Game 需提供商店購買指定卡牌 helper")
	if not app.has_method("_shop_inventory") or not app.has_method("_buy_shop_card"):
		app.queue_free()
		return
	var first_inventory: Dictionary = app._shop_inventory()
	var first_cards: Array = first_inventory.get("card_ids", []).duplicate()
	var first_sale_key := str(first_inventory.get("sale_key", ""))
	app.show_shop()
	await process_frame
	app.show_shop()
	await process_frame
	var reopened_inventory: Dictionary = app._shop_inventory()
	_expect_eq(reopened_inventory.get("card_ids", []), first_cards, "同一個商店節點重開時卡牌庫存不可刷新")
	_expect_eq(str(reopened_inventory.get("sale_key", "")), first_sale_key, "同一個商店節點重開時特價商品不可刷新")
	if not first_cards.is_empty():
		app.run_state.gold = 999
		var bought: bool = app._buy_shop_card(str(first_cards[0]), 1)
		_expect_true(bought, "商店購買卡牌 helper 應可購買指定庫存卡")
		var after_buy_inventory: Dictionary = app._shop_inventory()
		_expect_false(after_buy_inventory.get("card_ids", []).has(str(first_cards[0])), "商店卡牌購買後應從該商店庫存移除")
	app.queue_free()

func _card_count(deck_ids: Array[String], card_id: String) -> int:
	var count := 0
	for deck_card_id in deck_ids:
		if str(deck_card_id) == card_id:
			count += 1
	return count

func _has_scroll_container(app: Node) -> bool:
	for child in app.screen_host.get_children():
		if child is ScrollContainer:
			return true
	return false

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
