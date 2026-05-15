extends Control

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")
const CardRewardDraftScript := preload("res://scripts/data/CardRewardDraft.gd")
const RunStateScript := preload("res://scripts/core/RunState.gd")
const CombatEngineScript := preload("res://scripts/core/CombatEngine.gd")
const CombatCardViewScript := preload("res://scripts/ui/CombatCardView.gd")
const CombatHandViewScript := preload("res://scripts/ui/CombatHandView.gd")
const ActorStatusViewScript := preload("res://scripts/ui/ActorStatusView.gd")
const TooltipIconTextureRectScript := preload("res://scripts/ui/TooltipIconTextureRect.gd")
const BASE_SIZE := Vector2(960, 540)
const CARD_ANIMATION_SECONDS := 0.85
const CARD_ACTION_ANIMATION_SPEED := 12.0
const DEBUG_ENABLED := true
const SHOP_REMOVE_PRICE := 75
const SHOP_SALE_RATE := 0.75
const RELIC_FALLBACK_GOLD := 25
const DEFAULT_SPRITE_CELL_SIZE := 256
const DEFAULT_ANIMATION_GRID := Vector2i(3, 3)
const LEGACY_ANIMATION_GRID := Vector2i(2, 2)
const DEBUG_NORMAL_ENEMY_IDS := ["ssrb-gray", "ssrb-camouflage", "ssrb-guard-tutor", "ssrb-striker-intent", "ssrb-debuff-check", "ssrb-white", "youtube-kun", "desk-kun", "korone-suki", "announcement-shadow"]
const DEBUG_ELITE_ENEMY_IDS := ["ssrb-duo-gray-camouflage", "ssrb-duo-gray-white", "ssrb-duo-camouflage-white", "ssrb-duo-gold-glitch", "ssrb-scaling-clock", "kedama-elite", "ak-idol-unit"]
const DEBUG_BOSS_IDS := ["subaruto-duck", "ssrb-giant-gray", "ssrb-giant-camouflage", "ssrb-giant-white", "youtube-kun-core", "important-announcement"]
const DEBUG_RELIC_IDS := ["cheer-lightstick", "duck-whistle", "shishiro-crosshair"]
const DEBUG_EVENT_NODE_INDICES := [2, 7, 11]
const CHAPTER_1_ID := "mvp_single_act_tower"
const CHAPTER_2_ID := "chapter_2_algorithm_depths"

@onready var screen_host: Control = $ScreenHost

var database = RuntimeDatabaseScript.new()
var card_reward_draft = CardRewardDraftScript.new()
var run_state = RunStateScript.new()
var combat_engine = CombatEngineScript.new()
var combat_card_view = CombatCardViewScript.new()
var combat_hand_view = CombatHandViewScript.new(combat_card_view, BASE_SIZE)
var actor_status_view = ActorStatusViewScript.new()
var combat = null
var combat_hand_buttons: Array[Button] = []
var pending_draw_animation_start_index := -1
var current_screen := ""
var input_locked := false
var last_run_end_cleared := false
var debug_help_visible := false
var debug_message := ""
var debug_message_token := 0
var debug_normal_enemy_index := 0
var debug_elite_enemy_index := 0
var debug_boss_index := 0
var debug_relic_index := 0
var debug_event_index := 0
var debug_boss_override_id := ""
var chest_reward_node_key := ""
var chest_reward_text := ""
var reward_title := "寶箱獎勵"
var reward_subtitle := "選一張卡加入牌組，或跳過。"
var reward_random_pick := false
var reward_card_ids: Array[String] = []
var combat_reward_pending := false
var combat_reward_player_action := "idle"
var combat_reward_enemy_action := "idle"
var event_battle_pending := false
var chapter_start_options: Array[Dictionary] = []

func _ready() -> void:
	randomize()
	resized.connect(_fit_screen_host)
	call_deferred("_fit_screen_host")
	show_character_select()

func _unhandled_key_input(event: InputEvent) -> void:
	if not DEBUG_ENABLED:
		return
	if not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if _is_debug_key(key_event, KEY_1, KEY_KP_1):
		debug_help_visible = not debug_help_visible
		_set_debug_message("Debug 說明：%s" % ("顯示" if debug_help_visible else "隱藏"))
	elif _is_debug_key(key_event, KEY_2, KEY_KP_2):
		_debug_open_character_select()
	elif key_event.keycode == KEY_D or key_event.physical_keycode == KEY_D:
		show_demo_qa()
	elif _is_debug_key(key_event, KEY_3, KEY_KP_3):
		_debug_start_next_normal_battle()
	elif _is_debug_key(key_event, KEY_4, KEY_KP_4):
		_debug_cycle_boss()
	elif _is_debug_key(key_event, KEY_5, KEY_KP_5):
		_debug_start_boss_battle()
	elif _is_debug_key(key_event, KEY_6, KEY_KP_6):
		_debug_start_next_elite_battle()
	elif _is_debug_key(key_event, KEY_7, KEY_KP_7):
		_debug_open_chest_reward()
	elif _is_debug_key(key_event, KEY_8, KEY_KP_8):
		_debug_open_shop()
	elif _is_debug_key(key_event, KEY_9, KEY_KP_9):
		_debug_open_campfire()
	elif _is_debug_key(key_event, KEY_0, KEY_KP_0):
		_debug_open_event()
	elif key_event.keycode == KEY_EQUAL or key_event.physical_keycode == KEY_EQUAL or key_event.keycode == KEY_KP_ADD or key_event.physical_keycode == KEY_KP_ADD:
		_debug_open_event()
	elif key_event.keycode == KEY_MINUS or key_event.physical_keycode == KEY_MINUS or key_event.keycode == KEY_KP_SUBTRACT or key_event.physical_keycode == KEY_KP_SUBTRACT:
		_debug_add_relic()

func _is_debug_key(key_event: InputEventKey, keycode: Key, keypad_keycode: Key) -> bool:
	return key_event.keycode == keycode or key_event.physical_keycode == keycode or key_event.keycode == keypad_keycode or key_event.physical_keycode == keypad_keycode

