class_name CombatEngine
extends RefCounted

const CombatStateScript := preload("res://scripts/core/CombatState.gd")

func start_combat(player_hp: int, player_max_hp: int, deck: Array[Dictionary], enemy: Dictionary, relics: Array[Dictionary] = [], shuffle_deck := false, character_passive: Dictionary = {}, summon_config: Dictionary = {}):
	var state = CombatStateScript.new()
	state.player_hp = player_hp
	state.player_max_hp = player_max_hp
	state.player_energy = 3
	state.enemy = enemy
	state.enemy_hp = enemy["max_hp"]
	state.enemy_max_hp = enemy["max_hp"]
	state.current_intent = enemy["actions"][0]
	state.character_passive = character_passive.duplicate(true)
	_setup_summon(state, summon_config)
	state.relics = relics.duplicate(true)
	for relic in state.relics:
		state.relic_ids.append(str(relic["id"]))
	_apply_combat_start_relics(state)
	state.draw_pile = deck.duplicate(true)
	if shuffle_deck:
		state.draw_pile.shuffle()
	draw_cards(state, 5)
	return state

func try_play_card(state, hand_index: int) -> bool:
	if state.outcome != "ongoing":
		return false
	if hand_index < 0 or hand_index >= state.hand.size():
		return false

	var card: Dictionary = state.hand[hand_index]
	if bool(card.get("unplayable", false)):
		return false
	if state.player_energy < card["cost"]:
		return false

	state.player_energy -= card["cost"]
	state.hand.remove_at(hand_index)
	state.cards_played_this_turn += 1
	_apply_card_played_relics(state, card)
	_apply_card_played_passive(state, card)
	for effect in card["effects"]:
		_resolve_effect(state, effect, card)
	if bool(card.get("temporary", false)) or bool(card.get("exhaust_on_play", false)) or _card_has_effect_type(card, "exhaust_on_play"):
		state.exhaust_pile.append(_clear_runtime_card_flags(card))
	else:
		state.discard_pile.append(_clear_runtime_card_flags(card))

	if state.enemy_hp <= 0:
		state.enemy_hp = 0
		state.outcome = "victory"

	return true

func end_player_turn(state) -> String:
	_apply_end_turn_hand_effects(state)
	_move_end_turn_hand_cards(state)
	state.next_attack_bonus = 0
	_resolve_enemy_action(state)

	if state.player_hp <= 0:
		state.player_hp = 0
		state.outcome = "defeat"
		return state.outcome

	state.enemy_action_index += 1
	state.player_energy = 3
	state.player_block = 0
	state.passive_flags.clear()
	state.relic_turn_flags.clear()
	state.turn_events.clear()
	state.cards_played_this_turn = 0
	state.current_intent = state.enemy["actions"][state.enemy_action_index % state.enemy["actions"].size()]
	_push_boss_warning_for_current_intent(state)
	_apply_player_turn_start_summon(state)
	_apply_turn_start_relics(state)
	draw_cards(state, 5)
	return state.outcome

func _push_turn_event(state, event_id: String, text: String, kind := "info", source := "system") -> void:
	if event_id == "" or text == "":
		return
	state.turn_events.append({
		"id": event_id,
		"text": text,
		"kind": kind,
		"source": source
	})

func _push_boss_warning_for_current_intent(state) -> void:
	if not bool(state.enemy.get("is_boss", false)):
		return
	var intent_type := str(state.current_intent.get("type", ""))
	if intent_type not in ["attack", "attack_block"]:
		return
	var damage := int(state.current_intent.get("damage", 0))
	if damage < 24:
		return
	var danger_tag := str(state.enemy.get("boss_danger_tag", "高傷警告"))
	var description := str(state.current_intent.get("description", "重擊即將到來"))
	var counterplay := str(state.enemy.get("boss_counterplay", ""))
	var warning_text := "Boss 警告：[%s] %s" % [danger_tag, description]
	if counterplay != "":
		warning_text = "%s。%s" % [warning_text, counterplay]
	_push_turn_event(state, "boss-warning", warning_text, "warning", "boss_intent")

