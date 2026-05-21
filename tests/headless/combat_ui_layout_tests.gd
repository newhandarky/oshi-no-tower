extends SceneTree

const MainScene := preload("res://scenes/main.tscn")

var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	await _test_combat_hand_cards_are_portrait_three_by_four()
	await _test_stat_values_are_single_line_pairs_without_draw_discard()
	await _test_stat_value_backgrounds_and_hand_label_are_removed()
	await _test_enemy_intent_background_removed_and_text_shadowed()
	await _test_enemy_intent_uses_icon_placeholder()
	await _test_combat_background_blocks_are_removed()
	await _test_status_text_is_below_characters()
	await _test_status_icon_path_uses_texture_and_missing_icon_falls_back()
	await _test_character_passives_are_visible_in_character_select_and_combat()
	await _test_combat_card_cost_uses_number_only()
	await _test_combat_cards_have_sts_like_structure()
	await _test_combat_card_art_path_uses_texture_and_missing_art_falls_back()
	await _test_combat_card_view_component_exists()
	await _test_combat_hand_view_component_exists()
	await _test_actor_status_view_component_exists()
	await _test_combat_ui_has_v4_helper_boundaries()
	await _test_sprite_sheet_grid_defaults_square_animation_sheets_to_three_by_three()
	await _test_sprite_sheet_grid_supports_three_by_three_tsukkomi()
	await _test_azki_necrobinder_pair_and_fx_sheets_load()
	await _test_azki_action_fx_uses_forward_combat_space()
	await _test_azki_attack_actions_overlay_independent_fx()
	await _test_azki_laplus_summon_hp_bar_and_damage_states()
	await _test_ssrb_enemy_sheets_use_three_by_three_and_new_action_paths()
	await _test_player_card_animation_uses_action_timing()
	await _test_player_hurt_animation_uses_full_three_by_three_timing()
	await _test_victory_waits_for_manual_end_battle_before_reward()
	await _test_combat_hand_is_fanned_and_hover_enlarges_topmost()
	await _test_combat_hover_card_keeps_description_readable()
	await _test_combat_hand_discard_and_draw_animations_are_wired()
	await _test_played_card_animates_to_right_before_combat_refresh()
	await _test_hover_interrupted_by_play_restores_sibling_card_hit_testing()
	await _test_event_chapter_start_and_run_end_labels_stay_inside_screen()
	await _test_combat_hand_stays_centered_when_card_count_changes()
	await _test_intent_icon_path_uses_texture_and_missing_icon_falls_back()
	await _test_reward_cards_do_not_hover_enlarge()
	await _test_reward_cards_have_safe_text_labels()
	await _test_shop_uses_scroll_container()
	await _test_shop_cards_show_price_badges_and_descriptions()
	await _test_reward_and_shop_nonstarter_cards_use_art_textures()
	await _test_relic_icons_are_visible_in_header_and_shop()
	await _test_combat_actor_names_are_hidden_to_prevent_overflow()
	await _test_random_map_does_not_show_boss_hint_summary()
	await _test_combat_shows_character_identity_hint()
	await _test_combat_boss_warning_has_readable_layout()
	await _test_random_map_boss_label_handles_long_names()
	await _test_long_random_map_nodes_stay_inside_view()

	if failures.is_empty():
		print("combat_ui_layout_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("combat_ui_layout_tests: failed (%d)" % failures.size())
		quit(1)

func _test_combat_hand_cards_are_portrait_three_by_four() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	var card_buttons := _combat_card_buttons(app)
	_expect_eq(card_buttons.size(), 5, "戰鬥起始手牌按鈕數量")
	for button in card_buttons:
		_expect_true(button.position.y >= 388.0, "直式卡牌仍應位於畫面下方：%s" % button.text)
		_expect_eq(button.pivot_offset, Vector2(button.size.x / 2.0, button.size.y), "卡牌 hover 縮放 pivot 應在底部中央，讓卡牌往上放大")
		_expect_true(button.size.y > button.size.x, "戰鬥手牌應改為高度大於寬度的直式卡牌：%s" % button.text)
		var ratio := float(button.size.x) / float(button.size.y)
		_expect_true(abs(ratio - 0.75) <= 0.04, "戰鬥手牌比例應接近 3:4，目前 %.2f" % ratio)
	_expect_true(card_buttons[2].position.y < card_buttons[1].position.y and card_buttons[1].position.y < card_buttons[0].position.y, "未 hover 時手牌應維持中間較高、左右較低的扇形高度")
	_expect_true(card_buttons[2].position.y < card_buttons[3].position.y and card_buttons[3].position.y < card_buttons[4].position.y, "未 hover 時手牌應維持中間較高、左右較低的扇形高度")
	app.queue_free()


func _test_stat_values_are_single_line_pairs_without_draw_discard() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "botan")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	var stat_values := ["HP 80/80", "能量 3/3", "HP 36/36"]
	for value in stat_values:
		var label := _find_label(app, value)
		_expect_true(label != null, "狀態數值 label 應存在：%s" % value)
		if label != null:
			_expect_eq(label.autowrap_mode, TextServer.AUTOWRAP_OFF, "狀態數值不可自動換行：%s" % value)
			_expect_true(label.size.y <= 34.0, "狀態數值應維持單行高度：%s" % value)
	_expect_true(_find_label_prefix(app, "抽牌 ") == null, "玩家狀態欄不應顯示抽牌數")
	_expect_true(_find_label_prefix(app, "棄牌 ") == null, "玩家狀態欄不應顯示棄牌數")
	app.queue_free()

func _test_stat_value_backgrounds_and_hand_label_are_removed() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "botan")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	_expect_true(_find_label(app, "手牌") == null, "戰鬥下方不應顯示「手牌」文字")
	var stat_box_rects := [
		{ "position": Vector2(36, 62), "size": Vector2(92, 32) },
		{ "position": Vector2(136, 62), "size": Vector2(82, 32) },
		{ "position": Vector2(226, 62), "size": Vector2(82, 32) },
		{ "position": Vector2(634, 62), "size": Vector2(100, 32) },
		{ "position": Vector2(742, 62), "size": Vector2(82, 32) },
	]
	for rect in stat_box_rects:
		_expect_false(_has_color_rect(app, rect["position"], rect["size"]), "人物狀態欄文字區塊底色應移除：%s" % str(rect["position"]))
	app.queue_free()

func _test_enemy_intent_background_removed_and_text_shadowed() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	_expect_false(_has_color_rect(app, Vector2(634, 104), Vector2(290, 34)), "敵方意圖文字區塊底色應移除")
	var intent_label := _find_label(app, "意圖")
	_expect_true(intent_label != null, "敵方意圖標籤應存在")
	if intent_label != null:
		_expect_true(intent_label.has_theme_color_override("font_shadow_color"), "意圖文字應有陰影色")
		_expect_true(intent_label.has_theme_constant_override("shadow_offset_x"), "意圖文字應有陰影 X 偏移")
		_expect_true(intent_label.has_theme_constant_override("shadow_offset_y"), "意圖文字應有陰影 Y 偏移")
		_expect_true(intent_label.has_theme_color_override("font_outline_color"), "意圖文字應有描邊色")
		_expect_true(intent_label.has_theme_constant_override("outline_size"), "意圖文字應有描邊大小")
	var stat_label := _find_label_prefix(app, "HP ")
	_expect_true(stat_label != null, "人物狀態文字應存在")
	if stat_label != null:
		_expect_true(stat_label.has_theme_color_override("font_shadow_color"), "人物狀態文字應有陰影")
		_expect_true(stat_label.has_theme_constant_override("outline_size"), "人物狀態文字應有描邊")
	app.queue_free()

func _test_enemy_intent_uses_icon_placeholder() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	var icon_label := _find_label_prefix(app, "⚔")
	_expect_true(icon_label != null, "敵方意圖需顯示攻擊 icon placeholder")
	if icon_label != null:
		_expect_true(str(icon_label.text).contains("9"), "攻擊意圖 icon 需搭配數值")
		_expect_true(icon_label.has_theme_color_override("font_shadow_color"), "意圖 icon 也需有陰影")
	app.queue_free()

func _test_combat_background_blocks_are_removed() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	_expect_false(_has_color_rect(app, Vector2(0, 392), Vector2(960, 148)), "下方手牌區深色底板應移除")
	_expect_false(_has_color_rect(app, Vector2(18, 20), Vector2(326, 132)), "玩家狀態區深色底板應移除")
	_expect_false(_has_color_rect(app, Vector2(616, 20), Vector2(326, 132)), "敵方狀態區深色底板應移除")
	app.queue_free()

func _test_status_text_is_below_characters() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "botan")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	var player_status := _find_label(app, "狀態：無")
	_expect_true(player_status != null, "玩家狀態文字應顯示")
	if player_status != null:
		_expect_true(player_status.position.y >= 330.0, "玩家狀態文字應移到角色下方")
	var status_labels := _find_labels_with_text(app, "狀態：無")
	_expect_true(status_labels.size() >= 2, "玩家與敵方都應顯示狀態文字")
	if status_labels.size() >= 2:
		_expect_true(status_labels[1].position.y >= 330.0, "敵方狀態文字應移到敵人下方")
	app.queue_free()

