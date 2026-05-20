extends SceneTree

const RuntimeDatabaseScript := preload("res://scripts/data/RuntimeDatabase.gd")
const MainScene := preload("res://scenes/main.tscn")

var database = RuntimeDatabaseScript.new()
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_test_character_starting_decks_are_valid()
	_test_character_passives_are_defined()
	_test_character_identity_hooks_and_boss_warning_metadata_are_defined()
	_test_character_identity_metadata_is_structured()
	_test_boss_warning_metadata_is_structured()
	_test_azki_art_paths_are_prepared_for_future_drop_in_assets()
	_test_card_depth_metadata_is_valid()
	_test_cards_have_valid_effects_and_assets()
	_test_visual_asset_slots_are_present()
	_test_supported_status_icons_are_defined()
	_test_v42_visual_assets_are_connected()
	_test_all_cards_have_v43_art_paths()
	_test_player_attack_animation_matches_cost()
	_test_character_card_pools_have_distinct_combat_profiles()
	_test_subaru_early_bridge_cards_have_elite_stability_floor()
	_test_subaru_starter_payoff_has_elite_damage_floor()
	_test_enemies_have_valid_actions_and_assets()
	_test_enemy_pressure_progression_is_balanced()
	_test_map_nodes_reference_valid_enemies()
	_test_boss_pool_is_valid()
	_test_safe_lookup_methods_return_empty_for_missing_ids()
	_test_battle_gold_rewards_have_clear_progression()
	_test_relic_data_is_valid()
	_test_relic_depth_hooks_are_declared()
	_test_shop_discount_relic_description_matches_runtime_scope()
	_test_botan_survival_bridge_cards_have_demo_balance_floor()
	_test_content_pack_1b_cards_and_relics_are_connected()
	_test_content_pack_2a_cards_are_connected()
	_test_card_depth_v1_cards_are_connected()
	_test_upgrade_v2_uses_card_specific_effects()
	_test_enemy_pressure_metadata_is_valid()
	await _test_reward_and_shop_cards_are_valid()

	if failures.is_empty():
		print("runtime_database_tests: ok")
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("runtime_database_tests: failed (%d)" % failures.size())
		quit(1)

func _test_character_starting_decks_are_valid() -> void:
	var seen_ids: Dictionary = {}
	for character in database.characters:
		var character_id := str(character.get("id", ""))
		_expect_not_empty(character_id, "角色 id 不可為空")
		_expect_false(seen_ids.has(character_id), "角色 id 不可重複：%s" % character_id)
		seen_ids[character_id] = true
		_expect_eq(character["starting_deck"].size(), 10, "%s 起始牌組必須是 10 張" % character_id)
		_expect_true(int(character["max_hp"]) > 0, "%s max_hp 必須大於 0" % character_id)
		_expect_true(ResourceLoader.exists("%sidle/sheet-transparent.png" % str(character["resource_base_path"])), "%s 必須有 idle 圖片" % character_id)
		for card_id in character["starting_deck"]:
			_expect_true(_card_exists(str(card_id)), "%s 起始牌組卡牌不存在：%s" % [character_id, str(card_id)])

func _test_character_passives_are_defined() -> void:
	var subaru := database.get_character("subaru")
	var botan := database.get_character("botan")
	var azki := database.get_character("azki")
	_expect_eq(str(subaru.get("passive", {}).get("id", "")), "subaru-tempo-guard", "Subaru 需要低費節奏被動")
	_expect_eq(str(subaru.get("passive", {}).get("hook", "")), "first_cheap_card_each_turn", "Subaru 被動 hook")
	_expect_eq(int(subaru.get("passive", {}).get("cost_max", -1)), 1, "Subaru 被動應支援 0/1 費")
	_expect_eq(int(subaru.get("passive", {}).get("block", 0)), 3, "Subaru 被動應給 3 格擋")
	_expect_eq(str(botan.get("passive", {}).get("id", "")), "botan-sniper-opening", "Botan 需要 2 費攻擊爆發被動")
	_expect_eq(str(botan.get("passive", {}).get("hook", "")), "first_two_cost_attack_each_turn", "Botan 被動 hook")
	_expect_eq(int(botan.get("passive", {}).get("bonus_damage", 0)), 6, "Botan 被動應追加 6 傷害")
	_expect_eq(str(azki.get("passive", {}).get("id", "")), "azki-pioneer-coordinate", "AZKi 需要標記抽牌被動")
	_expect_eq(str(azki.get("passive", {}).get("hook", "")), "first_marker_each_turn", "AZKi 被動 hook")
	_expect_eq(int(azki.get("passive", {}).get("draw", 0)), 1, "AZKi 被動應抽 1 張")
	_expect_eq(str(azki.get("summon", {}).get("id", "")), "laplus", "AZKi 需要 Laplus summon 設定")
	_expect_eq(int(azki.get("summon", {}).get("max_hp", 0)), 1, "Laplus summon max_hp 只作起始參考")
	_expect_eq(int(azki.get("summon", {}).get("starting_hp", 0)), 1, "Laplus summon 初始 HP 應為 1")
	_expect_eq(int(azki.get("summon", {}).get("turn_start_summon", 0)), 0, "Laplus 不應在玩家回合開始自動疊 HP")
	_expect_true(ResourceLoader.exists("%sidle/sheet-transparent.png" % str(azki.get("summon", {}).get("resource_base_path", ""))), "Laplus summon idle 素材必須存在")

func _test_character_identity_hooks_and_boss_warning_metadata_are_defined() -> void:
	var subaru := database.get_character("subaru")
	var botan := database.get_character("botan")
	var azki := database.get_character("azki")
	_expect_not_empty(str(subaru.get("identity_hint", "")), "Subaru 應定義角色定位提示")
	_expect_not_empty(str(botan.get("identity_hint", "")), "Botan 應定義角色定位提示")
	_expect_not_empty(str(azki.get("identity_hint", "")), "AZKi 應定義角色定位提示")
	_expect_not_empty(str(subaru.get("passive", {}).get("preview_text", "")), "Subaru 被動需提供戰鬥提示短文")
	_expect_not_empty(str(botan.get("passive", {}).get("preview_text", "")), "Botan 被動需提供戰鬥提示短文")
	_expect_not_empty(str(azki.get("passive", {}).get("preview_text", "")), "AZKi 被動需提供戰鬥提示短文")
	for boss_id in ["subaruto-duck", "youtube-kun-core", "important-announcement", "ssrb-giant-gray", "ssrb-giant-camouflage", "ssrb-giant-white"]:
		var boss := database.get_enemy(boss_id)
		_expect_not_empty(str(boss.get("boss_danger_tag", "")), "%s 需提供 Boss 危險標籤" % boss_id)

func _test_character_identity_metadata_is_structured() -> void:
	for character_id in ["subaru", "botan", "azki"]:
		var character := database.get_character(character_id)
		var focus_tags: Array = character.get("identity_focus_tags", [])
		var signature_card_ids: Array = character.get("signature_card_ids", [])
		_expect_true(focus_tags.size() >= 2, "%s 需提供至少 2 個 identity_focus_tags" % character_id)
		_expect_true(signature_card_ids.size() >= 2, "%s 需提供至少 2 張 signature_card_ids" % character_id)
		for card_id_variant in signature_card_ids:
			var card_id := str(card_id_variant)
			_expect_true(_card_exists(card_id), "%s signature card 必須存在：%s" % [character_id, card_id])
			_expect_true(card_id.begins_with("%s-" % character_id), "%s signature card 不可引用其他角色卡：%s" % [character_id, card_id])
	var subaru := database.get_character("subaru")
	var botan := database.get_character("botan")
	var azki := database.get_character("azki")
	_expect_true(subaru.get("identity_focus_tags", []).has("cheap_chain"), "Subaru 應標記 cheap_chain")
	_expect_true(subaru.get("identity_focus_tags", []).has("tempo_block"), "Subaru 應標記 tempo_block")
	_expect_true(botan.get("identity_focus_tags", []).has("two_cost_burst"), "Botan 應標記 two_cost_burst")
	_expect_true(botan.get("identity_focus_tags", []).has("setup_control"), "Botan 應標記 setup_control")
	_expect_true(azki.get("identity_focus_tags", []).has("marker_setup"), "AZKi 應標記 marker_setup")
	_expect_true(azki.get("identity_focus_tags", []).has("marker_payoff"), "AZKi 應標記 marker_payoff")
	_expect_true(_card_cost_at_most(database.get_card("subaru-duck-tempo"), 1), "Subaru 招牌牌應維持低費節奏")
	_expect_true(_card_has_effect(database.get_card("subaru-new-oshi-call"), "block") and _card_has_effect(database.get_card("subaru-new-oshi-call"), "draw"), "Subaru 招牌牌應同時支援抽牌與防守")
	_expect_true(_card_cost_at_least(database.get_card("botan-heavy-shot"), 2), "Botan 招牌牌應維持 2 費爆發")
	_expect_true(_card_has_status(database.get_card("botan-funds-prepared"), "vulnerable"), "Botan 招牌牌應包含 setup/control")
	_expect_true(_card_has_effect(database.get_card("botan-funds-prepared"), "draw"), "Botan 招牌牌應讓 2 費爆發更容易接上")
	_expect_true(_card_has_status(database.get_card("azki-map-search"), "marker"), "AZKi 招牌牌應包含 marker setup")
	_expect_true(_card_has_effect(database.get_card("azki-open-route"), "draw_if_status"), "AZKi 招牌牌應包含 marker payoff")

