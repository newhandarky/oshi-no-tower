extends RefCounted

func create_button(parent: Control, card: Dictionary, ui_position: Vector2, ui_size: Vector2, callback: Callable, prefix := "", hover_enabled := false) -> Button:
	var button := Button.new()
	button.text = ""
	button.position = ui_position
	button.size = ui_size
	button.clip_contents = true
	button.pivot_offset = Vector2(ui_size.x / 2.0, ui_size.y)
	button.modulate = Color.WHITE
	button.add_theme_stylebox_override("normal", _empty_button_style())
	button.add_theme_stylebox_override("hover", _empty_button_style())
	button.add_theme_stylebox_override("pressed", _empty_button_style())
	button.add_theme_stylebox_override("disabled", _empty_button_style())
	button.pressed.connect(callback)
	parent.add_child(button)
	button.set_meta("card_data", card.duplicate(true))
	button.set_meta("card_prefix", prefix)
	button.set_meta("hover_enabled", hover_enabled)
	button.set_meta("base_position", ui_position)
	button.set_meta("base_rotation", 0.0)
	button.set_meta("base_z_index", button.z_index)
	button.set_meta("base_size", ui_size)
	render_button(button, card, ui_size, prefix)
	return button

func render_button(button: Button, card: Dictionary, ui_size: Vector2, prefix := "") -> void:
	for child in button.get_children():
		button.remove_child(child)
		child.free()
	button.size = ui_size
	button.pivot_offset = Vector2(ui_size.x / 2.0, ui_size.y)
	var compact := ui_size.x < 130.0
	var shop_mode := bool(card.get("shop_mode", false))
	var font_scale := 1.0
	if bool(button.get_meta("hover_enabled", false)):
		var base_size: Vector2 = button.get_meta("base_size", ui_size)
		font_scale = clamp(ui_size.x / max(1.0, base_size.x), 1.0, 1.18)
	var padding := (12.0 if compact else 16.0) * font_scale
	var text_width := ui_size.x - padding * 2.0
	_add_card_panel(button, "CardFrame", Vector2.ZERO, ui_size, _card_body_color(str(card["kind"])), Color(0.10, 0.08, 0.07), max(4, int(round(4.0 * font_scale))))
	var image_y := (36.0 if compact else 48.0) * font_scale
	var image_h := ui_size.y * 0.34
	var type_y := image_y + image_h + 3.0 * font_scale
	var desc_y := type_y + (16.0 if compact else 22.0) * font_scale
	var desc_h := ui_size.y - desc_y - padding
	if shop_mode:
		padding = 12.0
		text_width = ui_size.x - padding * 2.0
		image_y = 42.0
		image_h = clamp(ui_size.y * 0.23, 26.0, 36.0)
		type_y = image_y + image_h + 2.0
		desc_y = type_y + 15.0
		desc_h = max(24.0, ui_size.y - desc_y - 8.0)
	elif bool(button.get_meta("hover_enabled", false)) and ui_size.x > 150.0:
		image_h = ui_size.y * 0.30
		type_y = image_y + image_h + 4.0 * font_scale
		desc_y = type_y + 18.0 * font_scale
		desc_h = max(ui_size.y * 0.25, ui_size.y - desc_y - padding)
	var image_position := Vector2(padding, image_y)
	var image_size := Vector2(text_width, image_h)
	var image_slot := _add_card_panel(button, "ImageSlot", image_position, image_size, _card_image_placeholder_color(str(card["kind"])), Color(0.72, 0.72, 0.66), max(2, int(round(2.0 * font_scale))))
	image_slot.clip_contents = true
	if _add_card_art_texture(image_slot, str(card.get("art_path", "")), Vector2.ZERO, image_size) == null:
		var placeholder := _add_card_label(image_slot, "ART", Vector2.ZERO, image_size, int(round((13 if compact else 18) * font_scale)), HORIZONTAL_ALIGNMENT_CENTER, TextServer.AUTOWRAP_OFF, Color(0.18, 0.16, 0.13, 0.72))
		placeholder.name = "CardArtPlaceholder"
		placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var badge_size := Vector2(24 if compact else 32, 24 if compact else 32) * font_scale
	var badge_position := Vector2(5, 5) * font_scale
	if shop_mode:
		badge_size = Vector2(44, 30)
		badge_position = Vector2(5, 5)
	_add_card_panel(button, "CostBadge", badge_position, badge_size, Color(0.78, 0.20, 0.12), Color(1.0, 0.78, 0.34), max(2, int(round(2.0 * font_scale))))
	var cost_text := str(card.get("badge_text", "%s  %d" % [prefix, int(card["cost"])] if prefix != "" else str(int(card["cost"]))))
	var cost_label_position := badge_position + Vector2(2, 1) * font_scale
	if not shop_mode:
		cost_label_position = Vector2(10, 6) * font_scale
	_add_card_label(button, cost_text, cost_label_position, badge_size - Vector2(4, 2) * font_scale, int(round((11 if shop_mode else (13 if compact else 17)) * font_scale)), HORIZONTAL_ALIGNMENT_CENTER, TextServer.AUTOWRAP_OFF, Color.WHITE)
	var name_position := Vector2(padding + 18 * font_scale, (9 if compact else 13) * font_scale)
	var name_size := Vector2(ui_size.x - padding * 2.0 - 18 * font_scale, 20 * font_scale)
	var name_font := int(round((10 if compact else 15) * font_scale))
	if shop_mode:
		name_position = Vector2(58, 14)
		name_size = Vector2(ui_size.x - 70, 22)
		name_font = 15 if ui_size.x >= 220.0 else 13
	_add_card_label(button, str(card["name"]), name_position, name_size, name_font, HORIZONTAL_ALIGNMENT_CENTER, TextServer.AUTOWRAP_OFF, Color(0.96, 0.92, 0.82))
	var type_text := str(card.get("type_label", _card_kind_label(str(card["kind"]))))
	var type_label := _add_card_label(button, type_text, Vector2(padding, type_y), Vector2(text_width, (14 if shop_mode else (15 if compact else 20)) * font_scale), int(round((8 if compact or shop_mode else 11) * font_scale)), HORIZONTAL_ALIGNMENT_CENTER, TextServer.AUTOWRAP_OFF, Color(0.16, 0.15, 0.14))
	type_label.name = "TypeLabel"
	var desc_font := int(round((9 if compact else 13) * font_scale))
	if shop_mode:
		desc_font = 9 if ui_size.y < 130.0 else 10
	var desc_label := _add_card_label(button, str(card["description"]), Vector2(padding, desc_y), Vector2(text_width, desc_h), desc_font, HORIZONTAL_ALIGNMENT_CENTER, TextServer.AUTOWRAP_WORD_SMART, Color(0.96, 0.92, 0.84))
	desc_label.name = "DescriptionLabel"