func _test_status_icon_path_uses_texture_and_missing_icon_falls_back() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	app.combat_engine.apply_status(app.combat, "player", { "id": "strength", "value": 2, "duration": 99 })
	app.show_combat()
	await process_frame
	var status_icon := _find_child_by_name(app.screen_host, "PlayerStatusIconTexture_strength") as TextureRect
	_expect_true(status_icon != null, "有效 status icon_path 應建立玩家狀態 TextureRect")
	if status_icon != null:
		_expect_true(status_icon.size.x <= 18.0 and status_icon.size.y <= 18.0, "status icon 顯示尺寸應為原槽位約 0.9 倍寬高")
		_expect_true(status_icon.tooltip_text.contains("力量"), "status icon hover tooltip 應說明狀態內容")

	app.combat_engine.apply_status(app.combat, "player", { "id": "regen", "value": 2, "duration": 2 })
	app.show_combat()
	await process_frame
	var strength_icon := _find_child_by_name(app.screen_host, "PlayerStatusIconTexture_strength") as TextureRect
	var regen_icon := _find_child_by_name(app.screen_host, "PlayerStatusIconTexture_regen") as TextureRect
	_expect_true(strength_icon != null and regen_icon != null, "多個 status icon 應同時顯示")
	if strength_icon != null and regen_icon != null:
		_expect_true(abs(strength_icon.position.x - regen_icon.position.x) >= 120.0, "多個 status icon 應保持足夠水平間距，避免重疊")

	app.combat.player_statuses["weak"] = { "id": "weak", "value": 1, "duration": 2, "icon_path": "res://assets/missing/status.png" }
	app.show_combat()
	await process_frame
	_expect_true(_find_child_by_name(app.screen_host, "PlayerStatusIconTexture_weak") == null, "缺 status icon_path 時不可建立空貼圖節點")
	_expect_true(_screen_text(app).contains("虛弱 1/2"), "缺 status icon_path 時需保留狀態文字 fallback")

	app.combat.enemy_statuses["marker"] = { "id": "marker", "value": 2, "duration": 1 }
	app.show_combat()
	await process_frame
	_expect_true(_find_child_by_name(app.screen_host, "EnemyStatusIconTexture_marker") == null, "marker icon 尚未存在時不可建立空貼圖節點")
	_expect_true(_screen_text(app).contains("標記 2/1"), "marker 缺正式 icon 時需顯示繁中狀態文字 fallback")
	app.queue_free()

func _test_character_passives_are_visible_in_character_select_and_combat() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.show_character_select()
	await process_frame
	_expect_true(_screen_text(app).contains("節奏守備"), "角色選擇畫面需顯示 Subaru 被動名稱")
	_expect_true(_screen_text(app).contains("狙擊開場"), "角色選擇畫面需顯示 Botan 被動名稱")
	_expect_true(_screen_text(app).contains("AZKi"), "角色選擇畫面需顯示 AZKi")
	_expect_true(_screen_text(app).contains("開拓者的座標"), "角色選擇畫面需顯示 AZKi 被動名稱")

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame
	_expect_true(_screen_text(app).contains("被動：節奏守備"), "戰鬥中需顯示目前角色被動")

	app.combat.hand.clear()
	app.combat.hand.append(app.database.get_card("subaru-quick-retort"))
	app.play_card(0)
	await create_timer(0.5).timeout
	_expect_true(_screen_text(app).contains("被動觸發：節奏守備"), "被動觸發時需有短暫提示")
	app.queue_free()

func _test_random_map_does_not_show_boss_hint_summary() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_random_run(app.database, "subaru", 20260513)
	app.show_map()
	await process_frame

	var boss_enemy: Dictionary = app._random_map_boss_enemy()
	_expect_false(_screen_text(app).contains("Boss 提示："), "地圖畫面不應顯示 Boss 提示長文")
	_expect_true(_screen_text(app).contains(str(boss_enemy.get("display_name", ""))), "地圖畫面仍應顯示本局 Boss 名稱")
	app.queue_free()

func _test_combat_shows_character_identity_hint() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "botan")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	_expect_true(_screen_text(app).contains("玩法："), "戰鬥畫面需顯示角色特色短提示")
	_expect_true(_screen_text(app).contains("2 費爆發"), "Botan 特色提示應點出 2 費爆發")
	app.queue_free()

func _test_combat_boss_warning_has_readable_layout() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	var boss_node := { "type": "boss", "boss_enemy_ids": ["important-announcement"], "selected_boss_enemy_id": "important-announcement" }
	app.start_combat(boss_node)
	await process_frame
	app.combat_engine.end_player_turn(app.combat)
	app.combat_engine.end_player_turn(app.combat)
	app.show_combat()
	await process_frame

	var warning_label := _find_label_prefix(app, "提示：Boss 警告")
	_expect_true(warning_label != null, "Boss 高傷回合前需在戰鬥畫面顯示 warning")
	if warning_label != null:
		_expect_true(str(warning_label.text).contains("倒數與易傷回合先守住血線"), "Boss warning 需顯示可操作的 counterplay")
		_expect_true(warning_label.size.y >= 38.0, "Boss warning 需保留兩行高度，避免長文裁切")
		_expect_eq(warning_label.autowrap_mode, TextServer.AUTOWRAP_WORD_SMART, "Boss warning 需啟用自動換行")
	app.queue_free()

func _test_combat_card_cost_uses_number_only() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	for button in _combat_card_buttons(app):
		var labels := _child_labels(button)
		_expect_true(labels.size() >= 1, "卡牌需要費用文字區")
		if labels.size() >= 1:
			_expect_false(str(labels[0].text).contains("費用"), "戰鬥手牌費用不應顯示「費用」兩字")
			_expect_true(str(labels[0].text).is_valid_int(), "戰鬥手牌費用應只顯示數字")
	app.queue_free()

func _test_combat_cards_have_sts_like_structure() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	for button in _combat_card_buttons(app):
		_expect_true(_find_child_by_name(button, "CardFrame") != null, "卡牌需要外框")
		_expect_true(_find_child_by_name(button, "CostBadge") != null, "卡牌左上需要費用小區塊")
		_expect_true(_find_child_by_name(button, "ImageSlot") != null, "卡牌上半部需要圖片預留區")
		_expect_true(_find_child_by_name(button, "TypeLabel") != null, "圖片下方需要卡牌類別")
		_expect_true(_find_child_by_name(button, "DescriptionLabel") != null, "下半部需要功能說明")
	app.queue_free()

func _test_combat_card_art_path_uses_texture_and_missing_art_falls_back() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	app.combat.hand[0]["art_path"] = "res://assets/backgrounds/combat/background.png"
	app.show_combat()
	await process_frame
	var textured_buttons := _combat_card_buttons(app)
	_expect_true(textured_buttons.size() > 0, "有 art_path 時仍需顯示戰鬥手牌")
	if textured_buttons.size() > 0:
		var image_slot := _find_child_by_name(textured_buttons[0], "ImageSlot") as Control
		var art_texture := _find_child_by_name(textured_buttons[0], "CardArtTexture") as TextureRect
		_expect_true(image_slot != null, "有 art_path 時仍需保留 ImageSlot")
		_expect_true(art_texture != null, "有效 art_path 應建立卡圖 TextureRect")
		if image_slot != null and art_texture != null:
			_expect_eq(art_texture.get_parent(), image_slot, "卡圖必須放在卡牌上半部 ImageSlot 內")
			_expect_true(image_slot.clip_contents, "ImageSlot 必須裁切放大後的卡圖")
			_expect_true(art_texture.size.x <= image_slot.size.x * 1.26 and art_texture.size.y <= image_slot.size.y * 1.26, "卡圖顯示尺寸應為圖片槽約 1.25 倍寬高")
			_expect_true(art_texture.position.x <= 0.0 and art_texture.position.y <= 0.0, "放大後卡圖應置中並可被 ImageSlot 裁切")
			_expect_true(art_texture.position.x + art_texture.size.x >= image_slot.size.x and art_texture.position.y + art_texture.size.y >= image_slot.size.y, "放大後卡圖需覆蓋 ImageSlot 視覺範圍")
		_expect_true(_find_child_by_name(textured_buttons[0], "CardArtPlaceholder") == null, "有效 art_path 不應顯示 ART placeholder")

	app.combat.hand[0]["art_path"] = "res://assets/missing/card-art.png"
	app.show_combat()
	await process_frame
	var fallback_buttons := _combat_card_buttons(app)
	_expect_true(fallback_buttons.size() > 0, "缺 art_path 時仍需顯示戰鬥手牌")
	if fallback_buttons.size() > 0:
		_expect_true(_find_child_by_name(fallback_buttons[0], "ImageSlot") != null, "缺 art_path 時需保留 ImageSlot placeholder")
		_expect_true(_find_child_by_name(fallback_buttons[0], "CardArtTexture") == null, "缺 art_path 時不可建立空貼圖節點")
		var placeholder := _find_child_by_name(fallback_buttons[0], "CardArtPlaceholder") as Label
		_expect_true(placeholder != null, "缺 art_path 時圖片槽需顯示 ART placeholder")
		if placeholder != null:
			_expect_eq(placeholder.text, "ART", "卡圖 placeholder 文字")
	app.queue_free()