func _setup_summon(state, summon_config: Dictionary) -> void:
	var summon_id := str(summon_config.get("id", ""))
	if summon_id == "":
		return
	state.summon_id = summon_id
	state.summon_max_hp = int(summon_config.get("max_hp", 0))
	state.summon_hp = max(0, int(summon_config.get("starting_hp", state.summon_max_hp)))
	state.summon_alive = state.summon_hp > 0

func _apply_player_turn_start_summon(state) -> void:
	if state.summon_id == "" or int(state.enemy_hp) <= 0:
		return
	state.summon_alive = state.summon_hp > 0

func draw_cards(state, amount: int) -> void:
	for _i in range(amount):
		if state.draw_pile.is_empty():
			state.draw_pile.append_array(state.discard_pile)
			state.discard_pile.clear()
		if state.draw_pile.is_empty():
			return
		var card: Dictionary = _clear_runtime_card_flags(state.draw_pile.pop_front())
		state.hand.append(card)
		_apply_drawn_card_effect(state, card)

func _apply_combat_start_relics(state) -> void:
	for relic in state.relics:
		if str(relic.get("hook", "")) != "combat_start":
			continue
		_apply_relic_effects(state, relic)

func _apply_turn_start_relics(state) -> void:
	for relic in state.relics:
		if str(relic.get("hook", "")) != "turn_start":
			continue
		_apply_relic_effects(state, relic)

func _apply_drawn_card_effect(state, card: Dictionary) -> void:
	if str(card.get("curse_hook", "")) != "on_draw":
		return
	_apply_curse_effect(state, card)

func _apply_end_turn_hand_effects(state) -> void:
	for card_variant in state.hand:
		var card: Dictionary = card_variant
		if str(card.get("curse_hook", "")) != "end_turn_in_hand":
			continue
		_apply_curse_effect(state, card)

func _move_end_turn_hand_cards(state) -> void:
	var retained_cards: Array[Dictionary] = []
	for card_variant in state.hand:
		var card: Dictionary = card_variant
		if bool(card.get("ethereal", false)):
			state.exhaust_pile.append(_clear_runtime_card_flags(card))
		elif bool(card.get("retain", false)):
			var retained_card := card.duplicate(true)
			retained_card["_retained_from_previous_turn"] = true
			retained_cards.append(retained_card)
		else:
			state.discard_pile.append(_clear_runtime_card_flags(card))
	state.hand.clear()
	state.hand.append_array(retained_cards)

func _apply_curse_effect(state, card: Dictionary) -> void:
	match str(card.get("curse_effect", "")):
		"lose_energy":
			state.player_energy = max(0, state.player_energy - int(card.get("curse_amount", 0)))
		"lose_hp":
			state.player_hp = max(0, state.player_hp - int(card.get("curse_amount", 0)))
		"self_status":
			apply_status(state, "player", {
				"id": str(card.get("curse_status_id", "")),
				"value": int(card.get("curse_status_value", 1)),
				"duration": int(card.get("curse_status_duration", 1))
			})

func _apply_card_played_relics(state, card: Dictionary) -> void:
	for relic in state.relics:
		var relic_id := str(relic.get("id", ""))
		var hook := str(relic.get("hook", ""))
		if hook == "first_attack_played" and not bool(state.relic_flags.get(relic_id, false)) and str(card.get("kind", "")) == "attack":
			state.relic_flags[relic_id] = true
			_apply_relic_effects(state, relic)
		if hook == "first_cheap_card_played" and not bool(state.relic_flags.get(relic_id, false)) and int(card.get("cost", 0)) <= int(relic.get("cost_max", 1)):
			state.relic_flags[relic_id] = true
			_apply_relic_effects(state, relic)
		if hook == "first_two_cost_played" and not bool(state.relic_flags.get(relic_id, false)) and int(card.get("cost", 0)) >= 2:
			state.relic_flags[relic_id] = true
			_apply_relic_effects(state, relic)
		if hook == "first_marker_card_played" and not bool(state.relic_flags.get(relic_id, false)) and _card_applies_status(card, "marker"):
			state.relic_flags[relic_id] = true
			_apply_relic_effects(state, relic)
		_apply_card_played_relic_v2(state, relic, card)

