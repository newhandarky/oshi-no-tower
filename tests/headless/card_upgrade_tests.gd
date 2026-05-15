extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")

var database = RuntimeDatabaseScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_upgraded_card_description_matches_effect_numbers()

	if failures.is_empty():
		print("card_upgrade_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("card_upgrade_tests: failed (%d)" % failures.size())
		quit(1)

func _test_upgraded_card_description_matches_effect_numbers() -> void:
	var upgraded_attack := database.get_card("subaru-strike+")
	_expect_true(str(upgraded_attack["name"]).ends_with("+"), "升級卡名稱必須有 +")
	_expect_eq(int(upgraded_attack["effects"][0]["amount"]), 7, "subaru-strike+ 傷害應從 5 升到 7")
	_expect_true(str(upgraded_attack["description"]).contains("造成 7 點傷害"), "升級卡描述必須顯示升級後傷害")

	var upgraded_block := database.get_card("subaru-guard+")
	_expect_eq(int(upgraded_block["effects"][0]["amount"]), 7, "subaru-guard+ 格擋應從 5 升到 7")
	_expect_true(str(upgraded_block["description"]).contains("獲得 7 點格擋"), "升級卡描述必須顯示升級後格擋")

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