func _test_combat_card_view_component_exists() -> void:
	var script_path := "res://scripts/ui/CombatCardView.gd"
	_expect_true(ResourceLoader.exists(script_path), "MVP-v4.1 需抽出 CombatCardView component")
	if not ResourceLoader.exists(script_path):
		return
	var card_view_script := load(script_path)
	var card_view = card_view_script.new()
	_expect_true(card_view.has_method("create_button"), "CombatCardView 需提供 create_button 建立卡牌")
	_expect_true(card_view.has_method("render_button"), "CombatCardView 需提供 render_button 支援 hover 重新排版")

func _test_combat_hand_view_component_exists() -> void:
	var script_path := "res://scripts/ui/CombatHandView.gd"
	_expect_true(ResourceLoader.exists(script_path), "MVP-v4.1 需抽出 CombatHandView component")
	if not ResourceLoader.exists(script_path):
		return
	var hand_view_script := load(script_path)
	var hand_view = hand_view_script.new()
	_expect_true(hand_view.has_method("add_hand"), "CombatHandView 需提供 add_hand 建立戰鬥手牌")
	_expect_true(hand_view.has_method("card_position"), "CombatHandView 需提供 card_position 計算扇形位置")
	_expect_true(hand_view.has_method("configure_card"), "CombatHandView 需提供 configure_card 設定 rotation / z-index")
	_expect_true(hand_view.has_method("set_card_hovered"), "CombatHandView 需提供 set_card_hovered 管理 hover 放大")

func _test_actor_status_view_component_exists() -> void:
	var script_path := "res://scripts/ui/ActorStatusView.gd"
	_expect_true(ResourceLoader.exists(script_path), "MVP-v4.1 需抽出 ActorStatusView component")
	if not ResourceLoader.exists(script_path):
		return
	var actor_status_script := load(script_path)
	var actor_status_view = actor_status_script.new()
	_expect_true(actor_status_view.has_method("add_combat_status_panels"), "ActorStatusView 需提供 add_combat_status_panels 建立玩家 / 敵方狀態列")
	_expect_true(actor_status_view.has_method("add_status_labels"), "ActorStatusView 需提供 add_status_labels 建立角色下方狀態文字")
	_expect_true(actor_status_view.has_method("intent_icon_text"), "ActorStatusView 需提供 intent_icon_text 建立敵方意圖 icon fallback")

func _test_combat_ui_has_v4_helper_boundaries() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	var required_helpers := [
		"_add_combat_header_ui",
		"_add_combat_actor_sprites",
		"_add_combat_hand_ui",
		"_combat_hand_card_position",
		"_intent_icon_text",
		"_passive_display_text"
	]
	for helper in required_helpers:
		_expect_true(app.has_method(helper), "V4 需建立戰鬥 UI helper 邊界：%s" % helper)
	app.queue_free()

func _test_sprite_sheet_grid_defaults_square_animation_sheets_to_three_by_three() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	var legacy_image := Image.create(512, 512, false, Image.FORMAT_RGBA8)
	var legacy_texture := ImageTexture.create_from_image(legacy_image)
	var legacy_grid: Vector2i = app._sprite_sheet_grid(legacy_texture)
	_expect_eq(legacy_grid, Vector2i(2, 2), "既有 512x512 舊 sheet 需維持 2x2 / 4 幀相容")

	var image := Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
	var texture := ImageTexture.create_from_image(image)
	var grid: Vector2i = app._sprite_sheet_grid(texture)
	_expect_eq(grid, Vector2i(3, 3), "大張正方形動畫 sheet 預設應以 3x3 / 9 幀播放")
	app.queue_free()

func _test_sprite_sheet_grid_supports_three_by_three_tsukkomi() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	var idle_sprite := app._add_sprite_sheet("res://assets/characters/subaru/idle/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var normal_attack_sprite := app._add_sprite_sheet("res://assets/characters/subaru/normal_attack/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var tsukkomi_sprite := app._add_sprite_sheet("res://assets/characters/subaru/tsukkomi/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var subaru_defense_sprite := app._add_sprite_sheet("res://assets/characters/subaru/defense/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var subaru_hurt_sprite := app._add_sprite_sheet("res://assets/characters/subaru/hurt/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var botan_idle_sprite := app._add_sprite_sheet("res://assets/characters/botan/idle/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var botan_defense_sprite := app._add_sprite_sheet("res://assets/characters/botan/defense/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var botan_hurt_sprite := app._add_sprite_sheet("res://assets/characters/botan/hurt/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var botan_pistol_sprite := app._add_sprite_sheet("res://assets/characters/botan/pistol_attack/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var botan_sniper_sprite := app._add_sprite_sheet("res://assets/characters/botan/sniper_ultimate/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var azki_marker_sprite := app._add_sprite_sheet("res://assets/characters/azki_necromancer/map_marker_attack/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var azki_kiss_sprite := app._add_sprite_sheet("res://assets/characters/azki_necromancer/kiss_attack/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var azki_cast_marker_sprite := app._add_sprite_sheet("res://assets/characters/azki_necromancer/cast_marker/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var azki_cast_kiss_sprite := app._add_sprite_sheet("res://assets/characters/azki_necromancer/cast_kiss/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var azki_command_dash_sprite := app._add_sprite_sheet("res://assets/characters/azki_necromancer/command_dash/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var azki_command_crash_sprite := app._add_sprite_sheet("res://assets/characters/azki_necromancer/command_crash/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
	var laplus_dash_sprite := app._add_sprite_sheet("res://assets/characters/laplus_darkness_summon/dash_attack/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(154, 154)) as AnimatedSprite2D
	var laplus_crash_sprite := app._add_sprite_sheet("res://assets/characters/laplus_darkness_summon/crash_attack/sheet-transparent.png", Vector2(0.0, 0.0), Vector2(154, 154)) as AnimatedSprite2D
	_expect_eq(idle_sprite.sprite_frames.get_frame_count("default"), 9, "Subaru 新版 idle sheet 應使用 3x3 / 9 幀")
	_expect_eq(normal_attack_sprite.sprite_frames.get_frame_count("default"), 9, "新版 768x768 normal_attack sheet 應使用 3x3 / 9 幀")
	_expect_eq(tsukkomi_sprite.sprite_frames.get_frame_count("default"), 9, "新版 768x768 tsukkomi sheet 應使用 3x3 / 9 幀")
	_expect_eq(subaru_defense_sprite.sprite_frames.get_frame_count("default"), 9, "Subaru 新版 defense sheet 應使用 3x3 / 9 幀")
	_expect_eq(subaru_hurt_sprite.sprite_frames.get_frame_count("default"), 9, "Subaru 新版 hurt sheet 應使用 3x3 / 9 幀")
	_expect_eq(botan_idle_sprite.sprite_frames.get_frame_count("default"), 9, "Botan 新版 idle sheet 應使用 3x3 / 9 幀")
	_expect_eq(botan_defense_sprite.sprite_frames.get_frame_count("default"), 9, "Botan 新版 defense sheet 應使用 3x3 / 9 幀")
	_expect_eq(botan_hurt_sprite.sprite_frames.get_frame_count("default"), 9, "Botan 新版 hurt sheet 應使用 3x3 / 9 幀")
	_expect_eq(botan_pistol_sprite.sprite_frames.get_frame_count("default"), 9, "Botan pistol_attack sheet 應使用 3x3 / 9 幀")
	_expect_eq(botan_sniper_sprite.sprite_frames.get_frame_count("default"), 9, "Botan sniper_ultimate sheet 應使用 3x3 / 9 幀")
	_expect_eq(azki_marker_sprite.sprite_frames.get_frame_count("default"), 9, "AZKi map_marker_attack 分離 sheet 應使用 3x3 / 9 幀")
	_expect_eq(azki_kiss_sprite.sprite_frames.get_frame_count("default"), 9, "AZKi kiss_attack 分離 sheet 應使用 3x3 / 9 幀")
	_expect_eq(azki_cast_marker_sprite.sprite_frames.get_frame_count("default"), 9, "AZKi cast_marker 分離 sheet 應使用 3x3 / 9 幀")
	_expect_eq(azki_cast_kiss_sprite.sprite_frames.get_frame_count("default"), 9, "AZKi cast_kiss 分離 sheet 應使用 3x3 / 9 幀")
	_expect_eq(azki_command_dash_sprite.sprite_frames.get_frame_count("default"), 9, "AZKi command_dash 分離 sheet 應使用 3x3 / 9 幀")
	_expect_eq(azki_command_crash_sprite.sprite_frames.get_frame_count("default"), 9, "AZKi command_crash 分離 sheet 應使用 3x3 / 9 幀")
	_expect_eq(laplus_dash_sprite.sprite_frames.get_frame_count("default"), 9, "Laplus dash_attack 分離 sheet 應使用 3x3 / 9 幀")
	_expect_eq(laplus_crash_sprite.sprite_frames.get_frame_count("default"), 9, "Laplus crash_attack 分離 sheet 應使用 3x3 / 9 幀")
	app.queue_free()

func _test_azki_necrobinder_pair_and_fx_sheets_load() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "azki")
	_expect_eq(app._player_sheet_path("map_marker_attack"), "res://assets/characters/azki_necromancer/map_marker_attack/sheet-transparent.png", "AZKi map_marker_attack 應映射到指定攻擊 sheet")
	_expect_eq(app._player_sheet_path("kiss_attack"), "res://assets/characters/azki_necromancer/kiss_attack/sheet-transparent.png", "AZKi kiss_attack 應映射到指定攻擊 sheet")
	_expect_eq(app._player_sheet_path("laplus_dash"), "res://assets/characters/azki_necromancer/command_dash/sheet-transparent.png", "AZKi laplus_dash 時 AZKi 本體應播 command_dash")
	_expect_eq(app._player_sheet_path("laplus_crash"), "res://assets/characters/azki_necromancer/command_crash/sheet-transparent.png", "AZKi laplus_crash 時 AZKi 本體應播 command_crash")
	_expect_eq(app._player_action_fx_path("map_marker_attack"), "res://assets/fx/azki_necrobinder/map_marker_projectile/sheet-transparent.png", "AZKi map_marker_attack 應同步播放獨立紅色定位標記 FX")
	_expect_eq(app._player_action_fx_path("kiss_attack"), "res://assets/fx/azki_necrobinder/kiss_heart_projectile/sheet-transparent.png", "AZKi kiss_attack 應同步播放獨立愛心 FX")
	_expect_eq(app._player_action_fx_path("laplus_dash"), "res://assets/fx/azki_necrobinder/laplus_dash_trail/sheet-transparent.png", "AZKi laplus_dash 應同步播放獨立衝刺殘影 FX")
	_expect_eq(app._player_action_fx_path("laplus_crash"), "res://assets/fx/azki_necrobinder/laplus_crash_impact/sheet-transparent.png", "AZKi laplus_crash 應同步播放獨立墜擊衝擊 FX")

	var separated_paths := [
		"res://assets/characters/azki_necromancer/idle/sheet-transparent.png",
		"res://assets/characters/azki_necromancer/defense/sheet-transparent.png",
		"res://assets/characters/azki_necromancer/hurt/sheet-transparent.png",
		"res://assets/characters/azki_necromancer/defeat/sheet-transparent.png",
		"res://assets/characters/azki_necromancer/map_marker_attack/sheet-transparent.png",
		"res://assets/characters/azki_necromancer/kiss_attack/sheet-transparent.png",
		"res://assets/characters/azki_necromancer/cast_marker/sheet-transparent.png",
		"res://assets/characters/azki_necromancer/cast_kiss/sheet-transparent.png",
		"res://assets/characters/azki_necromancer/command_dash/sheet-transparent.png",
		"res://assets/characters/azki_necromancer/command_crash/sheet-transparent.png",
		"res://assets/characters/laplus_darkness_summon/idle/sheet-transparent.png",
		"res://assets/characters/laplus_darkness_summon/defense/sheet-transparent.png",
		"res://assets/characters/laplus_darkness_summon/hurt/sheet-transparent.png",
		"res://assets/characters/laplus_darkness_summon/defeat/sheet-transparent.png",
		"res://assets/characters/laplus_darkness_summon/dash_attack/sheet-transparent.png",
		"res://assets/characters/laplus_darkness_summon/crash_attack/sheet-transparent.png"
	]
	for path in separated_paths:
		var sprite := app._add_sprite_sheet(path, Vector2(0.0, 0.0), Vector2(178, 178)) as AnimatedSprite2D
		_expect_eq(sprite.sprite_frames.get_frame_count("default"), 9, "%s 應載入分離角色 sheet 的 3x3 / 9 幀" % path)

	var fx_paths := [
		"res://assets/fx/azki_necrobinder/map_marker_projectile/sheet-transparent.png",
		"res://assets/fx/azki_necrobinder/kiss_heart_projectile/sheet-transparent.png",
		"res://assets/fx/azki_necrobinder/laplus_dash_trail/sheet-transparent.png",
		"res://assets/fx/azki_necrobinder/laplus_crash_impact/sheet-transparent.png"
	]
	for path in fx_paths:
		var sprite := app._add_sprite_sheet(path, Vector2(0.0, 0.0), Vector2(210, 170)) as AnimatedSprite2D
		_expect_eq(sprite.sprite_frames.get_frame_count("default"), 9, "%s 應載入獨立 FX sheet 的 3x3 / 9 幀" % path)
	app.queue_free()

func _test_azki_action_fx_uses_forward_combat_space() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "azki")
	var expected_anchors := {
		"map_marker_attack": Vector2(0.54, 0.48),
		"kiss_attack": Vector2(0.54, 0.48),
		"laplus_dash": Vector2(0.52, 0.52),
		"laplus_crash": Vector2(0.54, 0.54)
	}
	var expected_sizes := {
		"map_marker_attack": Vector2(300, 170),
		"kiss_attack": Vector2(300, 170),
		"laplus_dash": Vector2(300, 160),
		"laplus_crash": Vector2(280, 220)
	}
	for action in expected_anchors.keys():
		_expect_eq(app._player_action_fx_anchor(action), expected_anchors[action], "%s FX anchor 應往敵方方向延展，避免主要視覺被 Laplus 壓住" % action)
		_expect_eq(app._player_action_fx_size(action), expected_sizes[action], "%s FX size 應保留足夠水平空間呈現投射物 / 衝擊" % action)
		_expect_true(app._player_action_fx_anchor(action).x > 0.50, "%s FX 起始/主視覺應位於 Laplus 右側並朝敵人方向" % action)
	app.queue_free()