func show_character_select() -> void:
	current_screen = "character_select"
	input_locked = false
	_clear_screen()
	_add_title("Oshi no Tower")
	_add_subtitle("選擇角色開始挑戰")
	_add_sprite_sheet("res://assets/characters/subaru/idle/sheet-transparent.png", Vector2(0.25, 0.45), Vector2(170, 170))
	_add_sprite_sheet("res://assets/characters/botan/idle/sheet-transparent.png", Vector2(0.50, 0.45), Vector2(170, 170))
	_add_sprite_sheet("res://assets/characters/azki_necromancer/idle/sheet-transparent.png", Vector2(0.75, 0.45), Vector2(170, 170))
	_add_label("大空昴", Vector2(120, 318), Vector2(240, 30), 20, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label("獅白牡丹", Vector2(360, 318), Vector2(240, 30), 20, HORIZONTAL_ALIGNMENT_CENTER)
	_add_label("AZKi", Vector2(600, 318), Vector2(240, 30), 20, HORIZONTAL_ALIGNMENT_CENTER)
	_add_character_select_passive("subaru", Vector2(100, 350), Vector2(280, 58))
	_add_character_select_passive("botan", Vector2(340, 350), Vector2(280, 58))
	_add_character_select_passive("azki", Vector2(580, 350), Vector2(280, 58))
	_add_button("使用昴", Vector2(0.25, 0.78), Vector2(150, 48), func() -> void:
		_start_run("subaru")
	)
	_add_button("使用牡丹", Vector2(0.50, 0.78), Vector2(150, 48), func() -> void:
		_start_run("botan")
	)
	_add_button("使用 AZKi", Vector2(0.75, 0.78), Vector2(150, 48), func() -> void:
		_start_run("azki")
	)
	_add_button("Demo QA", Vector2(0.5, 0.91), Vector2(180, 38), show_demo_qa)
	_add_debug_hint()

func show_demo_qa() -> void:
	current_screen = "demo_qa"
	input_locked = false
	_clear_screen()
	_add_title("Demo QA")
	_add_subtitle("直接查看目前 playable demo 的展示重點")
	_add_label("角色起跑", Vector2(104, 132), Vector2(220, 28), 18, HORIZONTAL_ALIGNMENT_CENTER, Color(0.92, 0.95, 1.0))
	_add_button("Subaru random run", Vector2(0.22, 0.37), Vector2(210, 42), func() -> void:
		_demo_start_character_map("subaru")
	)
	_add_button("Botan random run", Vector2(0.22, 0.48), Vector2(210, 42), func() -> void:
		_demo_start_character_map("botan")
	)
	_add_button("AZKi random run", Vector2(0.22, 0.59), Vector2(210, 42), func() -> void:
		_demo_start_character_map("azki")
	)

	_add_label("AZKi / Laplus", Vector2(370, 132), Vector2(220, 28), 18, HORIZONTAL_ALIGNMENT_CENTER, Color(0.92, 0.95, 1.0))
	_add_button("標記投射", Vector2(0.50, 0.34), Vector2(180, 40), func() -> void:
		_demo_start_azki_showcase("map_marker_attack")
	)
	_add_button("飛吻追擊", Vector2(0.50, 0.44), Vector2(180, 40), func() -> void:
		_demo_start_azki_showcase("kiss_attack")
	)
	_add_button("Laplus Dash", Vector2(0.50, 0.54), Vector2(180, 40), func() -> void:
		_demo_start_azki_showcase("laplus_dash")
	)
	_add_button("Laplus Crash", Vector2(0.50, 0.64), Vector2(180, 40), func() -> void:
		_demo_start_azki_showcase("laplus_crash")
	)

	_add_label("Boss / UI", Vector2(636, 132), Vector2(220, 28), 18, HORIZONTAL_ALIGNMENT_CENTER, Color(0.92, 0.95, 1.0))
	_add_button("Boss warning", Vector2(0.78, 0.39), Vector2(210, 42), _demo_start_boss_warning_showcase)
	_add_button("AZKi marker fallback", Vector2(0.78, 0.50), Vector2(210, 42), _demo_start_marker_fallback_showcase)
	_add_button("回角色選擇", Vector2(0.78, 0.72), Vector2(210, 42), show_character_select)
	_add_debug_hint()

func _start_run(character_id: String) -> void:
	_clear_pending_room_rewards()
	run_state.start_random_run(database, character_id)
	show_map()

func show_map() -> void:
	current_screen = "map"
	input_locked = false
	_clear_screen()
	_add_background_image("res://assets/backgrounds/map/background.png")
	if run_state.has_active_map():
		_show_random_map()
		return
	var current_node: Dictionary = run_state.get_current_node(database)
	_add_title("固定路線 fallback")
	_add_subtitle("HP %d/%d   Gold %d   Deck %d   Relic %d" % [run_state.hp, run_state.max_hp, run_state.gold, run_state.deck_ids.size(), run_state.relic_ids.size()])

	var node_count: int = database.map_nodes.size()
	var route_max_width := 900.0
	var node_gap: float = 12.0 if node_count > 12 else (16.0 if node_count > 8 else 18.0)
	var preferred_node_width: float = 70.0 if node_count > 8 else 94.0
	var node_width: float = min(preferred_node_width, (route_max_width - (node_count - 1) * node_gap) / node_count)
	var route_width: float = node_count * node_width + (node_count - 1) * node_gap
	var route_start_x: float = (BASE_SIZE.x - route_width) / 2.0
	var node_font_size: int = 11 if node_count > 12 else (14 if node_count > 8 else 17)

	for index in range(database.map_nodes.size()):
		var node: Dictionary = database.map_nodes[index]
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(node_width, 86)
		panel.position = Vector2(route_start_x + index * (node_width + node_gap), 205)
		screen_host.add_child(panel)
		var label := Label.new()
		label.text = "%s\n%s" % [_node_icon(str(node["type"])), node["label"]]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.add_theme_font_size_override("font_size", node_font_size)
		panel.add_child(label)
		if index == run_state.current_node_index:
			panel.modulate = Color(1.0, 0.78, 0.32)
		elif index < run_state.current_node_index:
			panel.modulate = Color(0.42, 0.8, 0.55)
		else:
			panel.modulate = Color(0.48, 0.52, 0.62)

	_add_button("進入：%s" % current_node["label"], Vector2(0.5, 0.74), Vector2(220, 50), enter_current_node)
	_add_relic_summary(Vector2(250, 455), Vector2(460, 24))
	_add_debug_hint()

func _show_random_map() -> void:
	var boss_name := _random_map_boss_name()
	var chapter_title := str(run_state.active_map.get("chapter_title", "隨機路線"))
	_add_title("隨機路線：%s" % chapter_title)
	_add_subtitle("Seed %d   HP %d/%d   Gold %d   Deck %d   Relic %d   Boss：%s" % [run_state.map_seed, run_state.hp, run_state.max_hp, run_state.gold, run_state.deck_ids.size(), run_state.relic_ids.size(), boss_name])
	var nodes: Array = run_state.active_map.get("nodes", [])
	var max_floor := int(run_state.active_map.get("boss_floor", 12))
	var scroll := ScrollContainer.new()
	scroll.name = "RandomMapScroll"
	scroll.position = Vector2(220, 166)
	scroll.size = Vector2(520, 268)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	screen_host.add_child(scroll)
	var map_content := Control.new()
	map_content.name = "RandomMapContent"
	map_content.custom_minimum_size = Vector2(500, 960)
	scroll.add_child(map_content)
	var lane_x_positions: Array[float] = [84.0, 286.0]
	var floor_step := 52.0
	var floor_base_y := 858.0
	var boss_y := floor_base_y - max_floor * floor_step
	for node in nodes:
		var floor := int(node.get("floor", 0))
		var lane := int(node.get("lane", 0))
		var x: float = lane_x_positions[min(lane, lane_x_positions.size() - 1)]
		var y: float = floor_base_y - floor * floor_step
		if str(node.get("type", "")) == "start":
			x = 176.0
			y = floor_base_y
		elif str(node.get("type", "")) == "boss":
			x = 168.0
			y = boss_y
		var node_id := str(node.get("id", ""))
		var is_available: bool = run_state.available_node_ids.has(node_id)
		var is_visited: bool = run_state.visited_node_ids.has(node_id) or node_id == "start"
		var panel_color := Color(0.20, 0.24, 0.34, 0.92)
		if is_available:
			panel_color = _node_color(str(node.get("type", "")))
		elif is_visited:
			panel_color = Color(0.30, 0.48, 0.35, 0.9)
		var node_size := Vector2(150, 28)
		if str(node.get("type", "")) == "boss":
			node_size = Vector2(162, 40)
		_add_panel_to(map_content, Vector2(x, y), node_size, panel_color)
		var label_text := "%s  %s" % [_node_icon(str(node.get("type", ""))), str(node.get("label", ""))]
		if str(node.get("type", "")) == "boss":
			label_text = "BOSS"
		var button := Button.new()
		button.name = "MapNodeButton_%s" % node_id
		button.text = label_text
		button.position = Vector2(x, y)
		button.size = node_size
		button.clip_text = true
		button.add_theme_font_size_override("font_size", 14 if str(node.get("type", "")) == "boss" else 13)
		button.disabled = not is_available
		button.pressed.connect(func() -> void:
			_enter_map_node(node_id)
		)
		map_content.add_child(button)
	call_deferred("_scroll_random_map_to_current_node", scroll, map_content)
	_add_relic_summary(Vector2(250, 455), Vector2(460, 24))
	_add_debug_hint()

func _scroll_random_map_to_current_node(scroll: ScrollContainer, map_content: Control) -> void:
	if scroll == null or map_content == null:
		return
	var target_y: float = _random_map_scroll_target_y(map_content)
	var max_scroll: int = max(0, int(map_content.custom_minimum_size.y - scroll.size.y))
	scroll.scroll_vertical = clamp(int(target_y - scroll.size.y * 0.72), 0, max_scroll)

func _random_map_scroll_target_y(map_content: Control) -> float:
	var target_ids: Array[String] = run_state.available_node_ids.duplicate()
	if target_ids.is_empty() and run_state.current_node_id != "":
		target_ids.append(run_state.current_node_id)
	for child in map_content.get_children():
		if child is Button and str(child.name).begins_with("MapNodeButton_"):
			var node_id := str(child.name).trim_prefix("MapNodeButton_")
			if target_ids.has(node_id):
				return (child as Button).position.y
	return map_content.custom_minimum_size.y

func _enter_map_node(node_id: String) -> void:
	if not run_state.set_current_node(node_id):
		return
	enter_current_node()

func enter_current_node() -> void:
	var node: Dictionary = run_state.get_current_node(database)
	_apply_room_enter_relics(node)
	match str(node["type"]):
		"start":
			_complete_node()
			show_map()
		"battle", "elite", "boss":
			start_combat(node)
		"chest":
			show_chest_reward()
		"shop":
			show_shop()
		"event":
			show_event(node)
		"campfire":
			show_campfire()

func start_combat(node: Dictionary) -> void:
	input_locked = false
	event_battle_pending = false
	var deck := database.resolve_cards(run_state.deck_ids)
	var enemy := _resolve_node_enemy(node)
	var relics := _resolve_run_relics()
	var character: Dictionary = database.get_character(run_state.character_id)
	var passive: Dictionary = character.get("passive", {})
	var summon: Dictionary = character.get("summon", {})
	combat = combat_engine.start_combat(run_state.hp, run_state.max_hp, deck, enemy, relics, true, passive, summon)
	show_combat()

func _resolve_node_enemy(node: Dictionary) -> Dictionary:
	if node.has("boss_enemy_ids"):
		if node.has("selected_boss_enemy_id"):
			var selected_boss := database.get_enemy(str(node["selected_boss_enemy_id"]))
			if not selected_boss.is_empty():
				return selected_boss
		var boss_ids: Array = node["boss_enemy_ids"]
		var boss := database.get_enemy(str(boss_ids.pick_random()))
		return boss if not boss.is_empty() else database.get_enemy("ssrb-gray")
	if node.has("enemy_id"):
		var enemy := database.get_enemy(str(node["enemy_id"]))
		return enemy if not enemy.is_empty() else database.get_enemy("ssrb-gray")
	if node.has("elite_enemy_ids"):
		var elite_ids: Array = node["elite_enemy_ids"]
		var elite := database.get_enemy(str(elite_ids.pick_random()))
		return elite if not elite.is_empty() else database.get_enemy("ssrb-gray")
	return database.get_enemy("ssrb-gray")

func show_combat(player_action: String = "idle", enemy_action: String = "idle", player_hurt := false, hide_hand := false) -> void:
	current_screen = "combat"
	if combat_reward_pending and player_action == "idle" and enemy_action == "idle" and not player_hurt:
		player_action = combat_reward_player_action
		enemy_action = combat_reward_enemy_action
	_clear_screen()
	_add_background_image("res://assets/backgrounds/combat/background.png")
	_add_combat_header_ui()
	_add_combat_actor_sprites(player_action, enemy_action, player_hurt)
	_add_character_status_labels()
	_add_character_identity_hint()
	_add_combat_turn_event_hint()
	if not combat_reward_pending and not hide_hand:
		_add_combat_hand_ui()

	var button_text := "結束對戰" if combat_reward_pending else "結束回合"
	var button_callback := _finish_pending_combat_reward if combat_reward_pending else end_turn
	_add_button(button_text, Vector2(0.89, 0.89), Vector2(130, 44), button_callback)
	_add_debug_hint()

func play_card(hand_index: int) -> void:
	if input_locked or combat_reward_pending:
		return
	if hand_index < 0 or hand_index >= combat.hand.size():
		return
	input_locked = true
	var played_card: Dictionary = combat.hand[hand_index]
	var player_action := str(played_card.get("animation", "idle"))
	var before_hp: int = combat.enemy_hp
	var expected_hand_count_without_draw: int = combat.hand.size() - 1
	var passive_id := str(combat.character_passive.get("id", ""))
	var passive_was_used := passive_id != "" and bool(combat.passive_flags.get(passive_id, false))
	if not combat_engine.try_play_card(combat, hand_index):
		input_locked = false
		return
	if _passive_triggered_now(passive_id, passive_was_used):
		_set_debug_message("被動觸發：%s" % str(combat.character_passive.get("name", "")))
	var enemy_was_damaged: bool = combat.enemy_hp < before_hp
	var draw_animation_start_index := _draw_animation_start_index_after_play(expected_hand_count_without_draw)
	await _animate_played_combat_card(hand_index)
	if combat.outcome == "victory":
		input_locked = true
		var victory_enemy_action := "defeat" if enemy_was_damaged else "idle"
		show_combat(player_action, victory_enemy_action)
		await get_tree().create_timer(CARD_ANIMATION_SECONDS).timeout
		input_locked = false
		_start_pending_combat_reward(player_action, victory_enemy_action)
		return
	if enemy_was_damaged:
		_show_card_animation(player_action, "hurt", draw_animation_start_index)
	else:
		_show_card_animation(player_action, "idle", draw_animation_start_index)

func _show_card_animation(player_action: String, enemy_action: String, draw_animation_start_index := -1) -> void:
	input_locked = true
	if draw_animation_start_index >= 0:
		pending_draw_animation_start_index = draw_animation_start_index
	show_combat(player_action, enemy_action)
	await get_tree().create_timer(CARD_ANIMATION_SECONDS).timeout
	input_locked = false
	show_combat()

func _start_pending_combat_reward(player_action: String, enemy_action: String) -> void:
	combat_reward_pending = true
	combat_reward_player_action = player_action
	combat_reward_enemy_action = enemy_action
	show_combat("idle", enemy_action)

func _finish_pending_combat_reward() -> void:
	if not combat_reward_pending:
		return
	combat_reward_pending = false
	combat_reward_player_action = "idle"
	combat_reward_enemy_action = "idle"
	run_state.hp = combat.player_hp
	run_state.gold += int(combat.enemy.get("gold", 0)) + _battle_reward_gold_bonus()
	_grant_combat_relic_reward(combat.enemy)
	if event_battle_pending:
		show_reward("事件戰鬥獎勵", _combat_reward_subtitle(combat.enemy), true)
		return
	if bool(combat.enemy.get("is_boss", false)):
		_complete_node()
		show_boss_reward()
	else:
		show_reward("戰鬥獎勵", _combat_reward_subtitle(combat.enemy), true)

func end_turn() -> void:
	if input_locked:
		return
	input_locked = true
	await _animate_combat_hand_discard()
	var enemy_intent_type := str(combat.current_intent["type"])
	if enemy_intent_type in ["attack", "attack_block"]:
		show_combat("idle", "attack", false, true)
		await get_tree().create_timer(0.35).timeout
	elif enemy_intent_type == "block":
		show_combat("idle", "guard", false, true)
		await get_tree().create_timer(0.35).timeout
	var before_hp: int = combat.player_hp
	var outcome: String = combat_engine.end_player_turn(combat)
	if outcome == "defeat":
		run_state.hp = 0
		input_locked = false
		show_run_end(false)
		return
	run_state.hp = combat.player_hp
	var was_hurt: bool = combat.player_hp < before_hp
	var summon_was_hit: bool = int(combat.last_summon_damage) > 0 or bool(combat.last_summon_defeated)
	var draw_animation_start_index := _draw_animation_start_index_after_turn_start()
	if draw_animation_start_index >= 0:
		pending_draw_animation_start_index = draw_animation_start_index
	show_combat("idle", "idle", was_hurt)
	await get_tree().create_timer(CARD_ANIMATION_SECONDS if was_hurt or summon_was_hit else 0.25).timeout
	_clear_combat_transient_flags()
	input_locked = false
	show_combat()

func _clear_combat_transient_flags() -> void:
	if combat == null:
		return
	combat.last_summon_damage = 0
	combat.last_summon_defeated = false

func _animate_combat_hand_discard() -> void:
	if combat_hand_buttons.is_empty():
		return
	var tween := combat_hand_view.animate_cards_to_discard(screen_host, combat_hand_buttons)
	if tween != null:
		await tween.finished

func _animate_played_combat_card(hand_index: int) -> void:
	if hand_index < 0 or hand_index >= combat_hand_buttons.size():
		return
	var tween := combat_hand_view.animate_played_card_to_right(screen_host, combat_hand_buttons[hand_index], hand_index)
	if tween != null:
		await tween.finished

func _draw_animation_start_index_after_play(expected_hand_count_without_draw: int) -> int:
	if combat == null:
		return -1
	var drawn_count: int = combat.hand.size() - expected_hand_count_without_draw
	if drawn_count <= 0:
		return -1
	return max(0, combat.hand.size() - drawn_count)

func _draw_animation_start_index_after_turn_start() -> int:
	if combat == null or combat.hand.is_empty():
		return -1
	var retained_count := 0
	for card in combat.hand:
		if bool((card as Dictionary).get("_retained_from_previous_turn", false)):
			retained_count += 1
		else:
			break
	if retained_count >= combat.hand.size():
		return -1
	return retained_count

func _grant_combat_relic_reward(enemy: Dictionary) -> String:
	if str(enemy.get("tier", "")) != "elite":
		return ""
	return _grant_relic_from_source("elite", RELIC_FALLBACK_GOLD)

func _combat_reward_subtitle(enemy: Dictionary) -> String:
	var gold := int(enemy.get("gold", 0)) + _battle_reward_gold_bonus()
	if bool(enemy.get("is_boss", false)):
		return "Boss 戰勝利：進入終局獎勵。"
	if str(enemy.get("tier", "")) == "elite":
		return "菁英戰獎勵：獲得 Gold %d 與 relic。選一張卡加入牌組，或跳過。" % gold
	return "獲得 Gold %d。選一張卡加入牌組，或跳過。" % gold

func _battle_reward_gold_bonus() -> int:
	var bonus := 0
	for relic in _resolve_run_relics():
		if str(relic.get("hook", "")) == "battle_reward" and str(relic.get("effect", "")) == "gold_bonus":
			bonus += int(relic.get("amount", 0))
	return bonus

func show_boss_reward() -> void:
	current_screen = "boss_reward"
	input_locked = false
	_clear_screen()
	_add_title("Boss 獎勵")
	_add_subtitle("選一張高價值卡牌，或取得 Boss relic。")
	var rewards: Array[String] = _draft_card_rewards(3)
	for index in range(rewards.size()):
		var card_id := _upgraded_id(str(rewards[index]))
		var card := database.get_card(card_id)
		_add_card_button(card, Vector2(180 + index * 220, 160), Vector2(180, 210), func() -> void:
			run_state.deck_ids.append(card_id)
			_continue_after_boss_reward()
		)
	_add_button("取得 Boss relic", Vector2(0.38, 0.83), Vector2(180, 44), func() -> void:
		_grant_relic_from_source("boss", RELIC_FALLBACK_GOLD)
		_continue_after_boss_reward()
	)
	_add_button(_boss_reward_continue_label(), Vector2(0.62, 0.83), Vector2(180, 44), func() -> void:
		_continue_after_boss_reward()
	)
	_add_debug_hint()

func _boss_reward_continue_label() -> String:
	if run_state.current_chapter_id == CHAPTER_1_ID:
		return "前往第二章"
	return "進入結算"

func _continue_after_boss_reward() -> void:
	if run_state.current_chapter_id == CHAPTER_1_ID:
		run_state.hp = run_state.max_hp
		show_chapter_start_event()
		return
	show_run_end(true)

func show_chapter_start_event() -> void:
	current_screen = "chapter_start_event"
	input_locked = false
	_clear_screen()
	_add_background_image("res://assets/backgrounds/map/background.png")
	var event_def := database.get_chapter_start_event(CHAPTER_2_ID)
	if chapter_start_options.is_empty():
		chapter_start_options = database.draft_chapter_start_options(CHAPTER_2_ID, run_state.map_seed + run_state.deck_ids.size() + run_state.gold, run_state.gold, _run_curse_count())
	_add_title(str(event_def.get("title", "Holo Support Desk")))
	_add_subtitle("HP 已回滿。選一項支援，準備進入演算法深層。")
	_add_label(str(event_def.get("body", "")), Vector2(180, 110), Vector2(600, 54), 16, HORIZONTAL_ALIGNMENT_CENTER, Color(0.9, 0.94, 1.0))
	for index in range(chapter_start_options.size()):
		var option: Dictionary = chapter_start_options[index]
		var x := 175 + index * 205
		var risk_text := "風險：%s" % _risk_tier_label(str(option.get("risk_tier", "medium")))
		_add_panel(Vector2(x, 198), Vector2(185, 138), Color(0.05, 0.07, 0.12, 0.86))
		_add_label(risk_text, Vector2(x + 12, 210), Vector2(160, 24), 13, HORIZONTAL_ALIGNMENT_LEFT, Color(1.0, 0.86, 0.58))
		var option_label := _wrap_button_text(str(option.get("label", "")), 16)
		_add_button(option_label, Vector2((x + 92.5) / BASE_SIZE.x, 0.52), Vector2(168, 72), func() -> void:
			_resolve_chapter_start_option(option)
		)
	_add_label("Deck %d   Relic %d   Gold %d" % [run_state.deck_ids.size(), run_state.relic_ids.size(), run_state.gold], Vector2(290, 382), Vector2(380, 28), 15, HORIZONTAL_ALIGNMENT_CENTER, Color(0.9, 0.86, 0.62))
	_add_debug_hint()

func _resolve_chapter_start_option(option: Dictionary) -> bool:
	if not _event_option_available(option):
		return false
	for outcome in option.get("outcomes", []):
		_apply_event_outcome(outcome)
	chapter_start_options.clear()
	_start_chapter_2_map()
	return true

func _start_chapter_2_map() -> void:
	run_state.start_next_chapter(database, CHAPTER_2_ID, run_state.map_seed + 2000)
	show_map()

func _run_curse_count() -> int:
	var count := 0
	for card_id in run_state.deck_ids:
		if str(card_id).begins_with("curse-"):
			count += 1
	return count

func _risk_tier_label(risk_tier: String) -> String:
	match risk_tier:
		"low":
			return "低"
		"medium":
			return "中"
		"high":
			return "高"
	return risk_tier

func _wrap_button_text(text: String, max_chars: int) -> String:
	var result := ""
	var line_length := 0
	for character in text:
		if line_length >= max_chars and character != " ":
			result += "\n"
			line_length = 0
		result += character
		line_length += 1
	return result

func show_chest_reward() -> void:
	current_screen = "chest_reward"
	input_locked = false
	var reward_key := _current_chest_reward_key()
	if chest_reward_node_key != reward_key:
		_claim_chest_relic_reward(reward_key)
	_clear_screen()
	_add_title("寶箱獎勵")
	_add_subtitle("寶箱會固定隨機取得 1 個 relic。")
	_add_panel(Vector2(240, 206), Vector2(480, 116), Color(0.05, 0.07, 0.11, 0.9))
	_add_label(chest_reward_text, Vector2(270, 230), Vector2(420, 58), 19, HORIZONTAL_ALIGNMENT_CENTER, Color(0.92, 0.86, 0.62))
	_add_button("繼續", Vector2(0.5, 0.76), Vector2(150, 44), _continue_after_chest_reward)
	_add_debug_hint()

func _take_chest_gold_reward() -> void:
	_continue_after_chest_reward()

func _take_chest_relic_reward() -> void:
	_continue_after_chest_reward()

func _claim_chest_relic_reward(reward_key: String) -> void:
	chest_reward_node_key = reward_key
	var relic_id := _add_next_relic_to_run("chest")
	if relic_id != "":
		chest_reward_text = "取得 relic：%s" % str(database.get_relic(relic_id)["name"])
		return
	run_state.gold += RELIC_FALLBACK_GOLD
	chest_reward_text = "relic 已全數取得，改獲得 Gold %d" % RELIC_FALLBACK_GOLD

func _continue_after_chest_reward() -> void:
	chest_reward_node_key = ""
	chest_reward_text = ""
	_complete_node()
	show_map()

func _current_chest_reward_key() -> String:
	if run_state.has_active_map():
		return "map:%s" % run_state.current_node_id
	return "fixed:%d" % run_state.current_node_index

func show_reward(title := "寶箱獎勵", subtitle := "選一張卡加入牌組，或跳過。", random_pick := false, use_existing_cards := false) -> void:
	current_screen = "reward"
	input_locked = false
	reward_title = title
	reward_subtitle = subtitle
	reward_random_pick = random_pick
	_clear_screen()
	_add_title(title)
	_add_subtitle(subtitle)
	if not use_existing_cards or reward_card_ids.is_empty():
		reward_card_ids = _draft_card_rewards(3) if random_pick else _draft_card_rewards(3)
	var rewards: Array[String] = reward_card_ids
	for index in range(rewards.size()):
		var card_id := rewards[index]
		var card := database.get_card(card_id)
		_add_card_button(card, Vector2(180 + index * 220, 178), Vector2(180, 220), func() -> void:
			_take_reward_card(card_id)
		)
	_add_button("跳過", Vector2(0.5, 0.82), Vector2(140, 44), func() -> void:
		_skip_reward()
	)
	_add_debug_hint()

func _take_reward_card(card_id: String) -> void:
	run_state.deck_ids.append(card_id)
	_finish_reward_flow()

func _skip_reward() -> void:
	_finish_reward_flow()

func _finish_reward_flow() -> void:
	if event_battle_pending:
		event_battle_pending = false
	_complete_node()
	show_map()

func show_shop() -> void:
	current_screen = "shop"
	input_locked = false
	_clear_screen()
	_add_title("商店")
	_add_subtitle("Gold %d   Deck %d   Relic %d" % [run_state.gold, run_state.deck_ids.size(), run_state.relic_ids.size()])
	_apply_shop_enter_relics()
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(142, 136)
	scroll.size = Vector2(676, 278)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	screen_host.add_child(scroll)
	var shop_content := Control.new()
	shop_content.custom_minimum_size = Vector2(676, 0)
	scroll.add_child(shop_content)
	var inventory := _shop_inventory()
	var cards: Array = inventory.get("card_ids", [])
	var shop_relic := _shop_relic_for_inventory(inventory)
	var sale_key := str(inventory.get("sale_key", ""))
	for index in range(cards.size()):
		var card_id := str(cards[index])
		var card_data := database.get_card(card_id)
		var is_sale := sale_key == _shop_item_key("card", card_id)
		var card_price := _shop_sale_price(_shop_card_price(card_data)) if is_sale else _shop_card_price(card_data)
		var card := _shop_card_display(card_data, _shop_price_badge(card_price, is_sale))
		var column := index % 3
		var row := index / 3
		var purchase_card_id := card_id
		var purchase_price := card_price
		_add_card_button_to(shop_content, card, Vector2(10 + column * 220, 10 + row * 148), Vector2(196, 134), func() -> void:
			_buy_shop_card(purchase_card_id, purchase_price)
		)
	var service_row := int(ceil(float(cards.size()) / 3.0))
	var service_y := 16 + service_row * 148
	if not shop_relic.is_empty():
		var relic_is_sale := sale_key == _shop_item_key("relic", str(shop_relic["id"]))
		var relic_price := _shop_sale_price(_shop_relic_price(shop_relic)) if relic_is_sale else _shop_relic_price(shop_relic)
		var relic_card := {
			"kind": "support",
			"cost": 0,
			"name": str(shop_relic["name"]),
			"description": str(shop_relic["description"]),
			"art_path": str(shop_relic.get("icon_path", "")),
			"badge_text": _shop_price_badge(relic_price, relic_is_sale),
			"type_label": "遺物",
			"shop_mode": true
		}
		var purchase_relic_price := relic_price
		_add_card_button_to(shop_content, relic_card, Vector2(10, service_y), Vector2(306, 118), func() -> void:
			_buy_shop_relic(purchase_relic_price)
		)
	var remove_card := {
		"kind": "mixed",
		"cost": 0,
		"name": "移除卡",
		"description": "選擇 1 張牌從牌組移除。",
		"badge_text": "%dg" % _shop_remove_price(),
		"type_label": "服務",
		"shop_mode": true
	}
	var remove_button := _add_card_button_to(shop_content, remove_card, Vector2(336, service_y), Vector2(306, 118), func() -> void:
		if run_state.gold < _shop_remove_price():
			return
		show_shop_remove_selection()
	)
	remove_button.disabled = run_state.gold < _shop_remove_price() or run_state.deck_ids.size() <= 1
	shop_content.custom_minimum_size = Vector2(676, service_y + 132)

	_add_button("離開", Vector2(0.5, 0.86), Vector2(160, 46), func() -> void:
		_complete_node()
		show_map()
	)
	_add_debug_hint()

func show_event(node: Dictionary = {}) -> void:
	current_screen = "event"
	input_locked = false
	_clear_screen()
	var event_id := str(node.get("event_id", "holostar-sponsor"))
	if event_id == "" and node.has("id"):
		event_id = str(node["id"])
	var event_def := database.get_event(event_id)
	if event_def.is_empty():
		event_def = database.get_event("holostar-sponsor")
	var title := str(event_def.get("title", node.get("title", "遇到流離失所的 HoloStar 成員")))
	var description := str(event_def.get("description", node.get("description", "是否要贊助資源給他")))
	var body := str(event_def.get("body", node.get("body", "一位看起來剛結束長途漂流的 HoloStar 成員需要補給。")))
	_add_title(title)
	_add_subtitle(description)
	_add_panel(Vector2(184, 188), Vector2(592, 168), Color(0.05, 0.07, 0.11, 0.9))
	_add_label(body, Vector2(216, 206), Vector2(528, 82), 16, HORIZONTAL_ALIGNMENT_CENTER, Color(0.86, 0.9, 1.0))
	var options: Array = event_def.get("options", [])
	for index in range(options.size()):
		var option: Dictionary = options[index]
		var option_copy := option.duplicate(true)
		var button := _add_button(str(option.get("label", "")), Vector2(0.34 + index * 0.32, 0.65), Vector2(290, 48), func() -> void:
			_resolve_event_option(option_copy)
		)
		button.disabled = not _event_option_available(option)
	_add_relic_summary(Vector2(250, 455), Vector2(460, 24))
	_add_debug_hint()

func _event_option_available(option: Dictionary) -> bool:
	for requirement in option.get("requirements", []):
		match str(requirement.get("stat", "")):
			"gold":
				if run_state.gold < int(requirement.get("min", 0)):
					return false
	return true

func _resolve_event_option(option: Dictionary) -> bool:
	if not _event_option_available(option):
		return false
	var starts_battle := false
	var pending_remove_count := 0
	for outcome in option.get("outcomes", []):
		if str(outcome.get("action", "")) == "start_battle":
			_start_event_battle(outcome)
			starts_battle = true
		elif str(outcome.get("action", "")) == "remove_card":
			pending_remove_count += max(1, int(outcome.get("amount", 1)))
		else:
			_apply_event_outcome(outcome)
	if starts_battle:
		return true
	if pending_remove_count > 0 and run_state.deck_ids.size() > 1:
		show_event_remove_selection(pending_remove_count)
		return true
	_complete_node()
	show_map()
	return true

func _apply_event_outcome(outcome: Dictionary) -> void:
	match str(outcome.get("action", "")):
		"gain_gold":
			run_state.gold = max(0, run_state.gold + int(outcome.get("amount", 0)))
		"lose_hp":
			run_state.hp = max(1, run_state.hp - int(outcome.get("amount", 0)))
		"heal":
			run_state.hp = min(run_state.max_hp, run_state.hp + int(outcome.get("amount", 0)))
		"add_card":
			var specific_card_id := str(outcome.get("card_id", ""))
			if specific_card_id != "" and not database.get_card(specific_card_id).is_empty():
				var copies: int = max(1, int(outcome.get("amount", 1)))
				for _i in range(copies):
					run_state.deck_ids.append(specific_card_id)
			else:
				var rewards := _draft_card_rewards(max(1, int(outcome.get("amount", 1))))
				for card_id in rewards:
					run_state.deck_ids.append(str(card_id))
		"remove_card":
			_remove_first_removable_card()
		"upgrade_card":
			_upgrade_first_card()
		"grant_relic":
			_grant_relic_from_source(str(outcome.get("source", "event")), RELIC_FALLBACK_GOLD)
		"add_random_curse":
			var curses := ["curse-dead-air", "curse-bad-connection", "curse-comment-fire"]
			var copies: int = max(1, int(outcome.get("amount", 1)))
			for _i in range(copies):
				run_state.deck_ids.append(str(curses.pick_random()))
		"increase_max_hp":
			var amount := int(outcome.get("amount", 0))
			run_state.max_hp += amount
			run_state.hp = min(run_state.max_hp, run_state.hp + amount)

func _start_event_battle(outcome: Dictionary) -> void:
	input_locked = false
	event_battle_pending = true
	var enemy := _event_battle_enemy(outcome)
	var deck := database.resolve_cards(run_state.deck_ids)
	var relics := _resolve_run_relics()
	var character: Dictionary = database.get_character(run_state.character_id)
	var passive: Dictionary = character.get("passive", {})
	var summon: Dictionary = character.get("summon", {})
	combat = combat_engine.start_combat(run_state.hp, run_state.max_hp, deck, enemy, relics, true, passive, summon)
	show_combat()

func _event_battle_enemy(outcome: Dictionary) -> Dictionary:
	if outcome.has("enemy_id"):
		var enemy := database.get_enemy(str(outcome.get("enemy_id", "ssrb-gray")))
		return enemy if not enemy.is_empty() else database.get_enemy("ssrb-gray")
	var pool := str(outcome.get("enemy_pool", "normal"))
	var candidates: Array[Dictionary] = []
	for enemy in database.enemies:
		if bool(enemy.get("is_boss", false)):
			continue
		if pool == "elite" and str(enemy.get("tier", "")) == "elite":
			candidates.append(enemy)
		elif pool == "chapter_2_mid" and str(enemy.get("chapter_id", "")) == CHAPTER_2_ID and str(enemy.get("encounter_tier", "")) == "mid":
			candidates.append(enemy)
		elif pool in ["early", "mid", "late"] and str(enemy.get("encounter_tier", "")) == pool:
			candidates.append(enemy)
		elif pool == "normal" and str(enemy.get("tier", "")) != "elite":
			candidates.append(enemy)
	if candidates.is_empty():
		return database.get_enemy("ssrb-gray")
	return candidates.pick_random()

func _event_spend_gold_for_hp() -> bool:
	if run_state.gold < 30:
		return false
	run_state.gold -= 30
	run_state.hp = min(run_state.max_hp, run_state.hp + 12)
	_complete_node()
	show_map()
	return true

func _event_trade_hp_for_relic() -> bool:
	run_state.hp = max(1, run_state.hp - 8)
	_grant_relic_from_source("event", RELIC_FALLBACK_GOLD)
	_complete_node()
	show_map()
	return true

func _event_stream_incident_gain_gold() -> bool:
	run_state.hp = max(1, run_state.hp - 6)
	run_state.gold += 35
	_set_debug_message("事件：協助收拾，獲得 Gold 35")
	_complete_node()
	show_map()
	return true

func _event_stream_incident_add_card() -> bool:
	var rewards := _draft_card_rewards(1)
	if rewards.is_empty():
		return false
	var card_id := str(rewards[0])
	run_state.deck_ids.append(card_id)
	_set_debug_message("事件：加入卡牌 %s" % str(database.get_card(card_id)["name"]))
	_complete_node()
	show_map()
	return true

func _event_fan_cheer_buy_relic() -> bool:
	if run_state.gold < 40:
		return false
	run_state.gold -= 40
	_grant_relic_from_source("event", RELIC_FALLBACK_GOLD)
	_complete_node()
	show_map()
	return true

func _event_fan_cheer_gain_gold() -> bool:
	run_state.gold += 25
	_set_debug_message("事件：整理應援，獲得 Gold 25")
	_complete_node()
	show_map()
	return true

func show_campfire() -> void:
	current_screen = "campfire"
	input_locked = false
	_clear_screen()
	_add_title("篝火")
	_add_subtitle("HP %d/%d   選擇休息或升級 1 張牌" % [run_state.hp, run_state.max_hp])
	_add_button("休息：回復 22 HP", Vector2(0.38, 0.62), Vector2(190, 48), func() -> void:
		run_state.hp = min(run_state.max_hp, run_state.hp + 22)
		_complete_node()
		show_map()
	)
	_add_button("選擇 1 張牌升級", Vector2(0.62, 0.62), Vector2(230, 48), func() -> void:
		show_campfire_upgrade_selection()
	)
	_add_debug_hint()

func show_shop_remove_selection() -> void:
	current_screen = "shop_remove_selection"
	input_locked = false
	_clear_screen()
	_add_title("移除卡")
	_add_subtitle("Gold %d   費用 %d   選擇 1 張牌移除" % [run_state.gold, _shop_remove_price()])
	_add_deck_selection_grid("remove", func(index: int) -> void:
		if run_state.gold < _shop_remove_price():
			return
		if _remove_card_at_index(index):
			run_state.gold -= _shop_remove_price()
			_set_debug_message("商店：已移除 1 張牌")
		show_shop()
	)
	_add_button("返回商店", Vector2(0.5, 0.87), Vector2(160, 44), show_shop)
	_add_debug_hint()

func show_event_remove_selection(amount: int = 1) -> void:
	current_screen = "event_remove_selection"
	input_locked = false
	_clear_screen()
	_add_title("移除卡")
	_add_subtitle("事件效果：選擇 1 張牌移除")
	_add_deck_selection_grid("remove", func(index: int) -> void:
		_event_remove_card_at_index(index, amount)
	)
	_add_debug_hint()

func _event_remove_card_at_index(index: int, remaining_count: int = 1) -> bool:
	if not _remove_card_at_index(index):
		return false
	var next_count: int = max(0, remaining_count - 1)
	_set_debug_message("事件：已移除 1 張牌")
	if next_count > 0 and run_state.deck_ids.size() > 1:
		show_event_remove_selection(next_count)
		return true
	_complete_node()
	show_map()
	return true

func show_campfire_upgrade_selection() -> void:
	current_screen = "campfire_upgrade_selection"
	input_locked = false
	_clear_screen()
	_add_title("升級卡")
	_add_subtitle("選擇 1 張未升級牌")
	_add_deck_selection_grid("upgrade", func(index: int) -> void:
		if _upgrade_card_at_index(index):
			_set_debug_message("篝火：已升級 1 張牌")
		_complete_node()
		show_map()
	)
	_add_button("返回篝火", Vector2(0.5, 0.87), Vector2(160, 44), show_campfire)
	_add_debug_hint()

func _add_deck_selection_grid(mode: String, callback: Callable) -> void:
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(110, 136)
	scroll.size = Vector2(740, 298)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	screen_host.add_child(scroll)
	var content := Control.new()
	content.custom_minimum_size = Vector2(740, 0)
	scroll.add_child(content)
	var visible_items: Array[Dictionary] = []
	for index in range(run_state.deck_ids.size()):
		var card_id := str(run_state.deck_ids[index])
		if mode == "upgrade" and not _card_can_be_upgraded(card_id):
			continue
		visible_items.append({ "index": index, "card_id": card_id })
	for visible_index in range(visible_items.size()):
		var item: Dictionary = visible_items[visible_index]
		var card_index := int(item["index"])
		var card_id := str(item["card_id"])
		var card := database.get_card(card_id)
		var column := visible_index % 3
		var row := visible_index / 3
		var prefix := "移除" if mode == "remove" else "升級"
		var button := _add_card_button_to(content, card, Vector2(14 + column * 238, 12 + row * 146), Vector2(216, 130), func() -> void:
			callback.call(card_index)
		, prefix)
	content.custom_minimum_size = Vector2(740, 20 + int(ceil(float(max(1, visible_items.size())) / 3.0)) * 146)

func show_run_end(cleared: bool) -> void:
	current_screen = "run_end"
	input_locked = false
	last_run_end_cleared = cleared
	_clear_screen()
	_add_title("通關成功" if cleared else "挑戰失敗")
	_add_subtitle("Godot MVP route complete." if cleared else "HP 歸零，請再試一次。")
	_add_button("重新開始", Vector2(0.5, 0.62), Vector2(170, 48), show_character_select)
	_add_debug_hint()

func _complete_node() -> void:
	run_state.complete_current_node(database)

func _draft_card_rewards(amount: int) -> Array[String]:
	return card_reward_draft.draft(database, _character_reward_cards(), run_state.deck_ids, run_state.relic_ids, amount, _current_floor_for_draft(), _reward_draft_seed(amount))

func _character_reward_cards() -> Array[String]:
	if run_state.character_id == "azki":
		return [
			"azki-pinpoint", "azki-kiss", "azki-route-strike", "azki-double-pin",
			"azki-frontier-burst", "azki-laplus-dash", "azki-laplus-crash", "azki-safe-route",
			"azki-coordinate-shield", "azki-idol-stance", "azki-map-search", "azki-songline",
			"azki-open-route", "azki-pioneer-call", "azki-final-coordinate",
			"azki-laplus-cover", "azki-coordinate-barrage", "azki-laplus-combo",
			"azki-marker-echo", "azki-laplus-reposition", "azki-route-marker",
			"azki-laplus-guard-order", "azki-laplus-contract", "azki-dark-tether",
			"azki-singing-coordinate", "azki-laplus-overflow", "azki-necrobinder-finale"
		]
	if run_state.character_id == "botan":
		return [
			"botan-burst", "botan-reload", "botan-mark", "botan-heavy-shot",
			"botan-steady-aim", "botan-fortified-cover", "botan-counter-line", "botan-tap-shot",
			"botan-suppressive-fire", "botan-tactical-focus", "botan-medkit-cover",
			"botan-button-check", "botan-clean-scope", "botan-calm-burst", "botan-precise-cover",
			"botan-funds-prepared", "botan-range-finder", "botan-overwatch",
			"botan-piercing-round", "botan-perfect-line"
		]
	return [
		"subaru-duck-rush", "subaru-draw-breath", "subaru-tsukkomi", "subaru-second-wind",
		"subaru-quick-retort", "subaru-rhythm-guard", "subaru-cheer-loop", "subaru-duck-step",
		"subaru-team-rush", "subaru-hype-call", "subaru-duck-feint", "subaru-cheer-recover",
		"subaru-duck-tempo", "subaru-teetee-guard", "subaru-desk-reaction", "subaru-blue-wave",
		"subaru-new-oshi-call", "subaru-opening-quack", "subaru-crowd-cover",
		"subaru-table-slam-loop", "subaru-unstoppable-cheer"
	]

func _current_floor_for_draft() -> int:
	if run_state.has_active_map():
		var node: Dictionary = run_state.get_current_node(database)
		return int(node.get("floor", 1))
	return max(1, run_state.current_node_index + 1)

func _reward_draft_seed(amount: int) -> int:
	var seed := int(run_state.map_seed)
	if seed == 0:
		seed = int(run_state.current_node_index + 1) * 997
	return seed + run_state.deck_ids.size() * 31 + run_state.relic_ids.size() * 53 + amount * 7

func _resolve_run_relics() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for relic_id in run_state.relic_ids:
		result.append(database.get_relic(str(relic_id)))
	return result

func _next_available_relic() -> Dictionary:
	for relic in database.relics:
		if not run_state.relic_ids.has(str(relic["id"])):
			return relic
	return {}

func _buy_shop_relic(price_override := -1) -> bool:
	var inventory := _shop_inventory()
	var relic := _shop_relic_for_inventory(inventory)
	if relic.is_empty():
		_set_debug_message("所有 relic 已取得")
		return false
	var price := int(price_override) if int(price_override) >= 0 else _shop_relic_price(relic)
	if run_state.gold < price:
		return false
	run_state.gold -= price
	run_state.relic_ids.append(str(relic["id"]))
	inventory["relic_id"] = ""
	_set_debug_message("取得 relic：%s" % str(relic["name"]))
	show_shop()
	return true

func _grant_next_relic_or_gold(fallback_gold: int) -> String:
	var relic_id := _add_next_relic_to_run("debug")
	if relic_id != "":
		_set_debug_message("取得 relic：%s" % str(database.get_relic(relic_id)["name"]))
		return relic_id
	run_state.gold += fallback_gold
	_set_debug_message("relic 已全數取得，改獲得 Gold %d" % fallback_gold)
	return ""

func _grant_relic_from_source(source: String, fallback_gold: int) -> String:
	var relic_id := _add_next_relic_to_run(source)
	if relic_id != "":
		_set_debug_message("取得 relic：%s" % str(database.get_relic(relic_id)["name"]))
		return relic_id
	run_state.gold += fallback_gold
	_set_debug_message("relic 已全數取得，改獲得 Gold %d" % fallback_gold)
	return ""

func _add_next_relic_to_run(source := "debug") -> String:
	var relic := _next_available_relic_for_source(source)
	if relic.is_empty():
		return ""
	var relic_id := str(relic["id"])
	run_state.relic_ids.append(relic_id)
	return relic_id

func _next_available_relic_for_source(source: String) -> Dictionary:
	for relic in database.relics:
		var relic_id := str(relic["id"])
		if run_state.relic_ids.has(relic_id):
			continue
		if source == "debug" or relic.get("source_rules", []).has(source):
			return relic
	return {}

func _shop_key() -> String:
	if run_state.has_active_map() and run_state.current_node_id != "":
		return "map:%s" % run_state.current_node_id
	return "fixed:%d:%s" % [run_state.current_node_index, run_state.character_id]

func _shop_inventory() -> Dictionary:
	var key := _shop_key()
	if not run_state.shop_inventories.has(key):
		var card_ids: Array[String] = card_reward_draft.sort_shop_cards(database, _character_shop_cards(), run_state.deck_ids, run_state.relic_ids, _current_floor_for_draft(), _reward_draft_seed(6))
		var shop_relic := _next_available_relic_for_source("shop")
		var relic_id := str(shop_relic.get("id", ""))
		run_state.shop_inventories[key] = {
			"card_ids": card_ids.duplicate(),
			"relic_id": relic_id,
			"sale_key": _shop_sale_key(card_ids, shop_relic)
		}
	return run_state.shop_inventories[key]

func _shop_relic_for_inventory(inventory: Dictionary) -> Dictionary:
	var relic_id := str(inventory.get("relic_id", ""))
	if relic_id == "":
		return {}
	if run_state.relic_ids.has(relic_id):
		inventory["relic_id"] = ""
		return {}
	return database.get_relic(relic_id)

func _buy_shop_card(card_id: String, price: int) -> bool:
	var inventory := _shop_inventory()
	var card_ids: Array = inventory.get("card_ids", [])
	if not card_ids.has(card_id):
		return false
	if run_state.gold < price:
		return false
	run_state.gold -= price
	run_state.deck_ids.append(card_id)
	card_ids.erase(card_id)
	inventory["card_ids"] = card_ids
	show_shop()
	return true

func _shop_discount() -> int:
	var discount := 0
	for relic in _resolve_run_relics():
		if str(relic.get("hook", "")) == "shop_enter" and str(relic.get("effect", "")) == "shop_discount":
			discount += int(relic.get("amount", 0))
	return discount

func _shop_card_price(card: Dictionary) -> int:
	if str(card.get("rarity", "")) == "starter":
		return 0
	var price := 45 + int(card.get("cost", 1)) * 12
	match str(card.get("kind", "")):
		"attack":
			price += 6
		"mixed":
			price += 10
		"support":
			price -= 12
		"defense":
			price += 0
	return clamp(price, 25, 100)

func _shop_relic_price(relic: Dictionary = {}) -> int:
	match str(relic.get("pool", "common")):
		"boss":
			return 250
		"elite":
			return 220
		"event", "shop":
			return 180
	return 150

func _shop_sale_key(cards: Array, relic: Dictionary) -> String:
	if not cards.is_empty():
		return _shop_item_key("card", str(cards[0]))
	if not relic.is_empty():
		return _shop_item_key("relic", str(relic["id"]))
	return ""

func _shop_item_key(kind: String, id: String) -> String:
	return "%s:%s" % [kind, id]

func _shop_sale_price(price: int) -> int:
	return max(1, int(round(float(price) * SHOP_SALE_RATE)))

func _shop_price_badge(price: int, is_sale: bool) -> String:
	return "特價 %dg" % price if is_sale else "%dg" % price

func _shop_remove_price() -> int:
	return max(20, SHOP_REMOVE_PRICE - _shop_discount())

func _apply_shop_enter_relics() -> void:
	pass

func _apply_room_enter_relics(node: Dictionary) -> void:
	if str(node.get("type", "")) in ["battle", "elite", "boss"]:
		return
	for relic in _resolve_run_relics():
		if str(relic.get("hook", "")) == "room_enter" and str(relic.get("effect", "")) == "room_gold":
			run_state.gold += int(relic.get("amount", 0))

func _remove_first_removable_card() -> bool:
	if run_state.deck_ids.size() <= 1:
		return false
	var remove_index := -1
	for index in range(run_state.deck_ids.size()):
		if not str(run_state.deck_ids[index]).ends_with("+"):
			remove_index = index
			break
	if remove_index == -1:
		remove_index = 0
	run_state.deck_ids.remove_at(remove_index)
	return true

func _remove_card_at_index(index: int) -> bool:
	if run_state.deck_ids.size() <= 1:
		return false
	if index < 0 or index >= run_state.deck_ids.size():
		return false
	run_state.deck_ids.remove_at(index)
	return true

func _upgrade_first_card() -> bool:
	for index in range(run_state.deck_ids.size()):
		var card_id := str(run_state.deck_ids[index])
		if _card_can_be_upgraded(card_id):
			run_state.deck_ids[index] = _upgraded_id(card_id)
			return true
	return false

func _upgrade_card_at_index(index: int) -> bool:
	if index < 0 or index >= run_state.deck_ids.size():
		return false
	var card_id := str(run_state.deck_ids[index])
	if not _card_can_be_upgraded(card_id):
		return false
	run_state.deck_ids[index] = _upgraded_id(card_id)
	return true

func _card_can_be_upgraded(card_id: String) -> bool:
	if card_id.ends_with("+"):
		return false
	var card := database.get_card(card_id)
	if card.is_empty():
		return false
	if bool(card.get("unplayable", false)):
		return false
	if str(card.get("curse_hook", "")) != "":
		return false
	if str(card.get("kind", "")) == "curse" or card_id.begins_with("curse-"):
		return false
	return true

func _upgraded_id(card_id: String) -> String:
	return card_id if card_id.ends_with("+") else "%s+" % card_id

func _relic_summary_text() -> String:
	if run_state.relic_ids.is_empty():
		return "Relic：無"
	var names: Array[String] = []
	for relic in _resolve_run_relics():
		names.append(str(relic["name"]))
	return "Relic：%s" % "、".join(names)

func _character_shop_cards() -> Array[String]:
	if run_state.character_id == "azki":
		return [
			"azki-kiss", "azki-route-strike", "azki-frontier-burst", "azki-laplus-dash",
			"azki-laplus-crash", "azki-safe-route", "azki-coordinate-shield", "azki-songline",
			"azki-open-route", "azki-pioneer-call", "azki-final-coordinate",
			"azki-laplus-cover", "azki-coordinate-barrage", "azki-laplus-combo",
			"azki-marker-echo", "azki-laplus-reposition", "azki-route-marker",
			"azki-laplus-guard-order", "azki-laplus-contract", "azki-dark-tether",
			"azki-singing-coordinate", "azki-laplus-overflow", "azki-necrobinder-finale"
		]
	if run_state.character_id == "botan":
		return [
			"botan-mark", "botan-cover", "botan-burst", "botan-heavy-shot",
			"botan-fortified-cover", "botan-counter-line", "botan-suppressive-fire", "botan-tactical-focus",
			"botan-button-check", "botan-clean-scope", "botan-calm-burst", "botan-precise-cover",
			"botan-funds-prepared", "botan-range-finder", "botan-overwatch",
			"botan-piercing-round", "botan-perfect-line"
		]
	return [
		"subaru-tsukkomi", "subaru-second-wind", "subaru-duck-rush", "subaru-rhythm-guard",
		"subaru-cheer-loop", "subaru-team-rush", "subaru-hype-call", "subaru-duck-feint",
		"subaru-duck-tempo", "subaru-teetee-guard", "subaru-desk-reaction", "subaru-blue-wave",
		"subaru-new-oshi-call", "subaru-opening-quack", "subaru-crowd-cover",
		"subaru-table-slam-loop", "subaru-unstoppable-cheer"
	]

func _debug_open_character_select() -> void:
	input_locked = false
	_clear_pending_combat_reward()
	_clear_pending_room_rewards()
	show_character_select()
	_set_debug_message("Debug：回到角色選擇")

func _demo_start_character_map(character_id: String) -> void:
	_clear_pending_room_rewards()
	run_state.start_random_run(database, character_id)
	show_map()
	_set_debug_message("Demo QA：%s random run" % str(database.get_character(character_id).get("name", character_id)))

func _demo_start_azki_showcase(player_action: String) -> void:
	_clear_pending_room_rewards()
	run_state.start_run(database, "azki")
	run_state.deck_ids.clear()
	for card_id in [
		"azki-pinpoint",
		"azki-kiss",
		"azki-laplus-dash",
		"azki-laplus-crash",
		"azki-coordinate-shield",
		"azki-map-search"
	]:
		run_state.deck_ids.append(str(card_id))
	var enemy := database.get_enemy("ssrb-gray")
	var character: Dictionary = database.get_character("azki")
	combat = combat_engine.start_combat(run_state.hp, run_state.max_hp, database.resolve_cards(run_state.deck_ids), enemy, [], false, character.get("passive", {}), character.get("summon", {}))
	combat.enemy_statuses["marker"] = { "id": "marker", "value": 2, "duration": 1 }
	_set_debug_message_for_next_draw("Demo QA：AZKi / Laplus - %s" % player_action)
	show_combat(player_action, "idle")

func _demo_start_marker_fallback_showcase() -> void:
	_demo_start_azki_showcase("map_marker_attack")
	if combat != null:
		combat.enemy_statuses["marker"] = { "id": "marker", "value": 2, "duration": 2 }
	_set_debug_message_for_next_draw("Demo QA：marker fallback 應顯示「標記」")
	show_combat("map_marker_attack", "idle")

func _demo_start_boss_warning_showcase() -> void:
	_clear_pending_room_rewards()
	run_state.start_run(database, "subaru")
	run_state.hp = run_state.max_hp
	var enemy := database.get_enemy("important-announcement")
	var character: Dictionary = database.get_character("subaru")
	combat = combat_engine.start_combat(run_state.hp, run_state.max_hp, database.resolve_cards(run_state.deck_ids), enemy, [], false, character.get("passive", {}))
	combat_engine.end_player_turn(combat)
	combat_engine.end_player_turn(combat)
	run_state.hp = combat.player_hp
	_set_debug_message_for_next_draw("Demo QA：Boss warning showcase")
	show_combat("idle", "idle")

func _debug_start_next_normal_battle() -> void:
	_ensure_debug_run()
	var enemy_id := str(DEBUG_NORMAL_ENEMY_IDS[debug_normal_enemy_index])
	debug_normal_enemy_index = (debug_normal_enemy_index + 1) % DEBUG_NORMAL_ENEMY_IDS.size()
	run_state.current_node_index = 1
	_start_debug_combat(enemy_id)
	_set_debug_message("Debug：普通戰測試 - %s" % str(database.get_enemy(enemy_id)["display_name"]))

func _debug_start_next_elite_battle() -> void:
	_ensure_debug_run()
	var enemy_id := str(DEBUG_ELITE_ENEMY_IDS[debug_elite_enemy_index])
	debug_elite_enemy_index = (debug_elite_enemy_index + 1) % DEBUG_ELITE_ENEMY_IDS.size()
	run_state.current_node_index = 5
	_start_debug_combat(enemy_id)
	_set_debug_message("Debug：菁英戰測試 - %s" % str(database.get_enemy(enemy_id)["display_name"]))

func _debug_cycle_boss() -> void:
	debug_boss_index = (debug_boss_index + 1) % DEBUG_BOSS_IDS.size()
	debug_boss_override_id = str(DEBUG_BOSS_IDS[debug_boss_index])
	_set_debug_message("Debug：Boss 指定為 %s" % str(database.get_enemy(debug_boss_override_id)["display_name"]))

func _debug_start_boss_battle() -> void:
	_ensure_debug_run()
	if debug_boss_override_id == "":
		debug_boss_override_id = str(DEBUG_BOSS_IDS[0])
	run_state.current_node_index = database.map_nodes.size() - 1
	_start_debug_combat(debug_boss_override_id)
	_set_debug_message("Debug：Boss 戰測試 - %s" % str(database.get_enemy(debug_boss_override_id)["display_name"]))

func _debug_open_chest_reward() -> void:
	_ensure_debug_run()
	run_state.current_node_index = 4
	show_chest_reward()
	_set_debug_message("Debug：寶箱獎勵測試")

func _debug_open_shop() -> void:
	_ensure_debug_run()
	run_state.current_node_index = 6
	show_shop()
	_set_debug_message("Debug：商店測試")

func _debug_open_event() -> void:
	_ensure_debug_run()
	var event_node_index := int(DEBUG_EVENT_NODE_INDICES[debug_event_index])
	debug_event_index = (debug_event_index + 1) % DEBUG_EVENT_NODE_INDICES.size()
	run_state.current_node_index = event_node_index
	show_event(database.map_nodes[event_node_index])
	_set_debug_message("Debug：事件測試 - %s" % str(database.map_nodes[event_node_index]["label"]))

func _debug_open_campfire() -> void:
	_ensure_debug_run()
	run_state.current_node_index = 9
	show_campfire()
	_set_debug_message("Debug：篝火測試")

func _debug_add_relic() -> void:
	_ensure_debug_run()
	var relic_id := _add_next_relic_to_run()
	if relic_id == "":
		_set_debug_message("Debug：所有 relic 已取得")
		return
	debug_relic_index = (debug_relic_index + 1) % DEBUG_RELIC_IDS.size()
	_set_debug_message("Debug：取得 relic - %s" % str(database.get_relic(relic_id)["name"]))

func _ensure_debug_run() -> void:
	if run_state.character_id == "":
		_clear_pending_room_rewards()
		run_state.start_run(database, "subaru")

func _start_debug_combat(enemy_id: String) -> void:
	input_locked = false
	_clear_pending_combat_reward()
	var deck := database.resolve_cards(run_state.deck_ids)
	var enemy := database.get_enemy(enemy_id)
	var relics := _resolve_run_relics()
	var character: Dictionary = database.get_character(run_state.character_id)
	var passive: Dictionary = character.get("passive", {})
	var summon: Dictionary = character.get("summon", {})
	combat = combat_engine.start_combat(run_state.hp, run_state.max_hp, deck, enemy, relics, true, passive, summon)
	show_combat()

func _set_debug_message(message: String) -> void:
	debug_message_token += 1
	var token := debug_message_token
	debug_message = message
	_refresh_current_screen()
	_clear_debug_message_later(token)

func _set_debug_message_for_next_draw(message: String) -> void:
	debug_message_token += 1
	debug_message = message

func _clear_debug_message_later(token: int) -> void:
	await get_tree().create_timer(2.0).timeout
	if token != debug_message_token:
		return
	debug_message = ""
	_refresh_current_screen()

func _refresh_current_screen() -> void:
	match current_screen:
		"character_select":
			show_character_select()
		"demo_qa":
			show_demo_qa()
		"map":
			show_map()
		"combat":
			show_combat()
		"reward":
			show_reward(reward_title, reward_subtitle, reward_random_pick, true)
		"chest_reward":
			show_chest_reward()
		"shop":
			show_shop()
		"event":
			show_event(run_state.get_current_node(database))
		"campfire":
			show_campfire()
		"shop_remove_selection":
			show_shop_remove_selection()
		"campfire_upgrade_selection":
			show_campfire_upgrade_selection()
		"boss_reward":
			show_boss_reward()
		"chapter_start_event":
			show_chapter_start_event()
		"run_end":
			show_run_end(last_run_end_cleared)

func _clear_pending_room_rewards() -> void:
	chest_reward_node_key = ""
	chest_reward_text = ""
	chapter_start_options.clear()
	_clear_pending_combat_reward()

func _clear_pending_combat_reward() -> void:
	combat_reward_pending = false
	combat_reward_player_action = "idle"
	combat_reward_enemy_action = "idle"
	event_battle_pending = false

func _add_relic_summary(ui_position: Vector2, ui_size: Vector2) -> void:
	if run_state.relic_ids.is_empty():
		_add_label(_relic_summary_text(), ui_position, ui_size, 13, HORIZONTAL_ALIGNMENT_CENTER, Color(0.92, 0.86, 0.62))
		return
	var container := Control.new()
	container.name = "RelicSummary"
	container.position = ui_position
	container.size = ui_size
	screen_host.add_child(container)
	var relics := _resolve_run_relics()
	var visible_count = min(relics.size(), 5)
	var item_width := ui_size.x / float(visible_count)
	for index in range(visible_count):
		var relic: Dictionary = relics[index]
		var item_x := index * item_width
		var icon := _add_relic_icon_texture(container, str(relic.get("icon_path", "")), Vector2(item_x, 0), Vector2(27, 27))
		if icon != null:
			icon.name = "RelicSummaryIcon_%s" % str(relic.get("id", index))
		var label := Label.new()
		label.name = "RelicSummaryText_%s" % str(relic.get("id", index))
		label.text = str(relic.get("name", ""))
		label.position = Vector2(item_x + (31.0 if icon != null else 0.0), 0)
		label.size = Vector2(item_width - (33.0 if icon != null else 2.0), ui_size.y)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.clip_text = true
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.92, 0.86, 0.62))
		label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)
		container.add_child(label)