func _apply_card_played_relic_v2(state, relic: Dictionary, card: Dictionary) -> void:
	if str(relic.get("trigger", "")) != "card_played":
		return
	var relic_id := str(relic.get("id", ""))
	var limit := str(relic.get("limit", ""))
	if limit == "once_per_combat" and bool(state.relic_flags.get(relic_id, false)):
		return
	if limit == "once_per_turn" and bool(state.relic_turn_flags.get(relic_id, false)):
		return
	var condition: Dictionary = relic.get("condition", {})
	if not _condition_matches(state, condition, card):
		return
	if limit == "once_per_combat":
		state.relic_flags[relic_id] = true
	elif limit == "once_per_turn":
		state.relic_turn_flags[relic_id] = true
	_apply_relic_effects(state, relic)

func _apply_context_relics(state, trigger: String, context: Dictionary) -> void:
	for relic in state.relics:
		if str(relic.get("trigger", "")) != trigger:
			continue
		var relic_id := str(relic.get("id", ""))
		var limit := str(relic.get("limit", ""))
		if limit == "once_per_combat" and bool(state.relic_flags.get(relic_id, false)):
			continue
		if limit == "once_per_turn" and bool(state.relic_turn_flags.get(relic_id, false)):
			continue
		var condition: Dictionary = relic.get("condition", {})
		if not _relic_context_condition_matches(state, condition, context):
			continue
		if limit == "once_per_combat":
			state.relic_flags[relic_id] = true
		elif limit == "once_per_turn":
			state.relic_turn_flags[relic_id] = true
		_apply_relic_trigger_effects(state, relic)

func _relic_context_condition_matches(state, condition: Dictionary, context: Dictionary) -> bool:
	if condition.is_empty():
		return true
	if condition.has("bonus_amount_at_least") and int(context.get("bonus_amount", 0)) < int(condition.get("bonus_amount_at_least", 0)):
		return false
	if condition.has("retrieved_kind") and not _context_cards_include_kind(context.get("retrieved_cards", []), str(condition.get("retrieved_kind", ""))):
		return false
	if condition.has("temporary_card_kind") and not _context_cards_include_kind(context.get("temporary_cards", []), str(condition.get("temporary_card_kind", ""))):
		return false
	if condition.has("has_summon") and bool(condition.get("has_summon", false)) != (str(state.summon_id) != ""):
		return false
	return true

func _context_cards_include_kind(cards: Array, expected_kind: String) -> bool:
	if expected_kind == "":
		return true
	for card_variant in cards:
		var card: Dictionary = card_variant
		if str(card.get("kind", "")) == expected_kind:
			return true
	return false

func _apply_relic_trigger_effects(state, relic: Dictionary) -> void:
	if relic.has("trigger_effects"):
		for effect_variant in relic.get("trigger_effects", []):
			var effect: Dictionary = effect_variant
			_apply_single_relic_effect(state, relic, effect)
		return
	_apply_relic_effects(state, relic)

func _apply_relic_effects(state, relic: Dictionary) -> void:
	if relic.has("effects"):
		for effect_variant in relic.get("effects", []):
			var effect: Dictionary = effect_variant
			_apply_single_relic_effect(state, relic, effect)
		return
	_apply_single_relic_effect(state, relic, relic)

func _apply_single_relic_effect(state, relic: Dictionary, effect: Dictionary) -> void:
	match str(effect.get("effect", "")):
		"block":
			state.player_block += int(effect.get("amount", 0))
		"energy":
			state.player_energy += int(effect.get("amount", 0))
		"strength":
			apply_status(state, "player", { "id": "strength", "value": int(effect.get("amount", 0)), "duration": 99 })
		"regen":
			apply_status(state, "player", { "id": "regen", "value": int(effect.get("amount", 0)), "duration": 99 })
		"heal":
			state.player_hp = min(state.player_max_hp, state.player_hp + int(effect.get("amount", 0)))
		"summon_heal":
			_heal_summon(state, int(effect.get("amount", 0)))
		"draw":
			draw_cards(state, int(effect.get("amount", 0)))
		"bonus_damage":
			_damage_enemy(state, int(effect.get("amount", 0)))
		"turn_event":
			_push_turn_event(state, str(relic.get("id", "")), str(effect.get("text", relic.get("description", ""))), "relic", "relic")