func _test_azki_attack_actions_overlay_independent_fx() -> void:
	for action in ["map_marker_attack", "kiss_attack", "laplus_dash", "laplus_crash"]:
		var app = MainScene.instantiate()
		root.add_child(app)
		await process_frame

		app.run_state.start_run(app.database, "azki")
		app.start_combat(app.database.map_nodes[1])
		app.show_combat(action, "idle")
		await process_frame

		var azki_sprite := _find_child_by_name(app.screen_host, "AZKiBodySprite") as AnimatedSprite2D
		var laplus_sprite := _find_child_by_name(app.screen_host, "LaplusSummonSprite") as AnimatedSprite2D
		var fx_sprite := _find_child_by_name(app.screen_host, "PlayerActionFxSprite") as AnimatedSprite2D
		_expect_true(azki_sprite != null, "%s 應顯示 AZKi 本體 sprite" % action)
		_expect_true(laplus_sprite != null, "%s 應顯示 Laplus summon sprite" % action)
		_expect_true(fx_sprite != null, "%s 應疊加獨立 FX sprite" % action)
		if azki_sprite != null:
			_expect_eq(azki_sprite.sprite_frames.get_frame_count("default"), 9, "%s AZKi 本體 sheet 應使用 9 幀" % action)
		if laplus_sprite != null:
			_expect_eq(laplus_sprite.sprite_frames.get_frame_count("default"), 9, "%s Laplus summon sheet 應使用 9 幀" % action)
		if fx_sprite != null:
			_expect_eq(fx_sprite.sprite_frames.get_frame_count("default"), 9, "%s FX sheet 應使用 9 幀" % action)
			_expect_false(fx_sprite.sprite_frames.get_animation_loop("default"), "%s FX 動畫不應 loop" % action)
		if azki_sprite != null and laplus_sprite != null:
			_expect_true(azki_sprite.z_index > laplus_sprite.z_index, "%s AZKi 本體圖層應高於 Laplus，避免特效與動作被 summon 蓋住" % action)
		if fx_sprite != null and laplus_sprite != null:
			_expect_true(fx_sprite.z_index > laplus_sprite.z_index, "%s 動作 FX 圖層應高於 Laplus，避免投射物或軌跡被 summon 蓋住" % action)
		app.queue_free()

func _test_azki_laplus_summon_hp_bar_and_damage_states() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "azki")
	app.start_combat(app.database.map_nodes[1])
	app.combat.summon_hp = 7
	app.show_combat()
	await process_frame
	var hp_label := _find_child_by_name(app.screen_host, "LaplusSummonHpLabel") as Label
	_expect_true(_find_child_by_name(app.screen_host, "AZKiBodySprite") != null, "AZKi 戰鬥畫面應顯示 AZKi 本體")
	_expect_true(_find_child_by_name(app.screen_host, "LaplusSummonSprite") != null, "AZKi 戰鬥畫面應顯示 Laplus summon")
	_expect_true(hp_label != null, "Laplus summon 應有頭上 HP label")
	if hp_label != null:
		_expect_eq(hp_label.text, "7", "Laplus HP label 應只顯示目前 summon HP，不顯示上限")

	app.combat.last_summon_damage = 3
	app.show_combat()
	await process_frame
	var hurt_sprite := _find_child_by_name(app.screen_host, "LaplusSummonSprite") as AnimatedSprite2D
	_expect_true(hurt_sprite != null, "Laplus 受傷狀態仍應顯示 summon sprite")
	if hurt_sprite != null:
		_expect_false(hurt_sprite.sprite_frames.get_animation_loop("default"), "Laplus hurt 動畫不應 loop")

	app.combat.last_summon_damage = 0
	app.combat.last_summon_defeated = false
	app.combat.summon_alive = false
	app.combat.summon_hp = 0
	app.show_combat()
	await process_frame
	var down_label := _find_child_by_name(app.screen_host, "LaplusSummonHpLabel") as Label
	_expect_true(down_label != null, "Laplus down 狀態仍應顯示 HP label")
	if down_label != null:
		_expect_eq(down_label.text, "DOWN", "Laplus 倒下時 HP label 應顯示 DOWN")
	app.queue_free()