func _test_boss_warning_metadata_is_structured() -> void:
	for boss_id in ["subaruto-duck", "youtube-kun-core", "important-announcement", "ssrb-giant-gray", "ssrb-giant-camouflage", "ssrb-giant-white"]:
		var boss := database.get_enemy(boss_id)
		_expect_not_empty(str(boss.get("boss_pattern", "")), "%s 需提供 boss_pattern" % boss_id)
		_expect_not_empty(str(boss.get("boss_counterplay", "")), "%s 需提供 boss_counterplay" % boss_id)
		_expect_true(int(boss.get("boss_spike_turn", 0)) >= 2, "%s 需提供合理的 boss_spike_turn" % boss_id)

func _test_azki_art_paths_are_prepared_for_future_drop_in_assets() -> void:
	for card in _cards_for_prefix("azki-"):
		var card_id := str(card.get("id", ""))
		var expected_art_path := "res://assets/cards/azki/%s.png" % card_id
		_expect_eq(str(card.get("expected_art_path", "")), expected_art_path, "%s 應預留固定的 AZKi 卡圖路徑" % card_id)
		if ResourceLoader.exists(expected_art_path):
			_expect_eq(str(card.get("art_path", "")), expected_art_path, "%s 若正式卡圖已存在，art_path 應自動接上" % card_id)
		else:
			_expect_eq(str(card.get("art_path", "")), "", "%s 若正式卡圖尚未落地，art_path 應維持空字串 fallback" % card_id)

func _test_card_depth_metadata_is_valid() -> void:
	for card in database.cards:
		var card_id := str(card.get("id", ""))
		_expect_true(["starter", "common", "uncommon", "rare", "curse"].has(str(card.get("rarity", ""))), "%s rarity 必須是合法值" % card_id)
		_expect_true(card.get("archetype_tags", []).size() > 0, "%s 必須有 archetype_tags" % card_id)
		_expect_true(card.get("role_tags", []).size() > 0, "%s 必須有 role_tags" % card_id)
		_expect_true(["early", "mid", "late", "boss"].has(str(card.get("floor_band", ""))), "%s floor_band 必須合法" % card_id)
		_expect_not_empty(str(card.get("upgrade_plan", "")), "%s 必須有 upgrade_plan" % card_id)
		_expect_true(["formal", "prototype_placeholder", "generated_later"].has(str(card.get("art_status", ""))), "%s art_status 必須合法" % card_id)

func _test_cards_have_valid_effects_and_assets() -> void:
	var allowed_kinds := { "attack": true, "defense": true, "support": true, "mixed": true }
	var allowed_effects := { "damage": true, "block": true, "draw": true, "draw_if_status": true, "energy": true, "status": true, "conditional": true, "summon_heal": true, "summon_hp_damage": true, "next_attack_bonus": true, "draw_from_discard": true, "temporary_card": true }
	var seen_ids: Dictionary = {}
	for card in database.cards:
		var card_id := str(card.get("id", ""))
		_expect_not_empty(card_id, "卡牌 id 不可為空")
		_expect_false(seen_ids.has(card_id), "卡牌 id 不可重複：%s" % card_id)
		seen_ids[card_id] = true
		_expect_true(allowed_kinds.has(str(card["kind"])), "%s 卡牌 kind 不合法：%s" % [card_id, str(card["kind"])])
		_expect_true(int(card["cost"]) >= 0, "%s cost 不可小於 0" % card_id)
		_expect_true(card["effects"].size() > 0, "%s 必須至少有一個 effect" % card_id)
		for effect in card["effects"]:
			var effect_type := str(effect["type"])
			_expect_true(allowed_effects.has(effect_type), "%s effect type 不合法：%s" % [card_id, effect_type])
			if effect_type == "conditional":
				_expect_true(effect.has("condition"), "%s conditional effect 必須有 condition" % card_id)
				_expect_true(effect.get("effects", []).size() > 0, "%s conditional effect 必須有 nested effects" % card_id)
				continue
			if effect_type == "summon_hp_damage":
				_expect_true(int(effect.get("base", 0)) > 0, "%s summon_hp_damage base 必須大於 0" % card_id)
				_expect_true(int(effect.get("per_hp", 0)) > 0, "%s summon_hp_damage per_hp 必須大於 0" % card_id)
				continue
			if effect_type == "temporary_card":
				_expect_true(effect.has("card"), "%s temporary_card 必須提供內嵌 card" % card_id)
				_expect_true(int(effect.get("amount", 1)) > 0, "%s temporary_card amount 必須大於 0" % card_id)
				continue
			_expect_true(int(effect["amount"]) > 0, "%s effect amount 必須大於 0" % card_id)
			if effect_type == "damage":
				_expect_true(int(effect.get("hits", 1)) > 0, "%s damage hits 必須大於 0" % card_id)
		_expect_card_animation_asset_exists(card)

func _test_visual_asset_slots_are_present() -> void:
	for card in database.cards:
		var card_id := str(card.get("id", ""))
		_expect_true(card.has("art_path"), "%s card 必須預留 art_path 圖片欄位" % card_id)
		if str(card.get("art_path", "")) != "":
			_expect_true(ResourceLoader.exists(str(card["art_path"])), "%s card art_path 不存在：%s" % [card_id, str(card["art_path"])])
	for relic in database.relics:
		var relic_id := str(relic.get("id", ""))
		_expect_true(relic.has("icon_path"), "%s relic 必須預留 icon_path 圖片欄位" % relic_id)
		if str(relic.get("icon_path", "")) != "":
			_expect_true(ResourceLoader.exists(str(relic["icon_path"])), "%s relic icon_path 不存在：%s" % [relic_id, str(relic["icon_path"])])
	for enemy in database.enemies:
		var enemy_id := str(enemy.get("id", ""))
		for action in enemy.get("actions", []):
			_expect_true(action.has("icon_path"), "%s enemy action 必須預留 intent icon_path 欄位" % enemy_id)
			if str(action.get("icon_path", "")) != "":
				_expect_true(ResourceLoader.exists(str(action["icon_path"])), "%s enemy action icon_path 不存在：%s" % [enemy_id, str(action["icon_path"])])
			if str(action.get("status_id", "")) != "":
				_expect_true(action.has("status_icon_path"), "%s enemy status action 必須預留 status_icon_path 欄位" % enemy_id)
				if str(action.get("status_icon_path", "")) != "":
					_expect_true(ResourceLoader.exists(str(action["status_icon_path"])), "%s enemy status_icon_path 不存在：%s" % [enemy_id, str(action["status_icon_path"])])

func _test_supported_status_icons_are_defined() -> void:
	var expected_paths := {
		"strength": "res://assets/icons/status/strength.png",
		"weak": "res://assets/icons/status/weak.png",
		"vulnerable": "res://assets/icons/status/vulnerable.png",
		"regen": "res://assets/icons/status/regen.png"
	}
	for status_id in expected_paths.keys():
		var asset_path := str(expected_paths[status_id])
		_expect_true(ResourceLoader.exists(asset_path), "%s status icon 必須存在：%s" % [status_id, asset_path])
	for card in database.cards:
		for effect in card.get("effects", []):
			var status_id := str(effect.get("status_id", ""))
			if expected_paths.has(status_id):
				_expect_eq(str(effect.get("status_icon_path", "")), str(expected_paths[status_id]), "%s card status_icon_path 應接正式狀態 icon" % status_id)
	for enemy in database.enemies:
		for action in enemy.get("actions", []):
			var status_id := str(action.get("status_id", ""))
			if expected_paths.has(status_id):
				_expect_eq(str(action.get("status_icon_path", "")), str(expected_paths[status_id]), "%s enemy status_icon_path 應接正式狀態 icon" % status_id)

func _test_v42_visual_assets_are_connected() -> void:
	var card_paths := {
		"subaru-strike": "res://assets/cards/subaru/subaru-strike.png",
		"subaru-guard": "res://assets/cards/subaru/subaru-guard.png",
		"subaru-duck-rush": "res://assets/cards/subaru/subaru-duck-rush.png",
		"subaru-draw-breath": "res://assets/cards/subaru/subaru-draw-breath.png",
		"subaru-tsukkomi": "res://assets/cards/subaru/subaru-tsukkomi.png",
		"botan-shot": "res://assets/cards/botan/botan-shot.png",
		"botan-cover": "res://assets/cards/botan/botan-cover.png",
		"botan-burst": "res://assets/cards/botan/botan-burst.png",
		"botan-reload": "res://assets/cards/botan/botan-reload.png",
		"botan-mark": "res://assets/cards/botan/botan-mark.png"
	}
	for card_id in card_paths.keys():
		var card := database.get_card(str(card_id))
		_expect_eq(str(card.get("art_path", "")), str(card_paths[card_id]), "%s 起始牌圖應接正式 art_path" % str(card_id))
		_expect_true(ResourceLoader.exists(str(card_paths[card_id])), "%s 起始牌圖檔案必須存在" % str(card_id))

	var intent_paths := {
		"attack": "res://assets/icons/intent/attack.png",
		"block": "res://assets/icons/intent/block.png",
		"attack_block": "res://assets/icons/intent/attack_block.png",
		"buff": "res://assets/icons/intent/buff.png",
		"debuff": "res://assets/icons/intent/debuff.png"
	}
	for intent_type in intent_paths.keys():
		_expect_true(ResourceLoader.exists(str(intent_paths[intent_type])), "%s intent icon 必須存在" % str(intent_type))
	for enemy in database.enemies:
		for action in enemy.get("actions", []):
			var action_type := str(action.get("type", ""))
			if intent_paths.has(action_type):
				_expect_eq(str(action.get("icon_path", "")), str(intent_paths[action_type]), "%s action 應接 intent icon" % action_type)

	for relic in database.relics:
		var relic_id := str(relic.get("id", ""))
		var expected_path := "res://assets/icons/relic/%s.png" % relic_id
		_expect_eq(str(relic.get("icon_path", "")), expected_path, "%s relic 應接正式 icon_path" % relic_id)
		_expect_true(ResourceLoader.exists(expected_path), "%s relic icon 必須存在" % relic_id)

