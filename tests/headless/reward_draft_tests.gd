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
	_test_subaru_midrun_reward_prefers_tempo_block_over_repeat_sustain()
	_test_subaru_early_reward_frontloads_tempo_bridge()
	_test_subaru_early_elite_reward_frontloads_immediate_tempo_block()
	_test_subaru_midrun_reward_turns_bridge_into_payoff()
	_test_azki_midrun_reward_turns_laplus_bridge_into_payoff()
	_test_azki_midrun_reward_frontloads_payoff_before_late_boss()
	_test_botan_midrun_reward_limits_repeat_rare_payoff()
	_test_botan_midrun_reward_breaks_kill_zone_cover_reload_loop()
	_test_botan_depth_balance_does_not_push_extra_payoff()
	_test_azki_midrun_reward_does_not_repeat_existing_payoff()
	_test_azki_midrun_reward_recovers_after_laplus_payoff_stack()
	_test_reward_draft_fills_missing_role_gaps()

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

func _test_subaru_midrun_reward_prefers_tempo_block_over_repeat_sustain() -> void:
	var pool := _subaru_pool()
	var deck_ids := [
		"subaru-strike", "subaru-strike", "subaru-strike",
		"subaru-guard", "subaru-guard", "subaru-guard",
		"subaru-duck-rush", "subaru-draw-breath", "subaru-tsukkomi",
		"subaru-opening-quack", "subaru-cheer-recover", "subaru-blue-wave",
		"subaru-hype-call"
	]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 9, 2026051341)

	_expect_true(result.has("subaru-crowd-cover") or result.has("subaru-rhythm-guard") or result.has("subaru-desk-reaction") or result.has("subaru-new-oshi-call"), "Subaru mid-run reward 應補 tempo block，而不是繼續堆純續航 / buff")
	_expect_false(result.has("subaru-cheer-recover"), "Subaru 已有續航後不應再把 cheer-recover 放進固定 seed 前排")

func _test_subaru_early_reward_frontloads_tempo_bridge() -> void:
	var pool := _subaru_pool()
	var deck_ids := [
		"subaru-strike", "subaru-strike", "subaru-strike", "subaru-strike",
		"subaru-guard", "subaru-guard", "subaru-guard",
		"subaru-duck-rush", "subaru-draw-breath", "subaru-tsukkomi",
		"subaru-combo-boost", "subaru-opening-quack", "subaru-duck-tempo"
	]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 4, 202605261)

	_expect_true(result.has("subaru-crowd-cover") or result.has("subaru-encore-recall") or result.has("subaru-afterimage-table"), "Subaru early cheap-chain reward 應 frontload tempo bridge / payoff，不應只給泛用抽牌或續航")
	_expect_false(result.has("subaru-cheer-recover") or result.has("subaru-blue-wave"), "Subaru early cheap-chain reward 不應優先推第二張續航")

func _test_subaru_early_elite_reward_frontloads_immediate_tempo_block() -> void:
	var pool := _subaru_pool()
	var deck_ids := [
		"subaru-strike", "subaru-strike", "subaru-strike", "subaru-strike",
		"subaru-guard", "subaru-guard", "subaru-guard",
		"subaru-duck-rush", "subaru-draw-breath", "subaru-tsukkomi",
		"subaru-combo-boost", "subaru-blue-wave", "subaru-desk-reaction"
	]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 6, 202605271)

	_expect_true(_count_cards_in(result, ["subaru-crowd-cover", "subaru-rhythm-guard", "subaru-new-oshi-call"]) >= 3, "Subaru early elite 前若即時防守不足，reward 應集中提供 tempo block 選項")
	_expect_false(result.has("subaru-hype-call") or result.has("subaru-cheer-recover") or result.has("subaru-blue-wave"), "Subaru early elite 前不應優先推第二張 buff / 續航")

func _test_subaru_midrun_reward_turns_bridge_into_payoff() -> void:
	var pool := _subaru_pool()
	var deck_ids := [
		"subaru-strike", "subaru-strike", "subaru-strike",
		"subaru-guard", "subaru-guard", "subaru-guard",
		"subaru-duck-rush", "subaru-draw-breath", "subaru-tsukkomi",
		"subaru-combo-boost", "subaru-opening-quack", "subaru-duck-tempo",
		"subaru-crowd-cover", "subaru-new-oshi-call", "subaru-desk-reaction"
	]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 9, 202605262)

	_expect_true(result.has("subaru-table-slam-loop") or result.has("subaru-afterimage-table") or result.has("subaru-unstoppable-cheer"), "Subaru 已有 bridge/defense 後 mid-run reward 應轉向 payoff 或 scaling")
	_expect_false(result.has("subaru-cheer-recover"), "Subaru mid-run 已有 bridge 後不應再優先推低影響續航")

