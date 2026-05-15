class_name RandomMapGenerator
extends RefCounted

const BOSS_FLOOR := 16
const CHAPTER_1_ID := "mvp_single_act_tower"
const CHAPTER_2_ID := "chapter_2_algorithm_depths"
const FLOOR_ROOM_TYPES := [
	["battle", "battle"],
	["battle", "event"],
	["battle", "event"],
	["battle", "event"],
	["shop", "event"],
	["battle", "chest"],
	["campfire", "elite"],
	["battle", "event"],
	["battle", "battle"],
	["shop", "event"],
	["elite", "battle"],
	["campfire", "battle"],
	["battle", "event"],
	["shop", "campfire"],
	["battle", "event"]
]

func generate_map(database, seed: int, chapter_id: String = CHAPTER_1_ID) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var nodes: Array[Dictionary] = []
	nodes.append({
		"id": "start",
		"type": "start",
		"label": "開始",
		"floor": 0,
		"lane": 0,
		"outgoing": []
	})
	for floor_index in range(FLOOR_ROOM_TYPES.size()):
		var floor := floor_index + 1
		var room_types: Array = FLOOR_ROOM_TYPES[floor_index].duplicate()
		if rng.randi_range(0, 1) == 1:
			room_types.reverse()
		for lane in range(room_types.size()):
			nodes.append(_build_node(database, str(room_types[lane]), floor, lane, rng, chapter_id))
	var boss_node := _copy_boss_node(database, rng, chapter_id)
	boss_node["floor"] = BOSS_FLOOR
	boss_node["lane"] = 0
	boss_node["outgoing"] = []
	nodes.append(boss_node)
	_connect_layers(nodes)
	return {
		"seed": seed,
		"chapter_id": chapter_id,
		"chapter_title": _chapter_title(chapter_id),
		"start_node_id": "start",
		"boss_node_id": "boss",
		"boss_floor": BOSS_FLOOR,
		"nodes": nodes
	}

func _build_node(database, node_type: String, floor: int, lane: int, rng: RandomNumberGenerator, chapter_id: String) -> Dictionary:
	var node: Dictionary = {
		"id": "f%02d_l%d_%s" % [floor, lane, node_type],
		"type": node_type,
		"label": _label_for_type(node_type),
		"floor": floor,
		"lane": lane,
		"outgoing": []
	}
	match node_type:
		"battle":
			node["enemy_id"] = _pick_normal_enemy_id(floor, rng, chapter_id)
		"elite":
			node["enemy_id"] = _pick_elite_enemy_id(database, rng, floor, chapter_id)
		"event":
			var event_node := _pick_event_node(database, rng, chapter_id)
			node["event_id"] = str(event_node.get("event_id", event_node.get("id", "")))
			node["title"] = str(event_node.get("title", ""))
			node["description"] = str(event_node.get("description", ""))
			node["body"] = str(event_node.get("body", ""))
	return node

func _connect_layers(nodes: Array[Dictionary]) -> void:
	var nodes_by_floor := {}
	for node in nodes:
		var floor := int(node["floor"])
		if not nodes_by_floor.has(floor):
			nodes_by_floor[floor] = []
		nodes_by_floor[floor].append(node)
	for node in nodes:
		var floor := int(node["floor"])
		if floor >= BOSS_FLOOR:
			continue
		var next_floor := BOSS_FLOOR if floor == BOSS_FLOOR - 1 else floor + 1
		var outgoing: Array[String] = []
		for next_node in nodes_by_floor.get(next_floor, []):
			outgoing.append(str(next_node["id"]))
		node["outgoing"] = outgoing

func _copy_boss_node(database, rng: RandomNumberGenerator, chapter_id: String) -> Dictionary:
	if chapter_id == CHAPTER_2_ID:
		var boss_node := {
			"id": "boss",
			"type": "boss",
			"label": "Boss",
			"boss_enemy_ids": ["algorithm-core", "archive-phantom", "notification-storm"]
		}
		var boss_ids: Array = boss_node["boss_enemy_ids"]
		boss_node["selected_boss_enemy_id"] = str(boss_ids[rng.randi_range(0, boss_ids.size() - 1)])
		return boss_node
	for node in database.map_nodes:
		if str(node.get("type", "")) == "boss":
			var boss_node: Dictionary = node.duplicate(true)
			var boss_ids: Array = boss_node.get("boss_enemy_ids", [])
			if not boss_ids.is_empty():
				boss_node["selected_boss_enemy_id"] = str(boss_ids[rng.randi_range(0, boss_ids.size() - 1)])
			return boss_node
	return { "id": "boss", "type": "boss", "label": "Boss", "boss_enemy_ids": [] }