func _test_all_cards_have_v43_art_paths() -> void:
	for card in database.cards:
		var card_id := str(card.get("id", ""))
		var art_path := str(card.get("art_path", ""))
		if card_id.begins_with("azki-") or card_id.begins_with("curse-") or str(card.get("art_status", "")) == "prototype_placeholder":
			continue
		_expect_not_empty(art_path, "%s V4.3 後所有目前卡牌都應有正式 art_path" % card_id)
		_expect_true(ResourceLoader.exists(art_path), "%s card art_path 必須存在：%s" % [card_id, art_path])

func _test_player_attack_animation_matches_cost() -> void:
	for card in _cards_for_prefix("subaru-"):
		if not _card_has_damage_effect(card):
			continue
		var cost := int(card.get("cost", 0))
		if cost == 1:
			_expect_eq(str(card.get("animation", "")), "normal_attack", "%s cost 1 攻擊牌應使用 normal_attack" % str(card.get("id", "")))
		if cost == 2:
			_expect_eq(str(card.get("animation", "")), "tsukkomi", "%s cost 2 攻擊牌應使用 tsukkomi" % str(card.get("id", "")))
	for card in _cards_for_prefix("botan-"):
		if not _card_has_damage_effect(card):
			continue
		var cost := int(card.get("cost", 0))
		if cost == 1:
			_expect_eq(str(card.get("animation", "")), "pistol_attack", "%s cost 1 傷害牌應使用 pistol_attack" % str(card.get("id", "")))
		if cost == 2:
			_expect_eq(str(card.get("animation", "")), "sniper_ultimate", "%s cost 2 傷害牌應使用 sniper_ultimate" % str(card.get("id", "")))
	for card in _cards_for_prefix("azki-"):
		if not _card_has_damage_effect(card):
			continue
		var animation := str(card.get("animation", ""))
		_expect_true(["map_marker_attack", "kiss_attack", "laplus_dash", "laplus_crash"].has(animation), "%s AZKi 傷害牌應使用 AZKi / Laplus 攻擊動作：%s" % [str(card.get("id", "")), animation])

func _test_character_card_pools_have_distinct_combat_profiles() -> void:
	var subaru_cards := _cards_for_prefix("subaru-")
	var botan_cards := _cards_for_prefix("botan-")
	var azki_cards := _cards_for_prefix("azki-")
	_expect_true(_count_cards_with_cost_at_most(subaru_cards, 1) >= 14, "Subaru 應維持大量 0/1 費節奏牌")
	_expect_true(_count_cards_with_effect(subaru_cards, "draw") >= 5, "Subaru 應有足夠抽牌 / 循環牌")
	_expect_true(_count_cards_with_hits_at_least(subaru_cards, 2) >= 3, "Subaru 應有多段攻擊特色")
	_expect_true(_count_cards_with_cost_at_least(botan_cards, 2) >= 6, "Botan 應保留較多 2 費重牌")
	_expect_true(_average_attack_damage(botan_cards) > _average_attack_damage(subaru_cards), "Botan 攻擊牌平均輸出應高於 Subaru")
	_expect_true(_count_cards_with_status(botan_cards, "weak") + _count_cards_with_status(botan_cards, "vulnerable") >= 4, "Botan 應有較多弱化 / 易傷控制")
	_expect_true(azki_cards.size() >= 13, "AZKi 第一版至少需要起手與 reward 卡池")
	_expect_true(_count_cards_with_status(azki_cards, "marker") >= 5, "AZKi 應有足夠標記牌")
	_expect_true(_count_cards_with_effect(azki_cards, "draw") + _count_cards_with_effect(azki_cards, "draw_if_status") >= 4, "AZKi 應有抽牌 / 探索節奏")

func _test_subaru_early_bridge_cards_have_elite_stability_floor() -> void:
	var desk_reaction := database.get_card("subaru-desk-reaction")
	_expect_true(_card_effect_amount(desk_reaction, "block") >= 8, "Subaru desk-reaction 需提供足夠 early elite 即時格擋")

func _test_subaru_starter_payoff_has_elite_damage_floor() -> void:
	var tsukkomi := database.get_card("subaru-tsukkomi")
	_expect_true(_card_effect_amount(tsukkomi, "damage") >= 8, "Subaru tsukkomi 需提供足夠 early elite 收束傷害")

func _test_enemies_have_valid_actions_and_assets() -> void:
	var allowed_actions := { "attack": true, "block": true, "attack_block": true, "debuff": true, "buff": true }
	var seen_ids: Dictionary = {}
	for enemy in database.enemies:
		var enemy_id := str(enemy.get("id", ""))
		_expect_not_empty(enemy_id, "敵人 id 不可為空")
		_expect_false(seen_ids.has(enemy_id), "敵人 id 不可重複：%s" % enemy_id)
		seen_ids[enemy_id] = true
		_expect_true(int(enemy["max_hp"]) > 0, "%s max_hp 必須大於 0" % enemy_id)
		_expect_true(enemy["actions"].size() > 0, "%s 必須至少有一個 action" % enemy_id)
		_expect_enemy_asset_exists(enemy, "idle")
		_expect_enemy_asset_exists(enemy, "attack")
		_expect_enemy_asset_exists(enemy, "hurt")
		if _has_guard_and_defeat_enemy_assets(str(enemy["resource_base_path"])):
			_expect_enemy_asset_exists(enemy, "guard")
			_expect_enemy_asset_exists(enemy, "defeat")
		if enemy.has("secondary_resource_base_path"):
			_expect_enemy_secondary_asset_exists(enemy, "idle")
			_expect_enemy_secondary_asset_exists(enemy, "attack")
			_expect_enemy_secondary_asset_exists(enemy, "hurt")
			if _has_guard_and_defeat_enemy_assets(str(enemy["secondary_resource_base_path"])):
				_expect_enemy_secondary_asset_exists(enemy, "guard")
				_expect_enemy_secondary_asset_exists(enemy, "defeat")
		for action in enemy["actions"]:
			var action_type := str(action["type"])
			_expect_true(allowed_actions.has(action_type), "%s action type 不合法：%s" % [enemy_id, action_type])
			_expect_true(int(action["damage"]) >= 0, "%s action damage 不可小於 0" % enemy_id)
			_expect_true(int(action["block"]) >= 0, "%s action block 不可小於 0" % enemy_id)
			if action_type == "attack":
				_expect_true(int(action["damage"]) > 0, "%s attack action 必須有傷害" % enemy_id)
			if action_type == "block":
				_expect_true(int(action["block"]) > 0, "%s block action 必須有格擋" % enemy_id)
			if action_type == "attack_block":
				_expect_true(int(action["damage"]) > 0 and int(action["block"]) > 0, "%s attack_block 必須同時有傷害與格擋" % enemy_id)
			if action_type == "debuff" or action_type == "buff":
				_expect_not_empty(str(action.get("status_id", "")), "%s %s action 必須有 status_id" % [enemy_id, action_type])

