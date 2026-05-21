class_name CardRewardDraft
extends RefCounted

const SURVIVAL_ROLES := ["defense", "bridge"]

func draft(database, pool, deck_ids, relic_ids, amount: int, floor: int, seed: int) -> Array[String]:
	var valid_pool: Array[String] = _valid_pool_for_floor(database, pool, floor)
	if valid_pool.is_empty():
		valid_pool = _valid_pool(database, pool)
	var deck_signal: Dictionary = _build_signal(database, deck_ids, relic_ids)
	var selected: Array[String] = []
	_add_pick(selected, _pick_azki_early_survival_bridge(database, valid_pool, deck_signal, floor, selected))
	_add_pick(selected, _pick_build_relevant(database, valid_pool, deck_signal, floor, seed, selected))
	_add_pick(selected, _pick_role_gap(database, valid_pool, deck_signal, floor, seed + 11, selected))
	_add_pick(selected, _pick_survival_or_bridge(database, valid_pool, deck_signal, floor, seed + 17, selected))
	_add_pick(selected, _pick_wildcard(database, valid_pool, deck_signal, floor, seed + 31, selected))
	while selected.size() < amount:
		var pick := _pick_wildcard(database, valid_pool, deck_signal, floor, seed + 31 + selected.size() * 13, selected)
		if pick == "":
			break
		_add_pick(selected, pick)
	var result: Array[String] = []
	for index in range(min(amount, selected.size())):
		result.append(str(selected[index]))
	return result

func sort_shop_cards(database, pool, deck_ids, relic_ids, floor: int, seed: int) -> Array[String]:
	var deck_signal: Dictionary = _build_signal(database, deck_ids, relic_ids)
	var remaining: Array[String] = _valid_pool(database, pool)
	var result: Array[String] = []
	var index := 0
	while not remaining.is_empty():
		var pick := _pick_best(database, remaining, deck_signal, floor, seed + index * 19, [])
		if pick == "":
			break
		result.append(pick)
		remaining.erase(pick)
		index += 1
	return result

func _add_pick(selected: Array[String], card_id: String) -> void:
	if card_id == "" or selected.has(card_id):
		return
	selected.append(card_id)

func _pick_build_relevant(database, pool: Array[String], deck_signal: Dictionary, floor: int, seed: int, exclude: Array[String]) -> String:
	var candidates: Array[String] = []
	for card_id in pool:
		if exclude.has(card_id):
			continue
		var card: Dictionary = database.get_card(card_id)
		if _archetype_score(card, deck_signal) > 0:
			candidates.append(card_id)
	return _pick_best(database, candidates if not candidates.is_empty() else pool, deck_signal, floor, seed, exclude)

func _pick_survival_or_bridge(database, pool: Array[String], deck_signal: Dictionary, floor: int, seed: int, exclude: Array[String]) -> String:
	var candidates: Array[String] = []
	for card_id in pool:
		if exclude.has(card_id):
			continue
		var card: Dictionary = database.get_card(card_id)
		if _has_any_role(card, SURVIVAL_ROLES):
			candidates.append(card_id)
	return _pick_best(database, candidates if not candidates.is_empty() else pool, deck_signal, floor, seed, exclude)

func _pick_role_gap(database, pool: Array[String], deck_signal: Dictionary, floor: int, seed: int, exclude: Array[String]) -> String:
	var target_roles: Array[String] = []
	if int(deck_signal.get("role:defense", 0)) < 3:
		target_roles.append("defense")
	if int(deck_signal.get("role:payoff", 0)) < 2:
		target_roles.append("payoff")
	if floor >= 7 and int(deck_signal.get("role:scaling", 0)) < 1:
		target_roles.append("scaling")
	if int(deck_signal.get("role:bridge", 0)) < 2:
		target_roles.append("bridge")
	if target_roles.is_empty():
		return ""
	var candidates: Array[String] = []
	for card_id in pool:
		if exclude.has(card_id):
			continue
		var card: Dictionary = database.get_card(card_id)
		if _has_any_role(card, target_roles):
			candidates.append(card_id)
	return _pick_best(database, candidates, deck_signal, floor, seed, exclude)

func _pick_wildcard(database, pool: Array[String], deck_signal: Dictionary, floor: int, seed: int, exclude: Array[String]) -> String:
	return _pick_best(database, pool, deck_signal, floor, seed, exclude)

