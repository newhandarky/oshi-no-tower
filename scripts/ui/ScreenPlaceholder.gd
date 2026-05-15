extends Control

@export var screen_title: String = ""

func _ready() -> void:
	var label := Label.new()
	label.text = screen_title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	label.offset_top = 24
	label.offset_bottom = 68
	add_child(label)