func _test_enemy_pressure_progression_is_balanced() -> void:
	var normal_ids := ["ssrb-gray", "ssrb-camouflage", "ssrb-white", "ssrb-gold", "ssrb-glitch", "youtube-kun", "desk-kun", "announcement-shadow", "korone-suki"]
	for enemy_id in normal_ids:
		var enemy := database.get_enemy(enemy_id)
		var encounter_tier := str(enemy.get("encounter_tier", ""))
		_expect_true(["early", "mid", "late"].has(encounter_tier), "%s 普通敵人需要 encounter_tier" % enemy_id)
		if encounter_tier == "early":
			_expect_true(_max_enemy_damage(enemy) >= 9 and _max_enemy_damage(enemy) <= 15, "%s early 普通敵人壓力應維持前期範圍" % enemy_id)
			_expect_true(int(enemy.get("max_hp", 0)) <= 58, "%s early 普通敵人 HP 不應拖太長" % enemy_id)
		elif encounter_tier == "mid":
			_expect_true(_max_enemy_damage(enemy) >= 10 and _max_enemy_damage(enemy) <= 20, "%s mid 普通敵人壓力應高於前期" % enemy_id)
			_expect_true(int(enemy.get("max_hp", 0)) <= 66, "%s mid 普通敵人 HP 不應拖太長" % enemy_id)
		elif encounter_tier == "late":
			_expect_true(_max_enemy_damage(enemy) >= 14 and _max_enemy_damage(enemy) <= 24, "%s late 普通敵人需要後段壓力" % enemy_id)
			_expect_true(int(enemy.get("max_hp", 0)) <= 72, "%s late 普通敵人 HP 不應拖太長" % enemy_id)
	var elite_ids := ["ssrb-duo-gray-camouflage", "ssrb-duo-gray-white", "ssrb-duo-camouflage-white", "ssrb-duo-gold-glitch", "ak-idol-unit", "kedama-elite"]
	for enemy_id in elite_ids:
		var enemy := database.get_enemy(enemy_id)
		_expect_true(_max_enemy_damage(enemy) >= 18, "%s 菁英敵人需要高於普通戰壓力" % enemy_id)
		_expect_true(_max_enemy_damage(enemy) <= 26, "%s 菁英敵人單下壓力應維持中高範圍" % enemy_id)
		_expect_true(int(enemy.get("max_hp", 0)) >= 92 and int(enemy.get("max_hp", 0)) <= 112, "%s 菁英 HP 應符合長地圖範圍" % enemy_id)
		_expect_true(["mid", "late"].has(str(enemy.get("elite_tier", ""))), "%s 菁英敵人需要 elite_tier" % enemy_id)
	var boss_ids := ["subaruto-duck", "ssrb-giant-gray", "ssrb-giant-camouflage", "ssrb-giant-white", "youtube-kun-core", "important-announcement"]
	for enemy_id in boss_ids:
		var enemy := database.get_enemy(enemy_id)
		var min_boss_damage := 14 if enemy_id == "subaruto-duck" else 24
		var min_boss_hp := 78 if enemy_id == "subaruto-duck" else 112
		_expect_true(_max_enemy_damage(enemy) >= min_boss_damage, "%s Boss 需要長地圖終局壓力" % enemy_id)
		_expect_true(_max_enemy_damage(enemy) <= 32, "%s Boss 單下壓力應維持中等範圍" % enemy_id)
		_expect_true(int(enemy.get("max_hp", 0)) >= min_boss_hp and int(enemy.get("max_hp", 0)) <= 132, "%s Boss HP 應符合單 Act 終局範圍" % enemy_id)

func _test_map_nodes_reference_valid_enemies() -> void:
	var expected_ids := ["start", "enemy-1", "event-1", "enemy-2", "chest", "elite-1", "shop", "event-2", "enemy-3", "campfire", "enemy-4", "event-3", "enemy-5", "boss"]
	_expect_eq(database.map_nodes.size(), expected_ids.size(), "固定路線節點數量")
	for index in range(expected_ids.size()):
		_expect_eq(str(database.map_nodes[index]["id"]), expected_ids[index], "固定路線節點順序 index %d" % index)

	var battle_count := 0
	var elite_count := 0
	var event_count := 0
	var allowed_node_types := { "start": true, "battle": true, "elite": true, "chest": true, "shop": true, "event": true, "campfire": true, "boss": true }
	for node in database.map_nodes:
		var node_id := str(node["id"])
		var node_type := str(node["type"])
		_expect_true(allowed_node_types.has(node_type), "%s node type 不合法：%s" % [node_id, node_type])
		if node_type == "battle":
			battle_count += 1
			_expect_true(node.has("enemy_id"), "%s battle node 必須有 enemy_id" % node_id)
			_expect_true(_enemy_exists(str(node["enemy_id"])), "%s enemy_id 不存在：%s" % [node_id, str(node["enemy_id"])])
		if node_type == "event":
			event_count += 1
			_expect_not_empty(str(node.get("event_id", "")), "%s event_id 不可為空" % node_id)
			_expect_not_empty(str(node.get("title", "")), "%s event title 不可為空" % node_id)
			_expect_not_empty(str(node.get("description", "")), "%s event description 不可為空" % node_id)
		if node_type == "elite":
			elite_count += 1
			_expect_true(node.has("elite_enemy_ids"), "%s elite node 必須有 elite_enemy_ids" % node_id)
			_expect_true(node["elite_enemy_ids"].size() >= 2, "%s elite pool 至少需要 2 組敵人" % node_id)
			for enemy_id in node["elite_enemy_ids"]:
				_expect_true(_enemy_exists(str(enemy_id)), "%s elite enemy 不存在：%s" % [node_id, str(enemy_id)])
				if _enemy_exists(str(enemy_id)):
					var enemy: Dictionary = database.get_enemy(str(enemy_id))
					_expect_eq(str(enemy.get("tier", "")), "elite", "%s elite enemy 必須標記 tier=elite" % str(enemy_id))
					if str(enemy.get("id", "")).begins_with("ssrb-duo") or str(enemy.get("id", "")) == "ak-idol-unit":
						_expect_true(enemy.has("secondary_resource_base_path"), "%s 雙體菁英必須有第二隻 SSRB 視覺" % str(enemy_id))
	_expect_eq(battle_count, 5, "固定路線普通戰數量")
	_expect_eq(elite_count, 1, "固定路線菁英戰數量")
	_expect_eq(event_count, 3, "固定路線事件數量")
	_expect_eq(str(database.map_nodes[2].get("event_id", "")), "holostar-sponsor", "事件 1 必須是 HoloStar 贊助事件")
	_expect_eq(str(database.map_nodes[2].get("title", "")), "遇到流離失所的 HoloStar 成員", "事件 1 標題必須符合指定敘事")
	_expect_true(str(database.map_nodes[2].get("description", "")).contains("是否要贊助資源給他"), "事件 1 描述必須包含指定提問")
	_expect_eq(str(database.map_nodes[7].get("event_id", "")), "stream-incident-support", "事件 2 必須是直播事故支援事件")
	_expect_eq(str(database.map_nodes[11].get("event_id", "")), "fan-cheer-prep", "事件 3 必須是粉絲應援整隊事件")
	var event_ids := {}
	for node in database.map_nodes:
		if str(node["type"]) == "event":
			event_ids[str(node.get("event_id", ""))] = true
	_expect_eq(event_ids.size(), 3, "三個事件節點必須使用不同事件內容")

func _test_boss_pool_is_valid() -> void:
	var boss_node: Dictionary = database.map_nodes[database.map_nodes.size() - 1]
	_expect_eq(str(boss_node["type"]), "boss", "最後一個節點必須是 Boss")
	_expect_true(boss_node.has("boss_enemy_ids"), "Boss 節點必須有 boss_enemy_ids")
	_expect_true(boss_node["boss_enemy_ids"].size() > 0, "Boss pool 不可為空")
	for boss_id in boss_node["boss_enemy_ids"]:
		var enemy_id := str(boss_id)
		_expect_true(_enemy_exists(enemy_id), "Boss pool enemy 不存在：%s" % enemy_id)
		if _enemy_exists(enemy_id):
			var enemy: Dictionary = database.get_enemy(enemy_id)
			_expect_true(bool(enemy.get("is_boss", false)), "Boss pool 內敵人必須標記 is_boss：%s" % enemy_id)
			_expect_true(float(enemy.get("scale", 1.0)) >= 1.5, "Boss 顯示 scale 應至少 1.5：%s" % enemy_id)

func _test_safe_lookup_methods_return_empty_for_missing_ids() -> void:
	_expect_true(database.has_method("find_card"), "RuntimeDatabase 需提供 find_card safe lookup")
	_expect_true(database.has_method("find_enemy"), "RuntimeDatabase 需提供 find_enemy safe lookup")
	_expect_true(database.has_method("find_relic"), "RuntimeDatabase 需提供 find_relic safe lookup")
	if database.has_method("find_card"):
		_expect_true(database.find_card("__missing_card__").is_empty(), "find_card 缺資料時應回傳空 Dictionary")
	if database.has_method("find_enemy"):
		_expect_true(database.find_enemy("__missing_enemy__").is_empty(), "find_enemy 缺資料時應回傳空 Dictionary")
	if database.has_method("find_relic"):
		_expect_true(database.find_relic("__missing_relic__").is_empty(), "find_relic 缺資料時應回傳空 Dictionary")

func _test_battle_gold_rewards_have_clear_progression() -> void:
	var normal_gold_total := 0
	var normal_count := 0
	for node in database.map_nodes:
		if str(node["type"]) == "battle":
			var enemy := database.get_enemy(str(node["enemy_id"]))
			var gold := int(enemy.get("gold", 0))
			normal_gold_total += gold
			normal_count += 1
			_expect_true(gold >= 20 and gold <= 40, "%s 普通戰金錢應維持少量：%d" % [str(enemy["id"]), gold])
		if str(node["type"]) == "elite":
			for enemy_id in node["elite_enemy_ids"]:
				var enemy := database.get_enemy(str(enemy_id))
				var gold := int(enemy.get("gold", 0))
				_expect_true(gold >= 50, "%s 菁英戰金錢應高於普通戰：%d" % [str(enemy_id), gold])
	_expect_eq(normal_count, 5, "固定路線普通戰數量應為 5")
	_expect_true(normal_gold_total >= 90, "到商店前普通戰金錢節奏不可過低")