func _pick_azki_early_survival_bridge(database, pool: Array[String], deck_signal: Dictionary, floor: int, exclude: Array[String]) -> String:
	if floor > 6 or int(deck_signal.get("marker_loop", 0)) < 1:
		return ""
	for preferred_id in ["azki-laplus-guard-order", "azki-laplus-contract", "azki-dark-tether", "azki-safe-route"]:
		if exclude.has(preferred_id) or not pool.has(preferred_id):
			continue
		if int(deck_signal.get("card:%s" % preferred_id, 0)) >= 1:
			continue
		var card: Dictionary = database.get_card(preferred_id)
		if str(card.get("character", "")) == "azki":
			return preferred_id
	return ""

func _pick_best(database, pool: Array[String], deck_signal: Dictionary, floor: int, seed: int, exclude: Array[String]) -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var best_id := ""
	var best_score := -99999.0
	for card_id in pool:
		if exclude.has(card_id):
			continue
		var card: Dictionary = database.get_card(card_id)
		var score := _card_score(card, deck_signal, floor) + rng.randf() * 0.01
		if score > best_score:
			best_score = score
			best_id = card_id
	return best_id

func _card_score(card: Dictionary, deck_signal: Dictionary, floor: int) -> float:
	var score := 10.0
	var card_id := str(card.get("id", ""))
	var existing_copies := int(deck_signal.get("card:%s" % card_id, 0))
	if existing_copies > 0 and str(card.get("rarity", "")) != "starter":
		var duplicate_penalty := 96.0 if str(card.get("character", "")) == "azki" else 46.0
		if str(card.get("rarity", "")) == "rare":
			duplicate_penalty += 34.0
		score -= float(existing_copies) * duplicate_penalty
	score += float(_archetype_score(card, deck_signal)) * 18.0
	score += _subaru_natural_balance_bonus(card, deck_signal, floor)
	score += _subaru_midrun_tempo_block_bonus(card, deck_signal, floor)
	score += _botan_midrun_guard_bonus(card, deck_signal, floor)
	score += _botan_depth_balance_bonus(card, deck_signal, floor)
	score += _azki_early_survival_bonus(card, deck_signal, floor)
	score += _azki_natural_balance_bonus(card, deck_signal, floor)
	score += _azki_chapter_2_consistency_bonus(card, deck_signal, floor)
	score += _azki_midrun_payoff_bonus(card, deck_signal, floor)
	score += _role_gap_bonus(card, deck_signal, floor)
	if _has_any_role(card, SURVIVAL_ROLES):
		score += 7.0
	if card.get("role_tags", []).has("setup"):
		score += 4.0
	if card.get("role_tags", []).has("payoff") and _archetype_score(card, deck_signal) <= 0:
		score -= 5.0
	match str(card.get("rarity", "common")):
		"rare":
			score += -100.0 if floor <= 3 else (7.0 if floor >= 10 else 1.0)
		"uncommon":
			score += 4.0 if floor >= 4 else 0.0
		"starter":
			score -= 20.0
		"curse":
			score -= 100.0
	return score

func _role_gap_bonus(card: Dictionary, deck_signal: Dictionary, floor: int) -> float:
	var score := 0.0
	if int(deck_signal.get("role:defense", 0)) < 3 and card.get("role_tags", []).has("defense"):
		score += 42.0
	if int(deck_signal.get("role:payoff", 0)) < 2 and card.get("role_tags", []).has("payoff"):
		score += 38.0
	if floor >= 7 and int(deck_signal.get("role:scaling", 0)) < 1 and card.get("role_tags", []).has("scaling"):
		score += 52.0
	if int(deck_signal.get("role:bridge", 0)) < 2 and card.get("role_tags", []).has("bridge"):
		score += 18.0
	return score

func _subaru_natural_balance_bonus(card: Dictionary, deck_signal: Dictionary, floor: int) -> float:
	if str(card.get("character", "")) != "subaru":
		return 0.0
	var cheap_chain_count := int(deck_signal.get("cheap_chain", 0))
	if cheap_chain_count < 3:
		return 0.0
	var card_id := str(card.get("id", ""))
	if floor >= 7 and floor <= 11:
		var defense_count := int(deck_signal.get("role:defense", 0))
		var bridge_count := int(deck_signal.get("role:bridge", 0))
		if defense_count < 5 or bridge_count < 4:
			if card_id in ["subaru-encore-recall", "subaru-afterimage-table", "subaru-crowd-cover"]:
				return 92.0
			if card_id in ["subaru-blue-wave", "subaru-cheer-recover", "subaru-unstoppable-cheer"]:
				return -55.0
	if floor >= 7 and int(deck_signal.get("role:defense", 0)) >= 3 and int(deck_signal.get("role:payoff", 0)) < 3:
		if card_id in ["subaru-table-slam-loop", "subaru-afterimage-table", "subaru-unstoppable-cheer"]:
			return 28.0
	return 0.0