func _card_applies_status(card: Dictionary, status_id: String) -> bool:
	for effect_variant in card.get("effects", []):
		var effect: Dictionary = effect_variant
		if str(effect.get("type", "")) == "status" and str(effect.get("status_id", "")) == status_id:
			return true
		if str(effect.get("type", "")) == "conditional":
			var nested_effects: Array = effect.get("effects", [])
			for nested_variant in nested_effects:
				var nested: Dictionary = nested_variant
				if str(nested.get("type", "")) == "status" and str(nested.get("status_id", "")) == status_id:
					return true
	return false

func _card_has_effect_type(card: Dictionary, effect_type: String) -> bool:
	for effect_variant in card.get("effects", []):
		var effect: Dictionary = effect_variant
		if str(effect.get("type", "")) == effect_type:
			return true
	return false

func _apply_card_played_passive(state, card: Dictionary) -> void:
	var passive: Dictionary = state.character_passive
	var passive_id := str(passive.get("id", ""))
	if passive_id == "":
		return
	if bool(state.passive_flags.get(passive_id, false)):
		return
	match str(passive.get("hook", "")):
		"first_cheap_card_each_turn":
			if int(card.get("cost", 0)) <= int(passive.get("cost_max", 1)):
				state.passive_flags[passive_id] = true
				state.player_block += int(passive.get("block", 0))
				_push_turn_event(state, passive_id, str(passive.get("preview_text", passive.get("description", ""))), "identity", "passive")
		"first_two_cost_attack_each_turn":
			if int(card.get("cost", 0)) >= 2 and str(card.get("kind", "")) == "attack":
				state.passive_flags[passive_id] = true
				_damage_enemy(state, int(passive.get("bonus_damage", 0)))
				_push_turn_event(state, passive_id, str(passive.get("preview_text", passive.get("description", ""))), "identity", "passive")

func _resolve_effect(state, effect: Dictionary, card: Dictionary = {}) -> void:
	match effect["type"]:
		"damage":
			var hits := int(effect.get("hits", 1))
			for hit_index in range(max(1, hits)):
				var amount := int(effect["amount"])
				if hit_index == 0 and str(card.get("kind", "")) == "attack" and int(state.next_attack_bonus) > 0:
					amount += int(state.next_attack_bonus)
					state.next_attack_bonus = 0
				_damage_enemy(state, amount)
		"block":
			state.player_block += int(effect["amount"])
		"draw":
			draw_cards(state, int(effect["amount"]))
		"draw_from_discard":
			var retrieved_cards := _draw_from_discard(state, int(effect.get("amount", 1)), str(effect.get("kind", "")))
			if not retrieved_cards.is_empty():
				_apply_context_relics(state, "discard_retrieved", { "retrieved_cards": retrieved_cards })
		"next_attack_bonus":
			var bonus_amount := int(effect.get("amount", 0))
			state.next_attack_bonus += bonus_amount
			if bonus_amount > 0:
				_apply_context_relics(state, "next_attack_bonus_added", { "bonus_amount": bonus_amount })
		"temporary_card":
			var temporary_cards := _create_temporary_card(state, effect)
			if not temporary_cards.is_empty():
				_apply_context_relics(state, "temporary_card_created", { "temporary_cards": temporary_cards })
		"draw_if_status":
			var target := str(effect.get("target", "enemy"))
			var statuses: Dictionary = state.player_statuses if target == "player" else state.enemy_statuses
			if statuses.has(str(effect.get("status_id", ""))):
				draw_cards(state, int(effect["amount"]))
		"energy":
			state.player_energy += int(effect["amount"])
		"status":
			apply_status(state, str(effect.get("target", "enemy")), {
				"id": str(effect.get("status_id", "")),
				"value": int(effect.get("value", effect.get("amount", 1))),
				"duration": int(effect.get("duration", 1))
			})
			_apply_status_passive(state, str(effect.get("target", "enemy")), str(effect.get("status_id", "")))
		"conditional":
			var condition: Dictionary = effect.get("condition", {})
			if not _condition_matches(state, condition, card):
				return
			for nested_variant in effect.get("effects", []):
				var nested_effect: Dictionary = nested_variant
				_resolve_effect(state, nested_effect, card)
		"summon_heal":
			_heal_summon(state, int(effect.get("amount", 0)))
		"summon_hp_damage":
			var base_damage := int(effect.get("base", 0))
			var per_hp := int(effect.get("per_hp", 1))
			_damage_enemy(state, base_damage + max(0, int(state.summon_hp)) * per_hp)

