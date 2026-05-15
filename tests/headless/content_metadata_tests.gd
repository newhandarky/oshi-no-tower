extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")

var database = RuntimeDatabaseScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_v3_content_counts()
	_test_all_content_has_meme_metadata()
	_test_content_ids_are_unique()
	_test_meme_sources_are_not_overused_in_one_content_type()

	if failures.is_empty():
		print("content_metadata_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("content_metadata_tests: failed (%d)" % failures.size())
		quit(1)

func _test_v3_content_counts() -> void:
	_expect_true(database.events.size() >= 12, "MVP-v3 event pool 至少需要 12 個")
	_expect_true(database.relics.size() >= 16, "MVP-v3 relic pool 至少需要 16 個")
	_expect_true(_character_card_count("subaru") >= 18, "Subaru 牌池需包含 V3 新增牌")
	_expect_true(_character_card_count("botan") >= 18, "Botan 牌池需包含 V3 新增牌")
	_expect_true(_meme_enemy_count() >= 3, "至少需要 3 種 meme 主題敵人或精英敵人")
	_expect_true(_meme_boss_count() >= 1, "至少需要 1 個 meme 主題 Boss 候選")

func _test_all_content_has_meme_metadata() -> void:
	for event_def in database.events:
		_expect_metadata(event_def, "event")
	for relic in database.relics:
		_expect_metadata(relic, "relic")
	for card in database.cards:
		_expect_metadata(card, "card")
	for enemy in database.enemies:
		if bool(enemy.get("is_boss", false)) or str(enemy.get("tier", "")) == "elite" or str(enemy.get("content_group", "")) == "meme_enemy":
			_expect_metadata(enemy, "enemy")

func _test_content_ids_are_unique() -> void:
	_expect_unique_ids(database.events, "event")
	_expect_unique_ids(database.relics, "relic")
	_expect_unique_ids(database.cards, "card")
	_expect_unique_ids(database.enemies, "enemy")

func _test_meme_sources_are_not_overused_in_one_content_type() -> void:
	_expect_source_cap(database.events, "event", 3)
	_expect_source_cap(database.relics, "relic", 3)
	_expect_source_cap(database.cards, "card", 4)

func _character_card_count(character_id: String) -> int:
	var count := 0
	for card in database.cards:
		if str(card.get("character", "")) == character_id:
			count += 1
	return count

func _meme_enemy_count() -> int:
	var count := 0
	for enemy in database.enemies:
		if str(enemy.get("content_group", "")) == "meme_enemy":
			count += 1
	return count

func _meme_boss_count() -> int:
	var count := 0
	for enemy in database.enemies:
		if bool(enemy.get("is_boss", false)) and str(enemy.get("content_group", "")) == "meme_boss":
			count += 1
	return count

func _expect_metadata(item: Dictionary, label: String) -> void:
	var item_id := str(item.get("id", ""))
	_expect_not_empty(str(item.get("meme_source", "")), "%s %s meme_source 不可為空" % [label, item_id])
	_expect_not_empty(str(item.get("content_group", "")), "%s %s content_group 不可為空" % [label, item_id])
	_expect_not_empty(str(item.get("rarity", "")), "%s %s rarity 不可為空" % [label, item_id])
	_expect_not_empty(str(item.get("implementation_status", "")), "%s %s implementation_status 不可為空" % [label, item_id])

func _expect_unique_ids(items: Array, label: String) -> void:
	var seen := {}
	for item in items:
		var item_id := str(item.get("id", ""))
		_expect_not_empty(item_id, "%s id 不可為空" % label)
		_expect_false(seen.has(item_id), "%s id 不可重複：%s" % [label, item_id])
		seen[item_id] = true

func _expect_source_cap(items: Array, label: String, max_count: int) -> void:
	var source_counts := {}
	for item in items:
		var source := str(item.get("meme_source", ""))
		if source == "":
			continue
		source_counts[source] = int(source_counts.get(source, 0)) + 1
	for source in source_counts.keys():
		_expect_true(int(source_counts[source]) <= max_count, "%s meme_source 使用過度集中：%s = %d" % [label, source, int(source_counts[source])])

func _expect_not_empty(actual: String, message: String) -> void:
	if actual == "":
		failures.append("%s：expected non-empty string" % message)

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_false(actual: bool, message: String) -> void:
	if actual:
		failures.append("%s：expected false, got true" % message)