func _add_combat_relic_icons(ui_position: Vector2, ui_size: Vector2) -> void:
	if run_state.relic_ids.is_empty():
		return
	var container := Control.new()
	container.name = "CombatRelicIcons"
	container.position = ui_position
	container.size = ui_size
	screen_host.add_child(container)
	var relics := _resolve_run_relics()
	var visible_count = min(relics.size(), 8)
	var spacing := 32.0
	for index in range(visible_count):
		var relic: Dictionary = relics[index]
		var icon := _add_relic_icon_texture(container, str(relic.get("icon_path", "")), Vector2(index * spacing, 0), Vector2(30, 30), _relic_tooltip(relic), true)
		if icon != null:
			icon.name = "CombatRelicIcon_%s" % str(relic.get("id", index))

func _add_relic_icon_texture(parent: Control, asset_path: String, ui_position: Vector2, ui_size: Vector2, tooltip := "", match_status_size := false) -> TextureRect:
	if asset_path == "" or not ResourceLoader.exists(asset_path):
		return null
	var texture := load(asset_path) as Texture2D
	if texture == null:
		return null
	var icon := TooltipIconTextureRectScript.new()
	icon.texture = texture
	icon.ignore_texture_size = true
	if match_status_size:
		var icon_size := Vector2(max(1.0, ui_size.x * 0.9), max(1.0, ui_size.y * 0.9))
		icon.position = ui_position + (ui_size - icon_size) * 0.5
		icon.size = icon_size
	else:
		icon.position = ui_position
		icon.size = ui_size
	icon.mouse_filter = Control.MOUSE_FILTER_PASS
	icon.tooltip_text = tooltip
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	parent.add_child(icon)
	return icon