func _condition_matches(state, condition: Dictionary, card: Dictionary = {}) -> bool:
	if condition.is_empty():
		return true
	match str(condition.get("type", "")):
		"cards_played_this_turn_min":
			if state.cards_played_this_turn < int(condition.get("amount", 0)):
				return false
		"enemy_intent":
			if str(state.current_intent.get("type", "")) != str(condition.get("intent", condition.get("value", ""))):
				return false
		"target_status":
			var typed_target := str(condition.get("target", "enemy"))
			var typed_statuses: Dictionary = state.player_statuses if typed_target == "player" else state.enemy_statuses
			if not typed_statuses.has(str(condition.get("status_id", ""))):
				return false
		"summon_alive":
			if bool(state.summon_alive) != bool(condition.get("value", true)):
				return false
		"player_block_at_least":
			if state.player_block < int(condition.get("amount", 0)):
				return false
		"retained_card":
			if bool(card.get("_retained_from_previous_turn", false)) != bool(condition.get("value", true)):
				return false
	if condition.has("cards_played_this_turn_min") and state.cards_played_this_turn < int(condition.get("cards_played_this_turn_min", 0)):
		return false
	if condition.has("enemy_intent"):
		var expected_intent := str(condition.get("enemy_intent", ""))
		if str(state.current_intent.get("type", "")) != expected_intent:
			return false
	if condition.has("enemy_intents"):
		var expected_intents: Array = condition.get("enemy_intents", [])
		if not expected_intents.has(str(state.current_intent.get("type", ""))):
			return false
	if condition.has("target_status"):
		var status_condition: Dictionary = condition.get("target_status", {})
		var target := str(status_condition.get("target", "enemy"))
		var statuses: Dictionary = state.player_statuses if target == "player" else state.enemy_statuses
		if not statuses.has(str(status_condition.get("status_id", ""))):
			return false
	if condition.has("summon_alive") and bool(condition.get("summon_alive", false)) != bool(state.summon_alive):
		return false
	if condition.has("player_block_at_least") and state.player_block < int(condition.get("player_block_at_least", 0)):
		return false
	if condition.has("retained_card") and bool(condition.get("retained_card", false)) != bool(card.get("_retained_from_previous_turn", false)):
		return false
	if condition.has("exhaust_count_at_least") and state.exhaust_pile.size() < int(condition.get("exhaust_count_at_least", 0)):
		return false
	if condition.has("card_cost_at_most") and int(card.get("cost", 0)) > int(condition.get("card_cost_at_most", 0)):
		return false
	if condition.has("card_cost_at_least") and int(card.get("cost", 0)) < int(condition.get("card_cost_at_least", 0)):
		return false
	if condition.has("card_kind") and str(card.get("kind", "")) != str(condition.get("card_kind", "")):
		return false
	return true

func _draw_from_discard(state, amount: int, kind := "") -> Array[Dictionary]:
	var retrieved_cards: Array[Dictionary] = []
	for _i in range(max(0, amount)):
		var found_index := -1
		for discard_index in range(state.discard_pile.size() - 1, -1, -1):
			var candidate: Dictionary = state.discard_pile[discard_index]
			if kind == "" or str(candidate.get("kind", "")) == kind:
				found_index = discard_index
				break
		if found_index < 0:
			return retrieved_cards
		var card: Dictionary = state.discard_pile[found_index]
		state.discard_pile.remove_at(found_index)
		var retrieved_card := _clear_runtime_card_flags(card)
		state.hand.append(retrieved_card)
		retrieved_cards.append(retrieved_card)
	return retrieved_cards

func _create_temporary_card(state, effect: Dictionary) -> Array[Dictionary]:
	var temporary_cards: Array[Dictionary] = []
	var template: Dictionary = effect.get("card", {})
	if template.is_empty():
		return temporary_cards
	var amount: int = max(1, int(effect.get("amount", 1)))
	for _i in range(amount):
		var card := template.duplicate(true)
		card["temporary"] = true
		var temporary_card := _clear_runtime_card_flags(card)
		state.hand.append(temporary_card)
		temporary_cards.append(temporary_card)
	return temporary_cards

