extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_each_character_can_enter_random_map_battle()
	await _test_azki_demo_actions_keep_summon_and_fx_readable()

	if failures.is_empty():
		print("playable_demo_smoke_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("playable_demo_smoke_tests: failed (%d)" % failures.size())
		quit(1)

func _test_each_character_can_enter_random_map_battle() -> void:
	var cases := [
		{ "id": "subaru", "seed": 2026051301, "hint": "低費連段", "card_prefix": "subaru-" },
		{ "id": "botan", "seed": 2026051302, "hint": "2 費爆發", "card_prefix": "botan-" },
		{ "id": "azki", "seed": 2026051303, "hint": "先疊標記", "card_prefix": "azki-" }
	]
	for character_case in cases:
		var app = MainScene.instantiate()
		root.add_child(app)
		await process_frame

		var character_id := str(character_case["id"])
		app.run_state.start_random_run(app.database, character_id, int(character_case["seed"]))
		app.show_map()
		await process_frame

		_expect_eq(str(app.current_screen), "map", "%s 應可進入 random map 畫面" % character_id)
		_expect_true(app.run_state.has_active_map(), "%s random run 應建立 active_map" % character_id)
		_expect_eq(int(app.run_state.active_map.get("boss_floor", 0)), 16, "%s random map 應維持 16 floor demo 路線" % character_id)
		_expect_true(_find_child_by_name(app.screen_host, "RandomMapScroll") != null, "%s random map 應使用可捲動地圖 UI" % character_id)
		_expect_false(_screen_text(app).contains("Boss 提示："), "%s random map 不應顯示 Boss 提示文案" % character_id)

		var battle_node := _first_available_node_of_type(app, "battle")
		_expect_false(battle_node.is_empty(), "%s 起點後應有可自動進入的普通戰節點" % character_id)
		if battle_node.is_empty():
			app.queue_free()
			continue
		_expect_true(app.run_state.set_current_node(str(battle_node["id"])), "%s 應可選取第一個普通戰節點" % character_id)
		app.enter_current_node()
		await process_frame

		_expect_eq(str(app.current_screen), "combat", "%s 應可從 random map 進入普通戰" % character_id)
		_expect_true(app.combat != null, "%s 進普通戰後應建立 CombatState" % character_id)
		if app.combat != null:
			_expect_true(app.combat.hand.size() > 0, "%s 普通戰起手應抽到手牌" % character_id)
			_expect_true(int(app.combat.enemy_hp) > 0, "%s 普通戰敵人 HP 應大於 0" % character_id)
		_expect_true(_screen_text(app).contains("玩法："), "%s 戰鬥畫面應顯示角色玩法提示" % character_id)
		_expect_true(_screen_text(app).contains(str(character_case["hint"])), "%s 玩法提示應保留角色差異文字" % character_id)
		_expect_true(_deck_has_prefix(app.run_state.deck_ids, str(character_case["card_prefix"])), "%s 起始牌組應保留角色專屬卡牌" % character_id)

		if character_id == "azki":
			_expect_true(_find_child_by_name(app.screen_host, "AZKiBodySprite") != null, "AZKi 普通戰應顯示 AZKi 本體")
			_expect_true(_find_child_by_name(app.screen_host, "LaplusSummonSprite") != null, "AZKi 普通戰應顯示 Laplus summon")
			_expect_true(_find_child_by_name(app.screen_host, "LaplusSummonHpLabel") != null, "AZKi 普通戰應顯示 Laplus HP label")
			if app.combat != null:
				_expect_eq(str(app.combat.summon_id), "laplus", "AZKi 普通戰應建立 Laplus summon 狀態")
				_expect_eq(int(app.combat.summon_hp), 1, "AZKi 普通戰 Laplus 初始 HP 應為 1")
		else:
			_expect_true(_find_child_by_name(app.screen_host, "PlayerActorSprite") != null, "%s 普通戰應顯示玩家角色 sprite" % character_id)
		app.queue_free()

func _test_azki_demo_actions_keep_summon_and_fx_readable() -> void:
	for action in ["map_marker_attack", "kiss_attack", "laplus_dash", "laplus_crash"]:
		var app = MainScene.instantiate()
		root.add_child(app)
		await process_frame

		app.run_state.start_random_run(app.database, "azki", 2026051310)
		var battle_node := _first_available_node_of_type(app, "battle")
		if battle_node.is_empty():
			_fail("AZKi smoke 無法找到起點後普通戰節點")
			app.queue_free()
			continue
		app.run_state.set_current_node(str(battle_node["id"]))
		app.enter_current_node()
		app.show_combat(action, "idle")
		await process_frame

		var azki_sprite := _find_child_by_name(app.screen_host, "AZKiBodySprite") as AnimatedSprite2D
		var laplus_sprite := _find_child_by_name(app.screen_host, "LaplusSummonSprite") as AnimatedSprite2D
		var fx_sprite := _find_child_by_name(app.screen_host, "PlayerActionFxSprite") as AnimatedSprite2D
		var hp_label := _find_child_by_name(app.screen_host, "LaplusSummonHpLabel") as Label
		_expect_true(azki_sprite != null, "%s 應顯示 AZKi 本體" % action)
		_expect_true(laplus_sprite != null, "%s 應顯示 Laplus summon" % action)
		_expect_true(fx_sprite != null, "%s 應顯示獨立 FX" % action)
		_expect_true(hp_label != null, "%s 應保留 Laplus HP label" % action)
		if azki_sprite != null and laplus_sprite != null:
			_expect_true(azki_sprite.z_index > laplus_sprite.z_index, "%s AZKi 本體應高於 Laplus" % action)
		if fx_sprite != null and laplus_sprite != null:
			_expect_true(fx_sprite.z_index > laplus_sprite.z_index, "%s FX 應高於 Laplus" % action)
			_expect_true(fx_sprite.position.x > laplus_sprite.position.x, "%s FX 主位置應在 Laplus 右側、往敵人方向" % action)
		if hp_label != null and azki_sprite != null:
			_expect_true(hp_label.position.y < azki_sprite.position.y, "%s Laplus HP label 應維持在角色頭上，不落到 AZKi 臉部中央" % action)
		app.queue_free()

func _first_available_node_of_type(app: Node, node_type: String) -> Dictionary:
	for node_id in app.run_state.available_node_ids:
		var node: Dictionary = app.run_state.get_node_by_id(str(node_id))
		if str(node.get("type", "")) == node_type:
			return node
	return {}

func _deck_has_prefix(deck_ids: Array[String], prefix: String) -> bool:
	for card_id in deck_ids:
		if str(card_id).begins_with(prefix):
			return true
	return false

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