func _relic_tooltip(relic: Dictionary) -> String:
	var name := str(relic.get("name", ""))
	var description := str(relic.get("description", ""))
	if description == "":
		return name
	return "%s：%s" % [name, description]

func _add_debug_hint() -> void:
	if not DEBUG_ENABLED:
		return
	var lines := []
	if debug_message != "":
		lines.append(debug_message)
	if debug_help_visible:
		lines.append("1 說明  2 角色選擇  D Demo QA  3 普通戰  4 切 Boss  5 Boss 戰  6 菁英戰
7 寶箱  8 商店  9 篝火  0/= 事件  - 取得 relic")
	if lines.is_empty():
		return
	_add_panel(Vector2(168, 146), Vector2(624, 26 + 20 * (lines.size() - 1)), Color(0.02, 0.03, 0.05, 0.76))
	for index in range(lines.size()):
		_add_label(str(lines[index]), Vector2(178, 149 + index * 20), Vector2(604, 20), 13, HORIZONTAL_ALIGNMENT_CENTER, Color(0.86, 0.91, 1.0))

func _add_character_select_passive(character_id: String, ui_position: Vector2, ui_size: Vector2) -> void:
	var passive: Dictionary = database.get_character(character_id).get("passive", {})
	_add_label(_passive_display_text(passive), ui_position, ui_size, 11, HORIZONTAL_ALIGNMENT_CENTER, Color(0.82, 0.90, 1.0))

func _add_combat_header_ui() -> void:
	if bool(combat.enemy.get("is_boss", false)):
		_add_panel(Vector2.ZERO, BASE_SIZE, Color(0.04, 0.02, 0.02, 0.38))
		_add_panel(Vector2(342, 16), Vector2(276, 48), Color(0.48, 0.08, 0.08, 0.9))
		_add_label("BOSS", Vector2(352, 20), Vector2(256, 38), 23, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.86, 0.55))
	_add_combat_status_panels()
	_add_combat_relic_icons(Vector2(36, 4), Vector2(320, 32))