func _empty_button_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.set_content_margin_all(0)
	return style

func _add_card_panel(parent: Control, panel_name: String, ui_position: Vector2, ui_size: Vector2, bg_color: Color, border_color: Color, border_width: int) -> Panel:
	var panel := Panel.new()
	panel.name = panel_name
	panel.position = ui_position
	panel.size = ui_size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(6)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel

func _add_card_label(parent: Control, text: String, ui_position: Vector2, ui_size: Vector2, font_size: int, alignment: HorizontalAlignment, autowrap: TextServer.AutowrapMode, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = ui_position
	label.size = ui_size
	label.custom_minimum_size = Vector2.ZERO
	label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.clip_text = true
	label.autowrap_mode = autowrap
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	label.position = ui_position
	label.size = ui_size
	return label

func _add_card_art_texture(parent: Control, asset_path: String, ui_position: Vector2, ui_size: Vector2) -> TextureRect:
	if asset_path == "" or not ResourceLoader.exists(asset_path):
		return null
	var texture := load(asset_path) as Texture2D
	if texture == null:
		return null
	var art := TextureRect.new()
	art.name = "CardArtTexture"
	art.ignore_texture_size = true
	art.texture = texture
	var art_size := Vector2(max(1.0, ui_size.x * 1.25), max(1.0, ui_size.y * 1.25))
	art.position = ui_position + (ui_size - art_size) * 0.5
	art.size = art_size
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	parent.add_child(art)
	return art

func _card_body_color(kind: String) -> Color:
	match kind:
		"attack":
			return Color(0.55, 0.19, 0.14)
		"defense":
			return Color(0.18, 0.32, 0.44)
		"support":
			return Color(0.18, 0.39, 0.24)
		"mixed":
			return Color(0.34, 0.25, 0.43)
	return Color(0.28, 0.28, 0.30)

func _card_image_placeholder_color(kind: String) -> Color:
	match kind:
		"attack":
			return Color(0.82, 0.50, 0.26)
		"defense":
			return Color(0.38, 0.66, 0.74)
		"support":
			return Color(0.46, 0.68, 0.40)
		"mixed":
			return Color(0.56, 0.45, 0.68)
	return Color(0.56, 0.56, 0.56)

func _card_kind_label(kind: String) -> String:
	match kind:
		"attack":
			return "攻擊"
		"defense":
			return "技能"
		"support":
			return "能力"
		"mixed":
			return "技能"
	return "卡牌"