func _test_ssrb_enemy_sheets_use_three_by_three_and_new_action_paths() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	var ssrb_sheet_paths := []
	for color in ["gray", "camouflage", "white"]:
		for action in ["idle", "attack", "guard", "hurt", "defeat"]:
			ssrb_sheet_paths.append("res://assets/enemies/ssrb/%s/%s/sheet-transparent.png" % [color, action])
	for path in ssrb_sheet_paths:
		var sprite := app._add_sprite_sheet(path, Vector2(0.0, 0.0), Vector2(174, 174)) as AnimatedSprite2D
		_expect_eq(sprite.sprite_frames.get_frame_count("default"), 9, "%s 應載入 3x3 / 9 幀" % path)

	_expect_eq(app._enemy_sheet_path_for_base("res://assets/enemies/ssrb/gray/", "block"), "res://assets/enemies/ssrb/gray/guard/sheet-transparent.png", "SSRB block 應映射到 guard")
	_expect_eq(app._enemy_sheet_path_for_base("res://assets/enemies/ssrb/gray/", "guard"), "res://assets/enemies/ssrb/gray/guard/sheet-transparent.png", "SSRB guard 應映射到 guard")
	_expect_eq(app._enemy_sheet_path_for_base("res://assets/enemies/ssrb/gray/", "defeat"), "res://assets/enemies/ssrb/gray/defeat/sheet-transparent.png", "SSRB defeat 應映射到 defeat")
	app.queue_free()

func _test_player_card_animation_uses_action_timing() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	app.show_combat("normal_attack", "idle")
	await process_frame

	var sprites := _animated_sprites(app.screen_host)
	var player_sprite := sprites[0] if sprites.size() > 0 else null
	_expect_true(player_sprite != null, "玩家戰鬥 sprite 應可被測試定位")
	if player_sprite != null:
		_expect_eq(player_sprite.sprite_frames.get_frame_count("default"), 9, "normal_attack 應載入完整 9 幀")
		_expect_eq(player_sprite.sprite_frames.get_animation_speed("default"), 12.0, "打牌攻擊動畫需加速到能看到後段聲波 / 文字幀")
		_expect_false(player_sprite.sprite_frames.get_animation_loop("default"), "打牌攻擊動畫不應 loop，避免重置到相似起手幀")
	app.queue_free()

func _test_player_hurt_animation_uses_full_three_by_three_timing() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	app.show_combat("idle", "idle", true)
	await process_frame

	var sprites := _animated_sprites(app.screen_host)
	var player_sprite := sprites[0] if sprites.size() > 0 else null
	_expect_true(player_sprite != null, "玩家受傷 sprite 應可被測試定位")
	if player_sprite != null:
		_expect_eq(player_sprite.sprite_frames.get_frame_count("default"), 9, "Subaru hurt 應載入完整 3x3 / 9 幀")
		_expect_eq(player_sprite.sprite_frames.get_animation_speed("default"), 12.0, "受傷動畫需加速到能播完整 9 幀")
		_expect_false(player_sprite.sprite_frames.get_animation_loop("default"), "受傷動畫不應 loop，避免短暫顯示時重置到前段幀")
	app.queue_free()

func _test_victory_waits_for_manual_end_battle_before_reward() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.run_state.deck_ids.clear()
	app.run_state.deck_ids.append("subaru-strike")
	app.start_combat(app.database.map_nodes[1])
	app.combat.enemy_hp = 1
	var gold_before: int = app.run_state.gold
	app.play_card(0)
	await create_timer(0.95).timeout

	_expect_eq(app.current_screen, "combat", "勝利後應停在戰鬥畫面等待玩家手動結束")
	_expect_true(_screen_text(app).contains("結束對戰"), "勝利後原結束回合按鈕應改為結束對戰")
	_expect_false(_screen_text(app).contains("戰鬥獎勵"), "按下結束對戰前不應進入 reward")
	_expect_eq(app.run_state.gold, gold_before, "按下結束對戰前不應先發放戰鬥 Gold")

	var end_battle_button := _find_button(app, "結束對戰")
	_expect_true(end_battle_button != null, "勝利後應可找到結束對戰按鈕")
	if end_battle_button != null:
		end_battle_button.pressed.emit()
		await process_frame
		_expect_eq(app.current_screen, "reward", "按下結束對戰後才進入一般戰鬥 reward")
		_expect_true(_screen_text(app).contains("戰鬥獎勵"), "按下結束對戰後應顯示戰鬥獎勵")
		_expect_true(app.run_state.gold > gold_before, "按下結束對戰後才發放戰鬥 Gold")
	app.queue_free()

func _test_combat_hand_is_fanned_and_hover_enlarges_topmost() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	var card_buttons := _combat_card_buttons(app)
	_expect_eq(card_buttons.size(), 5, "戰鬥手牌數量")
	var rotations: Array[float] = []
	for button in card_buttons:
		rotations.append(button.rotation_degrees)
		_expect_true(button.has_meta("base_position"), "手牌需記錄 base_position 以支援 hover 還原")
		_expect_true(button.has_meta("base_rotation"), "手牌需記錄 base_rotation 以支援 hover 還原")
	_expect_true(rotations[0] < rotations[1] and rotations[1] < rotations[3] and rotations[3] < rotations[4], "手牌應以扇形角度排列")

	var target := card_buttons[1]
	var dimmed_sibling := card_buttons[3]
	var base_position: Vector2 = target.get_meta("base_position")
	var base_rotation := float(target.get_meta("base_rotation"))
	_expect_true(app.has_method("_set_card_hovered"), "Game 需提供卡牌 hover 放大函式")
	if app.has_method("_set_card_hovered"):
		app._set_card_hovered(target, true)
		_expect_eq(float(target.get_meta("hover_lift_duration", -1.0)), 0.1, "hover 第一段應用 0.1 秒抬起卡牌")
		_expect_eq(float(target.get_meta("hover_expand_duration", -1.0)), 0.3, "hover 展開動畫應為 0.3 秒")
		_expect_eq(target.position, base_position, "hover 不應改變原卡 hitbox 位置，避免 enter/exit 抖動")
		_expect_eq(target.size, target.get_meta("base_size"), "hover 不應改變原卡 hitbox 尺寸，點擊目標需穩定")
		await _wait_seconds(0.12)
		var preview := _find_child_by_name(app.screen_host, "CombatHoverPreview") as Button
		_expect_true(preview != null, "hover 應建立非互動式放大預覽")
		if preview != null:
			_expect_eq(preview.mouse_filter, Control.MOUSE_FILTER_IGNORE, "hover preview 不應吃滑鼠，點擊仍由原手牌處理")
			_expect_true(preview.position.y < base_position.y, "hover preview 應顯示在原卡上方")
		_expect_eq(target.rotation_degrees, base_rotation, "hover 抬起時不應轉正")
		await _wait_seconds(0.25)
		_expect_eq(target.scale, Vector2.ONE, "hover 時不應用 Control scale 放大，避免文字模糊")
		preview = _find_child_by_name(app.screen_host, "CombatHoverPreview") as Button
		_expect_true(preview != null and preview.size.x > target.size.x and preview.size.y > target.size.y, "hover preview 應以實際 size 放大")
		_expect_eq(target.rotation_degrees, base_rotation, "hover 放大後仍應保留原本扇形角度")
		_expect_eq(target.position.x, base_position.x, "hover 時卡牌不應橫向位移，避免滑鼠 enter/exit 閃爍")
		if preview != null:
			_expect_eq(preview.position.y + preview.size.y, 540.0, "hover preview 底部應貼齊畫面下緣，避免說明文字被切掉")
		_expect_eq(dimmed_sibling.modulate, Color.WHITE, "hover 前景卡時其他手牌不應變透明")
		_expect_eq(dimmed_sibling.mouse_filter, Control.MOUSE_FILTER_STOP, "hover preview 不改變其他手牌判定，避免點擊需要多次")
		var desc_label := _find_child_by_name(preview, "DescriptionLabel") as Label
		_expect_true(desc_label != null, "hover 卡牌需要描述文字")
		if desc_label != null:
			_expect_true(desc_label.get_theme_font_size("font_size") > 13, "hover 後描述文字應提高字級，而不是整張卡縮放")
		if preview != null:
			_expect_true(preview.z_index >= 1000, "hover preview 應在最上層")
		app._set_card_hovered(target, false)
		_expect_eq(float(target.get_meta("hover_shrink_duration", -1.0)), 0.3, "hover 收回動畫應為 0.3 秒")
		await _wait_seconds(0.35)
		_expect_eq(target.scale, Vector2.ONE, "離開 hover 應還原 scale")
		_expect_eq(target.size, target.get_meta("base_size"), "離開 hover 應還原 size")
		_expect_eq(target.position, base_position, "離開 hover 應還原位置")
		_expect_eq(target.rotation_degrees, base_rotation, "離開 hover 應還原原本角度")
		_expect_eq(dimmed_sibling.modulate, Color.WHITE, "離開 hover 後其他手牌應維持不透明")
		_expect_eq(dimmed_sibling.mouse_filter, Control.MOUSE_FILTER_STOP, "離開 hover 後其他手牌應恢復滑鼠判定")
		_expect_true(_find_child_by_name(app.screen_host, "CombatHoverPreview") == null, "離開 hover 後 preview 應移除")
	app.queue_free()

