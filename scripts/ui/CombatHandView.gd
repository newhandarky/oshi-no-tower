extends RefCounted

const DEFAULT_CARD_SIZE := Vector2(108, 144)
const HOVER_LIFT_SECONDS := 0.1
const HOVER_EXPAND_SECONDS := 0.3
const HOVER_SHRINK_SECONDS := 0.3
const DISCARD_SECONDS := 0.34
const DRAW_SECONDS := 0.36
const PLAY_LIFT_SECONDS := 0.08
const PLAY_EXIT_SECONDS := 0.22
const PLAY_SECONDS := PLAY_LIFT_SECONDS + PLAY_EXIT_SECONDS
const CARD_STAGGER_SECONDS := 0.045

var screen_size := Vector2(960, 540)
var card_view = null

func _init(card_view_instance = null, screen_size_value := Vector2(960, 540)) -> void:
	card_view = card_view_instance
	screen_size = screen_size_value

func add_hand(parent: Control, hand_cards: Array, play_card_callback: Callable) -> Array[Button]:
	var buttons: Array[Button] = []
	for index in range(hand_cards.size()):
		var card: Dictionary = hand_cards[index]
		var card_index := index
		var button: Button = card_view.create_button(parent, card, card_position(index, hand_cards.size(), DEFAULT_CARD_SIZE), DEFAULT_CARD_SIZE, func() -> void:
			play_card_callback.call(card_index)
		, "", true)
		configure_card(button, index, hand_cards.size())
		button.mouse_entered.connect(func() -> void:
			set_card_hovered(button, true)
		)
		button.mouse_exited.connect(func() -> void:
			set_card_hovered(button, false)
		)
		buttons.append(button)
	return buttons

func card_position(index: int, hand_size: int, card_size := DEFAULT_CARD_SIZE) -> Vector2:
	var center := float(hand_size - 1) / 2.0
	var offset := float(index) - center
	var x: float = screen_size.x / 2.0 - card_size.x / 2.0 + offset * 105.0
	var y: float = 406.0 + abs(offset) * 12.0
	return Vector2(x, y)

func configure_card(button: Button, index: int, hand_size: int) -> void:
	var center := float(hand_size - 1) / 2.0
	var offset := float(index) - center
	var rotation := offset * 6.0
	button.rotation_degrees = rotation
	button.z_index = 20 + index
	button.set_meta("base_position", button.position)
	button.set_meta("base_rotation", rotation)
	button.set_meta("base_z_index", button.z_index)
	button.set_meta("base_mouse_filter", button.mouse_filter)
	button.set_meta("hand_index", index)

func set_card_hovered(button: Button, hovered: bool) -> void:
	if not bool(button.get_meta("hover_enabled", false)):
		return
	var card: Dictionary = button.get_meta("card_data", {})
	var prefix := str(button.get_meta("card_prefix", ""))
	var base_size: Vector2 = button.get_meta("base_size", button.size)
	_kill_hover_tween(button)
	if hovered:
		var hover_size := base_size * 1.65
		var base_position: Vector2 = button.get_meta("base_position", button.position)
		var base_rotation := float(button.get_meta("base_rotation", button.rotation_degrees))
		_set_sibling_cards_hover_locked(button, true)
		button.set_meta("hover_expand_duration", HOVER_EXPAND_SECONDS)
		button.set_meta("hover_lift_duration", HOVER_LIFT_SECONDS)
		button.set_meta("hover_target", true)
		_animate_hover_in(button, card, hover_size, base_position, base_rotation, prefix)
		return
	_set_sibling_cards_hover_locked(button, false)
	button.set_meta("hover_shrink_duration", HOVER_SHRINK_SECONDS)
	button.set_meta("hover_target", false)
	_animate_card_to(button, card, base_size, button.get_meta("base_position", button.position), float(button.get_meta("base_rotation", button.rotation_degrees)), 1200, HOVER_SHRINK_SECONDS, prefix, false)