func _test_relic_data_is_valid() -> void:
	_expect_true(database.relics.size() >= 8, "V2 relic 至少需要 8 個")
	var required_ids := { "cheer-lightstick": true, "duck-whistle": true, "shishiro-crosshair": true }
	var allowed_hooks := { "combat_start": true, "first_attack_played": true, "first_cheap_card_played": true, "first_two_cost_played": true, "first_marker_card_played": true, "turn_start": true, "battle_reward": true, "shop_enter": true, "room_enter": true }
	var allowed_triggers := { "": true, "card_played": true, "next_attack_bonus_added": true, "discard_retrieved": true, "temporary_card_created": true }
	var seen_ids: Dictionary = {}
	for relic in database.relics:
		var relic_id := str(relic.get("id", ""))
		_expect_not_empty(relic_id, "relic id 不可為空")
		_expect_false(seen_ids.has(relic_id), "relic id 不可重複：%s" % relic_id)
		seen_ids[relic_id] = true
		_expect_not_empty(str(relic.get("name", "")), "%s relic 名稱不可為空" % relic_id)
		_expect_not_empty(str(relic.get("description", "")), "%s relic 說明不可為空" % relic_id)
		_expect_true(allowed_hooks.has(str(relic.get("hook", ""))), "%s relic hook 不合法：%s" % [relic_id, str(relic.get("hook", ""))])
		_expect_true(allowed_triggers.has(str(relic.get("trigger", ""))), "%s relic trigger 不合法：%s" % [relic_id, str(relic.get("trigger", ""))])
		_expect_true(relic.get("source_rules", []).size() > 0, "%s relic source_rules 不可為空" % relic_id)
		_expect_true(int(relic.get("amount", 0)) > 0, "%s relic amount 必須大於 0" % relic_id)
	for relic_id in required_ids.keys():
		_expect_true(_relic_exists(str(relic_id)), "必要 relic 不存在：%s" % str(relic_id))

func _test_relic_depth_hooks_are_declared() -> void:
	var required_triggers := {
		"next_attack_bonus_added": false,
		"discard_retrieved": false,
		"temporary_card_created": false
	}
	for relic in database.relics:
		var trigger := str(relic.get("trigger", ""))
		if not required_triggers.has(trigger):
			continue
		required_triggers[trigger] = true
		_expect_true(relic.has("trigger_effects"), "%s relic depth trigger 必須使用 trigger_effects，避免覆蓋既有 hook 效果" % str(relic.get("id", "")))
		_expect_true(relic.get("archetype_tags", []).size() > 0, "%s relic depth trigger 必須標記 archetype_tags" % str(relic.get("id", "")))
	for trigger in required_triggers.keys():
		_expect_true(bool(required_triggers[trigger]), "005 relic depth hooks 必須宣告 trigger：%s" % str(trigger))

func _test_shop_discount_relic_description_matches_runtime_scope() -> void:
	var shop_coupon := database.get_relic("shop-coupon")
	var x_funds := database.get_relic("x-funds-wallet")
	_expect_false(str(shop_coupon.get("description", "")).contains("relic 價格"), "shop-coupon 描述不可承諾降低商店 relic 價格")
	_expect_false(str(x_funds.get("description", "")).contains("relic 價格"), "x-funds-wallet 描述不可承諾降低商店 relic 價格")

func _test_botan_survival_bridge_cards_have_demo_balance_floor() -> void:
	_expect_true(_first_block_amount("botan-medkit-cover") >= 7, "Botan 醫療掩體需提供足夠即時格擋")
	_expect_true(_first_status_value("botan-medkit-cover", "regen") >= 2, "Botan 醫療掩體需提供足夠回復續航")
	_expect_true(_first_block_amount("botan-clean-scope") >= 9, "Botan Clean Scope 需可承接 late-floor 壓力")
	_expect_true(_first_block_amount("botan-overwatch") >= 9, "Botan Overwatch 需可承接攻擊意圖")

func _test_content_pack_1b_cards_and_relics_are_connected() -> void:
	for card_id in ["azki-marker-echo", "azki-laplus-reposition"]:
		var card := database.get_card(card_id)
		_expect_eq(str(card.get("id", "")), card_id, "Content Pack 1B AZKi 卡牌必須存在：%s" % card_id)
		_expect_eq(str(card.get("expected_art_path", "")), "res://assets/cards/azki/%s.png" % card_id, "Content Pack 1B AZKi 卡牌必須預留卡圖路徑：%s" % card_id)
		_expect_eq(str(card.get("art_path", "")), "", "Content Pack 1B AZKi 卡圖尚未落地時應維持 ART placeholder：%s" % card_id)
	var duck_whistle := database.get_relic("duck-whistle")
	_expect_true(duck_whistle.has("effects"), "duck-whistle 應改用 multi-effect relic schema")
	_expect_eq(duck_whistle.get("effects", []).size(), 2, "duck-whistle 應同時抽牌與給格擋")
	var healing_chat := database.get_relic("healing-chat")
	var pamomi_signal := database.get_relic("pamomi-signal")
	_expect_eq(str(healing_chat.get("effect", "")), "heal", "healing-chat turn_start 應直接回血")
	_expect_eq(str(pamomi_signal.get("effect", "")), "heal", "pamomi-signal turn_start 應直接回血")
	var archive := database.get_relic("unarchived-archive")
	_expect_true(archive.has("effects"), "unarchived-archive 應改用 multi-effect relic schema")

func _test_content_pack_2a_cards_are_connected() -> void:
	var required_ids := [
		"subaru-opening-quack", "subaru-crowd-cover", "subaru-table-slam-loop", "subaru-unstoppable-cheer",
		"botan-range-finder", "botan-overwatch", "botan-piercing-round", "botan-perfect-line",
		"azki-route-marker", "azki-laplus-guard-order", "azki-singing-coordinate", "azki-necrobinder-finale",
		"azki-laplus-contract", "azki-dark-tether", "azki-laplus-overflow"
	]
	for card_id in required_ids:
		var card := database.get_card(card_id)
		_expect_eq(str(card.get("id", "")), card_id, "Content Pack 2A 卡牌必須存在：%s" % card_id)
		_expect_true(card.get("archetype_tags", []).size() > 0, "%s 必須有 archetype_tags" % card_id)
		_expect_true(card.get("role_tags", []).size() > 0, "%s 必須有 role_tags" % card_id)
		_expect_not_empty(str(card.get("upgrade_plan", "")), "%s 必須定義 upgrade_plan" % card_id)
		_expect_true(card.has("upgrade_effects"), "%s 新卡必須定義專屬 upgrade_effects" % card_id)
		_expect_not_empty(str(card.get("upgrade_description", "")), "%s 新卡必須定義 upgrade_description" % card_id)
		_expect_eq(str(card.get("art_status", "")), "prototype_placeholder", "%s 新卡應標記 prototype placeholder" % card_id)
		_expect_not_empty(str(card.get("expected_art_path", "")), "%s 新卡必須預留 expected_art_path" % card_id)
		_expect_eq(str(card.get("art_path", "")), "", "%s prototype placeholder 新卡不應要求正式 art_path" % card_id)

func _test_card_depth_v1_cards_are_connected() -> void:
	var required_ids := [
		"subaru-combo-boost", "subaru-encore-recall", "subaru-afterimage-table",
		"botan-kill-zone", "botan-cover-reload", "botan-flashbang-round",
		"azki-phantom-route", "azki-necro-recall", "azki-laplus-release"
	]
	var required_effects := {
		"next_attack_bonus": false,
		"draw_from_discard": false,
		"temporary_card": false,
		"exhaust_count_at_least": false
	}
	for card_id in required_ids:
		var card := database.get_card(card_id)
		_expect_eq(str(card.get("id", "")), card_id, "卡牌深度 v1 卡牌必須存在：%s" % card_id)
		_expect_true(card.get("archetype_tags", []).size() > 0, "%s 必須有 archetype_tags" % card_id)
		_expect_true(card.get("role_tags", []).size() > 0, "%s 必須有 role_tags" % card_id)
		_expect_true(["common", "uncommon", "rare"].has(str(card.get("rarity", ""))), "%s 必須有合法 rarity" % card_id)
		_expect_true(["early", "mid", "late"].has(str(card.get("floor_band", ""))), "%s 必須有合法 floor_band" % card_id)
		_expect_true(card.has("upgrade_effects"), "%s 必須定義 upgrade_effects" % card_id)
		_expect_not_empty(str(card.get("upgrade_description", "")), "%s 必須定義 upgrade_description" % card_id)
		_expect_not_empty(str(card.get("upgrade_signal", "")), "%s 必須定義 upgrade_signal" % card_id)
		_expect_eq(str(card.get("art_status", "")), "prototype_placeholder", "%s v1 prototype 應標記 prototype placeholder" % card_id)
		_expect_eq(str(card.get("art_path", "")), "", "%s v1 prototype 不應要求正式卡圖" % card_id)
		for effect in card.get("effects", []):
			_collect_v1_effect_schema(effect, required_effects)
		var upgraded := database.get_card("%s+" % card_id)
		_expect_eq(str(upgraded.get("id", "")), "%s+" % card_id, "%s 升級版必須可由 RuntimeDatabase 取出" % card_id)
		_expect_eq(str(upgraded.get("description", "")), str(card.get("upgrade_description", "")), "%s+ 必須使用 upgrade_description" % card_id)
	for effect_name in required_effects.keys():
		_expect_true(bool(required_effects[effect_name]), "卡牌深度 v1 必須至少覆蓋 effect schema：%s" % str(effect_name))
	_expect_true(_archetype_has_roles("cheap_chain", ["setup", "bridge", "defense", "payoff", "scaling"]), "Subaru cheap_chain 必須覆蓋主流派基本 roles")
	_expect_true(_archetype_has_roles("two_cost_burst", ["setup", "bridge", "defense", "payoff", "scaling"]), "Botan two_cost_burst 必須覆蓋主流派基本 roles")
	_expect_true(_archetype_has_roles("marker_loop", ["setup", "bridge", "defense", "payoff", "scaling"]), "AZKi marker_loop 必須覆蓋主流派基本 roles")