func _test_combat_hover_card_keeps_description_readable() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	var card_buttons := _combat_card_buttons(app)
	_expect_eq(card_buttons.size(), 5, "戰鬥手牌數量")
	if card_buttons.size() >= 3 and app.has_method("_set_card_hovered"):
		var target := card_buttons[2]
		app._set_card_hovered(target, true)
		await _wait_seconds(0.55)
		var preview := _find_child_by_name(app.screen_host, "CombatHoverPreview") as Button
		var desc_label := _find_child_by_name(preview, "DescriptionLabel") as Label
		_expect_true(desc_label != null, "hover 卡牌需要描述文字")
		if desc_label != null:
			_expect_true(desc_label.size.y >= preview.size.y * 0.24, "hover 卡牌描述區需保留足夠比例，盡量完整呈現效果")
			_expect_true(desc_label.position.y + desc_label.size.y <= preview.size.y - 12.0, "hover 卡牌描述不可超出底部")
		app._set_card_hovered(target, false)
	app.queue_free()

func _test_event_chapter_start_and_run_end_labels_stay_inside_screen() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_random_run(app.database, "subaru", 2026052012)
	app.run_state.gold = 213
	app.run_state.hp = 17
	app.run_state.max_hp = 68
	app.run_state.deck_ids.append_array(["subaru-encore-recall", "subaru-afterimage-table", "subaru-crowd-cover", "subaru-blue-wave", "curse-bad-connection"])
	app.run_state.relic_ids.append_array(["duck-whistle", "shishiro-crosshair", "healing-chat", "energy-drink", "golden-superchat", "route-stamp"])
	app.show_event({ "event_id": "recommendation-auction" })
	await process_frame
	_expect_true(_screen_text(app).contains("HP 17/68"), "事件畫面應顯示目前 HP 以利選擇")
	_expect_true(_screen_text(app).contains("Gold 213"), "事件畫面應顯示目前 Gold 以利選擇")
	_expect_true(_screen_text(app).contains("Deck "), "事件畫面應顯示 deck 數量")
	_expect_true(_screen_text(app).contains("Relic "), "事件畫面應顯示 relic 數量")
	_expect_controls_inside_screen(app, "event")

	app.show_chapter_start_event()
	await process_frame
	_expect_true(_screen_text(app).contains("HP "), "Chapter start event 應顯示目前 HP")
	_expect_true(_screen_text(app).contains("Gold "), "Chapter start event 應顯示目前 Gold")
	_expect_controls_inside_screen(app, "chapter_start_event")

	app.run_state.deck_ids.append_array([
		"subaru-strike+", "subaru-strike+", "subaru-draw-breath+", "subaru-blue-wave",
		"subaru-new-oshi-call", "subaru-crowd-cover", "subaru-encore-recall+",
		"subaru-afterimage-table+", "subaru-unstoppable-cheer+", "curse-comment-fire"
	])
	app.show_run_end(true)
	await process_frame
	_expect_true(_screen_text(app).contains("主要 deck/relic"), "結算畫面應用截圖友善的主要 deck/relic 欄位")
	_expect_false(_screen_text(app).contains("subaru-strike+"), "結算畫面 deck/relic 摘要應優先使用中文名稱")
	_expect_false(_screen_text(app).contains("boss_pacing_summary"), "結算畫面不應直接塞 structured telemetry 欄位，避免跑版")
	_expect_false(_screen_text(app).contains("route_risk_summary"), "結算畫面不應直接塞 structured telemetry 欄位，避免跑版")
	_expect_controls_inside_screen(app, "run_end")
	app.queue_free()

func _test_combat_hand_discard_and_draw_animations_are_wired() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	var card_buttons := _combat_card_buttons(app)
	_expect_true(app.has_method("_animate_combat_hand_discard"), "Game 需提供未用手牌往右側捨棄動畫")
	if card_buttons.size() >= 2 and app.has_method("_animate_combat_hand_discard"):
		await app._animate_combat_hand_discard()
		for button in card_buttons:
			_expect_true(button.position.x > 960.0, "結束回合捨棄動畫應把未用手牌移到畫面右側")

	app.show_combat()
	await process_frame
	card_buttons = _combat_card_buttons(app)
	_expect_true(app.combat_hand_view.has_method("animate_draw_from_left"), "CombatHandView 需提供從左側抽牌進手牌動畫")
	if card_buttons.size() >= 2 and app.combat_hand_view.has_method("animate_draw_from_left"):
		var target := card_buttons[card_buttons.size() - 1]
		var base_position: Vector2 = target.get_meta("base_position")
		app.combat_hand_view.animate_draw_from_left(app.screen_host, card_buttons, card_buttons.size() - 1)
		_expect_true(target.position.x < 0.0, "抽牌動畫開始時，新加入手牌應從畫面左方進場")
		await _wait_seconds(0.45)
		_expect_eq(target.position, base_position, "抽牌動畫結束後，新卡應回到手牌最右方位置")
	app.queue_free()

func _test_played_card_animates_to_right_before_combat_refresh() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	var card_buttons := _combat_card_buttons(app)
	_expect_true(app.has_method("_animate_played_combat_card"), "Game 需提供打出手牌往右側滑出動畫")
	_expect_true(app.combat_hand_view.has_method("animate_played_card_to_right"), "CombatHandView 需提供單張打出卡滑出動畫")
	if card_buttons.size() >= 1 and app.combat_hand_view.has_method("animate_played_card_to_right"):
		var target := card_buttons[0]
		var base_position: Vector2 = target.get_meta("base_position")
		var tween = app.combat_hand_view.animate_played_card_to_right(app.screen_host, target, 0)
		_expect_true(target.has_meta("play_animation_lift_position"), "打出的手牌需先標記上浮位置，和回合結束棄牌動線區分")
		_expect_true(target.has_meta("play_animation_target_position"), "打出的手牌需標記右側滑出終點")
		_expect_true(target.has_meta("play_animation_duration"), "打出的手牌需標記動畫節奏時間")
		if target.has_meta("play_animation_lift_position"):
			var lift_position: Vector2 = target.get_meta("play_animation_lift_position")
			_expect_true(lift_position.y < base_position.y, "打出的手牌滑出前應先往上浮")
		if target.has_meta("play_animation_target_position"):
			var target_position: Vector2 = target.get_meta("play_animation_target_position")
			_expect_true(target_position.x > 960.0, "打出的手牌終點應在畫面右側")
			_expect_true(target_position.y < base_position.y, "打出的手牌終點應往右上方滑出，不應像棄牌一樣往右下方掉出")
		if target.has_meta("play_animation_duration"):
			var play_duration := float(target.get_meta("play_animation_duration"))
			_expect_true(play_duration >= 0.26 and play_duration <= 0.34, "打出手牌動畫應短於 hover，但保留可讀節奏")
		if tween != null:
			await tween.finished
		_expect_true(target.position.x > 960.0, "打出的手牌動畫結束後應移到畫面右側")
		_expect_true(target.modulate.a <= 0.05, "打出的手牌動畫結束後應淡出")
	app.queue_free()

func _test_hover_interrupted_by_play_restores_sibling_card_hit_testing() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	var card_buttons := _combat_card_buttons(app)
	_expect_true(card_buttons.size() >= 4, "戰鬥手牌需足夠測試 hover 被打牌中斷")
	if card_buttons.size() >= 4 and app.has_method("_set_card_hovered"):
		var target := card_buttons[1]
		var sibling := card_buttons[3]
		app._set_card_hovered(target, true)
		await _wait_seconds(0.37)
		_expect_eq(sibling.modulate, Color.WHITE, "hover 時其他手牌不應被透明化")
		_expect_eq(sibling.mouse_filter, Control.MOUSE_FILTER_STOP, "hover preview 不應鎖住其他手牌判定")
		var tween = app.combat_hand_view.animate_played_card_to_right(app.screen_host, target, 1)
		_expect_eq(sibling.modulate, Color.WHITE, "hover 被打牌中斷時，其他手牌仍應維持不透明")
		_expect_eq(sibling.mouse_filter, Control.MOUSE_FILTER_STOP, "hover 被打牌中斷時，其他手牌應立即恢復滑鼠判定")
		if tween != null:
			await tween.finished
	app.queue_free()

func _test_combat_hand_stays_centered_when_card_count_changes() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	app.combat.hand = app.combat.hand.slice(0, 3)
	app.show_combat()
	await process_frame

	var card_buttons := _combat_card_buttons(app)
	_expect_eq(card_buttons.size(), 3, "手牌減少後應只顯示現有手牌")
	if card_buttons.size() == 3:
		var min_x := card_buttons[0].position.x
		var max_x := card_buttons[0].position.x + card_buttons[0].size.x
		for button in card_buttons:
			min_x = min(min_x, button.position.x)
			max_x = max(max_x, button.position.x + button.size.x)
		var group_center := (min_x + max_x) / 2.0
		_expect_true(abs(group_center - 480.0) <= 18.0, "不管手牌幾張都應以畫面中央為核心擺放，目前中心 %.1f" % group_center)
		_expect_true(card_buttons[1].position.y < card_buttons[0].position.y and card_buttons[1].position.y < card_buttons[2].position.y, "三張手牌仍需維持中間較高的扇形")
	app.queue_free()