func _test_azki_midrun_reward_turns_laplus_bridge_into_payoff() -> void:
	var pool := _azki_pool()
	var deck_ids := [
		"azki-map-shot", "azki-map-shot", "azki-map-shot", "azki-map-shot",
		"azki-guard", "azki-guard", "azki-guard", "azki-pinpoint", "azki-tune-up", "azki-kiss",
		"azki-laplus-guard-order", "azki-laplus-contract", "azki-dark-tether",
		"azki-singing-coordinate", "azki-route-marker"
	]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 10, 2026051343)

	_expect_true(result.has("azki-laplus-overflow") or result.has("azki-necrobinder-finale") or result.has("azki-laplus-crash") or result.has("azki-laplus-combo"), "AZKi 已有 Laplus bridge 後 mid-run reward 應轉向收束牌")
	_expect_false(result.has("azki-singing-coordinate") and result.has("azki-route-marker"), "AZKi mid-run reward 不應同時塞重複 marker draw bridge")

func _test_azki_midrun_reward_frontloads_payoff_before_late_boss() -> void:
	var pool := _azki_pool()
	var deck_ids := [
		"azki-map-shot", "azki-map-shot", "azki-map-shot",
		"azki-guard", "azki-guard", "azki-guard",
		"azki-pinpoint", "azki-tune-up", "azki-kiss",
		"azki-laplus-guard-order", "azki-laplus-contract", "azki-dark-tether",
		"azki-safe-route", "azki-phantom-route"
	]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 7, 202605263)

	_expect_true(result.has("azki-laplus-overflow") or result.has("azki-laplus-release") or result.has("azki-necrobinder-finale") or result.has("azki-laplus-crash") or result.has("azki-laplus-combo"), "AZKi floor 7-11 已有 marker + Laplus bridge 時，reward 需提前提供 payoff/scaling")
	_expect_false(result.has("azki-laplus-contract") and result.has("azki-safe-route"), "AZKi mid-run 不應同時繼續塞純防守橋接而缺收束")

func _test_botan_midrun_reward_limits_repeat_rare_payoff() -> void:
	var pool := _botan_pool()
	var deck_ids := [
		"botan-shot", "botan-shot", "botan-shot", "botan-shot",
		"botan-cover", "botan-cover", "botan-cover", "botan-burst", "botan-reload", "botan-mark",
		"botan-medkit-cover", "botan-perfect-line", "botan-perfect-line", "botan-precise-cover"
	]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 11, 2026051342)

	_expect_false(result.has("botan-perfect-line"), "Botan 已有多張 perfect-line 時不應繼續推重複 rare payoff")
	_expect_true(result.has("botan-clean-scope") or result.has("botan-overwatch") or result.has("botan-fortified-cover") or result.has("botan-counter-line"), "Botan mid-run reward 應補防守或反擊橋接")

func _test_botan_midrun_reward_breaks_kill_zone_cover_reload_loop() -> void:
	var pool := _botan_pool()
	var deck_ids := [
		"botan-shot", "botan-shot", "botan-shot", "botan-shot",
		"botan-cover", "botan-cover", "botan-cover", "botan-burst", "botan-reload", "botan-mark",
		"botan-kill-zone", "botan-cover-reload", "botan-perfect-line",
		"botan-kill-zone", "botan-cover-reload", "botan-kill-zone"
	]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 11, 202605251)

	_expect_false(result.has("botan-kill-zone"), "Botan 已有多張 kill-zone 時不應繼續推同名 setup")
	_expect_false(result.has("botan-cover-reload"), "Botan 已有多張 cover-reload 時不應繼續推同名橋接")
	_expect_true(result.has("botan-overwatch") or result.has("botan-clean-scope") or result.has("botan-flashbang-round") or result.has("botan-fortified-cover") or result.has("botan-counter-line"), "Botan setup/bridge 已過量時，reward 應改補控制、防守或反擊")

func _test_botan_depth_balance_does_not_push_extra_payoff() -> void:
	var pool := _botan_pool()
	var deck_ids := [
		"botan-shot", "botan-shot", "botan-shot",
		"botan-cover", "botan-cover", "botan-cover",
		"botan-burst", "botan-reload", "botan-mark",
		"botan-kill-zone", "botan-cover-reload", "botan-perfect-line",
		"botan-piercing-round", "botan-calm-burst"
	]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 10, 202605264)

	_expect_false(result.has("botan-perfect-line") or result.has("botan-piercing-round"), "006 不應讓 Botan 已有收束時繼續推高 payoff 密度")
	_expect_true(result.has("botan-overwatch") or result.has("botan-clean-scope") or result.has("botan-flashbang-round") or result.has("botan-fortified-cover") or result.has("botan-counter-line") or result.has("botan-precise-cover"), "Botan 既有行為需維持轉向防守 / 控制 / 反擊")

func _test_azki_midrun_reward_does_not_repeat_existing_payoff() -> void:
	var pool := _azki_pool()
	var deck_ids := [
		"azki-map-shot", "azki-map-shot", "azki-map-shot", "azki-map-shot",
		"azki-guard", "azki-guard", "azki-guard", "azki-pinpoint", "azki-tune-up", "azki-kiss",
		"azki-laplus-guard-order", "azki-laplus-contract", "azki-dark-tether",
		"azki-laplus-overflow", "azki-necrobinder-finale"
	]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 11, 2026051343)

	_expect_false(result.has("azki-laplus-overflow") or result.has("azki-necrobinder-finale"), "AZKi 已有 Laplus payoff 時不應繼續重複塞同名收束牌")
	_expect_true(result.has("azki-laplus-cover") or result.has("azki-laplus-reposition") or result.has("azki-safe-route") or result.has("azki-laplus-combo") or result.has("azki-phantom-route") or result.has("azki-necro-recall"), "AZKi 已有 payoff 後 reward 應補防守橋接、臨時 marker、回收或不同收束")