func _test_upgrade_v2_uses_card_specific_effects() -> void:
	var base := database.get_card("subaru-opening-quack")
	var upgraded := database.get_card("subaru-opening-quack+")
	_expect_eq(str(upgraded.get("id", "")), "subaru-opening-quack+", "Upgrade v2 應保留 + id")
	_expect_eq(str(upgraded.get("description", "")), str(base.get("upgrade_description", "")), "Upgrade v2 應使用卡牌專屬 upgrade_description")
	_expect_eq(upgraded.get("effects", []).size(), base.get("upgrade_effects", []).size(), "Upgrade v2 應使用卡牌專屬 upgrade_effects")

func _test_enemy_pressure_metadata_is_valid() -> void:
	var required_pressure_tags := {
		"anti_burst_into_block": false,
		"attack_intent_test": false,
		"debuff_resilience": false,
		"scaling_clock": false
	}
	for enemy in database.enemies:
		var enemy_id := str(enemy.get("id", ""))
		_expect_true(enemy.get("pressure_tags", []).size() > 0, "%s 必須有 pressure_tags" % enemy_id)
		_expect_true(enemy.get("tests_archetypes", []).size() > 0, "%s 必須有 tests_archetypes" % enemy_id)
		_expect_not_empty(str(enemy.get("counterplay_hint", "")), "%s 必須有 counterplay_hint" % enemy_id)
		for tag in enemy.get("pressure_tags", []):
			if required_pressure_tags.has(str(tag)):
				required_pressure_tags[str(tag)] = true
	for tag in required_pressure_tags.keys():
		_expect_true(bool(required_pressure_tags[tag]), "至少一個敵人必須覆蓋 pressure tag：%s" % str(tag))