func _test_intent_icon_path_uses_texture_and_missing_icon_falls_back() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[1])
	await process_frame

	app.combat.current_intent["icon_path"] = "res://assets/icons/intent/attack.png"
	app.show_combat()
	await process_frame
	var intent_icon := _find_child_by_name(app.screen_host, "IntentIconTexture") as TextureRect
	_expect_true(intent_icon != null, "有效 intent icon_path 應建立意圖 TextureRect")
	if intent_icon != null:
		_expect_true(intent_icon.size.x <= 22.0 and intent_icon.size.y <= 22.0, "intent icon 顯示尺寸應為原槽位約 0.9 倍寬高")
		_expect_true(intent_icon.tooltip_text != "", "intent icon hover tooltip 應說明意圖內容")

	app.combat.current_intent["icon_path"] = "res://assets/missing/intent.png"
	app.show_combat()
	await process_frame
	_expect_true(_find_child_by_name(app.screen_host, "IntentIconTexture") == null, "缺 intent icon_path 時不可建立空貼圖節點")
	var icon_label := _find_label_prefix(app, "⚔")
	_expect_true(icon_label != null, "缺 intent icon_path 時需保留文字 icon fallback")
	app.queue_free()

func _test_reward_cards_do_not_hover_enlarge() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "botan")
	app.show_reward("戰鬥獎勵", "獲得 Gold 25。選一張卡加入牌組，或跳過。", true)
	await process_frame

	var card_buttons := _reward_card_buttons(app)
	_expect_eq(card_buttons.size(), 3, "獎勵畫面卡牌按鈕數量")
	for button in card_buttons:
		var base_size := button.size
		_expect_false(bool(button.get_meta("hover_enabled", false)), "戰鬥獎勵卡片不應啟用 hover 放大")
		app._set_card_hovered(button, true)
		_expect_eq(button.size, base_size, "戰鬥獎勵卡片呼叫 hover 也不應放大")
	app.queue_free()

func _test_shop_uses_scroll_container() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.show_shop()
	await process_frame

	var scroll_count := 0
	for child in app.screen_host.get_children():
		if child is ScrollContainer:
			scroll_count += 1
			var scroll := child as ScrollContainer
			_expect_true(scroll.size.y <= 300.0, "商店商品區應限制高度，避免和底部按鈕重疊")
			_expect_true(scroll.get_child_count() > 0, "商店 ScrollContainer 內應有商品內容")
	_expect_eq(scroll_count, 1, "商店應使用一個 ScrollContainer 呈現商品")
	app.queue_free()

func _test_shop_cards_show_price_badges_and_descriptions() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.run_state.gold = 200
	app.show_shop()
	await process_frame

	var shop_buttons := _shop_card_buttons(app)
	_expect_true(shop_buttons.size() >= 8, "商店應顯示卡牌、relic 與移除卡商品")
	var card_button := _first_shop_button_with_name(shop_buttons, "吐槽爆擊")
	_expect_true(card_button != null, "商店卡牌商品應存在")
	if card_button != null:
		var card_text := _button_child_text(card_button)
		_expect_true(card_text.contains("特價") or card_text.contains("75g"), "商店卡左上角應顯示依功能計算的購買金額")
		_expect_false(card_text.contains("購買 45g 2"), "商店卡價格不可再和卡牌費用混在一起")
		_expect_true(card_text.contains("造成 8 點傷害 2 次"), "商店卡需顯示卡牌功能說明")
	var relic_button := _first_shop_button_with_name(shop_buttons, "應援螢光棒")
	_expect_true(relic_button != null, "商店 relic 商品應存在")
	if relic_button != null:
		var relic_text := _button_child_text(relic_button)
		_expect_true(relic_text.contains("150g") or relic_text.contains("特價"), "商店 relic 左上角應顯示依 pool 計算的購買金額")
		_expect_true(relic_text.contains("格擋") or relic_text.contains("能量") or relic_text.contains("力量"), "商店 relic 需顯示功能說明")
	var remove_button := _first_shop_button_with_name(shop_buttons, "移除卡")
	_expect_true(remove_button != null, "商店移除卡商品應存在")
	if remove_button != null:
		var remove_text := _button_child_text(remove_button)
		_expect_true(remove_text.contains("75g"), "移除卡服務左上角應顯示金額")
		_expect_true(remove_text.contains("選擇 1 張牌從牌組移除"), "移除卡服務需顯示功能說明")
	_expect_true(_shop_has_sale_badge(shop_buttons), "商店每次應固定顯示一個特價商品")
	app.queue_free()

func _test_reward_and_shop_nonstarter_cards_use_art_textures() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.reward_card_ids.clear()
	app.reward_card_ids.append("subaru-second-wind")
	app.reward_card_ids.append("subaru-quick-retort")
	app.reward_card_ids.append("subaru-rhythm-guard")
	app.show_reward("戰鬥獎勵", "獲得 Gold 25。選一張卡加入牌組，或跳過。", true, true)
	await process_frame

	var reward_buttons := _reward_card_buttons(app)
	_expect_eq(reward_buttons.size(), 3, "V4.3 reward 測試應顯示三張指定非起始牌")
	for button in reward_buttons:
		var card: Dictionary = button.get_meta("card_data", {})
		_expect_false(str(card.get("id", "")) in ["subaru-strike", "subaru-guard", "subaru-duck-rush", "subaru-draw-breath", "subaru-tsukkomi"], "V4.3 reward 測試應使用非起始牌")
		_expect_true(_find_child_by_name(button, "CardArtTexture") != null, "%s reward card 應顯示正式卡圖 TextureRect" % str(card.get("id", "")))
		_expect_true(_find_child_by_name(button, "CardArtPlaceholder") == null, "%s reward card 不應再顯示 ART placeholder" % str(card.get("id", "")))

	app.show_shop()
	await process_frame

	var checked_shop_card := false
	for button in _shop_card_buttons(app):
		var card: Dictionary = button.get_meta("card_data", {})
		var card_id := str(card.get("id", ""))
		if card_id == "subaru-second-wind":
			checked_shop_card = true
			_expect_true(_find_child_by_name(button, "CardArtTexture") != null, "%s shop card 應顯示正式卡圖 TextureRect" % card_id)
			_expect_true(_find_child_by_name(button, "CardArtPlaceholder") == null, "%s shop card 不應再顯示 ART placeholder" % card_id)
			break
	_expect_true(checked_shop_card, "商店應檢查至少一張 V4.3 非起始牌卡圖")
	app.queue_free()

func _test_relic_icons_are_visible_in_header_and_shop() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.run_state.gold = 200
	app.run_state.relic_ids.append("cheer-lightstick")
	app._debug_start_next_normal_battle()
	await process_frame

	var combat_relic_icon := _find_child_by_name(app.screen_host, "CombatRelicIcon_cheer-lightstick") as TextureRect
	_expect_true(combat_relic_icon != null, "戰鬥 header 應在人名上方顯示持有 relic icon")
	if combat_relic_icon != null:
		_expect_true(combat_relic_icon.position.y <= 24.0, "戰鬥 relic icon 應放在人名上方")
		_expect_true(combat_relic_icon.size.x >= 24.0 and combat_relic_icon.size.y >= 24.0, "戰鬥 relic icon 應放大到原本約 1.5 倍")
		_expect_true(combat_relic_icon.tooltip_text.contains("應援螢光棒"), "relic icon hover tooltip 應顯示 relic 說明")
	_expect_true(_find_child_by_name(app.screen_host, "RelicSummaryText_cheer-lightstick") == null, "戰鬥 relic icon 不應顯示 relic 名稱文字")
	app.show_shop()
	await process_frame

	var shop_buttons := _shop_card_buttons(app)
	var relic_button := _first_shop_button_with_name(shop_buttons, "鴨鴨哨子")
	_expect_true(relic_button != null, "商店應顯示下一個可購買 relic")
	if relic_button != null:
		_expect_true(_find_child_by_name(relic_button, "CardArtTexture") != null, "商店 relic 商品應使用 relic icon 圖")
	app.queue_free()

func _test_reward_cards_have_safe_text_labels() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "botan")
	app.show_reward("戰鬥獎勵", "獲得 Gold 25。選一張卡加入牌組，或跳過。", true)
	await process_frame

	var card_buttons := _reward_card_buttons(app)
	_expect_eq(card_buttons.size(), 3, "獎勵畫面卡牌按鈕數量")
	for button in card_buttons:
		_expect_true(button.text == "", "卡牌按鈕本體不應直接承載長文字，避免按鈕文字溢出")
		var labels := _child_labels(button)
		_expect_true(labels.size() >= 4, "卡牌應使用費用、名稱、類別、描述安全文字區")
		if labels.size() < 4:
			continue
		for label in labels:
			_expect_true(label.position.x >= 10.0, "卡牌文字需有左側內距")
			_expect_true(label.position.x + label.size.x <= button.size.x - 10.0, "卡牌文字不可超出卡牌寬度")
		_expect_eq(labels[1].autowrap_mode, TextServer.AUTOWRAP_OFF, "卡牌名稱不可換行")
		_expect_true(labels[3].size.y <= button.size.y * 0.42, "卡牌描述需限制在卡牌下半部安全高度")
	app.queue_free()