func _heal_summon(state, amount: int) -> void:
	if amount <= 0 or state.summon_id == "":
		return
	state.summon_hp = max(0, state.summon_hp) + amount
	state.summon_alive = state.summon_hp > 0

func apply_status(state, target: String, status: Dictionary) -> void:
	var status_id := str(status.get("id", ""))
	if status_id == "":
		return
	var statuses: Dictionary = state.player_statuses if target == "player" else state.enemy_statuses
	var current: Dictionary = statuses.get(status_id, {
		"id": status_id,
		"value": 0,
		"duration": 0
	})
	if status_id == "strength":
		current["value"] = int(current.get("value", 0)) + int(status.get("value", 0))
		current["duration"] = max(int(current.get("duration", 0)), int(status.get("duration", 99)))
	elif status_id == "marker":
		current["value"] = max(int(current.get("value", 0)), int(status.get("value", 2)))
		current["duration"] = int(current.get("duration", 0)) + int(status.get("duration", status.get("amount", 1)))
	else:
		current["value"] = max(int(current.get("value", 0)), int(status.get("value", 1)))
		current["duration"] = int(current.get("duration", 0)) + int(status.get("duration", 1))
	statuses[status_id] = current

func _apply_status_passive(state, target: String, status_id: String) -> void:
	var passive: Dictionary = state.character_passive
	var passive_id := str(passive.get("id", ""))
	if passive_id == "" or bool(state.passive_flags.get(passive_id, false)):
		return
	if str(passive.get("hook", "")) == "first_marker_each_turn" and target == "enemy" and status_id == "marker":
		state.passive_flags[passive_id] = true
		draw_cards(state, int(passive.get("draw", 0)))
		_push_turn_event(state, passive_id, str(passive.get("preview_text", passive.get("description", ""))), "identity", "passive")

func status_duration(state, target: String, status_id: String) -> int:
	var statuses: Dictionary = state.player_statuses if target == "player" else state.enemy_statuses
	return int(statuses.get(status_id, {}).get("duration", 0))

func status_value(state, target: String, status_id: String) -> int:
	var statuses: Dictionary = state.player_statuses if target == "player" else state.enemy_statuses
	return int(statuses.get(status_id, {}).get("value", 0))

func status_summary(state, target: String) -> String:
	var statuses: Dictionary = state.player_statuses if target == "player" else state.enemy_statuses
	if statuses.is_empty():
		return "狀態：無"
	var parts: Array[String] = []
	for status_id in statuses.keys():
		var status: Dictionary = statuses[status_id]
		parts.append("%s %d/%d" % [_status_label(str(status_id)), int(status.get("value", 0)), int(status.get("duration", 0))])
	return "狀態：%s" % "、".join(parts)

func _damage_enemy(state, amount: int) -> void:
	amount = _modified_outgoing_damage(state, "player", amount)
	amount = _modified_incoming_damage(state, "enemy", amount)
	var unblocked: int = max(0, amount - state.enemy_block)
	state.enemy_block = max(0, state.enemy_block - amount)
	state.enemy_hp = max(0, state.enemy_hp - unblocked)
	if unblocked > 0:
		_trigger_enemy_marker_damage(state)

func _trigger_enemy_marker_damage(state) -> void:
	if not state.enemy_statuses.has("marker"):
		return
	var marker: Dictionary = state.enemy_statuses["marker"]
	var layers := int(marker.get("duration", 0))
	if layers <= 0:
		state.enemy_statuses.erase("marker")
		return
	var bonus := int(marker.get("value", 2))
	state.enemy_hp = max(0, state.enemy_hp - bonus)
	_push_turn_event(state, "azki-marker-payoff", "標記追擊：追加 %d 傷害" % bonus, "payoff", "marker")
	layers -= 1
	if layers <= 0:
		state.enemy_statuses.erase("marker")
	else:
		marker["duration"] = layers
		state.enemy_statuses["marker"] = marker