func _subaru_midrun_tempo_block_bonus(card: Dictionary, deck_signal: Dictionary, floor: int) -> float:
	if floor < 5 or floor > 12:
		return 0.0
	if str(card.get("character", "")) != "subaru":
		return 0.0
	if int(deck_signal.get("cheap_chain", 0)) < 4:
		return 0.0
	var card_id := str(card.get("id", ""))
	if card_id in ["subaru-crowd-cover", "subaru-rhythm-guard", "subaru-desk-reaction", "subaru-new-oshi-call"]:
		return 46.0
	if card.get("archetype_tags", []).has("tempo_block") and _has_any_role(card, ["defense", "bridge"]):
		return 30.0
	if card_id in ["subaru-cheer-recover", "subaru-hype-call"] and int(deck_signal.get("card:%s" % card_id, 0)) >= 1:
		return -35.0
	return 0.0

func _botan_midrun_guard_bonus(card: Dictionary, deck_signal: Dictionary, floor: int) -> float:
	if floor < 7 or floor > 13:
		return 0.0
	if str(card.get("character", "")) != "botan":
		return 0.0
	if int(deck_signal.get("two_cost_burst", 0)) < 4:
		return 0.0
	var card_id := str(card.get("id", ""))
	if card_id in ["botan-clean-scope", "botan-overwatch", "botan-fortified-cover", "botan-counter-line", "botan-precise-cover"]:
		return 46.0
	if card_id == "botan-perfect-line" and int(deck_signal.get("card:botan-perfect-line", 0)) >= 1:
		return -80.0
	if _has_any_role(card, ["defense", "bridge"]):
		return 24.0
	return 0.0

func _botan_depth_balance_bonus(card: Dictionary, deck_signal: Dictionary, floor: int) -> float:
	if floor < 7 or str(card.get("character", "")) != "botan":
		return 0.0
	var card_id := str(card.get("id", ""))
	var existing_copies := int(deck_signal.get("card:%s" % card_id, 0))
	if card_id in ["botan-kill-zone", "botan-cover-reload"] and existing_copies >= 2:
		return -180.0
	if card_id == "botan-perfect-line" and existing_copies >= 1:
		return -120.0
	var repeated_setup_bridge := _botan_repeated_setup_bridge_count(deck_signal)
	if repeated_setup_bridge < 4:
		return 0.0
	if card_id in ["botan-overwatch", "botan-clean-scope", "botan-fortified-cover", "botan-counter-line", "botan-flashbang-round", "botan-precise-cover"]:
		return 96.0
	if _has_any_role(card, ["defense"]) and existing_copies == 0:
		return 42.0
	return 0.0

func _botan_repeated_setup_bridge_count(deck_signal: Dictionary) -> int:
	var count := 0
	for card_id in ["botan-kill-zone", "botan-cover-reload", "botan-perfect-line"]:
		count += int(deck_signal.get("card:%s" % card_id, 0))
	return count

func _azki_early_survival_bonus(card: Dictionary, deck_signal: Dictionary, floor: int) -> float:
	if floor > 5:
		return 0.0
	if str(card.get("character", "")) != "azki":
		return 0.0
	if int(deck_signal.get("marker_loop", 0)) < 1:
		return 0.0
	var card_id := str(card.get("id", ""))
	if card_id == "azki-laplus-guard-order":
		return 42.0
	if card_id == "azki-laplus-contract":
		return 38.0
	if card_id == "azki-dark-tether":
		return 34.0
	if card_id == "azki-safe-route":
		return 28.0
	if card_id == "azki-phantom-route":
		return 30.0
	if card.get("archetype_tags", []).has("laplus_guard") and _has_any_role(card, SURVIVAL_ROLES):
		return 24.0
	return 0.0

func _azki_natural_balance_bonus(card: Dictionary, deck_signal: Dictionary, floor: int) -> float:
	if floor < 7 or floor > 11:
		return 0.0
	if str(card.get("character", "")) != "azki":
		return 0.0
	if int(deck_signal.get("marker_loop", 0)) < 1 or int(deck_signal.get("laplus_guard", 0)) < 2:
		return 0.0
	var card_id := str(card.get("id", ""))
	if _azki_existing_laplus_payoff_count(deck_signal) < 2 and card_id in ["azki-laplus-overflow", "azki-laplus-release", "azki-necrobinder-finale", "azki-laplus-crash", "azki-laplus-combo"]:
		return 58.0
	if _azki_existing_laplus_payoff_count(deck_signal) >= 1 and card_id in ["azki-phantom-route", "azki-necro-recall", "azki-laplus-cover", "azki-laplus-reposition", "azki-safe-route", "azki-dark-tether"]:
		return 28.0
	return 0.0