func _test_random_map_boss_label_handles_long_names() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_random_run(app.database, "subaru", 12345)
	for node in app.run_state.active_map.get("nodes", []):
		if str(node.get("type", "")) == "boss":
			node["selected_boss_enemy_id"] = "important-announcement"
	app.show_map()
	await process_frame

	var boss_button := _boss_map_button(app)
	_expect_true(boss_button != null, "隨機地圖必須有 Boss button")
	if boss_button != null:
		_expect_false(str(boss_button.text).contains("Important Announcement"), "Boss 節點不可把長名稱整行塞進按鈕")
		for line in str(boss_button.text).split("\n"):
			_expect_true(str(line).length() <= 10, "Boss 節點每行文字需短，避免跑版：%s" % str(line))
	app.queue_free()

func _test_long_random_map_nodes_stay_inside_view() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_random_run(app.database, "subaru", 20260509)
	app.show_map()
	await process_frame

	var map_scroll := _random_map_scroll(app)
	_expect_true(map_scroll != null, "16 floor 長地圖應使用 ScrollContainer 上下檢視")
	if map_scroll != null:
		_expect_true(map_scroll.size.y < 360.0, "地圖可視區應只顯示局部路線，避免整張硬塞進畫面")
		_expect_eq(map_scroll.horizontal_scroll_mode, ScrollContainer.SCROLL_MODE_DISABLED, "地圖不應需要水平捲動")
		var content := map_scroll.get_child(0) as Control if map_scroll.get_child_count() > 0 else null
		_expect_true(content != null, "地圖 ScrollContainer 內應有內容節點")
		if content != null:
			_expect_true(content.custom_minimum_size.y > map_scroll.size.y * 2.0, "地圖內容高度應明顯大於可視區，支援上下捲動")
	var map_buttons := _map_node_buttons(app)
	_expect_true(map_buttons.size() >= 30, "16 floor 長地圖應顯示完整單 Act 節點")
	for button in map_buttons:
		_expect_true(button.position.x >= 0.0, "地圖節點不可超出左側：%s" % button.text)
		_expect_true(button.position.x + button.size.x <= 500.0, "地圖節點不可超出 scroll content 右側：%s" % button.text)
		_expect_true(button.position.y >= 0.0, "地圖節點不可超出 scroll content 上方：%s" % button.text)
		_expect_true(button.position.y + button.size.y <= 960.0, "地圖節點不可超出 scroll content 下方：%s" % button.text)
	_expect_true(_vertical_map_uses_stacked_floors(map_buttons), "隨機地圖應改為近似直式堆疊，而不是橫向一路展開")
	_expect_true(_map_has_scroll_spacing(map_buttons), "直式地圖樓層間距應足夠，不應把 16 floor 壓在同一個畫面高度內")
	app.queue_free()

func _test_combat_actor_names_are_hidden_to_prevent_overflow() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame

	app.run_state.start_run(app.database, "subaru")
	app.start_combat(app.database.map_nodes[5])
	await process_frame

	_expect_true(_find_label(app, "大空昴") == null, "玩家名稱在戰鬥畫面應隱藏，避免跑版")
	_expect_true(_find_label(app, "菁英 SSRB Duo: Camouflage + White") == null, "敵方名稱在戰鬥畫面應隱藏，避免跑版")
	app.queue_free()

func _find_label(app: Node, text: String) -> Label:
	for child in app.screen_host.get_children():
		if child is Label and str(child.text) == text:
			return child as Label
	return null

func _find_label_prefix(app: Node, prefix: String) -> Label:
	for child in app.screen_host.get_children():
		if child is Label and str(child.text).begins_with(prefix):
			return child as Label
	return null

func _find_labels_with_text(app: Node, text: String) -> Array[Label]:
	var result: Array[Label] = []
	for child in app.screen_host.get_children():
		if child is Label and str(child.text) == text:
			result.append(child as Label)
	return result

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

func _has_color_rect(app: Node, expected_position: Vector2, expected_size: Vector2) -> bool:
	for child in app.screen_host.get_children():
		if child is ColorRect:
			var rect := child as ColorRect
			if rect.position == expected_position and rect.size == expected_size:
				return true
	return false

func _find_child_by_name(node: Node, child_name: String) -> Node:
	if node == null:
		return null
	for child in node.get_children():
		if str(child.name) == child_name or str(child.name).begins_with("%s" % child_name):
			return child
		var nested := _find_child_by_name(child, child_name)
		if nested != null:
			return nested
	return null

func _animated_sprites(node: Node) -> Array[AnimatedSprite2D]:
	var result: Array[AnimatedSprite2D] = []
	for child in node.get_children():
		if child is AnimatedSprite2D:
			result.append(child as AnimatedSprite2D)
		result.append_array(_animated_sprites(child))
	return result

func _child_labels(node: Node) -> Array[Label]:
	var labels: Array[Label] = []
	for child in node.get_children():
		if child is Label:
			labels.append(child as Label)
	return labels

func _expect_controls_inside_screen(app: Node, screen_name: String) -> void:
	var controls: Array[Control] = []
	_collect_layout_controls(app.screen_host, controls)
	for control in controls:
		if not control.visible:
			continue
		if control.size.x <= 0.0 or control.size.y <= 0.0:
			continue
		var rect := Rect2(control.global_position, control.size)
		_expect_true(rect.position.x >= -1.0, "%s control 不應超出左界：%s" % [screen_name, str(control.name)])
		_expect_true(rect.position.y >= -1.0, "%s control 不應超出上界：%s" % [screen_name, str(control.name)])
		_expect_true(rect.position.x + rect.size.x <= 961.0, "%s control 不應超出右界：%s" % [screen_name, str(control.name)])
		_expect_true(rect.position.y + rect.size.y <= 541.0, "%s control 不應超出下界：%s" % [screen_name, str(control.name)])

func _collect_layout_controls(node: Node, result: Array[Control]) -> void:
	for child in node.get_children():
		if child is Label or child is Button or child is ScrollContainer:
			result.append(child as Control)
		_collect_layout_controls(child, result)

func _reward_card_buttons(app: Node) -> Array[Button]:
	var result: Array[Button] = []
	for child in app.screen_host.get_children():
		if child is Button:
			var button := child as Button
			if button.size.x >= 180.0 and button.size.y >= 180.0:
				result.append(button)
	return result

func _shop_card_buttons(app: Node) -> Array[Button]:
	var result: Array[Button] = []
	for child in app.screen_host.get_children():
		if child is ScrollContainer and child.get_child_count() > 0:
			_collect_buttons(child.get_child(0), result)
	return result

func _collect_buttons(node: Node, result: Array[Button]) -> void:
	for child in node.get_children():
		if child is Button:
			result.append(child as Button)
		_collect_buttons(child, result)

func _first_shop_button_with_name(buttons: Array[Button], name_text: String) -> Button:
	for button in buttons:
		if _button_child_text(button).contains(name_text):
			return button
	return null

func _shop_has_sale_badge(buttons: Array[Button]) -> bool:
	for button in buttons:
		if _button_child_text(button).contains("特價"):
			return true
	return false

func _boss_map_button(app: Node) -> Button:
	return _find_boss_map_button(app.screen_host)

func _find_boss_map_button(node: Node) -> Button:
	for child in node.get_children():
		if child is Button and str((child as Button).text).begins_with("BOSS"):
			return child as Button
		var nested := _find_boss_map_button(child)
		if nested != null:
			return nested
	return null

func _map_node_buttons(app: Node) -> Array[Button]:
	var result: Array[Button] = []
	_collect_map_node_buttons(app.screen_host, result)
	return result

func _collect_map_node_buttons(node: Node, result: Array[Button]) -> void:
	for child in node.get_children():
		if child is Button and str(child.name).begins_with("MapNodeButton_"):
			result.append(child as Button)
		_collect_map_node_buttons(child, result)

func _random_map_scroll(app: Node) -> ScrollContainer:
	for child in app.screen_host.get_children():
		if child is ScrollContainer and str(child.name) == "RandomMapScroll":
			return child as ScrollContainer
	return null

func _vertical_map_uses_stacked_floors(buttons: Array[Button]) -> bool:
	var unique_x := {}
	var unique_y := {}
	for button in buttons:
		unique_x[int(round(button.position.x))] = true
		unique_y[int(round(button.position.y))] = true
	return unique_y.size() > unique_x.size()

func _map_has_scroll_spacing(buttons: Array[Button]) -> bool:
	var min_y := INF
	var max_y := -INF
	for button in buttons:
		min_y = min(min_y, button.position.y)
		max_y = max(max_y, button.position.y)
	return max_y - min_y > 700.0

func _find_button(app: Node, text: String) -> Button:
	for child in app.screen_host.get_children():
		if child is Button and str((child as Button).text) == text:
			return child as Button
	return null

func _combat_card_buttons(app: Node) -> Array[Button]:
	var result: Array[Button] = []
	var expected_names := {}
	for card in app.combat.hand:
		expected_names[str(card["name"])] = true
	for child in app.screen_host.get_children():
		if child is Button:
			var button := child as Button
			for card_name in expected_names.keys():
				if button.text.contains(str(card_name)) or _button_child_text(button).contains(str(card_name)):
					result.append(button)
					break
	return result

func _button_child_text(button: Button) -> String:
	var text := ""
	for child in button.get_children():
		if child is Label:
			text += " " + str((child as Label).text)
	return text

func _wait_seconds(seconds: float) -> void:
	await create_timer(seconds).timeout

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_false(actual: bool, message: String) -> void:
	if actual:
		failures.append("%s：expected false, got true" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