func _add_combat_actor_sprites(player_action: String, enemy_action: String, player_hurt: bool) -> void:
	if run_state.character_id == "azki":
		_add_azki_combat_actor_sprites(player_action, player_hurt)
		_add_combat_enemy_sprites(enemy_action)
		return
	var player_path := _player_sheet_path("hurt") if player_hurt else _player_sheet_path(player_action)
	var player_sprite := _add_sprite_sheet(player_path, _player_sprite_anchor(), _player_sprite_size())
	player_sprite.name = "PlayerActorSprite"
	if (player_action != "idle" or player_hurt) and player_sprite.sprite_frames != null:
		player_sprite.sprite_frames.set_animation_loop("default", false)
		player_sprite.sprite_frames.set_animation_speed("default", CARD_ACTION_ANIMATION_SPEED)
	if player_hurt:
		player_sprite.modulate = Color(1.0, 0.55, 0.55, 0.78)
		player_sprite.position.x -= 10.0
	_add_combat_enemy_sprites(enemy_action)

func _add_combat_enemy_sprites(enemy_action: String) -> void:
	var enemy_pos := Vector2(0.68, 0.49) if enemy_action == "attack" else Vector2(0.74, 0.49)
	var enemy_size := Vector2(174, 174) * float(combat.enemy.get("scale", 1.0))
	if combat.enemy.has("secondary_resource_base_path"):
		var primary_enemy_sprite := _add_sprite_sheet(_enemy_sheet_path_for_base(str(combat.enemy["resource_base_path"]), enemy_action), enemy_pos + Vector2(-0.05, 0.0), enemy_size)
		var secondary_enemy_sprite := _add_sprite_sheet(_enemy_sheet_path_for_base(str(combat.enemy["secondary_resource_base_path"]), enemy_action), enemy_pos + Vector2(0.07, 0.0), enemy_size)
		_configure_enemy_action_sprite(primary_enemy_sprite, enemy_action)
		_configure_enemy_action_sprite(secondary_enemy_sprite, enemy_action)
	else:
		var enemy_sprite := _add_sprite_sheet(_enemy_sheet_path(enemy_action), enemy_pos, enemy_size)
		_configure_enemy_action_sprite(enemy_sprite, enemy_action)

