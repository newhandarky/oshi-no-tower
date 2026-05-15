class_name RunState
extends RefCounted

var character_id: String = ""
var current_chapter_id: String = "mvp_single_act_tower"
var current_node_index: int = 0
var hp: int = 0
var max_hp: int = 0
var gold: int = 0
var deck_ids: Array[String] = []
var relic_ids: Array[String] = []
var upgraded_card_ids: Array[String] = []
var active_map: Dictionary = {}
var map_seed: int = 0
var current_node_id: String = ""
var available_node_ids: Array[String] = []
var visited_node_ids: Array[String] = []
var shop_inventories: Dictionary = {}

func start_run(database, selected_character_id: String) -> void:
	var character = database.get_character(selected_character_id)
	character_id = character["id"]
	current_chapter_id = "mvp_single_act_tower"
	current_node_index = 0
	max_hp = character["max_hp"]
	hp = max_hp
	gold = character["starting_gold"]
	deck_ids.clear()
	relic_ids.clear()
	upgraded_card_ids.clear()
	active_map.clear()
	map_seed = 0
	current_node_id = ""
	available_node_ids.clear()
	visited_node_ids.clear()
	shop_inventories.clear()
	for card_id in character["starting_deck"]:
		deck_ids.append(str(card_id))

func start_random_run(database, selected_character_id: String, seed: int = 0, chapter_id: String = "mvp_single_act_tower") -> void:
	start_run(database, selected_character_id)
	current_chapter_id = chapter_id
	if seed == 0:
		seed = int(Time.get_unix_time_from_system())
	map_seed = seed
	active_map = database.generate_random_map(seed, current_chapter_id)
	current_node_id = str(active_map.get("start_node_id", "start"))
	available_node_ids.clear()
	visited_node_ids.clear()
	var start_node := get_node_by_id(current_node_id)
	for outgoing_id in start_node.get("outgoing", []):
		available_node_ids.append(str(outgoing_id))

func start_next_chapter(database, chapter_id: String, seed: int = 0) -> void:
	current_chapter_id = chapter_id
	if seed == 0:
		seed = int(Time.get_unix_time_from_system())
	map_seed = seed
	active_map = database.generate_random_map(seed, current_chapter_id)
	current_node_id = str(active_map.get("start_node_id", "start"))
	current_node_index = 0
	available_node_ids.clear()
	visited_node_ids.clear()
	shop_inventories.clear()
	var start_node := get_node_by_id(current_node_id)
	for outgoing_id in start_node.get("outgoing", []):
		available_node_ids.append(str(outgoing_id))

func start_subaru_run(database) -> void:
	start_run(database, "subaru")

func has_active_map() -> bool:
	return not active_map.is_empty() and active_map.has("nodes")

func get_node_by_id(node_id: String) -> Dictionary:
	for node in active_map.get("nodes", []):
		if str(node.get("id", "")) == node_id:
			return node
	return {}

func get_current_node(database) -> Dictionary:
	if has_active_map() and current_node_id != "":
		return get_node_by_id(current_node_id)
	if current_node_index >= 0 and current_node_index < database.map_nodes.size():
		return database.map_nodes[current_node_index]
	return {}

func can_enter_node(node_id: String) -> bool:
	if not has_active_map():
		return false
	return available_node_ids.has(node_id)

func set_current_node(node_id: String) -> bool:
	if not can_enter_node(node_id):
		return false
	current_node_id = node_id
	return true

func complete_current_node(database) -> void:
	if has_active_map() and current_node_id != "":
		if not visited_node_ids.has(current_node_id):
			visited_node_ids.append(current_node_id)
		available_node_ids.clear()
		var current_node := get_node_by_id(current_node_id)
		for outgoing_id in current_node.get("outgoing", []):
			available_node_ids.append(str(outgoing_id))
		return
	current_node_index += 1

func is_node_visited(node_id: String) -> bool:
	return visited_node_ids.has(node_id)
