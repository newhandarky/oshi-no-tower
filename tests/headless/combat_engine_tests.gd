extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")
const CombatEngineScript := preload("res://scripts/core/CombatEngine.gd")

var database = RuntimeDatabaseScript.new()
var engine = CombatEngineScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_start_combat_draws_five_and_sets_energy()
	_test_start_combat_initializes_turn_events()
	_test_attack_card_spends_energy_and_damages_enemy()
	_test_block_card_prevents_enemy_damage()
	_test_draw_and_energy_effects_resolve()
	_test_enemy_block_and_attack_block_actions_resolve()
	_test_enemy_multi_hit_attack_resolves_each_hit()
	_test_victory_when_enemy_hp_reaches_zero()
	_test_defeat_when_player_hp_reaches_zero()
	_test_discard_recycles_into_draw_pile()
	_test_combat_start_relic_grants_block()
	_test_first_cheap_relic_draws_once()
	_test_turn_start_relic_heals_each_player_turn_without_overhealing()
	_test_first_two_cost_relic_deals_bonus_damage_once()
	_test_multi_effect_relic_applies_all_start_effects()
	_test_first_marker_relic_draws_once()
	_test_subaru_first_cheap_card_passive_grants_block_once_per_turn()
	_test_subaru_passive_pushes_turn_event()
	_test_botan_first_two_cost_attack_passive_deals_bonus_once_per_turn()
	_test_botan_passive_pushes_turn_event()
	_test_marker_adds_bonus_damage_and_consumes_one_layer()
	_test_marker_payoff_pushes_turn_event()
	_test_turn_event_records_kind_and_source()
	_test_boss_big_attack_pushes_warning_turn_event()
	_test_marker_layers_do_not_decay_at_turn_end()
	_test_cards_played_count_conditional_effect_and_reset()
	_test_retain_keeps_card_and_exhaust_on_play_exhausts_card()
	_test_retained_runtime_marker_is_cleared_after_play()
	_test_next_attack_bonus_applies_to_next_attack_once()
	_test_next_attack_bonus_expires_at_turn_end()
	_test_draw_from_discard_recovers_matching_card_to_hand()
	_test_exhaust_count_condition_enables_payoff()
	_test_temporary_card_is_created_and_exhausts_when_played()
	_test_summon_heal_restores_laplus_hp()
	_test_summon_hp_damage_uses_current_laplus_hp()
	_test_relic_trigger_v2_applies_once_per_turn()
	_test_azki_first_marker_passive_draws_once_per_turn()
	_test_azki_summon_starts_alive()
	_test_azki_summon_intercepts_unblocked_damage()
	_test_azki_summon_overflow_damages_player_and_stays_down()
	_test_azki_summon_alive_does_not_auto_stack_at_turn_start()
	_test_non_azki_characters_do_not_create_summon()
	_test_dead_air_reduces_energy_when_drawn()
	_test_bad_connection_hurts_if_left_in_hand()
	_test_comment_fire_applies_vulnerable_when_drawn()
	_test_curse_cards_are_unplayable()
	_test_comment_fire_is_ethereal_and_exhausts_at_end_turn()

	if failures.is_empty():
		print("combat_engine_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("combat_engine_tests: failed (%d)" % failures.size())
		quit(1)

func _test_start_combat_draws_five_and_sets_energy() -> void:
	var state = _start_state(_deck(["subaru-strike", "subaru-guard", "subaru-duck-rush", "subaru-draw-breath", "subaru-tsukkomi"]), _enemy_attack(6))

	_expect_eq(state.player_hp, 30, "start_combat 保留玩家 HP")
	_expect_eq(state.player_max_hp, 30, "start_combat 保留玩家 Max HP")
	_expect_eq(state.player_energy, 3, "start_combat 設定 3 能量")
	_expect_eq(state.hand.size(), 5, "start_combat 抽 5 張")
	_expect_eq(state.draw_pile.size(), 0, "5 張牌牌組抽完後抽牌堆為 0")
	_expect_eq(state.enemy_hp, 20, "start_combat 設定敵人 HP")
	_expect_eq(str(state.current_intent["type"]), "attack", "start_combat 設定第一個敵人意圖")

func _test_start_combat_initializes_turn_events() -> void:
	var state = _start_state(_deck(["subaru-strike"]), _enemy_attack(6))

	_expect_eq(state.turn_events.size(), 0, "start_combat 應初始化空的 turn_events")

func _test_attack_card_spends_energy_and_damages_enemy() -> void:
	var state = _start_state(_deck(["subaru-strike"]), _enemy_attack(6))

	var played := engine.try_play_card(state, 0)

	_expect_true(played, "攻擊牌可成功打出")
	_expect_eq(state.player_energy, 2, "攻擊牌消耗 1 能量")
	_expect_eq(state.enemy_hp, 15, "攻擊牌造成 5 傷害")
	_expect_eq(state.discard_pile.size(), 1, "打出的牌進入棄牌堆")

func _test_block_card_prevents_enemy_damage() -> void:
	var state = _start_state(_deck(["subaru-guard"]), _enemy_attack(6))
	engine.try_play_card(state, 0)

	var outcome: String = engine.end_player_turn(state)

	_expect_eq(outcome, "ongoing", "格擋後戰鬥仍持續")
	_expect_eq(state.player_hp, 29, "5 格擋抵擋 6 傷害後扣 1 HP")
	_expect_eq(state.player_block, 0, "新回合玩家格擋歸零")
	_expect_eq(state.player_energy, 3, "新回合能量回到 3")

func _test_draw_and_energy_effects_resolve() -> void:
	var state = _start_state(_deck(["subaru-draw-breath", "subaru-strike"]), _enemy_attack(6))

	var played := engine.try_play_card(state, 0)

	_expect_true(played, "抽牌能量牌可成功打出")
	_expect_eq(state.player_energy, 4, "0 費牌獲得 1 能量")
	_expect_eq(state.hand.size(), 1, "抽 1 張後手牌仍有 1 張")
	_expect_eq(str(state.hand[0]["id"]), "subaru-strike", "抽牌效果抽到下一張牌")

func _test_enemy_block_and_attack_block_actions_resolve() -> void:
	var state = _start_state(
		_deck(["subaru-strike"]),
		_enemy_actions([
			{ "type": "block", "damage": 0, "block": 8, "description": "防禦 8" },
			{ "type": "attack_block", "damage": 7, "block": 3, "description": "攻擊 7 + 防禦 3" }
		])
	)

	engine.end_player_turn(state)
	_expect_eq(state.enemy_block, 8, "敵人 block 意圖增加敵人格擋")
	_expect_eq(str(state.current_intent["type"]), "attack_block", "結束回合後切到下一個意圖")

	engine.end_player_turn(state)
	_expect_eq(state.player_hp, 23, "attack_block 造成玩家傷害")
	_expect_eq(state.enemy_block, 11, "attack_block 同時增加敵人格擋")

func _test_enemy_multi_hit_attack_resolves_each_hit() -> void:
	var state = _start_state(
		_deck(["subaru-guard"]),
		_enemy_actions([{ "type": "attack", "damage": 3, "hits": 4, "block": 0, "description": "多段 3x4" }])
	)
	engine.try_play_card(state, 0)

	engine.end_player_turn(state)

	_expect_eq(state.player_hp, 23, "敵方 hits 應逐段結算，5 格擋面對 3x4 後應承受 7 傷害")

func _test_victory_when_enemy_hp_reaches_zero() -> void:
	var state = _start_state(_deck(["subaru-tsukkomi"]), _enemy_attack(1, 10))

	var played := engine.try_play_card(state, 0)

	_expect_true(played, "致勝牌可成功打出")
	_expect_eq(state.enemy_hp, 0, "敵人 HP 不低於 0")
	_expect_eq(state.outcome, "victory", "敵人 HP 歸零後勝利")

func _test_defeat_when_player_hp_reaches_zero() -> void:
	var state = _start_state(_deck(["subaru-strike"]), _enemy_attack(99))

	var outcome: String = engine.end_player_turn(state)

	_expect_eq(outcome, "defeat", "敵人致命攻擊後失敗")
	_expect_eq(state.player_hp, 0, "玩家 HP 不低於 0")
	_expect_eq(state.outcome, "defeat", "state outcome 記錄失敗")

func _test_discard_recycles_into_draw_pile() -> void:
	var state = _start_state(_deck(["subaru-strike"]), _enemy_attack(1))
	var extra_card := database.get_card("subaru-guard")
	state.discard_pile.append(extra_card)

	engine.draw_cards(state, 1)

	_expect_eq(state.hand.size(), 2, "抽牌堆空時會從棄牌堆補牌")
	_expect_eq(str(state.hand[1]["id"]), "subaru-guard", "棄牌堆卡牌會被抽回手牌")
	_expect_eq(state.discard_pile.size(), 0, "補牌後棄牌堆清空")

func _test_combat_start_relic_grants_block() -> void:
	var state = engine.start_combat(30, 30, _deck(["subaru-strike"]), _enemy_attack(6), [database.get_relic("cheer-lightstick")])

	_expect_eq(state.player_block, 3, "應援螢光棒在戰鬥開始獲得 3 格擋")
	_expect_eq(state.relic_ids.size(), 1, "戰鬥狀態需記錄持有 relic")

func _test_first_cheap_relic_draws_once() -> void:
	var state = engine.start_combat(30, 30, _deck(["subaru-draw-breath", "subaru-guard", "subaru-guard", "subaru-guard", "subaru-guard", "subaru-guard", "subaru-guard"]), _enemy_attack(6), [database.get_relic("duck-whistle")])
	var before_hand: int = state.hand.size()

	engine.try_play_card(state, 0)

	_expect_eq(state.hand.size(), before_hand + 1, "鴨鴨哨子第一次 0/1 費牌後抽 1 張，且原卡也抽 1 張")
	_expect_eq(state.player_block, 2, "鴨鴨哨子第一次 0/1 費牌後應額外獲得 2 格擋")
	var after_first_hand: int = state.hand.size()
	engine.try_play_card(state, 0)
	_expect_eq(state.hand.size(), after_first_hand - 1, "鴨鴨哨子每場只觸發一次")
	_expect_eq(state.player_block, 7, "鴨鴨哨子第二張低費牌不應再次給 relic 格擋")

func _test_turn_start_relic_heals_each_player_turn_without_overhealing() -> void:
	var state = engine.start_combat(24, 30, _deck(["subaru-guard", "subaru-guard", "subaru-guard", "subaru-guard", "subaru-guard", "subaru-guard"]), _enemy_attack(0), [database.get_relic("healing-chat"), database.get_relic("pamomi-signal")])

	engine.end_player_turn(state)
	_expect_eq(state.player_hp, 26, "兩個 turn_start heal relic 應在下一個玩家回合開始各回復 1 HP")
	state.player_hp = 29
	engine.end_player_turn(state)
	_expect_eq(state.player_hp, 30, "turn_start heal relic 不應超過 player_max_hp")

func _test_first_two_cost_relic_deals_bonus_damage_once() -> void:
	var state = engine.start_combat(30, 30, _deck(["botan-heavy-shot", "botan-heavy-shot"]), _enemy_attack(6, 50), [database.get_relic("shishiro-crosshair")])

	engine.try_play_card(state, 0)
	_expect_eq(state.enemy_hp, 29, "獅白準星第一次 2 費牌額外造成 3 傷害")
	state.player_energy = 3
	engine.try_play_card(state, 0)
	_expect_eq(state.enemy_hp, 11, "獅白準星每場只觸發一次")

func _test_multi_effect_relic_applies_all_start_effects() -> void:
	var state = engine.start_combat(30, 30, _deck(["subaru-strike"]), _enemy_attack(6), [database.get_relic("blue-wave-badge")])

	_expect_eq(state.player_block, 2, "Blue Wave Badge 戰鬥開始應給 2 格擋")
	_expect_eq(state.player_energy, 4, "Blue Wave Badge 戰鬥開始應給 1 能量")

func _test_first_marker_relic_draws_once() -> void:
	var state = engine.start_combat(30, 30, _deck(["azki-map-search", "azki-map-shot", "azki-map-shot", "azki-map-shot", "azki-map-shot", "azki-map-shot", "azki-map-shot", "azki-map-shot"]), _enemy_attack(6), [database.get_relic("unarchived-archive")])
	var before_hand: int = state.hand.size()

	engine.try_play_card(state, 0)

	_expect_eq(state.hand.size(), before_hand + 1, "Unarchived Archive 第一次標記牌應額外抽 1 張，並疊加卡牌自身抽牌")
	_expect_eq(state.player_energy, 4, "Unarchived Archive 第一次標記牌應額外給 1 能量")
	var after_first_marker_hand: int = state.hand.size()
	engine.try_play_card(state, 0)
	_expect_eq(state.hand.size(), after_first_marker_hand - 1, "Unarchived Archive 每場只觸發一次")
	_expect_eq(state.player_energy, 3, "Unarchived Archive 第二張標記牌不應再次給能量")

func _test_subaru_first_cheap_card_passive_grants_block_once_per_turn() -> void:
	var passive: Dictionary = database.get_character("subaru").get("passive", {})
	var state = engine.start_combat(30, 30, _deck(["subaru-quick-retort", "subaru-draw-breath", "subaru-strike"]), _enemy_attack(1, 40), [], false, passive)

	engine.try_play_card(state, 0)
	_expect_eq(state.player_block, 3, "Subaru 每回合第一次打出 0/1 費牌應獲得 3 格擋")
	engine.try_play_card(state, 0)
	_expect_eq(state.player_block, 3, "Subaru 被動同一回合只觸發一次")
	engine.end_player_turn(state)
	state.hand.clear()
	state.hand.append(database.get_card("subaru-strike"))
	engine.try_play_card(state, 0)
	_expect_eq(state.player_block, 3, "Subaru 被動新回合可再次觸發")

func _test_subaru_passive_pushes_turn_event() -> void:
	var passive: Dictionary = database.get_character("subaru").get("passive", {})
	var state = engine.start_combat(30, 30, _deck(["subaru-quick-retort"]), _enemy_attack(1, 40), [], false, passive)

	engine.try_play_card(state, 0)

	_expect_eq(state.turn_events.size(), 1, "Subaru 被動觸發時應推入 turn event")
	_expect_eq(str(state.turn_events[0].get("id", "")), "subaru-tempo-guard", "Subaru turn event 應使用被動 id")

func _test_botan_first_two_cost_attack_passive_deals_bonus_once_per_turn() -> void:
	var passive: Dictionary = database.get_character("botan").get("passive", {})
	var state = engine.start_combat(30, 30, _deck(["botan-heavy-shot", "botan-burst", "botan-shot"]), _enemy_attack(1, 70), [], false, passive)

	engine.try_play_card(state, 0)
	_expect_eq(state.enemy_hp, 46, "Botan 每回合第一次打出 2 費攻擊應追加 6 傷害")
	state.player_energy = 3
	engine.try_play_card(state, 0)
	_expect_eq(state.enemy_hp, 34, "Botan 被動同一回合只觸發一次")
	engine.end_player_turn(state)
	state.hand.clear()
	state.hand.append(database.get_card("botan-heavy-shot"))
	engine.try_play_card(state, 0)
	_expect_eq(state.enemy_hp, 10, "Botan 被動新回合可再次觸發")

func _test_botan_passive_pushes_turn_event() -> void:
	var passive: Dictionary = database.get_character("botan").get("passive", {})
	var state = engine.start_combat(30, 30, _deck(["botan-heavy-shot"]), _enemy_attack(1, 40), [], false, passive)

	engine.try_play_card(state, 0)

	_expect_eq(state.turn_events.size(), 1, "Botan 被動觸發時應推入 turn event")
	_expect_eq(str(state.turn_events[0].get("id", "")), "botan-sniper-opening", "Botan turn event 應使用被動 id")

func _test_marker_adds_bonus_damage_and_consumes_one_layer() -> void:
	var state = engine.start_combat(30, 30, _deck(["azki-map-search", "azki-map-shot"]), _enemy_attack(1, 30))

	engine.try_play_card(state, 0)
	_expect_eq(engine.status_duration(state, "enemy", "marker"), 1, "AZKi 標記牌應給敵人 1 層標記")
	engine.try_play_card(state, 0)
	_expect_eq(state.enemy_hp, 20, "標記中的敵人受到攻擊傷害時應額外受到 2 點傷害")
	_expect_eq(engine.status_duration(state, "enemy", "marker"), 0, "標記觸發後應消耗 1 層")

func _test_marker_payoff_pushes_turn_event() -> void:
	var state = engine.start_combat(30, 30, _deck(["azki-map-search", "azki-map-shot"]), _enemy_attack(1, 30))

	engine.try_play_card(state, 0)
	state.turn_events.clear()
	engine.try_play_card(state, 0)

	_expect_eq(state.turn_events.size(), 1, "標記追擊時應推入 turn event")
	_expect_eq(str(state.turn_events[0].get("id", "")), "azki-marker-payoff", "標記追擊 event id 應固定")

func _test_turn_event_records_kind_and_source() -> void:
	var passive: Dictionary = database.get_character("subaru").get("passive", {})
	var state = engine.start_combat(30, 30, _deck(["subaru-quick-retort"]), _enemy_attack(1, 40), [], false, passive)

	engine.try_play_card(state, 0)

	_expect_eq(str(state.turn_events[0].get("kind", "")), "identity", "角色被動提示應標記為 identity")
	_expect_eq(str(state.turn_events[0].get("source", "")), "passive", "角色被動提示來源應標記為 passive")

func _test_boss_big_attack_pushes_warning_turn_event() -> void:
	var boss := database.get_enemy("important-announcement")
	var state = engine.start_combat(30, 30, _deck(["subaru-guard"]), boss)

	engine.end_player_turn(state)
	_expect_eq(state.turn_events.size(), 0, "Boss 非高傷下一意圖時不應提早推 warning")
	engine.end_player_turn(state)
	_expect_eq(state.turn_events.size(), 1, "Boss 切到高傷大招前應推 warning")
	_expect_eq(str(state.turn_events[0].get("id", "")), "boss-warning", "Boss warning event id 應固定")
	_expect_eq(str(state.turn_events[0].get("kind", "")), "warning", "Boss warning event kind 應為 warning")
	_expect_eq(str(state.turn_events[0].get("source", "")), "boss_intent", "Boss warning 來源應標記為 boss_intent")
	_expect_true(str(state.turn_events[0].get("text", "")).contains("Boss 警告"), "Boss warning 文案應清楚標示 Boss 警告")
	_expect_true(str(state.turn_events[0].get("text", "")).contains("倒數與易傷回合先守住血線"), "Boss warning 應帶入 boss_counterplay，讓提示可操作")

func _test_marker_layers_do_not_decay_at_turn_end() -> void:
	var state = engine.start_combat(30, 30, _deck(["azki-map-search"]), _enemy_attack(1, 30))

	engine.try_play_card(state, 0)
	engine.end_player_turn(state)

	_expect_eq(engine.status_duration(state, "enemy", "marker"), 1, "標記是層數，未觸發時不應隨回合自然衰減")

func _test_cards_played_count_conditional_effect_and_reset() -> void:
	var setup_card := { "id": "test-setup", "name": "Test Setup", "cost": 0, "kind": "support", "effects": [{ "type": "draw", "amount": 0 }] }
	var payoff_card := {
		"id": "test-payoff",
		"name": "Test Payoff",
		"cost": 0,
		"kind": "support",
		"effects": [{
			"type": "conditional",
			"condition": { "type": "cards_played_this_turn_min", "amount": 2 },
			"effects": [{ "type": "block", "amount": 5 }]
		}]
	}
	var state = engine.start_combat(30, 30, [setup_card, payoff_card], _enemy_attack(0, 30))

	engine.try_play_card(state, 0)
	engine.try_play_card(state, 0)
	_expect_eq(state.player_block, 5, "conditional cards_played_this_turn_min 應包含目前打出的牌")
	engine.end_player_turn(state)
	state.hand.clear()
	state.hand.append(payoff_card.duplicate(true))
	state.player_block = 0
	engine.try_play_card(state, 0)
	_expect_eq(state.player_block, 0, "cards_played_this_turn 應在新玩家回合重置")

func _test_retain_keeps_card_and_exhaust_on_play_exhausts_card() -> void:
	var retain_card := { "id": "test-retain", "name": "Test Retain", "cost": 0, "kind": "defense", "retain": true, "effects": [{ "type": "block", "amount": 3 }] }
	var exhaust_card := { "id": "test-exhaust", "name": "Test Exhaust", "cost": 0, "kind": "attack", "exhaust_on_play": true, "effects": [{ "type": "damage", "amount": 1, "hits": 1 }] }
	var state = engine.start_combat(30, 30, [retain_card], _enemy_attack(0, 30))

	engine.end_player_turn(state)
	_expect_eq(state.hand.size(), 1, "retain 卡回合結束後應留在手上")
	_expect_eq(str(state.hand[0].get("id", "")), "test-retain", "retain 卡應維持原本 id")
	_expect_true(bool(state.hand[0].get("_retained_from_previous_turn", false)), "retain 卡需標記為從前一回合保留")
	state.hand.clear()
	state.hand.append(exhaust_card.duplicate(true))
	engine.try_play_card(state, 0)
	_expect_eq(state.exhaust_pile.size(), 1, "exhaust_on_play 卡打出後應進 exhaust pile")
	_expect_eq(state.discard_pile.size(), 0, "exhaust_on_play 卡不應進 discard pile")

func _test_retained_runtime_marker_is_cleared_after_play() -> void:
	var retain_card := { "id": "test-retain", "name": "Test Retain", "cost": 0, "kind": "defense", "retain": true, "effects": [{ "type": "block", "amount": 3 }] }
	var state = engine.start_combat(30, 30, [retain_card], _enemy_attack(0, 30))
	engine.end_player_turn(state)

	engine.try_play_card(state, 0)

	_expect_eq(state.discard_pile.size(), 1, "保留牌打出後應進 discard pile")
	_expect_false(bool(state.discard_pile[0].get("_retained_from_previous_turn", false)), "打出保留牌後不應把 runtime retain 標記帶進 discard pile")

func _test_next_attack_bonus_applies_to_next_attack_once() -> void:
	var setup_card := { "id": "test-bonus", "name": "Test Bonus", "cost": 0, "kind": "support", "effects": [{ "type": "next_attack_bonus", "amount": 5 }] }
	var attack_card := { "id": "test-attack", "name": "Test Attack", "cost": 0, "kind": "attack", "effects": [{ "type": "damage", "amount": 4, "hits": 1 }] }
	var state = engine.start_combat(30, 30, [setup_card, attack_card, attack_card.duplicate(true)], _enemy_attack(0, 40))

	engine.try_play_card(state, 0)
	engine.try_play_card(state, 0)
	_expect_eq(state.enemy_hp, 31, "next_attack_bonus 應加到下一張攻擊牌的第一段傷害")
	engine.try_play_card(state, 0)
	_expect_eq(state.enemy_hp, 27, "next_attack_bonus 只應消耗一次")

func _test_next_attack_bonus_expires_at_turn_end() -> void:
	var setup_card := { "id": "test-bonus", "name": "Test Bonus", "cost": 0, "kind": "support", "effects": [{ "type": "next_attack_bonus", "amount": 5 }] }
	var attack_card := { "id": "test-attack", "name": "Test Attack", "cost": 0, "kind": "attack", "effects": [{ "type": "damage", "amount": 4, "hits": 1 }] }
	var state = engine.start_combat(30, 30, [setup_card, attack_card], _enemy_attack(0, 40))

	engine.try_play_card(state, 0)
	engine.end_player_turn(state)
	for index in range(state.hand.size()):
		if str(state.hand[index].get("id", "")) == "test-attack":
			engine.try_play_card(state, index)
			break

	_expect_eq(state.enemy_hp, 36, "next_attack_bonus 應只存在本回合，結束回合後不應保留")

func _test_draw_from_discard_recovers_matching_card_to_hand() -> void:
	var recover_card := { "id": "test-recover", "name": "Test Recover", "cost": 0, "kind": "support", "effects": [{ "type": "draw_from_discard", "amount": 1, "kind": "attack" }] }
	var attack_card := { "id": "test-attack", "name": "Test Attack", "cost": 0, "kind": "attack", "effects": [{ "type": "damage", "amount": 1, "hits": 1 }] }
	var defense_card := { "id": "test-defense", "name": "Test Defense", "cost": 0, "kind": "defense", "effects": [{ "type": "block", "amount": 1 }] }
	var state = engine.start_combat(30, 30, [recover_card], _enemy_attack(0, 30))
	state.discard_pile.append(defense_card.duplicate(true))
	state.discard_pile.append(attack_card.duplicate(true))

	engine.try_play_card(state, 0)

	_expect_eq(state.hand.size(), 1, "draw_from_discard 應把符合條件的棄牌拿回手牌")
	if state.hand.size() > 0:
		_expect_eq(str(state.hand[0].get("id", "")), "test-attack", "draw_from_discard 應依 kind 選取攻擊牌")
	_expect_eq(state.discard_pile.size(), 2, "draw_from_discard 應從棄牌堆移除被取回的牌，來源牌仍會正常進 discard")

func _test_exhaust_count_condition_enables_payoff() -> void:
	var exhaust_card := { "id": "test-exhaust", "name": "Test Exhaust", "cost": 0, "kind": "support", "exhaust_on_play": true, "effects": [{ "type": "draw", "amount": 0 }] }
	var payoff_card := {
		"id": "test-exhaust-payoff",
		"name": "Test Exhaust Payoff",
		"cost": 0,
		"kind": "defense",
		"effects": [{
			"type": "conditional",
			"condition": { "exhaust_count_at_least": 1 },
			"effects": [{ "type": "block", "amount": 8 }]
		}]
	}
	var state = engine.start_combat(30, 30, [payoff_card.duplicate(true), exhaust_card.duplicate(true), payoff_card.duplicate(true)], _enemy_attack(0, 30))

	engine.try_play_card(state, 0)
	_expect_eq(state.player_block, 0, "exhaust_count_at_least 未達成時不應觸發")
	engine.try_play_card(state, 0)
	engine.try_play_card(state, 0)
	_expect_eq(state.player_block, 8, "exhaust_count_at_least 達成後應觸發 payoff")

func _test_temporary_card_is_created_and_exhausts_when_played() -> void:
	var temp_attack := { "id": "test-temp-attack", "name": "Test Temp Attack", "cost": 0, "kind": "attack", "effects": [{ "type": "damage", "amount": 3, "hits": 1 }] }
	var creator_card := { "id": "test-temp-maker", "name": "Test Temp Maker", "cost": 0, "kind": "support", "effects": [{ "type": "temporary_card", "card": temp_attack }] }
	var state = engine.start_combat(30, 30, [creator_card], _enemy_attack(0, 20))

	engine.try_play_card(state, 0)
	_expect_eq(state.hand.size(), 1, "temporary_card 應建立臨時手牌")
	if state.hand.size() > 0:
		_expect_eq(str(state.hand[0].get("id", "")), "test-temp-attack", "temporary_card 應保留指定 card id")
		_expect_true(bool(state.hand[0].get("temporary", false)), "temporary_card 建立的牌需標記 temporary")
		engine.try_play_card(state, 0)
		_expect_eq(state.enemy_hp, 17, "temporary card 應可正常打出")
		_expect_eq(state.exhaust_pile.size(), 1, "temporary card 打出後應進 exhaust，不進 discard")
		_expect_eq(state.discard_pile.size(), 1, "建立 temporary 的來源牌仍依原規則進 discard")

func _test_summon_heal_restores_laplus_hp() -> void:
	var summon_heal_card := { "id": "test-summon-heal", "name": "Test Summon Heal", "cost": 0, "kind": "defense", "effects": [{ "type": "summon_heal", "amount": 3 }] }
	var state = engine.start_combat(30, 30, [summon_heal_card], _enemy_attack(0, 30), [], false, {}, _azki_summon())
	state.summon_hp = 4

	engine.try_play_card(state, 0)
	_expect_eq(state.summon_hp, 7, "summon_heal 應回復 Laplus HP")
	state.hand.append(summon_heal_card.duplicate(true))
	engine.try_play_card(state, 0)
	_expect_eq(state.summon_hp, 10, "summon_heal 應可把 Laplus HP 疊到 max_hp 以上")
	state.hand.append(summon_heal_card.duplicate(true))
	engine.try_play_card(state, 0)
	_expect_eq(state.summon_hp, 13, "summon_heal 不應被 summon_max_hp 鎖上限")
	state.summon_hp = 0
	state.summon_alive = false
	state.hand.append(summon_heal_card.duplicate(true))
	engine.try_play_card(state, 0)
	_expect_eq(state.summon_hp, 3, "summon_heal 應可從 0 HP 重新疊起 Laplus")
	_expect_true(state.summon_alive, "summon_heal 疊到正數後 Laplus 應恢復 alive")

func _test_summon_hp_damage_uses_current_laplus_hp() -> void:
	var hp_payoff_card := { "id": "test-summon-payoff", "name": "Test Summon Payoff", "cost": 0, "kind": "attack", "effects": [{ "type": "summon_hp_damage", "base": 4, "per_hp": 2 }] }
	var state = engine.start_combat(30, 30, [hp_payoff_card], _enemy_attack(0, 40), [], false, {}, _azki_summon())
	state.summon_hp = 6

	engine.try_play_card(state, 0)
	_expect_eq(state.enemy_hp, 24, "summon_hp_damage 應依目前 Laplus HP 加成傷害")

func _test_relic_trigger_v2_applies_once_per_turn() -> void:
	var zero_card := { "id": "test-zero", "name": "Test Zero", "cost": 0, "kind": "support", "effects": [{ "type": "draw", "amount": 0 }] }
	var combo_relic := {
		"id": "test-third-card-badge",
		"name": "Test Third Card Badge",
		"trigger": "card_played",
		"limit": "once_per_turn",
		"condition": { "type": "cards_played_this_turn_min", "amount": 3 },
		"effects": [{ "effect": "block", "amount": 4 }]
	}
	var state = engine.start_combat(30, 30, [zero_card, zero_card, zero_card, zero_card], _enemy_attack(0, 30), [combo_relic])

	engine.try_play_card(state, 0)
	engine.try_play_card(state, 0)
	engine.try_play_card(state, 0)
	_expect_eq(state.player_block, 4, "trigger v2 應在本回合第 3 張牌觸發")
	engine.try_play_card(state, 0)
	_expect_eq(state.player_block, 4, "once_per_turn trigger v2 同回合不可重複觸發")
	engine.end_player_turn(state)
	state.hand.clear()
	state.hand.append_array([zero_card.duplicate(true), zero_card.duplicate(true), zero_card.duplicate(true)])
	state.player_block = 0
	engine.try_play_card(state, 0)
	engine.try_play_card(state, 0)
	engine.try_play_card(state, 0)
	_expect_eq(state.player_block, 4, "once_per_turn trigger v2 新回合應可再次觸發")

func _test_azki_first_marker_passive_draws_once_per_turn() -> void:
	var passive: Dictionary = database.get_character("azki").get("passive", {})
	var state = engine.start_combat(30, 30, _deck(["azki-map-search", "azki-pinpoint", "azki-map-shot", "azki-guard", "azki-tune-up", "azki-songline"]), _enemy_attack(1, 40), [], false, passive)
	var before_hand: int = state.hand.size()

	engine.try_play_card(state, 0)
	_expect_eq(state.hand.size(), before_hand, "AZKi 每回合第一次給予標記時應抽 1 張，抵銷出牌少 1 張")
	var after_first_marker_hand: int = state.hand.size()
	engine.try_play_card(state, 0)
	_expect_eq(state.hand.size(), after_first_marker_hand - 1, "AZKi 標記被動同一回合只觸發一次")
	engine.end_player_turn(state)
	state.hand.clear()
	state.draw_pile.clear()
	state.draw_pile.append(database.get_card("azki-map-shot"))
	state.hand.append(database.get_card("azki-map-search"))
	engine.try_play_card(state, 0)
	_expect_eq(state.hand.size(), 1, "AZKi 標記被動新回合可再次觸發")

func _test_azki_summon_starts_alive() -> void:
	var state = engine.start_combat(30, 30, _deck(["azki-map-shot"]), _enemy_attack(1, 20), [], false, {}, _azki_summon())

	_expect_eq(str(state.summon_id), "laplus", "AZKi 戰鬥應建立 Laplus summon")
	_expect_eq(state.summon_hp, 1, "Laplus 初始 HP 應為 1")
	_expect_eq(state.summon_max_hp, 1, "Laplus max_hp 只作為起始參考，不應作為疊加上限")
	_expect_true(state.summon_alive, "Laplus 初始應為 alive")

func _test_azki_summon_intercepts_unblocked_damage() -> void:
	var block_card := { "id": "test-block", "name": "Test Block", "cost": 0, "kind": "defense", "effects": [{ "type": "block", "amount": 6 }] }
	var state = engine.start_combat(30, 30, [block_card], _enemy_attack(7, 20), [], false, {}, _azki_summon())
	state.summon_hp = 5
	engine.try_play_card(state, 0)

	engine.end_player_turn(state)

	_expect_eq(state.player_hp, 30, "敵方未被格擋擋住的傷害應先由 Laplus 承受")
	_expect_eq(state.summon_hp, 4, "Laplus 承受 1 傷害後不應靠回合開始自動補回")
	_expect_eq(state.last_summon_damage, 1, "戰鬥狀態需記錄 Laplus 本次承傷")
	_expect_true(state.summon_alive, "Laplus 未歸零時仍應 alive")

func _test_azki_summon_overflow_damages_player_and_stays_down() -> void:
	var state = engine.start_combat(30, 30, _deck(["azki-map-shot"]), _enemy_attack(12, 20), [], false, {}, _azki_summon())

	engine.end_player_turn(state)

	_expect_eq(state.player_hp, 19, "超過 Laplus HP 的 overflow 應扣 AZKi HP")
	_expect_eq(state.summon_hp, 0, "Laplus 倒下後不應靠回合開始自動復活")
	_expect_false(state.summon_alive, "Laplus 倒下後需靠卡牌重新疊 HP")
	_expect_true(state.last_summon_defeated, "戰鬥狀態需記錄 Laplus 本次倒下")
	_expect_eq(state.last_summon_damage, 1, "Laplus 倒下前最多承受自身剩餘 HP")

func _test_azki_summon_alive_does_not_auto_stack_at_turn_start() -> void:
	var state = engine.start_combat(30, 30, _deck(["azki-map-shot"]), _enemy_attack(0, 20), [], false, {}, _azki_summon())
	state.summon_hp = 8

	engine.end_player_turn(state)

	_expect_eq(state.summon_hp, 8, "Laplus 活著進入新玩家回合時不應自動疊 HP")
	_expect_true(state.summon_alive, "Laplus 活著時不應被重置")

func _test_non_azki_characters_do_not_create_summon() -> void:
	var state = engine.start_combat(30, 30, _deck(["subaru-strike"]), _enemy_attack(6, 20))

	_expect_eq(str(state.summon_id), "", "非 AZKi 戰鬥不應建立 summon")
	_expect_false(state.summon_alive, "非 AZKi 戰鬥 summon_alive 應維持 false")

func _test_dead_air_reduces_energy_when_drawn() -> void:
	var state = engine.start_combat(30, 30, _deck(["curse-dead-air"]), _enemy_attack(1, 20))

	_expect_eq(state.player_energy, 2, "Dead Air 抽到時應立刻失去 1 能量")

func _test_bad_connection_hurts_if_left_in_hand() -> void:
	var state = engine.start_combat(30, 30, _deck(["curse-bad-connection"]), _enemy_attack(0, 20))

	engine.end_player_turn(state)

	_expect_eq(state.player_hp, 27, "Bad Connection 若回合結束仍留在手上應失去 3 HP")

func _test_comment_fire_applies_vulnerable_when_drawn() -> void:
	var state = engine.start_combat(30, 30, _deck(["curse-comment-fire"]), _enemy_attack(1, 20))

	_expect_eq(engine.status_duration(state, "player", "vulnerable"), 1, "Comment Fire 抽到時應對玩家附加 1 回合 vulnerable")

func _test_curse_cards_are_unplayable() -> void:
	var state = engine.start_combat(30, 30, _deck(["curse-dead-air"]), _enemy_attack(1, 20))

	_expect_true(not engine.try_play_card(state, 0), "Curse 卡應不可打出")
	_expect_eq(state.hand.size(), 1, "不可打出的 curse 應留在手上")
	_expect_eq(state.discard_pile.size(), 0, "不可打出的 curse 不應進棄牌堆")

func _test_comment_fire_is_ethereal_and_exhausts_at_end_turn() -> void:
	var state = engine.start_combat(30, 30, _deck(["curse-comment-fire"]), _enemy_attack(0, 20))

	engine.end_player_turn(state)

	_expect_eq(state.discard_pile.size(), 0, "Comment Fire 作為 ethereal 不應進入棄牌堆")
	_expect_eq(state.exhaust_pile.size(), 1, "Comment Fire 回合結束時應進入 exhaust pile")
	_expect_eq(str(state.exhaust_pile[0]["id"]), "curse-comment-fire", "Comment Fire 應被 exhaust")

func _start_state(deck: Array[Dictionary], enemy: Dictionary):
	return engine.start_combat(30, 30, deck, enemy)

func _deck(card_ids: Array[String]) -> Array[Dictionary]:
	return database.resolve_cards(card_ids)

func _enemy_attack(damage: int, hp := 20) -> Dictionary:
	return _enemy_actions([{ "type": "attack", "damage": damage, "block": 0, "description": "攻擊 %d" % damage }], hp)

func _azki_summon() -> Dictionary:
	return database.get_character("azki").get("summon", {})

func _enemy_actions(actions: Array[Dictionary], hp := 20) -> Dictionary:
	return {
		"id": "test-enemy",
		"display_name": "測試敵人",
		"max_hp": hp,
		"gold": 0,
		"scale": 1.0,
		"resource_base_path": "",
		"actions": actions
	}

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_false(actual: bool, message: String) -> void:
	if actual:
		failures.append("%s：expected false, got true" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
