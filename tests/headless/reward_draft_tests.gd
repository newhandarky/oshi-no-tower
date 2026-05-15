extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")
const CardRewardDraftScript := preload("res://scripts/data/CardRewardDraft.gd")

var database = RuntimeDatabaseScript.new()
var drafter = CardRewardDraftScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_fixed_seed_reward_draft_is_reproducible()
	_test_deck_signal_prioritizes_matching_archetype()
	_test_early_reward_draft_avoids_rare_when_possible()
	_test_reward_draft_includes_survival_or_bridge_card()
	_test_shop_sort_prioritizes_build_relevant_cards()
	_test_azki_chapter_2_entry_reward_draft_frontloads_laplus_guard()
	_test_azki_chapter_2_reward_draft_bridges_marker_and_laplus()
	_test_azki_reward_draft_penalizes_repeated_laplus_bridge_cards()
	_test_azki_chapter_2_shop_frontloads_marker_guard_and_payoff()

	if failures.is_empty():
		print("reward_draft_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("reward_draft_tests: failed (%d)" % failures.size())
		quit(1)

func _test_fixed_seed_reward_draft_is_reproducible() -> void:
	var pool := _subaru_pool()
	var deck_ids := ["subaru-opening-quack", "subaru-duck-tempo", "subaru-new-oshi-call"]
	var first: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 6, 20260514)
	var second: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 6, 20260514)

	_expect_eq(first, second, "fixed seed reward draft 必須可重現")
	_expect_eq(first.size(), 3, "reward draft 必須維持 3 選 1")

func _test_deck_signal_prioritizes_matching_archetype() -> void:
	var pool := _subaru_pool()
	var deck_ids := ["subaru-opening-quack", "subaru-duck-tempo", "subaru-new-oshi-call"]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 8, 20260515)

	_expect_true(_any_card_has_archetype(result, "cheap_chain"), "deck signal 應提高同 archetype 卡牌出現率")

func _test_early_reward_draft_avoids_rare_when_possible() -> void:
	var pool := _subaru_pool()
	var result: Array[String] = drafter.draft(database, pool, ["subaru-strike", "subaru-guard"], [], 3, 1, 20260516)

	for card_id in result:
		_expect_false(str(database.get_card(card_id).get("rarity", "")) == "rare", "early reward draft 不應過早塞 rare：%s" % card_id)

func _test_reward_draft_includes_survival_or_bridge_card() -> void:
	var pool := _botan_pool()
	var deck_ids := ["botan-heavy-shot", "botan-piercing-round", "botan-perfect-line"]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 9, 20260517)

	_expect_true(_any_card_has_role(result, "defense") or _any_card_has_role(result, "bridge"), "reward draft 不應三張全 payoff，至少要有 defense/bridge")

func _test_shop_sort_prioritizes_build_relevant_cards() -> void:
	var pool := _azki_pool()
	var deck_ids := ["azki-route-marker", "azki-map-search", "azki-marker-echo"]
	var sorted: Array[String] = drafter.sort_shop_cards(database, pool, deck_ids, [], 10, 20260518)

	_expect_true(sorted.size() >= pool.size(), "shop sort 不應移除商品")
	_expect_true(database.get_card(sorted[0]).get("archetype_tags", []).has("marker_loop"), "shop sort 第一張應優先符合目前 build signal")

func _test_azki_chapter_2_entry_reward_draft_frontloads_laplus_guard() -> void:
	var pool := _azki_pool()
	var deck_ids := ["azki-map-search", "azki-pinpoint", "azki-open-route", "azki-safe-route"]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 6, 20260521)

	_expect_true(result.has("azki-laplus-guard-order"), "AZKi Chapter 2 入口 reward 需直接提供 Laplus 防守橋接，不能等 marker loop 完全成形")

func _test_azki_chapter_2_reward_draft_bridges_marker_and_laplus() -> void:
	var pool := _azki_pool()
	var deck_ids := ["azki-map-search", "azki-marker-echo", "azki-open-route", "azki-pinpoint"]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 12, 20260519)

	_expect_true(_any_card_has_archetype(result, "marker_loop"), "AZKi Chapter 2 reward 需保留 marker 節奏牌")
	_expect_true(_any_card_has_archetype(result, "laplus_guard"), "AZKi Chapter 2 reward 需補 Laplus/survival bridge，不可只給 marker payoff")
	_expect_true(_any_card_has_role(result, "payoff") or _any_card_has_role(result, "scaling"), "AZKi Chapter 2 reward 至少需提供一張收束或 scaling 選項")

