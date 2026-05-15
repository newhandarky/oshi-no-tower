extends RefCounted

const TooltipIconTextureRectScript := preload("res://scripts/ui/TooltipIconTextureRect.gd")

const STATUS_ICON_PATHS := {
	"strength": "res://assets/icons/status/strength.png",
	"weak": "res://assets/icons/status/weak.png",
	"vulnerable": "res://assets/icons/status/vulnerable.png",
	"regen": "res://assets/icons/status/regen.png"
}

func add_combat_status_panels(parent: Control, combat, character: Dictionary) -> void:
	add_stat_box(parent, Vector2(36, 62), Vector2(92, 32), "HP", "%d/%d" % [combat.player_hp, combat.player_max_hp], Color(0.94, 0.62, 0.62))
	add_stat_box(parent, Vector2(136, 62), Vector2(82, 32), "格擋", str(combat.player_block), Color(0.64, 0.82, 1.0))
	add_stat_box(parent, Vector2(226, 62), Vector2(82, 32), "能量", "%d/3" % combat.player_energy, Color(1.0, 0.88, 0.44))
	_add_label(parent, "被動：%s" % str(character.get("passive", {}).get("name", "無")), Vector2(36, 102), Vector2(290, 24), 13, HORIZONTAL_ALIGNMENT_LEFT, Color(0.82, 0.90, 1.0))

	add_stat_box(parent, Vector2(634, 62), Vector2(100, 32), "HP", "%d/%d" % [combat.enemy_hp, combat.enemy_max_hp], Color(0.94, 0.62, 0.62))
	add_stat_box(parent, Vector2(742, 62), Vector2(82, 32), "格擋", str(combat.enemy_block), Color(0.64, 0.82, 1.0))
	_add_label(parent, "意圖", Vector2(646, 108), Vector2(48, 24), 14, HORIZONTAL_ALIGNMENT_LEFT, Color(1.0, 0.82, 0.46))
	if _add_intent_icon_texture(parent, str(combat.current_intent.get("icon_path", "")), Vector2(696, 108), Vector2(24, 24), _intent_tooltip(combat.current_intent)) != null:
		_add_label(parent, intent_icon_text(combat.current_intent), Vector2(724, 108), Vector2(188, 24), 14, HORIZONTAL_ALIGNMENT_LEFT, Color(1.0, 0.91, 0.72))
	else:
		_add_label(parent, intent_icon_text(combat.current_intent), Vector2(696, 108), Vector2(216, 24), 14, HORIZONTAL_ALIGNMENT_LEFT, Color(1.0, 0.91, 0.72))

func add_status_labels(parent: Control, player_status_text: String, enemy_status_text: String, player_statuses: Dictionary = {}, enemy_statuses: Dictionary = {}) -> void:
	if player_statuses.is_empty():
		_add_label(parent, player_status_text, Vector2(170, 342), Vector2(190, 24), 13, HORIZONTAL_ALIGNMENT_CENTER, Color(0.78, 1.0, 0.78))
	else:
		_add_status_icons(parent, player_statuses, "Player", Vector2(142, 342), Color(0.78, 1.0, 0.78))
	if enemy_statuses.is_empty():
		_add_label(parent, enemy_status_text, Vector2(630, 342), Vector2(220, 24), 13, HORIZONTAL_ALIGNMENT_CENTER, Color(1.0, 0.78, 0.78))
	else:
		_add_status_icons(parent, enemy_statuses, "Enemy", Vector2(612, 342), Color(1.0, 0.78, 0.78))

func add_stat_box(parent: Control, ui_position: Vector2, ui_size: Vector2, title: String, value: String, color: Color) -> Label:
	var label := _add_label(parent, "%s %s" % [title, value], ui_position + Vector2(7, 0), Vector2(ui_size.x - 14, ui_size.y), 15, HORIZONTAL_ALIGNMENT_LEFT, color)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = true
	return label

func intent_icon_text(intent: Dictionary) -> String:
	var action_type := str(intent.get("type", ""))
	var icon := "?"
	match action_type:
		"attack":
			icon = "⚔"
		"block":
			icon = "▣"
		"attack_block":
			icon = "⚔▣"
		"buff":
			icon = "↑"
		"debuff":
			icon = "↓"
	var values: Array[String] = []
	if int(intent.get("damage", 0)) > 0:
		values.append(str(int(intent.get("damage", 0))))
	if int(intent.get("block", 0)) > 0:
		values.append(str(int(intent.get("block", 0))))
	var value_text := " / ".join(values)
	if value_text != "":
		return "%s %s  %s" % [icon, value_text, str(intent.get("description", ""))]
	return "%s %s" % [icon, str(intent.get("description", ""))]

