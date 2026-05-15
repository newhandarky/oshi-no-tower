extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")
const CombatEngineScript := preload("res://scripts/core/CombatEngine.gd")

var database = RuntimeDatabaseScript.new()
var engine = CombatEngineScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_strength_increases_player_attack_damage()
	_test_weak_reduces_player_attack_damage()
	_test_vulnerable_increases_received_attack_damage()
	_test_regen_heals_at_turn_start_and_duration_decays()
	_test_enemy_debuff_action_applies_status_to_player()

	if failures.is_empty():
		print("combat_status_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("combat_status_tests: failed (%d)" % failures.size())
		quit(1)

func _test_strength_increases_player_attack_damage() -> void:
	var state = engine.start_combat(30, 30, _deck(["subaru-strike"]), _enemy_attack(1, 30))
	engine.apply_status(state, "player", { "id": "strength", "value": 2, "duration": 99 })

	engine.try_play_card(state, 0)

	_expect_eq(state.enemy_hp, 23, "strength 2 必須讓 5 傷害變成 7")

func _test_weak_reduces_player_attack_damage() -> void:
	var state = engine.start_combat(30, 30, _deck(["subaru-strike"]), _enemy_attack(1, 30))
	engine.apply_status(state, "player", { "id": "weak", "value": 1, "duration": 2 })

	engine.try_play_card(state, 0)

	_expect_eq(state.enemy_hp, 27, "weak 必須讓 5 傷害降低為 3")

func _test_vulnerable_increases_received_attack_damage() -> void:
	var state = engine.start_combat(30, 30, _deck(["subaru-guard"]), _enemy_attack(10, 30))
	engine.apply_status(state, "player", { "id": "vulnerable", "value": 1, "duration": 2 })

	engine.end_player_turn(state)

	_expect_eq(state.player_hp, 15, "vulnerable 必須讓敵人 10 傷害變成 15")

func _test_regen_heals_at_turn_start_and_duration_decays() -> void:
	var state = engine.start_combat(20, 30, _deck(["subaru-strike"]), _enemy_attack(1, 30))
	engine.apply_status(state, "player", { "id": "regen", "value": 3, "duration": 2 })

	engine.end_player_turn(state)

	_expect_eq(state.player_hp, 22, "regen 應在新玩家回合開始時治療 3，扣除敵人 1 傷害後為 22")
	_expect_eq(engine.status_duration(state, "player", "regen"), 1, "regen duration 必須衰減")

func _test_enemy_debuff_action_applies_status_to_player() -> void:
	var state = engine.start_combat(30, 30, _deck(["subaru-strike"]), _enemy_actions([
		{ "type": "debuff", "damage": 0, "block": 0, "description": "虛弱 2", "status_id": "weak", "status_value": 1, "status_duration": 2 }
	], 30))

	engine.end_player_turn(state)

	_expect_eq(engine.status_duration(state, "player", "weak"), 2, "debuff action 必須套用 weak 到玩家")
	_expect_eq(str(state.current_intent["type"]), "debuff", "debuff intent 必須保留")

func _deck(card_ids: Array[String]) -> Array[Dictionary]:
	return database.resolve_cards(card_ids)

func _enemy_attack(damage: int, hp := 20) -> Dictionary:
	return _enemy_actions([{ "type": "attack", "damage": damage, "block": 0, "description": "攻擊 %d" % damage }], hp)

func _enemy_actions(actions: Array[Dictionary], hp := 20) -> Dictionary:
	return {
		"id": "test-enemy",
		"display_name": "測試敵人",
		"max_hp": hp,
		"gold": 0,
		"scale": 1.0,
		"resource_base_path": "",
		"actions": actions
	}

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