func _add_azki_combat_actor_sprites(player_action: String, player_hurt: bool) -> void:
	var azki_action := _azki_body_action(player_action, player_hurt)
	var azki_sprite := _add_sprite_sheet(_azki_body_sheet_path(azki_action), Vector2(0.25, 0.50), Vector2(170, 220))
	azki_sprite.name = "AZKiBodySprite"
	azki_sprite.z_index = 2
	_configure_player_action_sprite(azki_sprite, azki_action, player_hurt)
	if player_hurt:
		azki_sprite.modulate = Color(1.0, 0.55, 0.55, 0.78)
		azki_sprite.position.x -= 8.0

	var laplus_action := _laplus_summon_action(player_action)
	var laplus_sprite := _add_sprite_sheet(_laplus_summon_sheet_path(laplus_action), Vector2(0.38, 0.53), Vector2(154, 154))
	laplus_sprite.name = "LaplusSummonSprite"
	laplus_sprite.z_index = 1
	_configure_player_action_sprite(laplus_sprite, laplus_action, laplus_action != "idle")
	if combat.summon_id != "" and not bool(combat.summon_alive) and laplus_action == "defeat":
		laplus_sprite.modulate = Color(1.0, 1.0, 1.0, 0.72)
		if laplus_sprite.sprite_frames != null:
			laplus_sprite.stop()
			laplus_sprite.frame = laplus_sprite.sprite_frames.get_frame_count("default") - 1

	_add_laplus_summon_hp_bar()
	_add_player_action_fx_sprite(player_action)

