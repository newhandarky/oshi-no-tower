extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")
const CombatEngineScript := preload("res://scripts/core/CombatEngine.gd")

var database = RuntimeDatabaseScript.new()
var combat_engine = CombatEngineScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_youtube_kun_applies_debuff()
	_test_announcement_shadow_has_telegraphed_heavy_hit()
	_test_meme_boss_is_in_boss_pool()

	if failures.is_empty():
		print("enemy_meme_behavior_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("enemy_meme_behavior_tests: failed (%d)" % failures.size())
		quit(1)

func _test_youtube_kun_applies_debuff() -> void:
	var enemy := _find_enemy("youtube-kun")
	if enemy.is_empty():
		failures.append("YouTube-kun enemy 必須存在")
		return
	_expect_eq(str(enemy.get("content_group", "")), "meme_enemy", "YouTube-kun 應標示為 meme enemy")
	var deck := database.resolve_cards(["subaru-guard", "subaru-guard", "subaru-guard", "subaru-guard", "subaru-guard"])
	var state = combat_engine.start_combat(68, 68, deck, enemy, [], false)
	var outcome: String = combat_engine.end_player_turn(state)
	_expect_eq(outcome, "ongoing", "YouTube-kun 第一回合不應直接結束戰鬥")
	_expect_true(combat_engine.status_duration(state, "player", "weak") > 0 or combat_engine.status_duration(state, "player", "vulnerable") > 0, "YouTube-kun 需要施加 weak 或 vulnerable")

func _test_announcement_shadow_has_telegraphed_heavy_hit() -> void:
	var enemy := _find_enemy("announcement-shadow")
	if enemy.is_empty():
		failures.append("Announcement Shadow enemy 必須存在")
		return
	_expect_eq(str(enemy.get("content_group", "")), "meme_enemy", "Announcement Shadow 應標示為 meme enemy")
	var actions: Array = enemy.get("actions", [])
	_expect_true(actions.size() >= 2, "Announcement Shadow 需要至少 2 個 intent")
	_expect_true(str(actions[0].get("description", "")).contains("預告") or str(actions[0].get("description", "")).contains("倒數"), "第一個 intent 應清楚 telegraph")
	_expect_true(int(actions[actions.size() - 1].get("damage", 0)) >= 18, "最後 intent 應是明顯重擊")

func _test_meme_boss_is_in_boss_pool() -> void:
	var boss_ids: Array = []
	for node in database.map_nodes:
		if str(node.get("type", "")) == "boss":
			for boss_id in node.get("boss_enemy_ids", []):
				boss_ids.append(str(boss_id))
	_expect_true(boss_ids.has("youtube-kun-core") or boss_ids.has("important-announcement"), "Boss pool 需包含至少一個 V3 meme Boss")
	if boss_ids.has("youtube-kun-core"):
		_expect_true(bool(database.get_enemy("youtube-kun-core").get("is_boss", false)), "YouTube-kun Core 需標示為 Boss")
	if boss_ids.has("important-announcement"):
		_expect_true(bool(database.get_enemy("important-announcement").get("is_boss", false)), "Important Announcement 需標示為 Boss")

func _find_enemy(enemy_id: String) -> Dictionary:
	for enemy in database.enemies:
		if str(enemy.get("id", "")) == enemy_id:
			return enemy
	return {}

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
