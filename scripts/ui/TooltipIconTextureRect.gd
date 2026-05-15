extends TextureRect

func _make_custom_tooltip(for_text: String) -> Object:
	if for_text == "":
		return null
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.06, 0.10, 0.96)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.32, 0.42, 0.54, 0.92)
	panel.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = for_text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(280, 0)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(0.96, 0.97, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.88))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.74))
	label.add_theme_constant_override("outline_size", 2)
	panel.add_theme_constant_override("margin_left", 12)
	panel.add_theme_constant_override("margin_top", 8)
	panel.add_theme_constant_override("margin_right", 12)
	panel.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(label)
	return panel