func _resolve_enemy_action(state) -> void:
	var action: Dictionary = state.current_intent
	var action_type := str(action["type"])
	_reset_summon_hit_flags(state)
	var pre_player_status_ids: Array[String] = []
	for status_id in state.player_statuses.keys():
		pre_player_status_ids.append(str(status_id))
	var pre_enemy_status_ids: Array[String] = []
	for status_id in state.enemy_statuses.keys():
		pre_enemy_status_ids.append(str(status_id))
	if action_type == "attack" or action_type == "attack_block":
		var damage := int(action["damage"])
		var hits: int = max(1, int(action.get("hits", 1)))
		for _i in range(hits):
			var hit_damage := _modified_outgoing_damage(state, "enemy", damage)
			hit_damage = _modified_incoming_damage(state, "player", hit_damage)
			var unblocked: int = max(0, hit_damage - state.player_block)
			state.player_block = max(0, state.player_block - hit_damage)
			_damage_player_or_summon(state, unblocked)

	if action_type == "block" or action_type == "attack_block":
		state.enemy_block += int(action["block"])
	if action_type == "debuff":
		apply_status(state, "player", {
			"id": str(action.get("status_id", "")),
			"value": int(action.get("status_value", 1)),
			"duration": int(action.get("status_duration", 1))
		})
	if action_type == "buff":
		apply_status(state, "enemy", {
			"id": str(action.get("status_id", "")),
			"value": int(action.get("status_value", 1)),
			"duration": int(action.get("status_duration", 99))
		})
	_decay_statuses(state, "enemy", pre_enemy_status_ids)
	_apply_turn_start_statuses(state, "player")
	_decay_statuses(state, "player", pre_player_status_ids)

func _reset_summon_hit_flags(state) -> void:
	state.last_summon_damage = 0
	state.last_summon_defeated = false

func _damage_player_or_summon(state, amount: int) -> void:
	if amount <= 0:
		return
	if state.summon_id != "" and state.summon_alive and state.summon_hp > 0:
		var summon_damage: int = min(state.summon_hp, amount)
		state.summon_hp -= summon_damage
		state.last_summon_damage = summon_damage
		amount -= summon_damage
		if state.summon_hp <= 0:
			state.summon_hp = 0
			state.summon_alive = false
			state.last_summon_defeated = true
	if amount > 0:
		state.player_hp = max(0, state.player_hp - amount)

func _clear_runtime_card_flags(card: Dictionary) -> Dictionary:
	var cleaned := card.duplicate(true)
	cleaned.erase("_retained_from_previous_turn")
	return cleaned

func _apply_turn_start_statuses(state, target: String) -> void:
	var statuses: Dictionary = state.player_statuses if target == "player" else state.enemy_statuses
	if statuses.has("regen"):
		var amount := int(statuses["regen"].get("value", 0))
		if target == "player":
			state.player_hp = min(state.player_max_hp, state.player_hp + amount)
		else:
			state.enemy_hp = min(state.enemy_max_hp, state.enemy_hp + amount)

func _decay_statuses(state, target: String, status_ids: Array[String] = []) -> void:
	if status_ids.is_empty():
		return
	var statuses: Dictionary = state.player_statuses if target == "player" else state.enemy_statuses
	var expired: Array[String] = []
	var ids: Array = status_ids
	for status_id in ids:
		if not statuses.has(status_id):
			continue
		if str(status_id) == "strength" or str(status_id) == "marker":
			continue
		var status: Dictionary = statuses[status_id]
		status["duration"] = int(status.get("duration", 0)) - 1
		if int(status["duration"]) <= 0:
			expired.append(str(status_id))
		else:
			statuses[status_id] = status
	for status_id in expired:
		statuses.erase(status_id)

func _modified_outgoing_damage(state, attacker: String, amount: int) -> int:
	var result := amount
	var statuses: Dictionary = state.player_statuses if attacker == "player" else state.enemy_statuses
	if statuses.has("strength"):
		result += int(statuses["strength"].get("value", 0))
	if statuses.has("weak"):
		result = int(floor(float(result) * 0.65))
	return max(0, result)

func _modified_incoming_damage(state, defender: String, amount: int) -> int:
	var statuses: Dictionary = state.player_statuses if defender == "player" else state.enemy_statuses
	if statuses.has("vulnerable"):
		return int(ceil(float(amount) * 1.5))
	return amount

func _status_label(status_id: String) -> String:
	match status_id:
		"strength":
			return "力量"
		"weak":
			return "虛弱"
		"vulnerable":
			return "易傷"
		"regen":
			return "回復"
		"marker":
			return "標記"
	return status_id