func _configure_player_action_sprite(sprite: AnimatedSprite2D, action: String, force_action := false) -> void:
	if (force_action or action != "idle") and sprite.sprite_frames != null:
		sprite.sprite_frames.set_animation_loop("default", false)
		sprite.sprite_frames.set_animation_speed("default", CARD_ACTION_ANIMATION_SPEED)

func _azki_body_action(player_action: String, player_hurt: bool) -> String:
	if player_hurt:
		return "hurt"
	match player_action:
		"map_marker_attack":
			return "map_marker_attack"
		"kiss_attack":
			return "kiss_attack"
		"laplus_dash":
			return "command_dash"
		"laplus_crash":
			return "command_crash"
		"defense":
			return "defense"
		"hurt":
			return "hurt"
		"defeat":
			return "defeat"
	return "idle"

func _laplus_summon_action(player_action: String) -> String:
	if bool(combat.last_summon_defeated):
		return "defeat"
	if int(combat.last_summon_damage) > 0:
		return "hurt"
	if combat.summon_id != "" and not bool(combat.summon_alive):
		return "defeat"
	match player_action:
		"defense":
			return "defense"
		"laplus_dash":
			return "dash_attack"
		"laplus_crash":
			return "crash_attack"
	return "idle"

func _azki_body_sheet_path(action: String) -> String:
	return "res://assets/characters/azki_necromancer/%s/sheet-transparent.png" % action

func _laplus_summon_sheet_path(action: String) -> String:
	return "res://assets/characters/laplus_darkness_summon/%s/sheet-transparent.png" % action

func _add_laplus_summon_hp_bar() -> void:
	if combat.summon_id == "":
		return
	var bar_position := Vector2(292, 220)
	var bar_size := Vector2(92, 8)
	_add_panel(bar_position + Vector2(-1, -1), bar_size + Vector2(2, 2), Color(0.02, 0.02, 0.03, 0.72))
	var ratio: float = 0.0 if combat.summon_hp <= 0 else clamp(float(combat.summon_hp) / 12.0, 0.08, 1.0)
	_add_panel(bar_position, Vector2(bar_size.x * ratio, bar_size.y), Color(0.78, 0.36, 0.95, 0.92))
	var hp_text := "DOWN" if not bool(combat.summon_alive) else "%d" % combat.summon_hp
	var hp_label := _add_label(hp_text, bar_position + Vector2(-8, -21), Vector2(108, 18), 12, HORIZONTAL_ALIGNMENT_CENTER, Color(0.92, 0.82, 1.0))
	hp_label.name = "LaplusSummonHpLabel"

func _player_sprite_anchor() -> Vector2:
	if run_state.character_id == "azki":
		return Vector2(0.31, 0.50)
	return Vector2(0.27, 0.49)

func _player_sprite_size() -> Vector2:
	if run_state.character_id == "azki":
		return Vector2(300, 240)
	return Vector2(178, 178)

func _add_player_action_fx_sprite(player_action: String) -> void:
	var fx_path := _player_action_fx_path(player_action)
	if fx_path == "" or not ResourceLoader.exists(fx_path):
		return
	var fx_sprite := _add_sprite_sheet(fx_path, _player_action_fx_anchor(player_action), _player_action_fx_size(player_action))
	fx_sprite.name = "PlayerActionFxSprite"
	fx_sprite.z_index = 3
	if fx_sprite.sprite_frames != null:
		fx_sprite.sprite_frames.set_animation_loop("default", false)
		fx_sprite.sprite_frames.set_animation_speed("default", CARD_ACTION_ANIMATION_SPEED)

func _player_action_fx_path(player_action: String) -> String:
	if run_state.character_id != "azki":
		return ""
	match player_action:
		"map_marker_attack":
			return "res://assets/fx/azki_necrobinder/map_marker_projectile/sheet-transparent.png"
		"kiss_attack":
			return "res://assets/fx/azki_necrobinder/kiss_heart_projectile/sheet-transparent.png"
		"laplus_dash":
			return "res://assets/fx/azki_necrobinder/laplus_dash_trail/sheet-transparent.png"
		"laplus_crash":
			return "res://assets/fx/azki_necrobinder/laplus_crash_impact/sheet-transparent.png"
	return ""

func _player_action_fx_anchor(player_action: String) -> Vector2:
	match player_action:
		"laplus_dash":
			return Vector2(0.52, 0.52)
		"laplus_crash":
			return Vector2(0.54, 0.54)
	return Vector2(0.54, 0.48)

func _player_action_fx_size(player_action: String) -> Vector2:
	match player_action:
		"laplus_dash":
			return Vector2(300, 160)
		"laplus_crash":
			return Vector2(280, 220)
	return Vector2(300, 170)

func _configure_enemy_action_sprite(sprite: AnimatedSprite2D, enemy_action: String) -> void:
	if enemy_action != "idle" and sprite.sprite_frames != null:
		sprite.sprite_frames.set_animation_loop("default", false)
		sprite.sprite_frames.set_animation_speed("default", CARD_ACTION_ANIMATION_SPEED)
	if combat_reward_pending and enemy_action == "defeat" and sprite.sprite_frames != null:
		sprite.stop()
		sprite.frame = sprite.sprite_frames.get_frame_count("default") - 1

func _add_combat_hand_ui() -> void:
	combat_hand_buttons = combat_hand_view.add_hand(screen_host, combat.hand, func(index: int) -> void:
		play_card(index)
	)
	if pending_draw_animation_start_index >= 0:
		combat_hand_view.animate_draw_from_left(screen_host, combat_hand_buttons, pending_draw_animation_start_index)
		pending_draw_animation_start_index = -1

func _combat_hand_card_position(index: int, hand_size: int, card_size := Vector2(108, 144)) -> Vector2:
	return combat_hand_view.card_position(index, hand_size, card_size)

func _passive_display_text(passive: Dictionary) -> String:
	if passive.is_empty():
		return "被動：無"
	return "被動：%s\n%s" % [str(passive.get("name", "")), str(passive.get("description", ""))]

func _passive_triggered_now(passive_id: String, passive_was_used: bool) -> bool:
	if passive_id == "" or passive_was_used:
		return false
	return bool(combat.passive_flags.get(passive_id, false))

func _add_combat_status_panels() -> void:
	var character := database.get_character(run_state.character_id)
	actor_status_view.add_combat_status_panels(screen_host, combat, character)

func _intent_icon_text(intent: Dictionary) -> String:
	return actor_status_view.intent_icon_text(intent)

func _add_character_status_labels() -> void:
	actor_status_view.add_status_labels(screen_host, combat_engine.status_summary(combat, "player"), combat_engine.status_summary(combat, "enemy"), combat.player_statuses, combat.enemy_statuses)

