extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")

var database = RuntimeDatabaseScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_event_definitions_are_data_driven()
	_test_relic_definitions_have_v2_pool_and_hook_metadata()

	if failures.is_empty():
		print("event_relic_definition_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("event_relic_definition_tests: failed (%d)" % failures.size())
		quit(1)

func _test_event_definitions_are_data_driven() -> void:
	_expect_true(database.events.size() >= 6, "V2 event pool 至少需要 6 個")
	var allowed_actions := {
		"gain_gold": true,
		"lose_hp": true,
		"heal": true,
		"add_card": true,
		"add_random_curse": true,
		"remove_card": true,
		"upgrade_card": true,
		"increase_max_hp": true,
		"grant_relic": true,
		"start_battle": true
	}
	var seen_ids := {}
	var action_coverage := {}
	for event_def in database.events:
		var event_id := str(event_def.get("id", ""))
		_expect_not_empty(event_id, "event id 不可為空")
		_expect_false(seen_ids.has(event_id), "event id 不可重複：%s" % event_id)
		seen_ids[event_id] = true
		_expect_not_empty(str(event_def.get("title", "")), "%s title 不可為空" % event_id)
		_expect_true(event_def.get("options", []).size() >= 2, "%s 至少要有 2 個選項" % event_id)
		for option in event_def.get("options", []):
			_expect_not_empty(str(option.get("label", "")), "%s option label 不可為空" % event_id)
			_expect_true(option.get("outcomes", []).size() > 0, "%s option 必須有 outcome" % event_id)
			for outcome in option.get("outcomes", []):
				var action := str(outcome.get("action", ""))
				_expect_true(allowed_actions.has(action), "%s outcome action 不合法：%s" % [event_id, action])
				if action == "start_battle":
					_expect_true(_valid_event_battle_outcome(outcome), "%s start_battle 必須指定存在的 enemy_id 或合法 enemy_pool" % event_id)
				if action == "add_card" and str(outcome.get("card_id", "")) != "":
					_expect_true(_card_exists(str(outcome.get("card_id", ""))), "%s add_card.card_id 必須引用存在的卡牌" % event_id)
				action_coverage[action] = true
	for required_action in allowed_actions.keys():
		_expect_true(action_coverage.has(str(required_action)), "event pool 必須涵蓋 outcome action：%s" % str(required_action))

func _valid_event_battle_outcome(outcome: Dictionary) -> bool:
	if outcome.has("enemy_id"):
		return _enemy_exists(str(outcome.get("enemy_id", "")))
	var allowed_pools := { "normal": true, "early": true, "mid": true, "late": true, "elite": true, "chapter_2_mid": true }
	return allowed_pools.has(str(outcome.get("enemy_pool", "")))

func _enemy_exists(enemy_id: String) -> bool:
	for enemy in database.enemies:
		if str(enemy.get("id", "")) == enemy_id:
			return true
	return false

func _card_exists(card_id: String) -> bool:
	for card in database.cards:
		if str(card.get("id", "")) == card_id:
			return true
	return false

func _test_relic_definitions_have_v2_pool_and_hook_metadata() -> void:
	_expect_true(database.relics.size() >= 8, "V2 relic pool 至少需要 8 個")
	var allowed_pools := { "common": true, "elite": true, "shop": true, "event": true, "boss": true }
	var allowed_sources := { "elite": true, "chest": true, "shop": true, "event": true, "boss": true, "debug": true }
	var allowed_hooks := {
		"combat_start": true,
		"first_cheap_card_played": true,
		"first_two_cost_played": true,
		"first_marker_card_played": true,
		"turn_start": true,
		"battle_reward": true,
		"shop_enter": true,
		"room_enter": true
	}
	var hook_coverage := {}
	var seen_ids := {}
	for relic in database.relics:
		var relic_id := str(relic.get("id", ""))
		_expect_not_empty(relic_id, "relic id 不可為空")
		_expect_false(seen_ids.has(relic_id), "relic id 不可重複：%s" % relic_id)
		seen_ids[relic_id] = true
		_expect_true(allowed_pools.has(str(relic.get("pool", ""))), "%s relic pool 不合法：%s" % [relic_id, str(relic.get("pool", ""))])
		_expect_true(relic.get("source_rules", []).size() > 0, "%s relic source_rules 不可為空" % relic_id)
		for source in relic.get("source_rules", []):
			_expect_true(allowed_sources.has(str(source)), "%s relic source 不合法：%s" % [relic_id, str(source)])
		var hooks: Array = relic.get("hooks", [str(relic.get("hook", ""))])
		for hook in hooks:
			_expect_true(allowed_hooks.has(str(hook)), "%s relic hook 不合法：%s" % [relic_id, str(hook)])
			hook_coverage[str(hook)] = true
	for required_hook in ["combat_start", "turn_start", "first_cheap_card_played", "first_two_cost_played", "first_marker_card_played", "battle_reward", "shop_enter", "room_enter"]:
		_expect_true(hook_coverage.has(required_hook), "relic pool 必須涵蓋 hook：%s" % required_hook)

func _expect_not_empty(actual: String, message: String) -> void:
	if actual == "":
		failures.append("%s：expected non-empty string" % message)

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_false(actual: bool, message: String) -> void:
	if actual:
		failures.append("%s：expected false, got true" % message)