func _test_reward_and_shop_cards_are_valid() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame
	for character_id in ["subaru", "botan", "azki"]:
		app.run_state.start_run(database, character_id)
		var reward_cards: Array[String] = app._character_reward_cards()
		var shop_cards: Array[String] = app._character_shop_cards()
		_expect_true(reward_cards.size() >= 8, "%s reward card pool 至少需要 8 張" % character_id)
		_expect_true(shop_cards.size() >= 5, "%s shop card pool 至少需要 5 張" % character_id)
		_expect_card_pool_matches_character(character_id, reward_cards, "reward")
		_expect_card_pool_matches_character(character_id, shop_cards, "shop")
		var drafted_rewards: Array[String] = app._draft_card_rewards(3)
		_expect_eq(drafted_rewards.size(), 3, "%s 戰鬥後 reward draft 必須是 3 選 1" % character_id)
		_expect_card_pool_matches_character(character_id, drafted_rewards, "drafted reward")
		for card_id in reward_cards:
			_expect_true(_card_exists(str(card_id)), "%s reward card 不存在：%s" % [character_id, str(card_id)])
		for card_id in shop_cards:
			_expect_true(_card_exists(str(card_id)), "%s shop card 不存在：%s" % [character_id, str(card_id)])
	app.run_state.start_run(database, "subaru")
	var normal_subtitle: String = app._combat_reward_subtitle(database.get_enemy("ssrb-gray"))
	_expect_true(normal_subtitle.contains("Gold 25"), "普通戰獎勵說明必須顯示取得 Gold")
	_expect_false(normal_subtitle.contains("relic"), "普通戰獎勵說明不應提到 relic")
	var elite_subtitle: String = app._combat_reward_subtitle(database.get_enemy("ssrb-duo-gray-camouflage"))
	_expect_true(elite_subtitle.contains("菁英戰"), "菁英戰獎勵說明必須標示菁英戰")
	_expect_true(elite_subtitle.contains("Gold 55"), "菁英戰獎勵說明必須顯示較高 Gold")
	_expect_true(elite_subtitle.contains("relic"), "菁英戰獎勵說明必須提示取得 relic")
	var boss_subtitle: String = app._combat_reward_subtitle(database.get_enemy("subaruto-duck"))
	_expect_true(boss_subtitle.contains("Boss"), "Boss 獎勵說明必須和一般卡牌獎勵區分")

	app.run_state.start_run(database, "subaru")
	app.run_state.current_node_index = 4
	app.show_chest_reward()
	await process_frame
	_expect_eq(app.run_state.relic_ids.size(), 1, "寶箱進入時必須固定隨機加入 1 個 relic")
	_expect_true(_relic_exists(str(app.run_state.relic_ids[0])), "寶箱取得的 relic 必須存在")
	_expect_eq(app.current_screen, "chest_reward", "寶箱畫面必須有獨立 current_screen，避免被一般 reward 刷新覆蓋")
	_expect_eq(_large_reward_card_button_count(app), 0, "寶箱不應顯示卡牌三選一")
	_expect_eq(_button_count_with_text(app, "取得 Gold 40"), 0, "寶箱不應提供 Gold 選項")
	_expect_eq(_button_count_with_text(app, "取得 relic"), 0, "寶箱不應提供 relic 多選按鈕")
	app.show_chest_reward()
	await process_frame
	_expect_eq(app.run_state.relic_ids.size(), 1, "刷新寶箱畫面不可重複取得 relic")
	app._continue_after_chest_reward()
	_expect_eq(app.run_state.current_node_index, 5, "確認寶箱 relic 後必須推進到下一節點")
	_expect_eq(app.current_screen, "map", "確認寶箱 relic 後必須回到地圖")

	app.run_state.start_run(database, "subaru")
	var normal_relic_count: int = app.run_state.relic_ids.size()
	var elite_relic_count := _relic_count_for_source("elite")
	app._grant_combat_relic_reward(database.get_enemy("ssrb-gray"))
	_expect_eq(app.run_state.relic_ids.size(), normal_relic_count, "普通戰不應自動給 relic")
	for _i in range(elite_relic_count):
		app._grant_combat_relic_reward(database.get_enemy("ssrb-duo-gray-camouflage"))
	_expect_eq(app.run_state.relic_ids.size(), elite_relic_count, "菁英戰必須依 elite source pool 發放 relic")
	var full_relic_gold_before: int = app.run_state.gold
	app._grant_combat_relic_reward(database.get_enemy("ssrb-duo-gray-camouflage"))
	_expect_eq(app.run_state.relic_ids.size(), elite_relic_count, "elite source pool 拿滿後菁英戰不可重複給")
	_expect_eq(app.run_state.gold, full_relic_gold_before + 25, "relic 拿滿後菁英戰 relic fallback 必須改給 Gold 25")

	app.run_state.start_run(database, "subaru")
	var cheap_card_price: int = app._shop_card_price(database.get_card("subaru-new-oshi-call"))
	var expensive_card_price: int = app._shop_card_price(database.get_card("subaru-team-rush"))
	_expect_true(cheap_card_price < expensive_card_price, "商店卡牌價格應依 cost / kind 拉開差異")
	_expect_true(cheap_card_price >= 25 and expensive_card_price <= 100, "商店卡牌價格應維持 MVP 合理範圍")
	_expect_eq(app._shop_relic_price(database.get_relic("cheer-lightstick")), 150, "common relic 商店價格應為 150")
	_expect_eq(app._shop_relic_price(database.get_relic("shishiro-crosshair")), 220, "elite relic 商店價格應為 220")
	_expect_eq(app._shop_relic_price(database.get_relic("boss-spotlight")), 250, "boss relic 商店價格應為 250")
	app.run_state.relic_ids.append("shop-coupon")
	_expect_eq(app._shop_relic_price(database.get_relic("cheer-lightstick")), 150, "商店 relic 價格不應被折扣 relic 降低")
	app.run_state.relic_ids.clear()
	app.run_state.gold = 220
	var before_shop_gold: int = app.run_state.gold
	var bought_shop_relic: bool = app._buy_shop_relic()
	_expect_true(bought_shop_relic, "商店 relic 金錢足夠時必須可購買")
	_expect_eq(app.run_state.gold, before_shop_gold - 150, "商店 common relic 必須扣除對應價格")
	_expect_eq(app.run_state.relic_ids.size(), 1, "商店 relic 購買後必須加入 1 個 relic")
	var owned_shop_relic := str(app.run_state.relic_ids[0])
	app.run_state.gold = 220
	app._buy_shop_relic()
	_expect_false(app.run_state.relic_ids.slice(1).has(owned_shop_relic), "商店 relic 不可重複購買已持有 relic")
	app.run_state.start_run(database, "subaru")
	for relic in database.relics:
		app.run_state.relic_ids.append(str(relic["id"]))
	var full_shop_gold_before: int = app.run_state.gold
	_expect_false(app._buy_shop_relic(), "商店 relic 拿滿時不可購買 relic")
	_expect_eq(app.run_state.gold, full_shop_gold_before, "商店 relic 拿滿時不可扣 Gold")
	app.run_state.start_run(database, "subaru")
	app.run_state.gold = 149
	var poor_shop_relic: bool = app._buy_shop_relic()
	_expect_false(poor_shop_relic, "商店 relic 金錢不足時不可購買")
	_expect_eq(app.run_state.relic_ids.size(), 0, "商店 relic 金錢不足時不可加入 relic")
	_expect_eq(app.run_state.gold, 149, "商店 relic 金錢不足時不可扣 Gold")

	var number_event := InputEventKey.new()
	number_event.keycode = KEY_6
	_expect_true(app._is_debug_key(number_event, KEY_6, KEY_KP_6), "debug 快捷鍵必須支援上排數字 6")
	var keypad_event := InputEventKey.new()
	keypad_event.keycode = KEY_KP_6
	_expect_true(app._is_debug_key(keypad_event, KEY_6, KEY_KP_6), "debug 快捷鍵必須支援小鍵盤 6")
	app.run_state.start_run(database, "azki")
	_press_debug_key(app, KEY_2)
	await process_frame
	_expect_eq(app.current_screen, "character_select", "debug 2 必須回到角色選擇畫面")
	_expect_true(app.run_state.character_id == "" or app.run_state.character_id == "azki", "debug 2 不應直接切換成固定角色")
	_press_debug_key(app, KEY_3)
	await process_frame
	_expect_eq(app.current_screen, "combat", "debug 3 必須直接進入普通戰測試")
	_expect_eq(app.run_state.current_node_index, 1, "debug 3 必須定位到普通戰節點")
	_expect_false(bool(app.combat.enemy.get("is_boss", false)), "debug 3 不應進入 Boss 戰")
	_expect_false(str(app.combat.enemy.get("tier", "")) == "elite", "debug 3 不應進入菁英戰")
	_press_debug_key(app, KEY_6)
	await process_frame
	_expect_eq(app.current_screen, "combat", "debug 6 必須直接進入戰鬥畫面")
	_expect_eq(str(app.combat.enemy.get("tier", "")), "elite", "debug 6 必須直接進入菁英戰")
	_expect_true(app.combat.enemy.has("secondary_resource_base_path"), "debug 6 菁英戰必須有第二隻 SSRB 視覺")
	app._debug_open_chest_reward()
	_expect_eq(app.current_screen, "chest_reward", "debug 7 必須直接進入寶箱獎勵畫面")
	_expect_eq(app.run_state.current_node_index, 4, "debug 7 必須定位到寶箱節點")
	app._debug_open_shop()
	_expect_eq(app.current_screen, "shop", "debug 8 必須直接進入商店畫面")
	_expect_eq(app.run_state.current_node_index, 6, "debug 8 必須定位到商店節點")
	app._debug_open_campfire()
	_expect_eq(app.current_screen, "campfire", "debug 9 必須直接進入篝火畫面")
	_expect_eq(app.run_state.current_node_index, 9, "debug 9 必須定位到篝火節點")
	app._debug_open_event()
	_expect_eq(app.current_screen, "event", "debug 0 必須直接進入事件畫面")
	_expect_eq(app.run_state.current_node_index, 2, "debug 0 第一次必須定位到事件 1")
	app._debug_open_event()
	_expect_eq(app.run_state.current_node_index, 7, "debug 0 第二次必須定位到事件 2")
	app._debug_open_event()
	_expect_eq(app.run_state.current_node_index, 11, "debug 0 第三次必須定位到事件 3")
	app._debug_open_event()
	_expect_eq(app.run_state.current_node_index, 2, "debug 0 第四次必須輪回事件 1")
	app.run_state.start_run(database, "subaru")
	app.run_state.current_node_index = 2
	var event_battle_option := {
		"label": "測試事件戰鬥",
		"outcomes": [{ "action": "start_battle", "enemy_id": "ssrb-gray" }]
	}
	_expect_true(app._resolve_event_option(event_battle_option), "事件 start_battle outcome 必須可進入戰鬥")
	_expect_eq(app.current_screen, "combat", "事件 start_battle 必須切到戰鬥畫面")
	_expect_eq(str(app.combat.enemy.get("id", "")), "ssrb-gray", "事件 start_battle 必須使用指定 enemy")
	_expect_true(app.has_method("_skip_reward"), "Game 需提供跳過 reward helper")
	var event_battle_gold_before: int = app.run_state.gold
	app.combat.enemy_hp = 0
	app.combat.outcome = "victory"
	app._start_pending_combat_reward("idle", "defeat")
	app._finish_pending_combat_reward()
	_expect_eq(app.current_screen, "reward", "事件戰鬥勝利後必須先進入戰鬥獎勵")
	_expect_eq(app.run_state.gold, event_battle_gold_before + int(app.combat.enemy.get("gold", 0)), "事件戰鬥勝利後必須拿到該場戰鬥 Gold")
	if app.has_method("_skip_reward"):
		app._skip_reward()
	_expect_eq(app.current_screen, "map", "事件戰鬥 reward 結束後必須回到地圖")
	_expect_eq(app.run_state.current_node_index, 3, "事件戰鬥 reward 結束後必須完成事件節點")
	app.run_state.start_run(database, "subaru")
	var curse_option := {
		"label": "測試加入 curse",
		"outcomes": [{ "action": "add_card", "card_id": "curse-dead-air" }]
	}
	_expect_true(app._resolve_event_option(curse_option), "事件 add_card.card_id 必須可加入指定卡牌")
	_expect_true(app.run_state.deck_ids.has("curse-dead-air"), "事件應可直接加入指定 curse 卡")
	app.run_state.start_run(database, "subaru")
	app.run_state.gold = 35
	app.run_state.hp = 20
	app.run_state.current_node_index = 2
	var event_gold_before: int = app.run_state.gold
	var event_hp_before: int = app.run_state.hp
	var event_gold_result: bool = app._event_spend_gold_for_hp()
	_expect_true(event_gold_result, "事件 Gold 贊助選項在 Gold 足夠時必須成功")
	_expect_eq(app.run_state.gold, event_gold_before - 30, "事件 Gold 贊助必須扣 30 Gold")
	_expect_eq(app.run_state.hp, event_hp_before + 12, "事件 Gold 贊助必須回復 12 HP")
	_expect_eq(app.run_state.current_node_index, 3, "事件 Gold 贊助後必須推進到下一節點")
	app.run_state.start_run(database, "subaru")
	app.run_state.gold = 20
	app.run_state.hp = 20
	app.run_state.current_node_index = 2
	var event_poor_result: bool = app._event_spend_gold_for_hp()
	_expect_false(event_poor_result, "事件 Gold 不足時不可贊助")
	_expect_eq(app.run_state.gold, 20, "事件 Gold 不足時不可扣 Gold")
	_expect_eq(app.run_state.hp, 20, "事件 Gold 不足時不可回復 HP")
	_expect_eq(app.run_state.current_node_index, 2, "事件 Gold 不足時不可推進節點")
	app.run_state.start_run(database, "subaru")
	app.run_state.hp = 5
	app.run_state.current_node_index = 2
	var event_relic_result: bool = app._event_trade_hp_for_relic()
	_expect_true(event_relic_result, "事件 HP 贊助必須成功取得 relic")
	_expect_eq(app.run_state.hp, 1, "事件 HP 贊助不可讓 HP 低於 1")
	_expect_eq(app.run_state.relic_ids.size(), 1, "事件 HP 贊助必須加入 1 個 relic")
	_expect_eq(app.run_state.current_node_index, 3, "事件 HP 贊助後必須推進到下一節點")

	app.run_state.start_run(database, "subaru")
	app.run_state.gold = 10
	app.run_state.hp = 30
	app.run_state.current_node_index = 7
	var event2_gold_result: bool = app._event_stream_incident_gain_gold()
	_expect_true(event2_gold_result, "事件 2 協助收拾必須成功")
	_expect_eq(app.run_state.gold, 45, "事件 2 協助收拾必須獲得 Gold 35")
	_expect_eq(app.run_state.hp, 24, "事件 2 協助收拾必須失去 6 HP")
	_expect_eq(app.run_state.current_node_index, 8, "事件 2 協助收拾後必須推進節點")
	app.run_state.start_run(database, "subaru")
	app.run_state.current_node_index = 7
	var event2_deck_before: int = app.run_state.deck_ids.size()
	_expect_true(app._event_stream_incident_add_card(), "事件 2 備用牌選項必須成功")
	_expect_eq(app.run_state.deck_ids.size(), event2_deck_before + 1, "事件 2 備用牌必須加入 1 張角色卡")
	_expect_true(str(app.run_state.deck_ids[-1]).begins_with("subaru-"), "事件 2 備用牌必須加入當前角色卡")

	app.run_state.start_run(database, "subaru")
	app.run_state.gold = 50
	app.run_state.current_node_index = 11
	var event3_relic_result: bool = app._event_fan_cheer_buy_relic()
	_expect_true(event3_relic_result, "事件 3 Gold 應援必須可取得 relic")
	_expect_eq(app.run_state.gold, 10, "事件 3 Gold 應援必須扣 40 Gold")
	_expect_eq(app.run_state.relic_ids.size(), 1, "事件 3 Gold 應援必須取得 relic")
	_expect_eq(app.run_state.current_node_index, 12, "事件 3 Gold 應援後必須推進節點")
	app.run_state.start_run(database, "subaru")
	for relic in database.relics:
		app.run_state.relic_ids.append(str(relic["id"]))
	app.run_state.gold = 50
	app.run_state.current_node_index = 11
	_expect_true(app._event_fan_cheer_buy_relic(), "事件 3 relic 拿滿時仍可完成")
	_expect_eq(app.run_state.gold, 35, "事件 3 relic 拿滿時改為花 40 Gold 並返還 Gold 25")
	app.run_state.start_run(database, "subaru")
	app.run_state.gold = 5
	app.run_state.current_node_index = 11
	_expect_true(app._event_fan_cheer_gain_gold(), "事件 3 整理應援必須成功")
	_expect_eq(app.run_state.gold, 30, "事件 3 整理應援必須獲得 Gold 25")
	_expect_eq(app.run_state.current_node_index, 12, "事件 3 整理應援後必須推進節點")

	app.run_state.start_run(database, "subaru")
	var before_debug_relics: int = app.run_state.relic_ids.size()
	app._debug_add_relic()
	_expect_eq(app.run_state.relic_ids.size(), before_debug_relics + 1, "debug relic 入口必須加入一個 relic")
	app.queue_free()