func _add_character_identity_hint() -> void:
	if current_screen != "combat":
		return
	var hint_text := _character_identity_text()
	if hint_text == "":
		return
	_add_label(hint_text, Vector2(36, 154), Vector2(320, 34), 12, HORIZONTAL_ALIGNMENT_LEFT, Color(0.84, 0.94, 1.0))

func _add_combat_turn_event_hint() -> void:
	if current_screen != "combat" or combat == null:
		return
	var event_text := _latest_combat_turn_event_text()
	if event_text == "":
		return
	var event_label := _add_label(event_text, Vector2(300, 72), Vector2(360, 42), 11, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.90, 0.66))
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _add_stat_box(ui_position: Vector2, ui_size: Vector2, title: String, value: String, color: Color) -> void:
	actor_status_view.add_stat_box(screen_host, ui_position, ui_size, title, value, color)

func _enemy_sheet_path(action: String) -> String:
	var asset_path := _enemy_sheet_path_for_base(str(combat.enemy["resource_base_path"]), action)
	if ResourceLoader.exists(asset_path):
		return asset_path
	var fallback_base := str(combat.enemy.get("fallback_resource_base_path", "res://assets/enemies/ssrb/white/"))
	return _enemy_sheet_path_for_base(fallback_base, action)

func _enemy_sheet_path_for_base(base_path: String, action: String) -> String:
	var mapped := action.capitalize()
	if action == "idle":
		mapped = "idle"
	elif action == "attack":
		mapped = "attack"
	elif action == "block" or action == "guard":
		mapped = "guard"
	elif action == "hurt":
		mapped = "hurt"
	elif action == "defeat":
		mapped = "defeat"
	return "%s%s/sheet-transparent.png" % [base_path, mapped]

func _player_sheet_path(action: String) -> String:
	var character := database.get_character(run_state.character_id)
	var base_path := str(character.get("resource_base_path", "res://assets/characters/subaru/"))
	if run_state.character_id == "azki":
		match action:
			"map_marker_attack":
				return "%smap_marker_attack/sheet-transparent.png" % base_path
			"kiss_attack":
				return "%skiss_attack/sheet-transparent.png" % base_path
			"laplus_dash":
				return "%scommand_dash/sheet-transparent.png" % base_path
			"laplus_crash":
				return "%scommand_crash/sheet-transparent.png" % base_path
			"cast_marker":
				return "%scast_marker/sheet-transparent.png" % base_path
			"cast_kiss":
				return "%scast_kiss/sheet-transparent.png" % base_path
			"command_dash":
				return "%scommand_dash/sheet-transparent.png" % base_path
			"command_crash":
				return "%scommand_crash/sheet-transparent.png" % base_path
	match action:
		"normal_attack":
			return "%snormal_attack/sheet-transparent.png" % base_path
		"defense":
			return "%sdefense/sheet-transparent.png" % base_path
		"hurt":
			return "%shurt/sheet-transparent.png" % base_path
		"tsukkomi":
			return "%stsukkomi/sheet-transparent.png" % base_path
		"shooting_skill":
			return "%sshooting_skill/sheet-transparent.png" % base_path
		"pistol_attack":
			return "%spistol_attack/sheet-transparent.png" % base_path
		"sniper_ultimate":
			return "%ssniper_ultimate/sheet-transparent.png" % base_path
		"map_marker_attack":
			return "%smap_marker_attack/sheet-transparent.png" % base_path
		"kiss_attack":
			return "%skiss_attack/sheet-transparent.png" % base_path
		"laplus_dash":
			return "res://assets/characters/laplus_darkness_summon/dash_attack/sheet-transparent.png"
		"laplus_crash":
			return "res://assets/characters/laplus_darkness_summon/crash_attack/sheet-transparent.png"
	return "%sidle/sheet-transparent.png" % base_path

func _random_map_boss_name() -> String:
	var boss := _random_map_boss_enemy()
	if not boss.is_empty():
		return str(boss.get("display_name", "未知"))
	return "未知"

func _random_map_boss_enemy() -> Dictionary:
	for node in run_state.active_map.get("nodes", []):
		if str(node.get("type", "")) == "boss":
			var boss_id := str(node.get("selected_boss_enemy_id", ""))
			if boss_id != "":
				return database.get_enemy(boss_id)
	return {}

func _character_identity_text() -> String:
	var character := database.get_character(run_state.character_id)
	var hint := str(character.get("identity_hint", ""))
	if hint == "":
		return ""
	return "玩法：%s" % hint

func _latest_combat_turn_event_text() -> String:
	if combat == null or combat.turn_events.is_empty():
		return ""
	var event_text := str(combat.turn_events[combat.turn_events.size() - 1].get("text", ""))
	if event_text == "":
		return ""
	return "提示：%s" % event_text

func _compact_boss_label(boss_name: String) -> String:
	match boss_name:
		"Important Announcement":
			return "Important\nAnnounce."
		"YouTube-kun Core":
			return "YouTube\nCore"
		"巨大 SSRB Camouflage":
			return "巨大 SSRB\nCamou."
		"巨大 SSRB White":
			return "巨大 SSRB\nWhite"
		"巨大 SSRB Gray":
			return "巨大 SSRB\nGray"
	if boss_name.length() <= 10:
		return boss_name
	var words := boss_name.split(" ", false)
	if words.size() >= 2:
		var lines: Array[String] = []
		var current := ""
		for word in words:
			var candidate := str(word) if current == "" else "%s %s" % [current, str(word)]
			if candidate.length() > 10:
				lines.append(current)
				current = str(word)
			else:
				current = candidate
		if current != "":
			lines.append(current)
		return "\n".join(lines)
	return boss_name.substr(0, 10)

func _node_color(type: String) -> Color:
	match type:
		"battle":
			return Color(0.50, 0.22, 0.20, 0.94)
		"elite":
			return Color(0.58, 0.26, 0.08, 0.96)
		"chest":
			return Color(0.58, 0.46, 0.16, 0.94)
		"shop":
			return Color(0.18, 0.42, 0.32, 0.94)
		"event":
			return Color(0.30, 0.26, 0.56, 0.94)
		"campfire":
			return Color(0.54, 0.30, 0.14, 0.94)
		"boss":
			return Color(0.58, 0.06, 0.08, 0.98)
	return Color(0.20, 0.24, 0.34, 0.92)

func _node_icon(type: String) -> String:
	match type:
		"start":
			return ">"
		"battle":
			return "!"
		"elite":
			return "E"
		"chest":
			return "$"
		"shop":
			return "S"
		"event":
			return "?"
		"campfire":
			return "+"
		"boss":
			return "B"
	return "?"

func _clear_screen() -> void:
	combat_hand_buttons.clear()
	for child in screen_host.get_children():
		child.queue_free()

func _fit_screen_host() -> void:
	var viewport_size := get_viewport_rect().size
	var scale_factor: float = min(viewport_size.x / BASE_SIZE.x, viewport_size.y / BASE_SIZE.y)
	screen_host.set_anchors_preset(Control.PRESET_TOP_LEFT)
	screen_host.size = BASE_SIZE
	screen_host.scale = Vector2(scale_factor, scale_factor)
	screen_host.position = (viewport_size - BASE_SIZE * scale_factor) / 2.0

func _add_title(text: String) -> void:
	_add_label(text, Vector2(0, 44), Vector2(960, 48), 34, HORIZONTAL_ALIGNMENT_CENTER)

func _add_subtitle(text: String) -> void:
	_add_label(text, Vector2(0, 96), Vector2(960, 32), 17, HORIZONTAL_ALIGNMENT_CENTER, Color(0.74, 0.79, 0.88))

func _add_label(text: String, ui_position: Vector2, ui_size: Vector2, font_size: int, alignment: HorizontalAlignment, color := Color.WHITE) -> Label:
	var label := Label.new()
	label.text = text
	label.position = ui_position
	label.size = ui_size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.72))
	label.add_theme_constant_override("outline_size", 2)
	screen_host.add_child(label)
	return label

func _add_button(text: String, anchor: Vector2, ui_size: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.size = ui_size
	button.position = Vector2(BASE_SIZE.x * anchor.x - ui_size.x / 2.0, BASE_SIZE.y * anchor.y - ui_size.y / 2.0)
	button.pressed.connect(callback)
	screen_host.add_child(button)
	return button

func _add_card_button(card: Dictionary, ui_position: Vector2, ui_size: Vector2, callback: Callable, prefix := "", hover_enabled := false) -> Button:
	return _add_card_button_to(screen_host, card, ui_position, ui_size, callback, prefix, hover_enabled)

func _shop_card_display(card: Dictionary, badge_text: String) -> Dictionary:
	var display := card.duplicate(true)
	display["badge_text"] = badge_text
	display["shop_mode"] = true
	return display

func _add_card_button_to(parent: Control, card: Dictionary, ui_position: Vector2, ui_size: Vector2, callback: Callable, prefix := "", hover_enabled := false) -> Button:
	var button := combat_card_view.create_button(parent, card, ui_position, ui_size, callback, prefix, hover_enabled)
	button.mouse_entered.connect(func() -> void:
		_set_card_hovered(button, true)
	)
	button.mouse_exited.connect(func() -> void:
		_set_card_hovered(button, false)
	)
	return button

func _render_card_button(button: Button, card: Dictionary, ui_size: Vector2, prefix := "") -> void:
	combat_card_view.render_button(button, card, ui_size, prefix)

func _configure_combat_hand_card(button: Button, index: int, hand_size: int) -> void:
	combat_hand_view.configure_card(button, index, hand_size)

func _set_card_hovered(button: Button, hovered: bool) -> void:
	combat_hand_view.set_card_hovered(button, hovered)

func _add_background_image(asset_path: String) -> void:
	if not ResourceLoader.exists(asset_path):
		return
	var texture := load(asset_path) as Texture2D
	if texture == null:
		return
	var background := TextureRect.new()
	background.texture = texture
	background.position = Vector2.ZERO
	background.size = BASE_SIZE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.modulate = Color(0.72, 0.78, 0.86, 1.0)
	screen_host.add_child(background)

func _add_panel(ui_position: Vector2, ui_size: Vector2, color: Color) -> ColorRect:
	return _add_panel_to(screen_host, ui_position, ui_size, color)

func _add_panel_to(parent: Control, ui_position: Vector2, ui_size: Vector2, color: Color) -> ColorRect:
	var panel := ColorRect.new()
	panel.position = ui_position
	panel.size = ui_size
	panel.color = color
	parent.add_child(panel)
	return panel

func _add_sprite_sheet(asset_path: String, anchor: Vector2, ui_size: Vector2) -> AnimatedSprite2D:
	var texture := load(asset_path) as Texture2D
	var sprite := AnimatedSprite2D.new()
	screen_host.add_child(sprite)
	if texture == null:
		return sprite

	var grid := _sprite_sheet_grid(texture)
	var cols := grid.x
	var rows := grid.y
	var frame_size := Vector2i(texture.get_width() / cols, texture.get_height() / rows)
	var frames := SpriteFrames.new()
	frames.set_animation_loop("default", true)
	frames.set_animation_speed("default", 6.0)

	for row in range(rows):
		for col in range(cols):
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(
				Vector2(col * frame_size.x, row * frame_size.y),
				Vector2(frame_size.x, frame_size.y)
			)
			frames.add_frame("default", atlas)

	sprite.sprite_frames = frames
	sprite.animation = "default"
	sprite.position = Vector2(BASE_SIZE.x * anchor.x, BASE_SIZE.y * anchor.y)
	var scale_factor: float = min(ui_size.x / float(frame_size.x), ui_size.y / float(frame_size.y))
	sprite.scale = Vector2(scale_factor, scale_factor)
	sprite.play()
	return sprite

func _sprite_sheet_grid(texture: Texture2D) -> Vector2i:
	var width := texture.get_width()
	var height := texture.get_height()
	if width == height:
		if width <= DEFAULT_SPRITE_CELL_SIZE * 2:
			return LEGACY_ANIMATION_GRID
		return DEFAULT_ANIMATION_GRID
	return LEGACY_ANIMATION_GRID
