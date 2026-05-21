extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")
const CombatEngineScript := preload("res://scripts/core/CombatEngine.gd")

const MAX_TURNS := 16
const MAX_PLAYS_PER_TURN := 48

var database = RuntimeDatabaseScript.new()
var combat_engine = CombatEngineScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_subaru_cheap_chain_early_fixture_beats_debuff_pressure()
	_test_subaru_natural_midrun_fixture_beats_repeated_debuff_check()
	_test_subaru_cheap_chain_late_fixture_beats_boss_warning()
	_test_botan_fortress_early_fixture_beats_block_puzzle()
	_test_botan_fortress_late_fixture_beats_high_attack_boss()
	_test_azki_marker_laplus_early_fixture_beats_multi_hit()
	_test_azki_marker_laplus_late_fixture_beats_elite_pressure()
	_test_azki_late_fixture_beats_camouflage_boss_pacing()

	if failures.is_empty():
		print("archetype_fixture_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("archetype_fixture_tests: failed (%d)" % failures.size())
		quit(1)

func _test_subaru_cheap_chain_early_fixture_beats_debuff_pressure() -> void:
	var deck := database.resolve_cards([
		"subaru-combo-boost", "subaru-opening-quack", "subaru-duck-tempo",
		"subaru-crowd-cover", "subaru-encore-recall", "subaru-afterimage-table",
		"subaru-table-slam-loop", "subaru-new-oshi-call", "subaru-tsukkomi",
		"subaru-rhythm-guard"
	])
	var character := database.get_character("subaru")
	var result := _resolve_fixture(78, deck, database.get_enemy("ssrb-debuff-check"), character.get("passive", {}), {})
	_expect_victory_with_hp(result, 18, "Subaru cheap_chain early_formed fixture 應能解 debuff pressure")

func _test_subaru_natural_midrun_fixture_beats_repeated_debuff_check() -> void:
	var deck := database.resolve_cards([
		"subaru-strike+", "subaru-strike", "subaru-guard+", "subaru-guard",
		"subaru-duck-rush", "subaru-draw-breath", "subaru-tsukkomi",
		"subaru-combo-boost", "subaru-opening-quack", "subaru-duck-tempo",
		"subaru-crowd-cover", "subaru-rhythm-guard", "subaru-new-oshi-call",
		"subaru-desk-reaction", "subaru-afterimage-table"
	])
	var character := database.get_character("subaru")
	var result := _resolve_fixture(78, deck, database.get_enemy("ssrb-debuff-check"), character.get("passive", {}), {})
	_expect_victory_with_hp_and_turn_cap(result, 16, 14, "Subaru natural midrun fixture 應能解 repeated debuff-check 壓力")

func _test_subaru_cheap_chain_late_fixture_beats_boss_warning() -> void:
	var deck := database.resolve_cards([
		"subaru-combo-boost+", "subaru-opening-quack+", "subaru-duck-tempo+",
		"subaru-crowd-cover+", "subaru-encore-recall+", "subaru-afterimage-table+",
		"subaru-table-slam-loop+", "subaru-unstoppable-cheer+", "subaru-team-rush+",
		"subaru-hype-call+", "subaru-blue-wave+", "subaru-new-oshi-call+",
		"subaru-tsukkomi+", "subaru-rhythm-guard+"
	])
	var character := database.get_character("subaru")
	var result := _resolve_fixture(112, deck, database.get_enemy("algorithm-core"), character.get("passive", {}), {})
	_expect_victory_with_hp(result, 20, "Subaru cheap_chain late_formed fixture 應能解 boss warning 類壓力")

func _test_botan_fortress_early_fixture_beats_block_puzzle() -> void:
	var deck := database.resolve_cards([
		"botan-kill-zone", "botan-cover-reload", "botan-flashbang-round",
		"botan-range-finder", "botan-overwatch", "botan-piercing-round",
		"botan-perfect-line", "botan-heavy-shot", "botan-fortified-cover",
		"botan-reload"
	])
	var character := database.get_character("botan")
	var result := _resolve_fixture(86, deck, database.get_enemy("buffering-wall"), character.get("passive", {}), {})
	_expect_victory_with_hp(result, 18, "Botan fortress_burst early_formed fixture 應能解 block puzzle")

func _test_botan_fortress_late_fixture_beats_high_attack_boss() -> void:
	var deck := database.resolve_cards([
		"botan-kill-zone+", "botan-cover-reload+", "botan-flashbang-round+",
		"botan-range-finder+", "botan-overwatch+", "botan-piercing-round+",
		"botan-perfect-line+", "botan-heavy-shot+", "botan-fortified-cover+",
		"botan-counter-line+", "botan-clean-scope+", "botan-precise-cover+",
		"botan-funds-prepared+", "botan-burst+"
	])
	var character := database.get_character("botan")
	var result := _resolve_fixture(118, deck, database.get_enemy("ssrb-giant-white"), character.get("passive", {}), {})
	_expect_victory_with_hp(result, 24, "Botan fortress_burst late_formed fixture 應能解 high attack boss")

func _test_azki_marker_laplus_early_fixture_beats_multi_hit() -> void:
	var deck := database.resolve_cards([
		"azki-phantom-route", "azki-route-marker", "azki-necro-recall",
		"azki-laplus-guard-order", "azki-dark-tether", "azki-marker-echo",
		"azki-laplus-release", "azki-laplus-overflow", "azki-map-search",
		"azki-safe-route", "azki-kiss"
	])
	var character := database.get_character("azki")
	var result := _resolve_fixture(92, deck, database.get_enemy("comment-flood"), character.get("passive", {}), character.get("summon", {}))
	_expect_victory_with_hp(result, 16, "AZKi marker_laplus early_formed fixture 應能解 multi-hit 壓力")

func _test_azki_marker_laplus_late_fixture_beats_elite_pressure() -> void:
	var deck := database.resolve_cards([
		"azki-phantom-route+", "azki-route-marker+", "azki-necro-recall+",
		"azki-laplus-guard-order+", "azki-dark-tether+", "azki-marker-echo+",
		"azki-laplus-release+", "azki-laplus-overflow+", "azki-necrobinder-finale+",
		"azki-laplus-contract+", "azki-laplus-cover+", "azki-coordinate-barrage+",
		"azki-open-route+", "azki-safe-route+", "azki-laplus-crash+"
	])
	var character := database.get_character("azki")
	var result := _resolve_fixture(124, deck, database.get_enemy("notification-storm-elite"), character.get("passive", {}), character.get("summon", {}))
	_expect_victory_with_hp(result, 18, "AZKi marker_laplus late_formed fixture 應能解 elite / boss 類壓力")

func _test_azki_late_fixture_beats_camouflage_boss_pacing() -> void:
	var deck := database.resolve_cards([
		"azki-phantom-route+", "azki-route-marker+", "azki-necro-recall+",
		"azki-laplus-guard-order+", "azki-dark-tether+", "azki-marker-echo+",
		"azki-laplus-release+", "azki-laplus-overflow+", "azki-necrobinder-finale+",
		"azki-laplus-contract+", "azki-laplus-cover+", "azki-coordinate-barrage+",
		"azki-open-route+", "azki-safe-route+", "azki-laplus-crash+"
	])
	var character := database.get_character("azki")
	var result := _resolve_fixture(124, deck, database.get_enemy("ssrb-giant-camouflage"), character.get("passive", {}), character.get("summon", {}))
	_expect_victory_with_hp_and_turn_cap(result, 14, 12, "AZKi late formed fixture 應能在合理節奏內解 camouflage boss")

func _resolve_fixture(player_hp: int, deck: Array[Dictionary], enemy: Dictionary, passive: Dictionary, summon: Dictionary) -> Dictionary:
	var state = combat_engine.start_combat(player_hp, player_hp, deck, enemy, [], false, passive, summon)
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
	return {
		"outcome": str(state.outcome),
		"turns": turns,
		"player_hp": int(state.player_hp),
		"enemy_hp": int(state.enemy_hp)
	}

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
	if int(state.next_attack_bonus) > 0 and str(card.get("kind", "")) == "attack":
		score += float(int(state.next_attack_bonus)) * 6.0
	score -= float(int(card.get("cost", 0))) * 0.3
	return score

func _effect_score(effect: Dictionary, enemy_attacking: bool) -> float:
	match str(effect.get("type", "")):
		"damage":
			return float(int(effect.get("amount", 0)) * max(1, int(effect.get("hits", 1)))) * 3.0
		"block":
			return float(int(effect.get("amount", 0))) * (2.4 if enemy_attacking else 0.5)
		"draw":
			return float(int(effect.get("amount", 0))) * 4.5
		"draw_from_discard":
			return float(int(effect.get("amount", 1))) * 7.0
		"next_attack_bonus":
			return float(int(effect.get("amount", 0))) * 5.5
		"temporary_card":
			var temp_card: Dictionary = effect.get("card", {})
			var score := 7.0
			for nested_variant in temp_card.get("effects", []):
				var nested: Dictionary = nested_variant
				score += _effect_score(nested, enemy_attacking) * 0.65
			return score
		"draw_if_status":
			return float(int(effect.get("amount", 0))) * 3.5
		"energy":
			return float(int(effect.get("amount", 0))) * 5.0
		"status":
			var status_id := str(effect.get("status_id", ""))
			if status_id in ["marker", "vulnerable", "weak"]:
				return 10.0
			if status_id in ["strength", "regen"]:
				return 8.0
		"conditional":
			var nested_score := 0.0
			for nested_variant in effect.get("effects", []):
				var nested: Dictionary = nested_variant
				nested_score += _effect_score(nested, enemy_attacking)
			return nested_score * 0.85
		"summon_heal":
			return float(int(effect.get("amount", 0))) * 2.4
		"summon_hp_damage":
			return float(int(effect.get("base", 0)) + int(effect.get("per_hp", 1)) * 10) * 2.6
	return 0.0

func _expect_victory_with_hp(result: Dictionary, min_hp: int, message: String) -> void:
	_expect_eq(str(result.get("outcome", "")), "victory", "%s outcome" % message)
	_expect_true(int(result.get("turns", 99)) <= MAX_TURNS, "%s turn guardrail" % message)
	_expect_true(int(result.get("player_hp", 0)) >= min_hp, "%s min HP guardrail，result=%s" % [message, JSON.stringify(result)])

func _expect_victory_with_hp_and_turn_cap(result: Dictionary, min_hp: int, max_turns: int, message: String) -> void:
	_expect_eq(str(result.get("outcome", "")), "victory", "%s outcome" % message)
	_expect_true(int(result.get("turns", 99)) <= max_turns, "%s turn cap %d，result=%s" % [message, max_turns, JSON.stringify(result)])
	_expect_true(int(result.get("player_hp", 0)) >= min_hp, "%s min HP guardrail，result=%s" % [message, JSON.stringify(result)])

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