func _test_azki_midrun_reward_recovers_after_laplus_payoff_stack() -> void:
	var pool := _azki_pool()
	var deck_ids := [
		"azki-map-shot", "azki-map-shot", "azki-map-shot",
		"azki-guard", "azki-guard", "azki-guard", "azki-pinpoint", "azki-tune-up", "azki-kiss",
		"azki-laplus-guard-order", "azki-laplus-contract", "azki-dark-tether", "azki-safe-route",
		"azki-laplus-overflow", "azki-necrobinder-finale", "azki-laplus-release"
	]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 13, 202605252)

	_expect_false(result.has("azki-laplus-overflow") or result.has("azki-necrobinder-finale") or result.has("azki-laplus-release"), "AZKi 已有多張 Laplus payoff 時不應繼續推同類收束")
	_expect_true(result.has("azki-phantom-route") or result.has("azki-necro-recall") or result.has("azki-laplus-cover") or result.has("azki-laplus-reposition"), "AZKi 已有 payoff 後應補 Laplus 防守、臨時 marker 或回收穩定度")

func _test_reward_draft_fills_missing_role_gaps() -> void:
	var subaru_no_payoff_deck := [
		"subaru-opening-quack", "subaru-combo-boost", "subaru-crowd-cover",
		"subaru-new-oshi-call", "subaru-cheer-loop", "subaru-rhythm-guard"
	]
	var subaru_result: Array[String] = drafter.draft(database, _subaru_pool(), subaru_no_payoff_deck, [], 3, 9, 202605241)
	_expect_true(_any_card_has_role(subaru_result, "payoff") or _any_card_has_role(subaru_result, "scaling"), "deck 已有 setup/bridge/defense 但缺收束時，reward 應補 payoff 或 scaling")

	var botan_no_defense_deck := [
		"botan-heavy-shot", "botan-piercing-round", "botan-perfect-line",
		"botan-range-finder", "botan-kill-zone", "botan-burst"
	]
	var botan_result: Array[String] = drafter.draft(database, _botan_pool(), botan_no_defense_deck, [], 3, 9, 202605242)
	_expect_true(_any_card_has_role(botan_result, "defense"), "deck 已有 Botan setup/payoff 但防守密度低時，reward 應補 defense")

	var azki_no_scaling_deck := [
		"azki-route-marker", "azki-phantom-route", "azki-necro-recall",
		"azki-laplus-guard-order", "azki-dark-tether", "azki-marker-echo"
	]
	var azki_result: Array[String] = drafter.draft(database, _azki_pool(), azki_no_scaling_deck, [], 3, 12, 202605243)
	_expect_true(_any_card_has_role(azki_result, "scaling"), "deck 已有 AZKi setup/defense/bridge 但缺 scaling 時，reward 應補 scaling")

func _subaru_pool() -> Array[String]:
	return [
		"subaru-duck-rush", "subaru-draw-breath", "subaru-tsukkomi", "subaru-second-wind",
		"subaru-quick-retort", "subaru-rhythm-guard", "subaru-cheer-loop", "subaru-duck-step",
		"subaru-team-rush", "subaru-hype-call", "subaru-duck-feint", "subaru-cheer-recover",
		"subaru-duck-tempo", "subaru-teetee-guard", "subaru-desk-reaction", "subaru-blue-wave",
		"subaru-new-oshi-call", "subaru-opening-quack", "subaru-crowd-cover",
		"subaru-table-slam-loop", "subaru-unstoppable-cheer", "subaru-combo-boost",
		"subaru-encore-recall", "subaru-afterimage-table"
	]

func _botan_pool() -> Array[String]:
	return [
		"botan-burst", "botan-reload", "botan-mark", "botan-heavy-shot",
		"botan-steady-aim", "botan-fortified-cover", "botan-counter-line", "botan-tap-shot",
		"botan-suppressive-fire", "botan-tactical-focus", "botan-medkit-cover",
		"botan-button-check", "botan-clean-scope", "botan-calm-burst", "botan-precise-cover",
		"botan-funds-prepared", "botan-range-finder", "botan-overwatch",
		"botan-piercing-round", "botan-perfect-line", "botan-kill-zone",
		"botan-cover-reload", "botan-flashbang-round"
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
		"azki-singing-coordinate", "azki-laplus-overflow", "azki-necrobinder-finale",
		"azki-phantom-route", "azki-necro-recall", "azki-laplus-release"
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

func _count_cards_in(card_ids: Array[String], expected_ids: Array[String]) -> int:
	var count := 0
	for card_id in card_ids:
		if expected_ids.has(card_id):
			count += 1
	return count

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_false(actual: bool, message: String) -> void:
	if actual:
		failures.append("%s：expected false, got true" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