func animate_cards_to_discard(parent: Control, buttons: Array[Button]) -> Tween:
	if buttons.is_empty() or parent == null:
		return null
	_clear_hand_hover_lock(parent)
	var tween := parent.create_tween()
	tween.set_parallel(true)
	for index in range(buttons.size()):
		var button := buttons[index]
		if button == null or not is_instance_valid(button):
			continue
		_kill_hover_tween(button)
		button.disabled = true
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.z_index = 900 + index
		var target_position := Vector2(screen_size.x + button.size.x + 36.0 + index * 14.0, button.position.y + 28.0)
		tween.tween_property(button, "position", target_position, DISCARD_SECONDS).set_delay(index * CARD_STAGGER_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(button, "rotation_degrees", 18.0, DISCARD_SECONDS).set_delay(index * CARD_STAGGER_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(button, "modulate", Color(1, 1, 1, 0), DISCARD_SECONDS).set_delay(index * CARD_STAGGER_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	return tween

func animate_played_card_to_right(parent: Control, button: Button, hand_index: int = 0) -> Tween:
	if button == null or not is_instance_valid(button) or parent == null:
		return null
	_clear_hand_hover_lock(parent)
	var tween := parent.create_tween()
	tween.set_parallel(true)
	_kill_hover_tween(button)
	button.disabled = true
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.z_index = 1000 + hand_index
	button.set_meta("play_animation_to_right", true)
	button.set_meta("play_animation_duration", PLAY_SECONDS)
	var start_position := button.position
	var lift_position := Vector2(start_position.x + 8.0, start_position.y - 24.0)
	var target_position := Vector2(screen_size.x + button.size.x + 42.0, start_position.y - 18.0)
	button.set_meta("play_animation_lift_position", lift_position)
	button.set_meta("play_animation_target_position", target_position)
	tween.tween_property(button, "position", lift_position, PLAY_LIFT_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "rotation_degrees", -5.0, PLAY_LIFT_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "position", target_position, PLAY_EXIT_SECONDS).set_delay(PLAY_LIFT_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(button, "rotation_degrees", 22.0, PLAY_EXIT_SECONDS).set_delay(PLAY_LIFT_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(button, "modulate", Color(1, 1, 1, 0), PLAY_EXIT_SECONDS).set_delay(PLAY_LIFT_SECONDS * 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	return tween

func animate_draw_from_left(parent: Control, buttons: Array[Button], start_index: int = 0) -> Tween:
	if buttons.is_empty() or parent == null:
		return null
	_clear_hand_hover_lock(parent)
	start_index = clamp(start_index, 0, buttons.size())
	if start_index >= buttons.size():
		return null
	var tween := parent.create_tween()
	tween.set_parallel(true)
	var animated_index := 0
	for index in range(start_index, buttons.size()):
		var button := buttons[index]
		if button == null or not is_instance_valid(button):
			continue
		_kill_hover_tween(button)
		var base_position: Vector2 = button.get_meta("base_position", button.position)
		var base_rotation := float(button.get_meta("base_rotation", button.rotation_degrees))
		button.position = Vector2(-button.size.x - 48.0 - animated_index * 18.0, base_position.y)
		button.rotation_degrees = -8.0
		button.modulate = Color(1, 1, 1, 0)
		button.z_index = int(button.get_meta("base_z_index", button.z_index))
		button.set_meta("draw_animation_from_left", true)
		tween.tween_property(button, "position", base_position, DRAW_SECONDS).set_delay(animated_index * CARD_STAGGER_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "rotation_degrees", base_rotation, DRAW_SECONDS).set_delay(animated_index * CARD_STAGGER_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(button, "modulate", Color.WHITE, DRAW_SECONDS).set_delay(animated_index * CARD_STAGGER_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		animated_index += 1
	return tween

func _animate_hover_in(button: Button, card: Dictionary, target_size: Vector2, base_position: Vector2, base_rotation: float, prefix: String) -> void:
	var current_size := button.size
	var current_position := button.position
	var lift_position := Vector2(base_position.x, base_position.y - 24.0)
	var target_position := Vector2(base_position.x, screen_size.y - target_size.y)
	button.set_meta("hover_lift_position", lift_position)
	button.set_meta("hover_target_position", target_position)
	button.scale = Vector2.ONE
	button.z_index = 1200
	card_view.render_button(button, card, target_size, prefix)
	button.size = current_size
	button.pivot_offset = Vector2(current_size.x / 2.0, current_size.y)
	button.position = current_position
	button.rotation_degrees = base_rotation
	var tween := button.create_tween()
	button.set_meta("hover_tween", tween)
	tween.set_parallel(true)
	tween.tween_property(button, "position", lift_position, HOVER_LIFT_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "size", target_size, HOVER_EXPAND_SECONDS - HOVER_LIFT_SECONDS).set_delay(HOVER_LIFT_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "position", target_position, HOVER_EXPAND_SECONDS - HOVER_LIFT_SECONDS).set_delay(HOVER_LIFT_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func() -> void:
		if not is_instance_valid(button):
			return
		button.size = target_size
		button.pivot_offset = Vector2(target_size.x / 2.0, target_size.y)
		button.position = target_position
		button.rotation_degrees = base_rotation
	)

func _animate_card_to(button: Button, card: Dictionary, target_size: Vector2, target_position: Vector2, target_rotation: float, target_z: int, duration: float, prefix: String, hovered: bool) -> void:
	var current_size := button.size
	var current_position := button.position
	var current_rotation := button.rotation_degrees
	button.scale = Vector2.ONE
	button.z_index = target_z
	card_view.render_button(button, card, target_size, prefix)
	button.size = current_size
	button.pivot_offset = Vector2(current_size.x / 2.0, current_size.y)
	button.position = current_position
	button.rotation_degrees = current_rotation
	var tween := button.create_tween()
	button.set_meta("hover_tween", tween)
	tween.set_parallel(true)
	tween.tween_property(button, "size", target_size, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT if hovered else Tween.EASE_IN_OUT)
	tween.tween_property(button, "position", target_position, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT if hovered else Tween.EASE_IN_OUT)
	tween.tween_property(button, "rotation_degrees", target_rotation, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT if hovered else Tween.EASE_IN_OUT)
	tween.finished.connect(func() -> void:
		if not is_instance_valid(button):
			return
		button.size = target_size
		button.pivot_offset = Vector2(target_size.x / 2.0, target_size.y)
		button.position = target_position
		button.rotation_degrees = target_rotation
		if not bool(button.get_meta("hover_target", false)):
			button.z_index = int(button.get_meta("base_z_index", button.z_index))
			card_view.render_button(button, card, target_size, prefix)
	)

func _kill_hover_tween(button: Button) -> void:
	if not button.has_meta("hover_tween"):
		return
	var tween = button.get_meta("hover_tween")
	if tween != null and tween is Tween and is_instance_valid(tween):
		(tween as Tween).kill()

func _set_sibling_cards_hover_locked(active_button: Button, locked: bool) -> void:
	var parent := active_button.get_parent()
	if parent == null:
		return
	for child in parent.get_children():
		if child == active_button or not (child is Button):
			continue
		var button := child as Button
		if not bool(button.get_meta("hover_enabled", false)):
			continue
		button.modulate = Color.WHITE
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE if locked else int(button.get_meta("base_mouse_filter", Control.MOUSE_FILTER_STOP))

func _clear_hand_hover_lock(parent: Control) -> void:
	for child in parent.get_children():
		if not (child is Button):
			continue
		var button := child as Button
		if not bool(button.get_meta("hover_enabled", false)):
			continue
		button.modulate = Color.WHITE
		button.mouse_filter = int(button.get_meta("base_mouse_filter", Control.MOUSE_FILTER_STOP))