func _expect_card_pool_matches_character(character_id: String, card_ids: Array[String], pool_name: String) -> void:
	var seen_ids: Dictionary = {}
	for card_id in card_ids:
		_expect_false(seen_ids.has(card_id), "%s %s card pool 不可重複：%s" % [character_id, pool_name, card_id])
		seen_ids[card_id] = true
		_expect_true(card_id.begins_with("%s-" % character_id), "%s %s card pool 不可混入其他角色卡：%s" % [character_id, pool_name, card_id])

func _cards_for_prefix(prefix: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card in database.cards:
		if str(card.get("id", "")).begins_with(prefix):
			result.append(card)
	return result

func _count_cards_with_cost_at_most(cards_to_check: Array[Dictionary], max_cost: int) -> int:
	var count := 0
	for card in cards_to_check:
		if int(card.get("cost", 0)) <= max_cost:
			count += 1
	return count

func _count_cards_with_cost_at_least(cards_to_check: Array[Dictionary], min_cost: int) -> int:
	var count := 0
	for card in cards_to_check:
		if int(card.get("cost", 0)) >= min_cost:
			count += 1
	return count

func _count_cards_with_effect(cards_to_check: Array[Dictionary], effect_type: String) -> int:
	var count := 0
	for card in cards_to_check:
		for effect in card.get("effects", []):
			if str(effect.get("type", "")) == effect_type:
				count += 1
				break
	return count

func _count_cards_with_hits_at_least(cards_to_check: Array[Dictionary], min_hits: int) -> int:
	var count := 0
	for card in cards_to_check:
		for effect in card.get("effects", []):
			if str(effect.get("type", "")) == "damage" and int(effect.get("hits", 1)) >= min_hits:
				count += 1
				break
	return count

func _count_cards_with_status(cards_to_check: Array[Dictionary], status_id: String) -> int:
	var count := 0
	for card in cards_to_check:
		for effect in card.get("effects", []):
			if str(effect.get("type", "")) == "status" and str(effect.get("status_id", "")) == status_id:
				count += 1
				break
	return count

func _card_cost_at_most(card: Dictionary, max_cost: int) -> bool:
	return int(card.get("cost", 0)) <= max_cost

func _card_cost_at_least(card: Dictionary, min_cost: int) -> bool:
	return int(card.get("cost", 0)) >= min_cost

func _card_has_effect(card: Dictionary, effect_type: String) -> bool:
	for effect in card.get("effects", []):
		if str(effect.get("type", "")) == effect_type:
			return true
	return false

func _card_effect_amount(card: Dictionary, effect_type: String) -> int:
	for effect in card.get("effects", []):
		if str(effect.get("type", "")) == effect_type:
			return int(effect.get("amount", 0))
	return 0

func _collect_v1_effect_schema(effect: Dictionary, schema_flags: Dictionary) -> void:
	var effect_type := str(effect.get("type", ""))
	if schema_flags.has(effect_type):
		schema_flags[effect_type] = true
	if effect.has("condition"):
		var condition: Dictionary = effect.get("condition", {})
		if condition.has("exhaust_count_at_least"):
			schema_flags["exhaust_count_at_least"] = true
	for nested_variant in effect.get("effects", []):
		var nested: Dictionary = nested_variant
		_collect_v1_effect_schema(nested, schema_flags)
	if effect_type == "temporary_card":
		var temp_card: Dictionary = effect.get("card", {})
		for nested_variant in temp_card.get("effects", []):
			var nested: Dictionary = nested_variant
			_collect_v1_effect_schema(nested, schema_flags)

func _archetype_has_roles(archetype_tag: String, required_roles: Array[String]) -> bool:
	var found_roles: Dictionary = {}
	for card in database.cards:
		if not card.get("archetype_tags", []).has(archetype_tag):
			continue
		for role in card.get("role_tags", []):
			found_roles[str(role)] = true
	for role in required_roles:
		if not found_roles.has(str(role)):
			return false
	return true

func _card_has_status(card: Dictionary, status_id: String) -> bool:
	for effect in card.get("effects", []):
		if str(effect.get("type", "")) == "status" and str(effect.get("status_id", "")) == status_id:
			return true
	return false

func _card_has_damage_effect(card: Dictionary) -> bool:
	for effect in card.get("effects", []):
		if str(effect.get("type", "")) == "damage":
			return true
	return false

func _average_attack_damage(cards_to_check: Array[Dictionary]) -> float:
	var total := 0
	var count := 0
	for card in cards_to_check:
		for effect in card.get("effects", []):
			if str(effect.get("type", "")) == "damage":
				total += int(effect.get("amount", 0)) * int(effect.get("hits", 1))
				count += 1
	if count == 0:
		return 0.0
	return float(total) / float(count)

func _max_enemy_damage(enemy: Dictionary) -> int:
	var result := 0
	for action in enemy.get("actions", []):
		result = max(result, int(action.get("damage", 0)))
	return result

func _card_exists(card_id: String) -> bool:
	for card in database.cards:
		if str(card["id"]) == card_id:
			return true
	return false

func _relic_exists(relic_id: String) -> bool:
	for relic in database.relics:
		if str(relic["id"]) == relic_id:
			return true
	return false

func _large_reward_card_button_count(app: Node) -> int:
	var count := 0
	for button in _all_buttons(app.screen_host):
		if button.size.x >= 170.0 and button.size.y >= 180.0:
			count += 1
	return count

func _button_count_with_text(app: Node, text: String) -> int:
	var count := 0
	for button in _all_buttons(app.screen_host):
		if str(button.text) == text:
			count += 1
	return count

func _all_buttons(node: Node) -> Array[Button]:
	var result: Array[Button] = []
	for child in node.get_children():
		if child is Button:
			result.append(child as Button)
		result.append_array(_all_buttons(child))
	return result

func _press_debug_key(app: Node, keycode: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	app._unhandled_key_input(event)

func _relic_count_for_source(source: String) -> int:
	var count := 0
	for relic in database.relics:
		if relic.get("source_rules", []).has(source):
			count += 1
	return count

func _enemy_exists(enemy_id: String) -> bool:
	for enemy in database.enemies:
		if str(enemy["id"]) == enemy_id:
			return true
	return false

func _expect_card_animation_asset_exists(card: Dictionary) -> void:
	var animation := str(card.get("animation", "idle"))
	var laplus_animation := animation
	if animation == "laplus_dash":
		laplus_animation = "dash_attack"
	if animation == "laplus_crash":
		laplus_animation = "crash_attack"
	var candidate_paths := [
		"res://assets/characters/subaru/%s/sheet-transparent.png" % animation,
		"res://assets/characters/botan/%s/sheet-transparent.png" % animation,
		"res://assets/characters/azki_necromancer/%s/sheet-transparent.png" % animation,
		"res://assets/characters/laplus_darkness_summon/%s/sheet-transparent.png" % laplus_animation
	]
	var exists := false
	for path in candidate_paths:
		if ResourceLoader.exists(path):
			exists = true
			break
	_expect_true(exists, "%s animation asset 不存在：%s" % [str(card["id"]), animation])

func _expect_enemy_asset_exists(enemy: Dictionary, action: String) -> void:
	var path := "%s%s/sheet-transparent.png" % [str(enemy["resource_base_path"]), action]
	_expect_true(ResourceLoader.exists(path), "%s 缺少 %s 圖片：%s" % [str(enemy["id"]), action, path])

func _expect_enemy_secondary_asset_exists(enemy: Dictionary, action: String) -> void:
	var path := "%s%s/sheet-transparent.png" % [str(enemy["secondary_resource_base_path"]), action]
	_expect_true(ResourceLoader.exists(path), "%s 缺少第二隻 SSRB %s 圖片：%s" % [str(enemy["id"]), action, path])

func _has_guard_and_defeat_enemy_assets(base_path: String) -> bool:
	return base_path.begins_with("res://assets/enemies/ssrb/") or base_path.begins_with("res://assets/enemies/korone_suki/") or base_path.begins_with("res://assets/enemies/kedama/")

func _first_block_amount(card_id: String) -> int:
	var card := database.get_card(card_id)
	for effect_variant in card.get("effects", []):
		var effect: Dictionary = effect_variant
		if str(effect.get("type", "")) == "block":
			return int(effect.get("amount", 0))
	return 0

func _first_status_value(card_id: String, status_id: String) -> int:
	var card := database.get_card(card_id)
	for effect_variant in card.get("effects", []):
		var effect: Dictionary = effect_variant
		if str(effect.get("type", "")) == "status" and str(effect.get("status_id", "")) == status_id:
			return int(effect.get("value", effect.get("amount", 0)))
	return 0

func _expect_not_empty(value: String, message: String) -> void:
	if value == "":
		failures.append("%s：不可為空" % message)

func _expect_true(actual: bool, message: String) -> void:
	if not actual:
		failures.append("%s：expected true, got false" % message)

func _expect_false(actual: bool, message: String) -> void:
	if actual:
		failures.append("%s：expected false, got true" % message)

func _expect_eq(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s：expected %s, got %s" % [message, str(expected), str(actual)])
