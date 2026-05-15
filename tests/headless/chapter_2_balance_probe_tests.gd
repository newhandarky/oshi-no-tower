extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")
const CombatEngineScript := preload("res://scripts/core/CombatEngine.gd")

const MAX_TURNS := 14
const MAX_PLAYS_PER_TURN := 40

var database = RuntimeDatabaseScript.new()
var combat_engine = CombatEngineScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_subaru_cheap_chain_can_answer_anti_cycle_probe()
	_test_botan_burst_can_answer_block_puzzle_probe()
	_test_azki_laplus_can_answer_multi_hit_probe()

	if failures.is_empty():
		print("chapter_2_balance_probe_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("chapter_2_balance_probe_tests: failed (%d)" % failures.size())
		quit(1)

func _test_subaru_cheap_chain_can_answer_anti_cycle_probe() -> void:
	var deck := database.resolve_cards([
		"subaru-duck-tempo+", "subaru-duck-tempo+", "subaru-new-oshi-call+",
		"subaru-hype-call+", "subaru-table-slam-loop+", "subaru-team-rush+",
		"subaru-rhythm-guard+", "subaru-crowd-cover+", "subaru-blue-wave+",
		"subaru-tsukkomi+"
	])
	var character := database.get_character("subaru")
	var result := _resolve_probe(92, deck, database.get_enemy("recommendation-watcher"), [], character.get("passive", {}), {})
	_expect_eq(str(result.get("outcome", "")), "victory", "Subaru cheap-chain probe 應能打贏 recommendation-watcher")
	_expect_true(int(result.get("turns", 99)) <= MAX_TURNS, "Subaru cheap-chain probe 不應拖過 guardrail")

func _test_botan_burst_can_answer_block_puzzle_probe() -> void:
	var deck := database.resolve_cards([
		"botan-funds-prepared+", "botan-steady-aim+", "botan-range-finder+",
		"botan-heavy-shot+", "botan-piercing-round+", "botan-perfect-line+",
		"botan-counter-line+", "botan-overwatch+", "botan-cover+", "botan-burst+"
	])
	var character := database.get_character("botan")
	var result := _resolve_probe(96, deck, database.get_enemy("buffering-wall"), [], character.get("passive", {}), {})
	_expect_eq(str(result.get("outcome", "")), "victory", "Botan burst probe 應能打贏 buffering-wall")
	_expect_true(int(result.get("turns", 99)) <= MAX_TURNS, "Botan burst probe 不應拖過 guardrail")

func _test_azki_laplus_can_answer_multi_hit_probe() -> void:
	var deck := database.resolve_cards([
		"azki-map-search+", "azki-route-marker+", "azki-marker-echo+",
		"azki-laplus-guard-order+", "azki-laplus-cover+", "azki-coordinate-barrage+",
		"azki-laplus-crash+", "azki-laplus-contract+", "azki-dark-tether+",
		"azki-laplus-overflow+", "azki-necrobinder-finale+", "azki-open-route+",
		"azki-safe-route+"
	])
	var character := database.get_character("azki")
	var result := _resolve_probe(98, deck, database.get_enemy("comment-flood"), [], character.get("passive", {}), character.get("summon", {}))
	_expect_eq(str(result.get("outcome", "")), "victory", "AZKi/Laplus probe 應能打贏 comment-flood")
	_expect_true(int(result.get("turns", 99)) <= MAX_TURNS, "AZKi/Laplus probe 不應拖過 guardrail")

func _resolve_probe(player_hp: int, deck: Array[Dictionary], enemy: Dictionary, relics: Array[Dictionary], passive: Dictionary, summon: Dictionary) -> Dictionary:
	var state = combat_engine.start_combat(player_hp, player_hp, deck, enemy, relics, false, passive, summon)
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

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
