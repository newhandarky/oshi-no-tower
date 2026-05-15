class_name CombatState
extends RefCounted

var player_hp: int = 0
var player_max_hp: int = 0
var player_block: int = 0
var player_energy: int = 0
var enemy: Dictionary = {}
var enemy_hp: int = 0
var enemy_max_hp: int = 0
var enemy_block: int = 0
var enemy_action_index: int = 0
var current_intent: Dictionary = {}
var player_statuses: Dictionary = {}
var enemy_statuses: Dictionary = {}
var draw_pile: Array[Dictionary] = []
var hand: Array[Dictionary] = []
var discard_pile: Array[Dictionary] = []
var exhaust_pile: Array[Dictionary] = []
var character_passive: Dictionary = {}
var passive_flags: Dictionary = {}
var relic_ids: Array[String] = []
var relics: Array[Dictionary] = []
var relic_flags: Dictionary = {}
var relic_turn_flags: Dictionary = {}
var turn_events: Array[Dictionary] = []
var cards_played_this_turn: int = 0
var summon_id: String = ""
var summon_hp: int = 0
var summon_max_hp: int = 0
var summon_alive: bool = false
var last_summon_damage: int = 0
var last_summon_defeated: bool = false
var outcome: String = "ongoing"
