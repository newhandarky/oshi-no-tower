extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")

var database = RuntimeDatabaseScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_content_pack_2a_enemy_questions_exist()
	_test_pressure_tags_match_enemy_action_patterns()

	if failures.is_empty():
		print("enemy_design_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("enemy_design_tests: failed (%d)" % failures.size())
		quit(1)

func _test_content_pack_2a_enemy_questions_exist() -> void:
	var expected := {
		"ssrb-guard-tutor": "anti_burst_into_block",
		"ssrb-striker-intent": "attack_intent_test",
		"ssrb-debuff-check": "debuff_resilience",
		"ssrb-scaling-clock": "scaling_clock"
	}
	for enemy_id in expected.keys():
		var enemy := database.get_enemy(str(enemy_id))
		_expect_eq(str(enemy.get("id", "")), str(enemy_id), "Content Pack 2A enemy 必須存在：%s" % str(enemy_id))
		_expect_true(enemy.get("pressure_tags", []).has(str(expected[enemy_id])), "%s 必須標記 pressure tag：%s" % [str(enemy_id), str(expected[enemy_id])])
		_expect_not_empty(str(enemy.get("counterplay_hint", "")), "%s 必須提供 counterplay_hint" % str(enemy_id))

func _test_pressure_tags_match_enemy_action_patterns() -> void:
	for enemy in database.enemies:
		var enemy_id := str(enemy.get("id", ""))
		var pressure_tags: Array = enemy.get("pressure_tags", [])
		if pressure_tags.has("anti_burst_into_block"):
			_expect_true(_has_action(enemy, "block"), "%s anti_burst_into_block 敵人必須有 block action" % enemy_id)
		if pressure_tags.has("attack_intent_test"):
			_expect_true(_has_attack_action(enemy), "%s attack_intent_test 敵人必須有攻擊意圖" % enemy_id)
		if pressure_tags.has("debuff_resilience"):
			_expect_true(_has_action(enemy, "debuff"), "%s debuff_resilience 敵人必須有 debuff action" % enemy_id)
		if pressure_tags.has("scaling_clock"):
			_expect_true(_has_action(enemy, "buff"), "%s scaling_clock 敵人必須有 buff action" % enemy_id)

func _has_action(enemy: Dictionary, action_type: String) -> bool:
	for action in enemy.get("actions", []):
		if str(action.get("type", "")) == action_type:
			return true
	return false

func _has_attack_action(enemy: Dictionary) -> bool:
	for action in enemy.get("actions", []):
		if str(action.get("type", "")) in ["attack", "attack_block"]:
			return true
	return false

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])

func _expect_not_empty(actual: String, message: String) -> void:
	if actual == "":
		failures.append("%s：expected non-empty string" % message)
