extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")
const CombatEngineScript := preload("res://scripts/core/CombatEngine.gd")
const CardRewardDraftScript := preload("res://scripts/data/CardRewardDraft.gd")

const MAX_TURNS := 10
const MAX_PLAYS_PER_TURN := 30

var database = RuntimeDatabaseScript.new()
var combat_engine = CombatEngineScript.new()
var drafter = CardRewardDraftScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_azki_starter_deck_survives_early_pressure_probe()
	_test_azki_early_defense_numbers_are_not_below_survival_floor()
	_test_azki_first_reward_frontloads_early_survival_bridge()
	_test_azki_fixed_auto_run_first_reward_frontloads_guard_order()

	if failures.is_empty():
		print("azki_early_survival_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("azki_early_survival_tests: failed (%d)" % failures.size())
		quit(1)

func _test_azki_starter_deck_survives_early_pressure_probe() -> void:
	var character := database.get_character("azki")
	var result := _resolve_sequence(
		int(character.get("max_hp", 70)),
		_string_array(character.get("starting_deck", [])),
		["ssrb-gray", "desk-kun", "ssrb-camouflage"],
		character.get("passive", {}),
		character.get("summon", {})
	)

	_expect_eq(str(result.get("outcome", "")), "victory", "AZKi 起始牌組應能解掉第一章前三個 early pressure proxy")
	_expect_true(int(result.get("player_hp", 0)) >= 30, "AZKi early pressure proxy 後 HP 不應低於最低生存線；actual_hp=%d" % int(result.get("player_hp", 0)))

func _test_azki_early_defense_numbers_are_not_below_survival_floor() -> void:
	_expect_true(_first_block_amount("azki-guard") >= 6, "AZKi 起始防禦牌至少需有 6 點格擋")
	_expect_true(_first_block_amount("azki-route-strike") >= 4, "AZKi early mixed bridge 至少需有 4 點格擋")

func _test_azki_first_reward_frontloads_early_survival_bridge() -> void:
	var pool := [
		"azki-pinpoint", "azki-kiss", "azki-route-strike", "azki-double-pin",
		"azki-frontier-burst", "azki-laplus-dash", "azki-laplus-crash", "azki-safe-route",
		"azki-coordinate-shield", "azki-idol-stance", "azki-map-search", "azki-songline",
		"azki-open-route", "azki-pioneer-call", "azki-final-coordinate",
		"azki-laplus-cover", "azki-coordinate-barrage", "azki-laplus-combo",
		"azki-marker-echo", "azki-laplus-reposition", "azki-route-marker",
		"azki-laplus-guard-order", "azki-laplus-contract", "azki-dark-tether",
		"azki-singing-coordinate", "azki-laplus-overflow", "azki-necrobinder-finale"
	]
	var deck_ids := ["azki-map-shot", "azki-map-shot", "azki-guard", "azki-pinpoint", "azki-tune-up", "azki-kiss"]
	var result: Array[String] = drafter.draft(database, pool, deck_ids, [], 3, 2, 20260522)

	_expect_true(result.has("azki-laplus-guard-order") or result.has("azki-safe-route"), "AZKi 第一章 early reward 需前排提供防守橋接")

func _test_azki_fixed_auto_run_first_reward_frontloads_guard_order() -> void:
	var character := database.get_character("azki")
	var deck_ids := _string_array(character.get("starting_deck", []))
	var result: Array[String] = drafter.draft(database, _azki_pool(), deck_ids, [], 3, 1, 2026051674)

	_expect_eq(result[0] if not result.is_empty() else "", "azki-laplus-guard-order", "AZKi 固定 auto-run 第一個 reward 應優先給 Laplus 防守橋接")

func _resolve_sequence(player_hp: int, deck_ids: Array[String], enemy_ids: Array[String], passive: Dictionary, summon: Dictionary) -> Dictionary:
	var hp := player_hp
	for enemy_index in range(enemy_ids.size()):
		var enemy_id := enemy_ids[enemy_index]
		var deck := _resolve_deck(deck_ids)
		var state = combat_engine.start_combat(hp, player_hp, deck, database.get_enemy(enemy_id), [], false, passive, summon)
		var turns := 0
		while turns < MAX_TURNS and str(state.outcome) == "ongoing":
			turns += 1
			var played := true
			var plays_this_turn := 0
			while played and str(state.outcome) == "ongoing" and plays_this_turn < MAX_PLAYS_PER_TURN:
				plays_this_turn += 1
				played = _play_best_card(state)
			if str(state.outcome) == "ongoing":
				combat_engine.end_player_turn(state)
		if str(state.outcome) != "victory":
			return { "outcome": str(state.outcome), "player_hp": int(state.player_hp), "enemy_id": enemy_id }
		hp = int(state.player_hp)
		if enemy_index < enemy_ids.size() - 1:
			var reward: Array[String] = drafter.draft(database, _azki_pool(), deck_ids, [], 3, enemy_index + 1, 20260522 + enemy_index)
			if not reward.is_empty():
				deck_ids.append(reward[0])
	return { "outcome": "victory", "player_hp": hp }

func _play_best_card(state) -> bool:
	var best_index := -1
	var best_score := -99999.0
	for index in range(state.hand.size()):
		var card: Dictionary = state.hand[index]
		if bool(card.get("unplayable", false)) or str(card.get("id", "")).begins_with("curse-"):
			continue
		if int(card.get("cost", 0)) > int(state.player_energy):
			continue
		var score := _card_score(state, card)
		if score > best_score:
			best_score = score
			best_index = index
	if best_index < 0:
		return false
	return combat_engine.try_play_card(state, best_index)

func _card_score(state, card: Dictionary) -> float:
	var score := 0.0
	var enemy_attacking := str(state.current_intent.get("type", "")) in ["attack", "attack_block"]
	for effect_variant in card.get("effects", []):
		var effect: Dictionary = effect_variant
		score += _effect_score(effect, enemy_attacking)
	score -= float(int(card.get("cost", 0))) * 0.2
	return score

func _effect_score(effect: Dictionary, enemy_attacking: bool) -> float:
	match str(effect.get("type", "")):
		"damage":
			return float(int(effect.get("amount", 0)) * max(1, int(effect.get("hits", 1)))) * 3.0
		"block":
			return float(int(effect.get("amount", 0))) * (2.0 if enemy_attacking else 0.4)
		"draw":
			return float(int(effect.get("amount", 0))) * 4.0
		"draw_if_status":
			return float(int(effect.get("amount", 0))) * 3.5
		"energy":
			return float(int(effect.get("amount", 0))) * 5.0
		"status":
			var status_id := str(effect.get("status_id", ""))
			if status_id in ["marker", "vulnerable", "weak"]:
				return 9.0
			if status_id in ["strength", "regen"]:
				return 7.0
		"conditional":
			var nested := 0.0
			for nested_variant in effect.get("effects", []):
				nested += _effect_score(nested_variant, enemy_attacking)
			return nested * 0.8
		"summon_heal":
			return float(int(effect.get("amount", 0))) * 2.0
		"summon_hp_damage":
			return float(int(effect.get("base", 0)) + int(effect.get("per_hp", 1)) * 8) * 2.4
	return 0.0

func _resolve_deck(card_ids) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card_id in card_ids:
		result.append(database.get_card(str(card_id)))
	return result

func _string_array(values) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(str(value))
	return result

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

func _first_block_amount(card_id: String) -> int:
	var card := database.get_card(card_id)
	for effect_variant in card.get("effects", []):
		var effect: Dictionary = effect_variant
		if str(effect.get("type", "")) == "block":
			return int(effect.get("amount", 0))
	return 0

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