func _test_azki_reward_draft_penalizes_repeated_laplus_bridge_cards() -> void:
	var pool := _azki_pool()
	var deck_ids := ["azki-laplus-guard-order", "azki-laplus-guard-order", "azki-laplus-contract", "azki-laplus-contract", "azki-map-search", "azki-route-marker"]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 10, 20260523)

	_expect_false(result.has("azki-laplus-guard-order") and result.has("azki-laplus-contract"), "AZKi 已有多張 Laplus bridge 時，reward 不應繼續同時塞重複防守橋接")
	_expect_true(_any_card_has_role(result, "payoff") or _any_card_has_role(result, "scaling") or result.has("azki-dark-tether"), "AZKi 已有 Laplus bridge 後應轉向輸出、scaling 或不同橋接")

func _test_azki_chapter_2_shop_frontloads_marker_guard_and_payoff() -> void:
	var pool := _azki_pool()
	var deck_ids := ["azki-map-search", "azki-marker-echo", "azki-route-marker", "azki-open-route"]
	var sorted: Array[String] = drafter.sort_shop_cards(database, pool, deck_ids, [], 12, 20260520)
	var front: Array[String] = sorted.slice(0, min(5, sorted.size()))

	_expect_true(_any_card_has_archetype(front, "marker_loop"), "AZKi Chapter 2 shop 前排需有 marker 節奏牌")
	_expect_true(_any_card_has_archetype(front, "laplus_guard"), "AZKi Chapter 2 shop 前排需有 Laplus 防守橋接")
	_expect_true(_any_card_has_role(front, "payoff") or _any_card_has_role(front, "scaling"), "AZKi Chapter 2 shop 前排需有收束或 scaling 選項")

func _subaru_pool() -> Array[String]:
	return [
		"subaru-duck-rush", "subaru-draw-breath", "subaru-tsukkomi", "subaru-second-wind",
		"subaru-quick-retort", "subaru-rhythm-guard", "subaru-cheer-loop", "subaru-duck-step",
		"subaru-team-rush", "subaru-hype-call", "subaru-duck-feint", "subaru-cheer-recover",
		"subaru-duck-tempo", "subaru-teetee-guard", "subaru-desk-reaction", "subaru-blue-wave",
		"subaru-new-oshi-call", "subaru-opening-quack", "subaru-crowd-cover",
		"subaru-table-slam-loop", "subaru-unstoppable-cheer"
	]

func _botan_pool() -> Array[String]:
	return [
		"botan-burst", "botan-reload", "botan-mark", "botan-heavy-shot",
		"botan-steady-aim", "botan-fortified-cover", "botan-counter-line", "botan-tap-shot",
		"botan-suppressive-fire", "botan-tactical-focus", "botan-medkit-cover",
		"botan-button-check", "botan-clean-scope", "botan-calm-burst", "botan-precise-cover",
		"botan-funds-prepared", "botan-range-finder", "botan-overwatch",
		"botan-piercing-round", "botan-perfect-line"
	]

func _azki_pool() -> Array[String]:
	return [
		"azki-pinpoint", "azki-kiss", "azki-route-strike", "azki-double-pin",
		"azki-frontier-burst", "azki-laplus-dash", "azki-laplus-crash", "azki-safe-route",
		"azki-coordinate-shield", "azki-idol-stance", "azki-map-search", "azki-songline",
		"azki-open-route", "azki-pioneer-call", "azki-final-coordinate",
		"azki-laplus-cover", "azki-coordinate-barrage", "azki-laplus-combo",
		"azki-marker-echo", "azki-laplus-reposition", "azki-route-marker",
		"azki-laplus-guard-order", "azki-laplus-contract", "azki-dark-tether",
		"azki-singing-coordinate", "azki-laplus-overflow", "azki-necrobinder-finale"
	]

func _any_card_has_archetype(card_ids: Array[String], archetype: String) -> bool:
	for card_id in card_ids:
		if database.get_card(card_id).get("archetype_tags", []).has(archetype):
			return true
	return false

func _any_card_has_role(card_ids: Array[String], role: String) -> bool:
	for card_id in card_ids:
		if database.get_card(card_id).get("role_tags", []).has(role):
			return true
	return false

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_false(actual: bool, message: String) -> void:
	if actual:
		failures.append("%s：expected false, got true" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