func _azki_chapter_2_consistency_bonus(card: Dictionary, deck_signal: Dictionary, floor: int) -> float:
	if floor < 6:
		return 0.0
	if int(deck_signal.get("marker_loop", 0)) < 2:
		if floor < 6 or int(deck_signal.get("marker_loop", 0)) < 1:
			return 0.0
	if str(card.get("character", "")) != "azki":
		return 0.0
	var bonus := 0.0
	if card.get("archetype_tags", []).has("laplus_guard"):
		bonus += 45.0
		if floor <= 8:
			bonus += 20.0
	if floor >= 8 and (card.get("role_tags", []).has("payoff") or card.get("role_tags", []).has("scaling")):
		bonus += 50.0
	return bonus

func _azki_midrun_payoff_bonus(card: Dictionary, deck_signal: Dictionary, floor: int) -> float:
	if floor < 8:
		return 0.0
	if str(card.get("character", "")) != "azki":
		return 0.0
	if int(deck_signal.get("laplus_guard", 0)) < 2 or int(deck_signal.get("marker_loop", 0)) < 2:
		return 0.0
	var card_id := str(card.get("id", ""))
	if floor >= 10 and _azki_existing_laplus_payoff_count(deck_signal) < 1:
		if card_id in ["azki-necrobinder-finale", "azki-laplus-combo", "azki-laplus-release"]:
			return 128.0
		if card_id in ["azki-laplus-guard-order", "azki-laplus-contract", "azki-safe-route"]:
			return -42.0
	if _azki_existing_laplus_payoff_count(deck_signal) >= 2 and card_id in ["azki-laplus-cover", "azki-laplus-reposition", "azki-safe-route", "azki-coordinate-shield", "azki-phantom-route", "azki-necro-recall", "azki-laplus-guard-order", "azki-laplus-contract", "azki-dark-tether"]:
		return 138.0
	if card_id in ["azki-laplus-overflow", "azki-necrobinder-finale", "azki-laplus-crash", "azki-laplus-combo", "azki-laplus-release"]:
		if int(deck_signal.get("card:%s" % card_id, 0)) >= 1:
			return -95.0
		return 74.0
	if card.get("role_tags", []).has("payoff") or card.get("role_tags", []).has("scaling"):
		return 48.0
	if int(deck_signal.get("card:%s" % card_id, 0)) >= 1 and _has_any_role(card, ["bridge", "setup"]):
		return -45.0
	return 0.0

func _azki_existing_laplus_payoff_count(deck_signal: Dictionary) -> int:
	var count := 0
	for card_id in ["azki-laplus-overflow", "azki-necrobinder-finale", "azki-laplus-crash", "azki-laplus-combo", "azki-laplus-release"]:
		count += int(deck_signal.get("card:%s" % card_id, 0))
	return count

func _archetype_score(card: Dictionary, deck_signal: Dictionary) -> int:
	var score := 0
	for tag in card.get("archetype_tags", []):
		score += int(deck_signal.get(str(tag), 0))
	return score

func _has_any_role(card: Dictionary, roles) -> bool:
	for role in roles:
		if card.get("role_tags", []).has(str(role)):
			return true
	return false

func _build_signal(database, deck_ids, relic_ids) -> Dictionary:
	var deck_signal := {}
	for card_id in deck_ids:
		var base_id := str(card_id)
		if base_id.ends_with("+"):
			base_id = base_id.substr(0, base_id.length() - 1)
		deck_signal["card:%s" % base_id] = int(deck_signal.get("card:%s" % base_id, 0)) + 1
		var card: Dictionary = database.get_card(base_id)
		for tag in card.get("archetype_tags", []):
			deck_signal[str(tag)] = int(deck_signal.get(str(tag), 0)) + 1
		for role in card.get("role_tags", []):
			deck_signal["role:%s" % str(role)] = int(deck_signal.get("role:%s" % str(role), 0)) + 1
	for relic_id in relic_ids:
		var relic: Dictionary = database.get_relic(str(relic_id))
		for tag in relic.get("archetype_tags", []):
			deck_signal[str(tag)] = int(deck_signal.get(str(tag), 0)) + 2
	return deck_signal

func _valid_pool_for_floor(database, pool, floor: int) -> Array[String]:
	var result: Array[String] = []
	for card_id in _valid_pool(database, pool):
		var card: Dictionary = database.get_card(card_id)
		if floor <= 3 and str(card.get("rarity", "")) == "rare":
			continue
		result.append(card_id)
	return result

func _valid_pool(database, pool) -> Array[String]:
	var result: Array[String] = []
	for card_id in pool:
		var card: Dictionary = database.get_card(str(card_id))
		if str(card.get("rarity", "")) in ["starter", "curse"]:
			continue
		if not result.has(str(card_id)):
			result.append(str(card_id))
	return result