func _pick_normal_enemy_id(floor: int, rng: RandomNumberGenerator, chapter_id: String = CHAPTER_1_ID) -> String:
	var enemy_ids: Array[String] = []
	if chapter_id == CHAPTER_2_ID:
		if floor <= 3:
			enemy_ids = ["recommendation-watcher", "buffering-wall"]
		elif floor <= 9:
			enemy_ids = ["comment-flood", "bitrate-phantom", "clip-mirror"]
		else:
			enemy_ids = ["archive-sentinel", "bitrate-phantom", "comment-flood"]
		return str(enemy_ids[rng.randi_range(0, enemy_ids.size() - 1)])
	if floor <= 3:
		enemy_ids = ["ssrb-gray", "ssrb-camouflage", "ssrb-guard-tutor", "desk-kun"]
	elif floor <= 6:
		enemy_ids = ["ssrb-camouflage", "ssrb-white", "ssrb-gold", "ssrb-striker-intent", "desk-kun"]
	elif floor <= 9:
		enemy_ids = ["ssrb-white", "ssrb-gold", "ssrb-glitch", "ssrb-striker-intent", "youtube-kun", "korone-suki"]
	elif floor <= 12:
		enemy_ids = ["ssrb-white", "ssrb-glitch", "ssrb-debuff-check", "youtube-kun", "korone-suki", "announcement-shadow"]
	else:
		enemy_ids = ["announcement-shadow", "ssrb-debuff-check"]
	return str(enemy_ids[rng.randi_range(0, enemy_ids.size() - 1)])

func _pick_elite_enemy_id(database, rng: RandomNumberGenerator, floor: int = 0, chapter_id: String = CHAPTER_1_ID) -> String:
	var elite_ids: Array[String] = []
	if chapter_id == CHAPTER_2_ID:
		elite_ids = ["algorithm-auditor", "notification-storm-elite", "archive-hydra"]
		var chapter_2_valid_ids: Array[String] = []
		for chapter_2_enemy_id in elite_ids:
			if not database.get_enemy(chapter_2_enemy_id).is_empty():
				chapter_2_valid_ids.append(chapter_2_enemy_id)
		return str(chapter_2_valid_ids[rng.randi_range(0, chapter_2_valid_ids.size() - 1)])
	if floor <= 4:
		elite_ids = ["ssrb-duo-gray-camouflage", "ssrb-duo-gray-white"]
	elif floor <= 7:
		elite_ids = ["ssrb-duo-gray-white", "ssrb-duo-camouflage-white", "kedama-elite"]
	else:
		elite_ids = ["ssrb-duo-camouflage-white", "ssrb-duo-gold-glitch", "ssrb-scaling-clock", "ak-idol-unit", "kedama-elite"]
	var valid_ids: Array[String] = []
	for enemy_id in elite_ids:
		if not database.get_enemy(enemy_id).is_empty():
			valid_ids.append(enemy_id)
	if not valid_ids.is_empty():
		return str(valid_ids[rng.randi_range(0, valid_ids.size() - 1)])
	for node in database.map_nodes:
		if str(node.get("type", "")) == "elite":
			for enemy_id in node.get("elite_enemy_ids", []):
				valid_ids.append(str(enemy_id))
	if valid_ids.is_empty():
		return ""
	return str(valid_ids[rng.randi_range(0, valid_ids.size() - 1)])

func _event_node_for_floor(database, floor: int, rng: RandomNumberGenerator) -> Dictionary:
	var preferred_event_id := ""
	match floor:
		2:
			preferred_event_id = "holostar-sponsor"
		5:
			preferred_event_id = "stream-incident-support"
		7:
			preferred_event_id = "fan-cheer-prep"
	if preferred_event_id != "":
		var event_def: Dictionary = database.get_event(preferred_event_id)
		if not event_def.is_empty():
			return event_def.duplicate(true)
	return _pick_event_node(database, rng)

func _pick_event_node(database, rng: RandomNumberGenerator, chapter_id: String = CHAPTER_1_ID) -> Dictionary:
	var event_nodes: Array[Dictionary] = []
	for event_def in database.events:
		var event_chapter_id := str(event_def.get("chapter_id", CHAPTER_1_ID))
		if event_chapter_id == chapter_id:
			event_nodes.append(event_def)
	if event_nodes.is_empty():
		return {}
	return event_nodes[rng.randi_range(0, event_nodes.size() - 1)].duplicate(true)

func _chapter_title(chapter_id: String) -> String:
	if chapter_id == CHAPTER_2_ID:
		return "演算法深層"
	return "MVP 單 Act 推塔"

func _label_for_type(node_type: String) -> String:
	match node_type:
		"battle":
			return "小怪"
		"elite":
			return "菁英"
		"event":
			return "事件"
		"chest":
			return "寶箱"
		"shop":
			return "商店"
		"campfire":
			return "篝火"
	return node_type