func _add_label(parent: Control, text: String, ui_position: Vector2, ui_size: Vector2, font_size: int, alignment: HorizontalAlignment, color := Color.WHITE) -> Label:
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
	parent.add_child(label)
	return label

func _add_intent_icon_texture(parent: Control, asset_path: String, ui_position: Vector2, ui_size: Vector2, tooltip := "") -> TextureRect:
	if asset_path == "" or not ResourceLoader.exists(asset_path):
		return null
	var texture := load(asset_path) as Texture2D
	if texture == null:
		return null
	var icon := TooltipIconTextureRectScript.new()
	icon.name = "IntentIconTexture"
	icon.ignore_texture_size = true
	icon.texture = texture
	var icon_size := Vector2(max(1.0, ui_size.x * 0.9), max(1.0, ui_size.y * 0.9))
	icon.position = ui_position + (ui_size - icon_size) * 0.5
	icon.size = icon_size
	icon.mouse_filter = Control.MOUSE_FILTER_PASS
	icon.tooltip_text = tooltip
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	parent.add_child(icon)
	icon.name = "IntentIconTexture"
	return icon

func _add_status_icons(parent: Control, statuses: Dictionary, actor_prefix: String, ui_position: Vector2, color: Color) -> void:
	var offset_x := 0.0
	for status_id in statuses.keys():
		var status: Dictionary = statuses[status_id]
		var id := str(status.get("id", status_id))
		var icon := _add_status_icon_texture(parent, id, _status_icon_path(status), ui_position + Vector2(offset_x, 2), Vector2(20, 20), actor_prefix, _status_tooltip(id, status))
		var label_position := ui_position + Vector2(offset_x + (26.0 if icon != null else 0.0), 0.0)
		var label_width := 92.0 if icon != null else 118.0
		_add_label(parent, _status_display_text(id, status), label_position, Vector2(label_width, 24), 12, HORIZONTAL_ALIGNMENT_LEFT, color)
		offset_x += 128.0

func _add_status_icon_texture(parent: Control, status_id: String, asset_path: String, ui_position: Vector2, ui_size: Vector2, actor_prefix: String, tooltip := "") -> TextureRect:
	if asset_path == "" or not ResourceLoader.exists(asset_path):
		return null
	var texture := load(asset_path) as Texture2D
	if texture == null:
		return null
	var icon := TooltipIconTextureRectScript.new()
	icon.name = "%sStatusIconTexture_%s" % [actor_prefix, status_id]
	icon.ignore_texture_size = true
	icon.texture = texture
	var icon_size := Vector2(max(1.0, ui_size.x * 0.9), max(1.0, ui_size.y * 0.9))
	icon.position = ui_position + (ui_size - icon_size) * 0.5
	icon.size = icon_size
	icon.mouse_filter = Control.MOUSE_FILTER_PASS
	icon.tooltip_text = tooltip
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	parent.add_child(icon)
	icon.name = "%sStatusIconTexture_%s" % [actor_prefix, status_id]
	return icon

func _status_icon_path(status: Dictionary) -> String:
	if status.has("icon_path"):
		return str(status.get("icon_path", ""))
	return str(STATUS_ICON_PATHS.get(str(status.get("id", "")), ""))

func _status_display_text(status_id: String, status: Dictionary) -> String:
	return "%s %d/%d" % [_status_label(status_id), int(status.get("value", 0)), int(status.get("duration", 0))]

func _intent_tooltip(intent: Dictionary) -> String:
	var description := str(intent.get("description", ""))
	if description == "":
		return intent_icon_text(intent)
	return description

func _status_tooltip(status_id: String, status: Dictionary) -> String:
	var label := _status_label(status_id)
	var value := int(status.get("value", 0))
	var duration := int(status.get("duration", 0))
	match status_id:
		"strength":
			return "%s：造成傷害增加 %d。" % [label, value]
		"weak":
			return "%s：造成傷害降低，剩餘 %d 回合。" % [label, duration]
		"vulnerable":
			return "%s：受到傷害增加，剩餘 %d 回合。" % [label, duration]
		"regen":
			return "%s：回合開始回復 %d HP，剩餘 %d 回合。" % [label, value, duration]
	return "%s %d/%d" % [label, value, duration]

func _status_label(status_id: String) -> String:
	match status_id:
		"strength":
			return "力量"
		"weak":
			return "虛弱"
		"vulnerable":
			return "易傷"
		"regen":
			return "回復"
		"marker":
			return "標記"
	return status_id
