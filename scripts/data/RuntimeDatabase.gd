class_name RuntimeDatabase
extends RefCounted

const RandomMapGeneratorScript := preload("res://scripts/data/RandomMapGenerator.gd")
const CHAPTER_1_ID := "mvp_single_act_tower"
const CHAPTER_2_ID := "chapter_2_algorithm_depths"

const STATUS_ICON_PATHS := {
	"strength": "res://assets/icons/status/strength.png",
	"weak": "res://assets/icons/status/weak.png",
	"vulnerable": "res://assets/icons/status/vulnerable.png",
	"regen": "res://assets/icons/status/regen.png"
}

const CARD_ART_PATHS := {
	"subaru-strike": "res://assets/cards/subaru/subaru-strike.png",
	"subaru-guard": "res://assets/cards/subaru/subaru-guard.png",
	"subaru-duck-rush": "res://assets/cards/subaru/subaru-duck-rush.png",
	"subaru-draw-breath": "res://assets/cards/subaru/subaru-draw-breath.png",
	"subaru-tsukkomi": "res://assets/cards/subaru/subaru-tsukkomi.png",
	"subaru-second-wind": "res://assets/cards/subaru/subaru-second-wind.png",
	"subaru-quick-retort": "res://assets/cards/subaru/subaru-quick-retort.png",
	"subaru-rhythm-guard": "res://assets/cards/subaru/subaru-rhythm-guard.png",
	"subaru-cheer-loop": "res://assets/cards/subaru/subaru-cheer-loop.png",
	"subaru-duck-step": "res://assets/cards/subaru/subaru-duck-step.png",
	"subaru-team-rush": "res://assets/cards/subaru/subaru-team-rush.png",
	"subaru-hype-call": "res://assets/cards/subaru/subaru-hype-call.png",
	"subaru-duck-feint": "res://assets/cards/subaru/subaru-duck-feint.png",
	"subaru-cheer-recover": "res://assets/cards/subaru/subaru-cheer-recover.png",
	"subaru-duck-tempo": "res://assets/cards/subaru/subaru-duck-tempo.png",
	"subaru-teetee-guard": "res://assets/cards/subaru/subaru-teetee-guard.png",
	"subaru-desk-reaction": "res://assets/cards/subaru/subaru-desk-reaction.png",
	"subaru-blue-wave": "res://assets/cards/subaru/subaru-blue-wave.png",
	"subaru-new-oshi-call": "res://assets/cards/subaru/subaru-new-oshi-call.png",
	"botan-shot": "res://assets/cards/botan/botan-shot.png",
	"botan-cover": "res://assets/cards/botan/botan-cover.png",
	"botan-burst": "res://assets/cards/botan/botan-burst.png",
	"botan-reload": "res://assets/cards/botan/botan-reload.png",
	"botan-mark": "res://assets/cards/botan/botan-mark.png",
	"botan-heavy-shot": "res://assets/cards/botan/botan-heavy-shot.png",
	"botan-steady-aim": "res://assets/cards/botan/botan-steady-aim.png",
	"botan-fortified-cover": "res://assets/cards/botan/botan-fortified-cover.png",
	"botan-counter-line": "res://assets/cards/botan/botan-counter-line.png",
	"botan-tap-shot": "res://assets/cards/botan/botan-tap-shot.png",
	"botan-suppressive-fire": "res://assets/cards/botan/botan-suppressive-fire.png",
	"botan-tactical-focus": "res://assets/cards/botan/botan-tactical-focus.png",
	"botan-medkit-cover": "res://assets/cards/botan/botan-medkit-cover.png",
	"botan-button-check": "res://assets/cards/botan/botan-button-check.png",
	"botan-clean-scope": "res://assets/cards/botan/botan-clean-scope.png",
	"botan-calm-burst": "res://assets/cards/botan/botan-calm-burst.png",
	"botan-precise-cover": "res://assets/cards/botan/botan-precise-cover.png",
	"botan-funds-prepared": "res://assets/cards/botan/botan-funds-prepared.png"
}

const INTENT_ICON_PATHS := {
	"attack": "res://assets/icons/intent/attack.png",
	"block": "res://assets/icons/intent/block.png",
	"attack_block": "res://assets/icons/intent/attack_block.png",
	"buff": "res://assets/icons/intent/buff.png",
	"debuff": "res://assets/icons/intent/debuff.png"
}

const RELIC_ICON_PATHS := {
	"cheer-lightstick": "res://assets/icons/relic/cheer-lightstick.png",
	"duck-whistle": "res://assets/icons/relic/duck-whistle.png",
	"shishiro-crosshair": "res://assets/icons/relic/shishiro-crosshair.png",
	"energy-drink": "res://assets/icons/relic/energy-drink.png",
	"healing-chat": "res://assets/icons/relic/healing-chat.png",
	"golden-superchat": "res://assets/icons/relic/golden-superchat.png",
	"shop-coupon": "res://assets/icons/relic/shop-coupon.png",
	"route-stamp": "res://assets/icons/relic/route-stamp.png",
	"boss-spotlight": "res://assets/icons/relic/boss-spotlight.png",
	"yagoo-best-girl": "res://assets/icons/relic/yagoo-best-girl.png",
	"shishiro-button": "res://assets/icons/relic/shishiro-button.png",
	"superchat-reading": "res://assets/icons/relic/superchat-reading.png",
	"x-funds-wallet": "res://assets/icons/relic/x-funds-wallet.png",
	"ada-tv": "res://assets/icons/relic/ada-tv.png",
	"pamomi-signal": "res://assets/icons/relic/pamomi-signal.png",
	"blue-wave-badge": "res://assets/icons/relic/blue-wave-badge.png",
	"unarchived-archive": "res://assets/icons/relic/unarchived-archive.png",
	"blood-pressure-meter": "res://assets/icons/relic/blood-pressure-meter.png"
}

var characters: Array[Dictionary] = []
var cards: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var relics: Array[Dictionary] = []
var events: Array[Dictionary] = []
var map_nodes: Array[Dictionary] = []

func _init() -> void:
	characters = [
		{
			"id": "subaru",
			"display_name": "大空昴",
			"resource_base_path": "res://assets/characters/subaru/",
			"identity_hint": "低費連段與節奏守備，適合靠抽牌與連打穩住戰線。",
			"identity_focus_tags": ["cheap_chain", "tempo_block", "draw_cycle"],
			"signature_card_ids": ["subaru-duck-tempo", "subaru-new-oshi-call"],
			"max_hp": 68,
			"starting_gold": 65,
			"passive": {
				"id": "subaru-tempo-guard",
				"name": "節奏守備",
				"description": "每回合第一次打出 0/1 費牌時獲得 3 點格擋。",
				"preview_text": "先用 0/1 費牌起手，白拿格擋再展開。",
				"hook": "first_cheap_card_each_turn",
				"cost_max": 1,
				"block": 3
			},
			"starting_deck": [
				"subaru-strike", "subaru-strike", "subaru-strike", "subaru-strike",
				"subaru-guard", "subaru-guard", "subaru-guard",
				"subaru-duck-rush", "subaru-draw-breath", "subaru-tsukkomi"
			]
		},
		{
			"id": "botan",
			"display_name": "獅白牡丹",
			"resource_base_path": "res://assets/characters/botan/",
			"identity_hint": "2 費爆發與瞄準收頭，適合先控場再打大傷害。",
			"identity_focus_tags": ["two_cost_burst", "setup_control", "precision_finish"],
			"signature_card_ids": ["botan-heavy-shot", "botan-funds-prepared"],
			"max_hp": 80,
			"starting_gold": 65,
			"passive": {
				"id": "botan-sniper-opening",
				"name": "狙擊開場",
				"description": "每回合第一次打出 2 費攻擊牌時追加 6 點傷害。",
				"preview_text": "把高費攻擊留給關鍵回合，第一發會更痛。",
				"hook": "first_two_cost_attack_each_turn",
				"bonus_damage": 6
			},
			"starting_deck": [
				"botan-shot", "botan-shot", "botan-shot", "botan-shot",
				"botan-cover", "botan-cover", "botan-cover",
				"botan-burst", "botan-reload", "botan-mark"
			]
		},
		{
			"id": "azki",
			"display_name": "AZKi",
			"resource_base_path": "res://assets/characters/azki_necromancer/",
			"identity_hint": "先疊標記再追擊，靠標記轉成額外傷害與抽牌節奏。",
			"identity_focus_tags": ["marker_setup", "marker_payoff", "exploration_draw"],
			"signature_card_ids": ["azki-map-search", "azki-open-route"],
			"max_hp": 80,
			"starting_gold": 65,
			"passive": {
				"id": "azki-pioneer-coordinate",
				"name": "開拓者的座標",
				"description": "每回合第一次給予敵人標記時，抽 1 張牌。",
				"preview_text": "先上標記，再用追擊牌把標記換成節奏。",
				"hook": "first_marker_each_turn",
				"draw": 1
			},
			"summon": {
				"id": "laplus",
				"name": "ラプラス・ダークネス",
				"max_hp": 1,
				"starting_hp": 1,
				"turn_start_summon": 0,
				"resource_base_path": "res://assets/characters/laplus_darkness_summon/"
			},
			"starting_deck": [
				"azki-map-shot", "azki-map-shot", "azki-map-shot", "azki-map-shot",
				"azki-guard", "azki-guard", "azki-guard",
				"azki-pinpoint", "azki-tune-up", "azki-kiss"
			]
		}
	]
	cards = [
		{ "id": "subaru-strike", "name": "節奏拳", "cost": 1, "kind": "attack", "animation": "normal_attack", "description": "造成 5 點傷害。", "effects": [{ "type": "damage", "amount": 5, "hits": 1 }] },
		{ "id": "subaru-guard", "name": "團隊防守", "cost": 1, "kind": "defense", "animation": "defense", "description": "獲得 5 點格擋。", "effects": [{ "type": "block", "amount": 5 }] },
		{ "id": "subaru-duck-rush", "name": "鴨式連打", "cost": 1, "kind": "attack", "animation": "normal_attack", "description": "造成 3 點傷害 3 次。", "effects": [{ "type": "damage", "amount": 3, "hits": 3 }] },
		{ "id": "subaru-draw-breath", "name": "調整呼吸", "cost": 0, "kind": "support", "animation": "idle", "description": "抽 1 張牌，獲得 1 點能量。", "effects": [{ "type": "draw", "amount": 1 }, { "type": "energy", "amount": 1 }] },
		{ "id": "subaru-tsukkomi", "name": "吐槽爆擊", "cost": 2, "kind": "attack", "animation": "tsukkomi", "description": "造成 8 點傷害 2 次。", "effects": [{ "type": "damage", "amount": 8, "hits": 2 }] },
		{ "id": "subaru-second-wind", "name": "重新站穩", "cost": 1, "kind": "mixed", "animation": "defense", "description": "獲得 4 點格擋與 1 點能量。", "effects": [{ "type": "block", "amount": 4 }, { "type": "energy", "amount": 1 }] },
		{ "id": "subaru-quick-retort", "name": "快速吐槽", "cost": 0, "kind": "attack", "animation": "tsukkomi", "description": "造成 3 點傷害。", "effects": [{ "type": "damage", "amount": 3, "hits": 1 }] },
		{ "id": "subaru-rhythm-guard", "name": "節奏防守", "cost": 1, "kind": "defense", "animation": "defense", "description": "獲得 7 點格擋。", "effects": [{ "type": "block", "amount": 7 }] },
		{ "id": "subaru-cheer-loop", "name": "應援循環", "cost": 1, "kind": "support", "animation": "idle", "description": "抽 2 張牌，獲得 3 點格擋。", "effects": [{ "type": "draw", "amount": 2 }, { "type": "block", "amount": 3 }] },
		{ "id": "subaru-duck-step", "name": "鴨步閃身", "cost": 1, "kind": "mixed", "animation": "normal_attack", "description": "獲得 4 點格擋，造成 4 點傷害。", "effects": [{ "type": "block", "amount": 4 }, { "type": "damage", "amount": 4, "hits": 1 }] },
		{ "id": "subaru-team-rush", "name": "團隊連衝", "cost": 2, "kind": "attack", "animation": "tsukkomi", "description": "造成 4 點傷害 4 次。", "effects": [{ "type": "damage", "amount": 4, "hits": 4 }] },
		{ "id": "subaru-hype-call", "name": "元氣號召", "cost": 1, "kind": "support", "animation": "idle", "description": "獲得 1 層力量，抽 1 張牌。", "effects": [{ "type": "status", "target": "player", "status_id": "strength", "amount": 1, "value": 1, "duration": 99 }, { "type": "draw", "amount": 1 }] },
		{ "id": "subaru-duck-feint", "name": "鴨式佯攻", "cost": 1, "kind": "mixed", "animation": "normal_attack", "description": "造成 4 點傷害，給予 2 回合易傷。", "effects": [{ "type": "damage", "amount": 4, "hits": 1 }, { "type": "status", "target": "enemy", "status_id": "vulnerable", "amount": 1, "value": 1, "duration": 2 }] },
		{ "id": "subaru-cheer-recover", "name": "應援回氣", "cost": 1, "kind": "support", "animation": "idle", "description": "獲得 2 回合回復 2。", "effects": [{ "type": "status", "target": "player", "status_id": "regen", "amount": 2, "value": 2, "duration": 2 }] },
		{ "id": "subaru-duck-tempo", "name": "鴨群節拍", "cost": 0, "kind": "mixed", "animation": "normal_attack", "description": "造成 4 點傷害，抽 1 張牌。", "effects": [{ "type": "damage", "amount": 4, "hits": 1 }, { "type": "draw", "amount": 1 }] },
		{ "id": "subaru-teetee-guard", "name": "てぇてぇ守備", "cost": 1, "kind": "defense", "animation": "defense", "description": "獲得 6 點格擋，獲得 1 點能量。", "effects": [{ "type": "block", "amount": 6 }, { "type": "energy", "amount": 1 }] },
		{ "id": "subaru-desk-reaction", "name": "桌面反應", "cost": 1, "kind": "mixed", "animation": "normal_attack", "description": "造成 4 點傷害，獲得 8 點格擋。", "effects": [{ "type": "damage", "amount": 4, "hits": 1 }, { "type": "block", "amount": 8 }] },
		{ "id": "subaru-blue-wave", "name": "Blue Wave 應援", "cost": 1, "kind": "support", "animation": "idle", "description": "獲得 2 回合回復 2，抽 1 張牌，獲得 1 點能量。", "effects": [{ "type": "status", "target": "player", "status_id": "regen", "amount": 2, "value": 2, "duration": 2 }, { "type": "draw", "amount": 1 }, { "type": "energy", "amount": 1 }] },
		{ "id": "subaru-new-oshi-call", "name": "新推號召", "cost": 0, "kind": "support", "animation": "idle", "description": "抽 1 張牌，獲得 4 點格擋。", "effects": [{ "type": "draw", "amount": 1 }, { "type": "block", "amount": 4 }] },
		{ "id": "subaru-opening-quack", "name": "開場鴨聲", "cost": 0, "kind": "support", "animation": "idle", "description": "抽 1 張牌。若這是本回合第 2 張或之後的牌，獲得 5 點格擋。", "rarity": "common", "floor_band": "early", "archetype_tags": ["cheap_chain", "tempo_block"], "role_tags": ["setup", "bridge", "defense"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級提高條件格擋，讓低費連段起手更穩定。", "upgrade_description": "抽 1 張牌。若這是本回合第 2 張或之後的牌，獲得 8 點格擋。", "effects": [{ "type": "draw", "amount": 1 }, { "type": "conditional", "condition": { "cards_played_this_turn_min": 2 }, "effects": [{ "type": "block", "amount": 5 }] }], "upgrade_effects": [{ "type": "draw", "amount": 1 }, { "type": "conditional", "condition": { "cards_played_this_turn_min": 2 }, "effects": [{ "type": "block", "amount": 8 }] }] },
		{ "id": "subaru-crowd-cover", "name": "觀眾掩護", "cost": 1, "kind": "defense", "animation": "defense", "description": "獲得 7 點格擋。若敵人準備攻擊，抽 1 張牌。Retain。", "rarity": "common", "floor_band": "early", "archetype_tags": ["tempo_block", "cheap_chain"], "role_tags": ["defense", "bridge"], "retain": true, "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級提高基礎格擋，讓保留牌在攻擊意圖回合更可靠。", "upgrade_description": "獲得 10 點格擋。若敵人準備攻擊，抽 1 張牌。Retain。", "effects": [{ "type": "block", "amount": 7 }, { "type": "conditional", "condition": { "enemy_intents": ["attack", "attack_block"] }, "effects": [{ "type": "draw", "amount": 1 }] }], "upgrade_effects": [{ "type": "block", "amount": 10 }, { "type": "conditional", "condition": { "enemy_intents": ["attack", "attack_block"] }, "effects": [{ "type": "draw", "amount": 1 }] }] },
		{ "id": "subaru-table-slam-loop", "name": "拍桌循環", "cost": 1, "kind": "attack", "animation": "normal_attack", "description": "造成 3 點傷害 3 次。若這是本回合第 3 張或之後的牌，抽 1 張牌。Exhaust。", "rarity": "uncommon", "floor_band": "mid", "archetype_tags": ["cheap_chain", "multi_hit_strength"], "role_tags": ["payoff", "bridge", "risk"], "exhaust_on_play": true, "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級提高多段傷害與條件格擋，讓力量 build 和連段 payoff 都受益。", "upgrade_description": "造成 4 點傷害 3 次。若這是本回合第 3 張或之後的牌，抽 1 張牌並獲得 4 點格擋。Exhaust。", "effects": [{ "type": "damage", "amount": 3, "hits": 3 }, { "type": "conditional", "condition": { "cards_played_this_turn_min": 3 }, "effects": [{ "type": "draw", "amount": 1 }] }], "upgrade_effects": [{ "type": "damage", "amount": 4, "hits": 3 }, { "type": "conditional", "condition": { "cards_played_this_turn_min": 3 }, "effects": [{ "type": "draw", "amount": 1 }, { "type": "block", "amount": 4 }] }] },
		{ "id": "subaru-unstoppable-cheer", "name": "停不下來的應援", "cost": 2, "kind": "support", "animation": "idle", "description": "獲得 2 層力量。若這是本回合第 3 張或之後的牌，獲得 2 點能量。Exhaust。", "rarity": "rare", "floor_band": "late", "archetype_tags": ["cheap_chain", "multi_hit_strength"], "role_tags": ["scaling", "payoff", "risk"], "exhaust_on_play": true, "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級提高 scaling 並補抽牌，讓高投資回合不會斷手。", "upgrade_description": "獲得 3 層力量。若這是本回合第 3 張或之後的牌，獲得 2 點能量並抽 1 張牌。Exhaust。", "effects": [{ "type": "status", "target": "player", "status_id": "strength", "amount": 2, "value": 2, "duration": 99 }, { "type": "conditional", "condition": { "cards_played_this_turn_min": 3 }, "effects": [{ "type": "energy", "amount": 2 }] }], "upgrade_effects": [{ "type": "status", "target": "player", "status_id": "strength", "amount": 3, "value": 3, "duration": 99 }, { "type": "conditional", "condition": { "cards_played_this_turn_min": 3 }, "effects": [{ "type": "energy", "amount": 2 }, { "type": "draw", "amount": 1 }] }] },
		{ "id": "subaru-combo-boost", "name": "連段催化", "cost": 0, "kind": "support", "animation": "idle", "description": "下一張攻擊牌追加 5 點傷害，抽 1 張牌。", "rarity": "common", "floor_band": "early", "archetype_tags": ["cheap_chain", "tempo_block"], "role_tags": ["setup", "bridge", "utility"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_signal": "burst", "upgrade_plan": "升級提高下一張攻擊的追加傷害，讓低費起手更能轉成爆發。", "upgrade_description": "下一張攻擊牌追加 7 點傷害，抽 1 張牌。", "effects": [{ "type": "next_attack_bonus", "amount": 5 }, { "type": "draw", "amount": 1 }], "upgrade_effects": [{ "type": "next_attack_bonus", "amount": 7 }, { "type": "draw", "amount": 1 }] },
		{ "id": "subaru-encore-recall", "name": "Encore 回收", "cost": 1, "kind": "support", "animation": "idle", "description": "獲得 4 點格擋。從棄牌堆取回 1 張攻擊牌。", "rarity": "uncommon", "floor_band": "mid", "archetype_tags": ["cheap_chain", "tempo_block"], "role_tags": ["bridge", "utility", "defense"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_signal": "stability", "upgrade_plan": "升級提高格擋，讓回收攻擊牌時不犧牲太多防守。", "upgrade_description": "獲得 7 點格擋。從棄牌堆取回 1 張攻擊牌。", "effects": [{ "type": "block", "amount": 4 }, { "type": "draw_from_discard", "amount": 1, "kind": "attack" }], "upgrade_effects": [{ "type": "block", "amount": 7 }, { "type": "draw_from_discard", "amount": 1, "kind": "attack" }] },
		{ "id": "subaru-afterimage-table", "name": "殘響拍桌", "cost": 1, "kind": "attack", "animation": "normal_attack", "description": "造成 5 點傷害 2 次。若本場已 Exhaust 至少 1 張牌，獲得 5 點格擋。Exhaust。", "rarity": "uncommon", "floor_band": "mid", "archetype_tags": ["cheap_chain", "multi_hit_strength"], "role_tags": ["payoff", "defense", "risk"], "exhaust_on_play": true, "art_status": "prototype_placeholder", "art_path": "", "upgrade_signal": "defense", "upgrade_plan": "升級提高多段傷害與 Exhaust payoff 格擋，讓連段收束更安全。", "upgrade_description": "造成 6 點傷害 2 次。若本場已 Exhaust 至少 1 張牌，獲得 7 點格擋。Exhaust。", "effects": [{ "type": "damage", "amount": 5, "hits": 2 }, { "type": "conditional", "condition": { "exhaust_count_at_least": 1 }, "effects": [{ "type": "block", "amount": 5 }] }], "upgrade_effects": [{ "type": "damage", "amount": 6, "hits": 2 }, { "type": "conditional", "condition": { "exhaust_count_at_least": 1 }, "effects": [{ "type": "block", "amount": 7 }] }] },
		{ "id": "botan-shot", "name": "精準射擊", "cost": 1, "kind": "attack", "animation": "pistol_attack", "description": "造成 8 點傷害。", "effects": [{ "type": "damage", "amount": 8, "hits": 1 }] },
		{ "id": "botan-cover", "name": "掩體防守", "cost": 1, "kind": "defense", "animation": "defense", "description": "獲得 7 點格擋。", "effects": [{ "type": "block", "amount": 7 }] },
		{ "id": "botan-burst", "name": "連續點放", "cost": 2, "kind": "attack", "animation": "sniper_ultimate", "description": "造成 6 點傷害 2 次。", "effects": [{ "type": "damage", "amount": 6, "hits": 2 }] },
		{ "id": "botan-reload", "name": "快速換彈", "cost": 0, "kind": "support", "animation": "idle", "description": "抽 1 張牌。", "effects": [{ "type": "draw", "amount": 1 }] },
		{ "id": "botan-mark", "name": "狙擊準備", "cost": 2, "kind": "mixed", "animation": "sniper_ultimate", "description": "獲得 7 點格擋，造成 12 點傷害，給予 1 回合易傷。", "effects": [{ "type": "block", "amount": 7 }, { "type": "damage", "amount": 12, "hits": 1 }, { "type": "status", "target": "enemy", "status_id": "vulnerable", "amount": 1, "value": 1, "duration": 1 }] },
		{ "id": "botan-heavy-shot", "name": "重裝一擊", "cost": 2, "kind": "attack", "animation": "sniper_ultimate", "description": "造成 18 點傷害。", "effects": [{ "type": "damage", "amount": 18, "hits": 1 }] },
		{ "id": "botan-steady-aim", "name": "穩定瞄準", "cost": 1, "kind": "support", "animation": "idle", "description": "抽 1 張牌，獲得 1 點能量，給予 1 回合易傷。", "effects": [{ "type": "draw", "amount": 1 }, { "type": "energy", "amount": 1 }, { "type": "status", "target": "enemy", "status_id": "vulnerable", "amount": 1, "value": 1, "duration": 1 }] },
		{ "id": "botan-fortified-cover", "name": "強化掩體", "cost": 2, "kind": "defense", "animation": "defense", "description": "獲得 15 點格擋。", "effects": [{ "type": "block", "amount": 15 }] },
		{ "id": "botan-counter-line", "name": "反擊火線", "cost": 2, "kind": "mixed", "animation": "sniper_ultimate", "description": "獲得 10 點格擋，造成 10 點傷害。若敵人有易傷，抽 1 張牌。", "effects": [{ "type": "block", "amount": 10 }, { "type": "damage", "amount": 10, "hits": 1 }, { "type": "draw_if_status", "target": "enemy", "status_id": "vulnerable", "amount": 1 }] },
		{ "id": "botan-tap-shot", "name": "輕點射擊", "cost": 1, "kind": "attack", "animation": "pistol_attack", "description": "造成 9 點傷害。", "effects": [{ "type": "damage", "amount": 9, "hits": 1 }] },
		{ "id": "botan-suppressive-fire", "name": "壓制射擊", "cost": 1, "kind": "attack", "animation": "pistol_attack", "description": "造成 6 點傷害，給予 2 回合虛弱。", "effects": [{ "type": "damage", "amount": 6, "hits": 1 }, { "type": "status", "target": "enemy", "status_id": "weak", "amount": 1, "value": 1, "duration": 2 }] },
		{ "id": "botan-tactical-focus", "name": "戰術專注", "cost": 1, "kind": "support", "animation": "idle", "description": "獲得 1 層力量，抽 1 張牌。", "effects": [{ "type": "status", "target": "player", "status_id": "strength", "amount": 1, "value": 1, "duration": 99 }, { "type": "draw", "amount": 1 }] },
		{ "id": "botan-medkit-cover", "name": "醫療掩體", "cost": 1, "kind": "mixed", "animation": "defense", "description": "獲得 7 點格擋與 2 回合回復 2。", "effects": [{ "type": "block", "amount": 7 }, { "type": "status", "target": "player", "status_id": "regen", "amount": 2, "value": 2, "duration": 2 }] },
		{ "id": "botan-button-check", "name": "Button Check", "cost": 1, "kind": "attack", "animation": "pistol_attack", "description": "造成 6 點傷害，給予 2 回合虛弱。", "effects": [{ "type": "damage", "amount": 6, "hits": 1 }, { "type": "status", "target": "enemy", "status_id": "weak", "amount": 1, "value": 1, "duration": 2 }] },
		{ "id": "botan-clean-scope", "name": "Clean Scope", "cost": 1, "kind": "defense", "animation": "defense", "description": "獲得 11 點格擋，抽 1 張牌。", "effects": [{ "type": "block", "amount": 11 }, { "type": "draw", "amount": 1 }] },
		{ "id": "botan-calm-burst", "name": "冷靜爆發", "cost": 2, "kind": "attack", "animation": "sniper_ultimate", "description": "造成 10 點傷害 2 次，給予 2 回合易傷。", "effects": [{ "type": "damage", "amount": 10, "hits": 2 }, { "type": "status", "target": "enemy", "status_id": "vulnerable", "amount": 1, "value": 1, "duration": 2 }] },
		{ "id": "botan-precise-cover", "name": "精準掩護", "cost": 1, "kind": "mixed", "animation": "defense", "description": "獲得 12 點格擋，獲得 1 層力量。", "effects": [{ "type": "block", "amount": 12 }, { "type": "status", "target": "player", "status_id": "strength", "amount": 1, "value": 1, "duration": 99 }] },
		{ "id": "botan-funds-prepared", "name": "Funds Prepared", "cost": 0, "kind": "support", "animation": "idle", "description": "獲得 1 點能量，抽 1 張牌，給予 2 回合易傷。", "effects": [{ "type": "energy", "amount": 1 }, { "type": "draw", "amount": 1 }, { "type": "status", "target": "enemy", "status_id": "vulnerable", "amount": 1, "value": 1, "duration": 2 }] },
		{ "id": "botan-range-finder", "name": "測距儀", "cost": 0, "kind": "support", "animation": "idle", "description": "抽 1 張牌，給予 1 回合易傷。", "rarity": "common", "floor_band": "early", "archetype_tags": ["two_cost_burst", "precision_control"], "role_tags": ["setup", "bridge"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級延長易傷，讓 2 費爆發可以隔回合安排。", "upgrade_description": "抽 1 張牌，給予 2 回合易傷。", "effects": [{ "type": "draw", "amount": 1 }, { "type": "status", "target": "enemy", "status_id": "vulnerable", "amount": 1, "value": 1, "duration": 1 }], "upgrade_effects": [{ "type": "draw", "amount": 1 }, { "type": "status", "target": "enemy", "status_id": "vulnerable", "amount": 1, "value": 1, "duration": 2 }] },
		{ "id": "botan-overwatch", "name": "架槍監視", "cost": 1, "kind": "mixed", "animation": "pistol_attack", "description": "獲得 12 點格擋。若敵人準備攻擊，造成 8 點傷害。Retain。", "rarity": "common", "floor_band": "early", "archetype_tags": ["fortress_counter", "precision_control"], "role_tags": ["defense", "payoff"], "retain": true, "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級提高防守與反擊傷害，讓攻擊意圖成為 Botan 的反擊窗口。", "upgrade_description": "獲得 14 點格擋。若敵人準備攻擊，造成 10 點傷害。Retain。", "effects": [{ "type": "block", "amount": 12 }, { "type": "conditional", "condition": { "enemy_intents": ["attack", "attack_block"] }, "effects": [{ "type": "damage", "amount": 8, "hits": 1 }] }], "upgrade_effects": [{ "type": "block", "amount": 14 }, { "type": "conditional", "condition": { "enemy_intents": ["attack", "attack_block"] }, "effects": [{ "type": "damage", "amount": 10, "hits": 1 }] }] },
		{ "id": "botan-piercing-round", "name": "穿甲彈", "cost": 2, "kind": "attack", "animation": "sniper_ultimate", "description": "造成 14 點傷害。若敵人有易傷，額外造成 8 點傷害。", "rarity": "uncommon", "floor_band": "mid", "archetype_tags": ["two_cost_burst", "precision_control"], "role_tags": ["payoff"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級提高主傷與易傷 payoff，強化 setup 後的收頭感。", "upgrade_description": "造成 17 點傷害。若敵人有易傷，額外造成 10 點傷害。", "effects": [{ "type": "damage", "amount": 14, "hits": 1 }, { "type": "conditional", "condition": { "target_status": { "target": "enemy", "status_id": "vulnerable" } }, "effects": [{ "type": "damage", "amount": 8, "hits": 1 }] }], "upgrade_effects": [{ "type": "damage", "amount": 17, "hits": 1 }, { "type": "conditional", "condition": { "target_status": { "target": "enemy", "status_id": "vulnerable" } }, "effects": [{ "type": "damage", "amount": 10, "hits": 1 }] }] },
		{ "id": "botan-perfect-line", "name": "完美彈道", "cost": 2, "kind": "attack", "animation": "sniper_ultimate", "description": "造成 22 點傷害。若你有至少 10 點格擋，抽 2 張牌。", "rarity": "rare", "floor_band": "late", "archetype_tags": ["two_cost_burst", "fortress_counter"], "role_tags": ["payoff", "scaling"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級提高高費爆發並補能量，讓防守後的精準回合可以延伸。", "upgrade_description": "造成 26 點傷害。若你有至少 10 點格擋，抽 2 張牌並獲得 1 點能量。", "effects": [{ "type": "damage", "amount": 22, "hits": 1 }, { "type": "conditional", "condition": { "player_block_at_least": 10 }, "effects": [{ "type": "draw", "amount": 2 }] }], "upgrade_effects": [{ "type": "damage", "amount": 26, "hits": 1 }, { "type": "conditional", "condition": { "player_block_at_least": 10 }, "effects": [{ "type": "draw", "amount": 2 }, { "type": "energy", "amount": 1 }] }] },
		{ "id": "botan-kill-zone", "name": "Kill Zone", "cost": 1, "kind": "support", "animation": "idle", "description": "獲得 7 點格擋。下一張攻擊牌追加 9 點傷害。", "rarity": "common", "floor_band": "early", "archetype_tags": ["two_cost_burst", "fortress_counter"], "role_tags": ["setup", "bridge", "defense"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_signal": "burst", "upgrade_plan": "升級提高防守與下一槍爆發，讓 Botan 能先架陣再出手。", "upgrade_description": "獲得 9 點格擋。下一張攻擊牌追加 11 點傷害。", "effects": [{ "type": "block", "amount": 7 }, { "type": "next_attack_bonus", "amount": 9 }], "upgrade_effects": [{ "type": "block", "amount": 9 }, { "type": "next_attack_bonus", "amount": 11 }] },
		{ "id": "botan-cover-reload", "name": "掩體換彈", "cost": 1, "kind": "defense", "animation": "defense", "description": "獲得 11 點格擋。從棄牌堆取回 1 張攻擊牌。", "rarity": "uncommon", "floor_band": "mid", "archetype_tags": ["fortress_counter", "two_cost_burst"], "role_tags": ["defense", "bridge", "utility"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_signal": "stability", "upgrade_plan": "升級提高格擋，讓防守回合能穩定回收爆發牌。", "upgrade_description": "獲得 14 點格擋。從棄牌堆取回 1 張攻擊牌。", "effects": [{ "type": "block", "amount": 11 }, { "type": "draw_from_discard", "amount": 1, "kind": "attack" }], "upgrade_effects": [{ "type": "block", "amount": 14 }, { "type": "draw_from_discard", "amount": 1, "kind": "attack" }] },
		{ "id": "botan-flashbang-round", "name": "閃光彈", "cost": 1, "kind": "attack", "animation": "pistol_attack", "description": "造成 7 點傷害，給予 2 回合虛弱。Exhaust。", "rarity": "common", "floor_band": "early", "archetype_tags": ["fortress_counter", "precision_control"], "role_tags": ["setup", "defense", "risk"], "exhaust_on_play": true, "art_status": "prototype_placeholder", "art_path": "", "upgrade_signal": "control", "upgrade_plan": "升級提高干擾傷害，保留虛弱作為防守轉向工具。", "upgrade_description": "造成 9 點傷害，給予 2 回合虛弱。Exhaust。", "effects": [{ "type": "damage", "amount": 7, "hits": 1 }, { "type": "status", "target": "enemy", "status_id": "weak", "amount": 1, "value": 1, "duration": 2 }], "upgrade_effects": [{ "type": "damage", "amount": 9, "hits": 1 }, { "type": "status", "target": "enemy", "status_id": "weak", "amount": 1, "value": 1, "duration": 2 }] },
		{ "id": "azki-map-shot", "name": "座標彈", "cost": 1, "kind": "attack", "animation": "map_marker_attack", "description": "造成 8 點傷害。", "effects": [{ "type": "damage", "amount": 8, "hits": 1 }] },
		{ "id": "azki-guard", "name": "開拓防線", "cost": 1, "kind": "defense", "animation": "defense", "description": "獲得 7 點格擋，回復 Laplus 4 HP。", "effects": [{ "type": "block", "amount": 7 }, { "type": "summon_heal", "amount": 4 }] },
		{ "id": "azki-pinpoint", "name": "精準標記", "cost": 1, "kind": "mixed", "animation": "map_marker_attack", "description": "給予 1 層標記，造成 5 點傷害。", "effects": [{ "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }, { "type": "damage", "amount": 5, "hits": 1 }] },
		{ "id": "azki-tune-up", "name": "調音", "cost": 0, "kind": "support", "animation": "idle", "description": "抽 1 張牌。", "effects": [{ "type": "draw", "amount": 1 }] },
		{ "id": "azki-kiss", "name": "開拓飛吻", "cost": 2, "kind": "attack", "animation": "kiss_attack", "description": "造成 16 點傷害。若敵人有標記，抽 1 張牌。", "effects": [{ "type": "damage", "amount": 16, "hits": 1 }, { "type": "draw_if_status", "target": "enemy", "status_id": "marker", "amount": 1 }] },
		{ "id": "azki-route-strike", "name": "路線打擊", "cost": 1, "kind": "mixed", "animation": "map_marker_attack", "description": "造成 6 點傷害，獲得 4 點格擋。", "effects": [{ "type": "damage", "amount": 6, "hits": 1 }, { "type": "block", "amount": 4 }] },
		{ "id": "azki-double-pin", "name": "雙重定位", "cost": 1, "kind": "attack", "animation": "map_marker_attack", "description": "造成 3 點傷害 2 次。", "effects": [{ "type": "damage", "amount": 3, "hits": 2 }] },
		{ "id": "azki-frontier-burst", "name": "開拓爆發", "cost": 2, "kind": "attack", "animation": "kiss_attack", "description": "造成 8 點傷害 2 次。", "effects": [{ "type": "damage", "amount": 8, "hits": 2 }] },
		{ "id": "azki-laplus-dash", "name": "Laplus 衝刺", "cost": 1, "kind": "attack", "animation": "laplus_dash", "description": "造成 7 點傷害，給予 1 層標記。", "effects": [{ "type": "damage", "amount": 7, "hits": 1 }, { "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }] },
		{ "id": "azki-laplus-crash", "name": "Laplus 墜擊", "cost": 2, "kind": "attack", "animation": "laplus_crash", "description": "造成 20 點傷害，給予 2 回合易傷。若敵人有標記，抽 1 張牌。", "effects": [{ "type": "damage", "amount": 20, "hits": 1 }, { "type": "status", "target": "enemy", "status_id": "vulnerable", "amount": 1, "value": 1, "duration": 2 }, { "type": "draw_if_status", "target": "enemy", "status_id": "marker", "amount": 1 }] },
		{ "id": "azki-safe-route", "name": "安全路線", "cost": 1, "kind": "defense", "animation": "defense", "description": "獲得 11 點格擋。", "effects": [{ "type": "block", "amount": 11 }] },
		{ "id": "azki-coordinate-shield", "name": "座標護盾", "cost": 1, "kind": "mixed", "animation": "defense", "description": "獲得 7 點格擋，給予 1 層標記。", "effects": [{ "type": "block", "amount": 7 }, { "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }] },
		{ "id": "azki-idol-stance", "name": "偶像站姿", "cost": 2, "kind": "defense", "animation": "defense", "description": "獲得 12 點格擋，獲得 1 點能量。", "effects": [{ "type": "block", "amount": 12 }, { "type": "energy", "amount": 1 }] },
		{ "id": "azki-map-search", "name": "地圖搜尋", "cost": 0, "kind": "support", "animation": "idle", "description": "給予 1 層標記，抽 1 張牌。", "effects": [{ "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }, { "type": "draw", "amount": 1 }] },
		{ "id": "azki-songline", "name": "歌之航線", "cost": 1, "kind": "support", "animation": "idle", "description": "抽 2 張牌。", "effects": [{ "type": "draw", "amount": 2 }] },
		{ "id": "azki-open-route", "name": "開拓航路", "cost": 1, "kind": "support", "animation": "idle", "description": "獲得 1 點能量。若敵人有標記，抽 1 張牌。", "effects": [{ "type": "energy", "amount": 1 }, { "type": "draw_if_status", "target": "enemy", "status_id": "marker", "amount": 1 }] },
		{ "id": "azki-pioneer-call", "name": "開拓者號令", "cost": 1, "kind": "support", "animation": "idle", "description": "獲得 1 層力量，給予 1 層標記。", "effects": [{ "type": "status", "target": "player", "status_id": "strength", "amount": 1, "value": 1, "duration": 99 }, { "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }] },
		{ "id": "azki-final-coordinate", "name": "終點座標", "cost": 2, "kind": "mixed", "animation": "kiss_attack", "description": "給予 3 層標記，造成 12 點傷害。", "effects": [{ "type": "status", "target": "enemy", "status_id": "marker", "amount": 3, "value": 2, "duration": 3 }, { "type": "damage", "amount": 12, "hits": 1 }] },
		{ "id": "azki-laplus-cover", "name": "Laplus 掩護", "cost": 1, "kind": "mixed", "animation": "defense", "description": "獲得 8 點格擋，回復 Laplus 4 HP。若敵人有標記，抽 1 張牌。", "effects": [{ "type": "block", "amount": 8 }, { "type": "summon_heal", "amount": 4 }, { "type": "draw_if_status", "target": "enemy", "status_id": "marker", "amount": 1 }] },
		{ "id": "azki-coordinate-barrage", "name": "座標連射", "cost": 1, "kind": "mixed", "animation": "map_marker_attack", "description": "造成 2 點傷害 3 次，給予 1 層標記。", "effects": [{ "type": "damage", "amount": 2, "hits": 3 }, { "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }] },
		{ "id": "azki-laplus-combo", "name": "Laplus 連攜", "cost": 2, "kind": "attack", "animation": "laplus_dash", "description": "造成 10 點傷害 2 次。若敵人有標記，抽 1 張牌。", "effects": [{ "type": "damage", "amount": 10, "hits": 2 }, { "type": "draw_if_status", "target": "enemy", "status_id": "marker", "amount": 1 }] },
		{ "id": "azki-marker-echo", "name": "標記回聲", "cost": 1, "kind": "support", "animation": "map_marker_attack", "description": "若敵人有標記，抽 2 張牌。給予 1 層標記。", "effects": [{ "type": "draw_if_status", "target": "enemy", "status_id": "marker", "amount": 2 }, { "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }] },
		{ "id": "azki-laplus-reposition", "name": "Laplus 換位", "cost": 1, "kind": "mixed", "animation": "defense", "description": "若敵人有標記，抽 1 張牌。獲得 8 點格擋，給予 1 層標記。", "effects": [{ "type": "draw_if_status", "target": "enemy", "status_id": "marker", "amount": 1 }, { "type": "block", "amount": 8 }, { "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }] },
		{ "id": "azki-route-marker", "name": "航線標記", "cost": 0, "kind": "support", "animation": "map_marker_attack", "description": "若敵人有標記，抽 1 張牌。給予 1 層標記。", "rarity": "common", "floor_band": "early", "archetype_tags": ["marker_loop", "route_explore"], "role_tags": ["setup", "bridge"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級把標記 payoff 轉成更多抽牌，讓 marker loop 不只是一張 setup。", "upgrade_description": "若敵人有標記，抽 2 張牌。給予 1 層標記。", "effects": [{ "type": "draw_if_status", "target": "enemy", "status_id": "marker", "amount": 1 }, { "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }], "upgrade_effects": [{ "type": "draw_if_status", "target": "enemy", "status_id": "marker", "amount": 2 }, { "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }] },
		{ "id": "azki-laplus-guard-order", "name": "Laplus 防衛指令", "cost": 1, "kind": "defense", "animation": "defense", "description": "獲得 8 點格擋，回復 Laplus 5 HP。若 Laplus 存活，抽 1 張牌。", "rarity": "common", "floor_band": "early", "archetype_tags": ["laplus_guard", "marker_loop"], "role_tags": ["defense", "utility", "bridge"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級提高格擋與 summon_heal，讓 Laplus HP 成為可管理的資源。", "upgrade_description": "獲得 10 點格擋，回復 Laplus 6 HP。若 Laplus 存活，抽 1 張牌。", "effects": [{ "type": "block", "amount": 8 }, { "type": "summon_heal", "amount": 5 }, { "type": "conditional", "condition": { "summon_alive": true }, "effects": [{ "type": "draw", "amount": 1 }] }], "upgrade_effects": [{ "type": "block", "amount": 10 }, { "type": "summon_heal", "amount": 6 }, { "type": "conditional", "condition": { "summon_alive": true }, "effects": [{ "type": "draw", "amount": 1 }] }] },
		{ "id": "azki-laplus-contract", "name": "Laplus 契約補強", "cost": 1, "kind": "support", "animation": "defense", "description": "獲得 4 點格擋，回復 Laplus 7 HP，抽 1 張牌。", "rarity": "common", "floor_band": "early", "archetype_tags": ["laplus_guard", "route_explore"], "role_tags": ["bridge", "utility", "defense"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級提高格擋與 Laplus HP 疊加量，讓 AZKi 能更早建立召喚獸護盾。", "upgrade_description": "獲得 6 點格擋，回復 Laplus 9 HP，抽 1 張牌。", "effects": [{ "type": "block", "amount": 4 }, { "type": "summon_heal", "amount": 7 }, { "type": "draw", "amount": 1 }], "upgrade_effects": [{ "type": "block", "amount": 6 }, { "type": "summon_heal", "amount": 9 }, { "type": "draw", "amount": 1 }] },
		{ "id": "azki-dark-tether", "name": "Dark Tether", "cost": 1, "kind": "mixed", "animation": "map_marker_attack", "description": "獲得 3 點格擋，造成 6 點傷害，給予 1 層標記，回復 Laplus 5 HP。", "rarity": "common", "floor_band": "early", "archetype_tags": ["laplus_guard", "marker_loop"], "role_tags": ["bridge", "setup", "defense"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級把攻擊、標記、防守與 Laplus 疊血壓在同一張低費橋接牌上，降低 AZKi 前期斷手感。", "upgrade_description": "獲得 4 點格擋，造成 8 點傷害，給予 1 層標記，回復 Laplus 6 HP。", "effects": [{ "type": "block", "amount": 3 }, { "type": "damage", "amount": 6, "hits": 1 }, { "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }, { "type": "summon_heal", "amount": 5 }], "upgrade_effects": [{ "type": "block", "amount": 4 }, { "type": "damage", "amount": 8, "hits": 1 }, { "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }, { "type": "summon_heal", "amount": 6 }] },
		{ "id": "azki-singing-coordinate", "name": "歌唱座標", "cost": 1, "kind": "support", "animation": "idle", "description": "抽 1 張牌。若敵人有標記，獲得 1 點能量。Retain。", "rarity": "uncommon", "floor_band": "mid", "archetype_tags": ["route_explore", "marker_loop"], "role_tags": ["bridge", "setup"], "retain": true, "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級提高抽牌，讓保留牌在標記回合能更穩地延伸。", "upgrade_description": "抽 2 張牌。若敵人有標記，獲得 1 點能量。Retain。", "effects": [{ "type": "draw", "amount": 1 }, { "type": "conditional", "condition": { "target_status": { "target": "enemy", "status_id": "marker" } }, "effects": [{ "type": "energy", "amount": 1 }] }], "upgrade_effects": [{ "type": "draw", "amount": 2 }, { "type": "conditional", "condition": { "target_status": { "target": "enemy", "status_id": "marker" } }, "effects": [{ "type": "energy", "amount": 1 }] }] },
		{ "id": "azki-laplus-overflow", "name": "Laplus Overflow", "cost": 2, "kind": "attack", "animation": "laplus_crash", "description": "造成 12 點傷害，並追加等同 Laplus HP 的傷害。Exhaust。", "rarity": "uncommon", "floor_band": "mid", "archetype_tags": ["laplus_guard", "marker_loop"], "role_tags": ["payoff", "scaling"], "exhaust_on_play": true, "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級提高基礎傷害，保留 Laplus HP 疊加作為無上限 payoff。", "upgrade_description": "造成 16 點傷害，並追加等同 Laplus HP 的傷害。Exhaust。", "effects": [{ "type": "summon_hp_damage", "base": 12, "per_hp": 1 }], "upgrade_effects": [{ "type": "summon_hp_damage", "base": 16, "per_hp": 1 }] },
		{ "id": "azki-necrobinder-finale", "name": "Necrobinder Finale", "cost": 2, "kind": "attack", "animation": "laplus_crash", "description": "造成 22 點傷害。若 Laplus 存活，額外造成 10 點傷害並回復 Laplus 3 HP。Exhaust。", "rarity": "rare", "floor_band": "late", "archetype_tags": ["laplus_guard", "marker_loop"], "role_tags": ["payoff", "risk"], "exhaust_on_play": true, "art_status": "prototype_placeholder", "art_path": "", "upgrade_plan": "升級提高終結傷害與 Laplus 回復，讓 summon 存活成為明確 payoff。", "upgrade_description": "造成 26 點傷害。若 Laplus 存活，額外造成 12 點傷害並回復 Laplus 4 HP。Exhaust。", "effects": [{ "type": "damage", "amount": 22, "hits": 1 }, { "type": "conditional", "condition": { "summon_alive": true }, "effects": [{ "type": "damage", "amount": 10, "hits": 1 }, { "type": "summon_heal", "amount": 3 }] }], "upgrade_effects": [{ "type": "damage", "amount": 26, "hits": 1 }, { "type": "conditional", "condition": { "summon_alive": true }, "effects": [{ "type": "damage", "amount": 12, "hits": 1 }, { "type": "summon_heal", "amount": 4 }] }] },
		{ "id": "azki-phantom-route", "name": "Phantom Route", "cost": 1, "kind": "support", "animation": "map_marker_attack", "description": "建立 1 張臨時 Phantom Marker。回復 Laplus 5 HP。", "rarity": "common", "floor_band": "early", "archetype_tags": ["marker_loop", "laplus_guard"], "role_tags": ["setup", "bridge", "defense"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_signal": "setup", "upgrade_plan": "升級提高臨時標記牌傷害與 Laplus 疊血，讓 setup 同時兼顧安全。", "upgrade_description": "建立 1 張臨時強化 Phantom Marker。回復 Laplus 6 HP。", "effects": [{ "type": "temporary_card", "amount": 1, "card": { "id": "azki-phantom-marker", "name": "Phantom Marker", "cost": 0, "kind": "attack", "animation": "map_marker_attack", "description": "造成 4 點傷害，給予 1 層標記。Temporary。", "effects": [{ "type": "damage", "amount": 4, "hits": 1 }, { "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }] } }, { "type": "summon_heal", "amount": 5 }], "upgrade_effects": [{ "type": "temporary_card", "amount": 1, "card": { "id": "azki-phantom-marker", "name": "Phantom Marker+", "cost": 0, "kind": "attack", "animation": "map_marker_attack", "description": "造成 6 點傷害，給予 1 層標記。Temporary。", "effects": [{ "type": "damage", "amount": 6, "hits": 1 }, { "type": "status", "target": "enemy", "status_id": "marker", "amount": 1, "value": 2, "duration": 1 }] } }, { "type": "summon_heal", "amount": 6 }] },
		{ "id": "azki-necro-recall", "name": "Necro Recall", "cost": 1, "kind": "support", "animation": "idle", "description": "從棄牌堆取回 1 張 support 牌，回復 Laplus 6 HP。", "rarity": "uncommon", "floor_band": "mid", "archetype_tags": ["marker_loop", "laplus_guard"], "role_tags": ["bridge", "utility", "defense"], "art_status": "prototype_placeholder", "art_path": "", "upgrade_signal": "stability", "upgrade_plan": "升級提高 Laplus 疊血，讓回收支援牌時也能穩住 summon 防線。", "upgrade_description": "從棄牌堆取回 1 張 support 牌，回復 Laplus 8 HP。", "effects": [{ "type": "draw_from_discard", "amount": 1, "kind": "support" }, { "type": "summon_heal", "amount": 6 }], "upgrade_effects": [{ "type": "draw_from_discard", "amount": 1, "kind": "support" }, { "type": "summon_heal", "amount": 8 }] },
		{ "id": "azki-laplus-release", "name": "Laplus Release", "cost": 1, "kind": "attack", "animation": "laplus_crash", "description": "造成 12 點傷害。若本場已 Exhaust 至少 2 張牌，追加 4 點傷害與等同 Laplus HP 的傷害。Exhaust。", "rarity": "uncommon", "floor_band": "mid", "archetype_tags": ["marker_loop", "laplus_guard"], "role_tags": ["payoff", "scaling", "risk"], "exhaust_on_play": true, "art_status": "prototype_placeholder", "art_path": "", "upgrade_signal": "scaling", "upgrade_plan": "升級提高基礎傷害與 Exhaust payoff，讓 Laplus HP 轉成更明確收束。", "upgrade_description": "造成 14 點傷害。若本場已 Exhaust 至少 2 張牌，追加 6 點傷害與等同 Laplus HP 的傷害。Exhaust。", "effects": [{ "type": "damage", "amount": 12, "hits": 1 }, { "type": "conditional", "condition": { "exhaust_count_at_least": 2 }, "effects": [{ "type": "summon_hp_damage", "base": 4, "per_hp": 1 }] }], "upgrade_effects": [{ "type": "damage", "amount": 14, "hits": 1 }, { "type": "conditional", "condition": { "exhaust_count_at_least": 2 }, "effects": [{ "type": "summon_hp_damage", "base": 6, "per_hp": 1 }] }] },
		{ "id": "curse-dead-air", "name": "Dead Air", "cost": 99, "kind": "support", "animation": "idle", "description": "無法打出。抽到時失去 1 點能量。", "unplayable": true, "curse_hook": "on_draw", "curse_effect": "lose_energy", "curse_amount": 1, "effects": [{ "type": "draw", "amount": 1 }] },
		{ "id": "curse-bad-connection", "name": "Bad Connection", "cost": 99, "kind": "support", "animation": "idle", "description": "無法打出。若回合結束仍留在手上，失去 3 HP。", "unplayable": true, "curse_hook": "end_turn_in_hand", "curse_effect": "lose_hp", "curse_amount": 3, "effects": [{ "type": "draw", "amount": 1 }] },
		{ "id": "curse-comment-fire", "name": "Comment Fire", "cost": 99, "kind": "support", "animation": "idle", "description": "無法打出。抽到時獲得 1 回合易傷。Ethereal。", "unplayable": true, "ethereal": true, "curse_hook": "on_draw", "curse_effect": "self_status", "curse_status_id": "vulnerable", "curse_status_value": 1, "curse_status_duration": 1, "effects": [{ "type": "draw", "amount": 1 }] }
	]
	enemies = [
		{ "id": "ssrb-gray", "display_name": "SSRB Gray", "encounter_tier": "early", "max_hp": 36, "gold": 25, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/gray/", "actions": [{ "type": "attack", "damage": 9, "block": 0, "description": "攻擊 9" }] },
		{ "id": "ssrb-camouflage", "display_name": "SSRB Camouflage", "encounter_tier": "early", "max_hp": 46, "gold": 30, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/camouflage/", "actions": [{ "type": "attack", "damage": 9, "block": 0, "description": "攻擊 9" }, { "type": "block", "damage": 0, "block": 10, "description": "防禦 10" }] },
		{ "id": "ssrb-white", "display_name": "SSRB White", "encounter_tier": "mid", "max_hp": 58, "gold": 35, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/white/", "actions": [{ "type": "block", "damage": 0, "block": 8, "description": "蓄力防禦 8" }, { "type": "attack", "damage": 15, "block": 0, "description": "重擊 15" }] },
		{ "id": "ssrb-gold", "display_name": "SSRB Gold", "encounter_tier": "mid", "max_hp": 44, "gold": 40, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/gray/", "actions": [{ "type": "buff", "damage": 0, "block": 0, "description": "打氣：力量 +2", "status_id": "strength", "status_value": 2, "status_duration": 99 }, { "type": "attack", "damage": 10, "block": 0, "description": "加速攻擊 10" }] },
		{ "id": "ssrb-glitch", "display_name": "SSRB Glitch", "encounter_tier": "mid", "max_hp": 50, "gold": 32, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/camouflage/", "actions": [{ "type": "debuff", "damage": 0, "block": 0, "description": "雜訊：虛弱 2", "status_id": "weak", "status_value": 1, "status_duration": 2 }, { "type": "attack_block", "damage": 12, "block": 6, "description": "雜訊衝撞 12 + 防禦 6" }] },
		{ "id": "ssrb-guard-tutor", "display_name": "SSRB Guard Tutor", "encounter_tier": "early", "max_hp": 48, "gold": 32, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/camouflage/", "pressure_tags": ["anti_burst_into_block"], "tests_archetypes": ["two_cost_burst", "marker_loop", "cheap_chain"], "counterplay_hint": "高防禦回合不要把 2 費爆發打進護甲，先用 setup、抽牌或低費橋接。", "actions": [{ "type": "block", "damage": 0, "block": 18, "description": "教學防禦 18" }, { "type": "attack", "damage": 10, "block": 0, "description": "反打 10" }] },
		{ "id": "ssrb-striker-intent", "display_name": "SSRB Striker Intent", "encounter_tier": "mid", "max_hp": 60, "gold": 38, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/white/", "pressure_tags": ["attack_intent_test"], "tests_archetypes": ["tempo_block", "fortress_counter", "laplus_guard"], "counterplay_hint": "攻擊意圖明確時優先防守，保留反擊或 enemy_intent 條件牌。", "actions": [{ "type": "attack", "damage": 18, "block": 0, "description": "突進 18" }, { "type": "attack_block", "damage": 12, "block": 6, "description": "壓制 12 + 防禦 6" }] },
		{ "id": "ssrb-debuff-check", "display_name": "SSRB Debuff Check", "encounter_tier": "late", "max_hp": 66, "gold": 40, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/camouflage/", "pressure_tags": ["debuff_resilience"], "tests_archetypes": ["precision_control", "route_explore", "tempo_block"], "counterplay_hint": "易傷與虛弱會降低回合品質，先穩住血線再把 payoff 留給乾淨回合。", "actions": [{ "type": "debuff", "damage": 0, "block": 0, "description": "壓力標籤：易傷 2", "status_id": "vulnerable", "status_value": 1, "status_duration": 2 }, { "type": "attack", "damage": 17, "block": 0, "description": "追擊 17" }, { "type": "debuff", "damage": 0, "block": 0, "description": "節奏干擾：虛弱 2", "status_id": "weak", "status_value": 1, "status_duration": 2 }] },
		{ "id": "ssrb-scaling-clock", "display_name": "菁英 SSRB Scaling Clock", "max_hp": 112, "gold": 70, "tier": "elite", "elite_tier": "late", "scale": 0.94, "resource_base_path": "res://assets/enemies/ssrb/gray/", "secondary_resource_base_path": "res://assets/enemies/ssrb/white/", "pressure_tags": ["scaling_clock"], "tests_archetypes": ["multi_hit_strength", "two_cost_burst", "marker_loop"], "counterplay_hint": "敵人會持續累積力量，拖太久會失控；需要 scaling 或集中爆發窗口。", "actions": [{ "type": "buff", "damage": 0, "block": 0, "description": "倒數強化：力量 +2", "status_id": "strength", "status_value": 2, "status_duration": 99 }, { "type": "attack", "damage": 18, "block": 0, "description": "時鐘重擊 18" }, { "type": "attack_block", "damage": 20, "block": 12, "description": "壓線 20 + 防禦 12" }] },
		{ "id": "ssrb-duo-gray-camouflage", "display_name": "菁英 SSRB Duo: Gray + Camouflage", "max_hp": 92, "gold": 55, "tier": "elite", "elite_tier": "mid", "scale": 0.92, "resource_base_path": "res://assets/enemies/ssrb/gray/", "secondary_resource_base_path": "res://assets/enemies/ssrb/camouflage/", "actions": [{ "type": "attack", "damage": 18, "block": 0, "description": "雙重衝撞 18" }, { "type": "attack_block", "damage": 14, "block": 10, "description": "交互掩護 14 + 防禦 10" }] },
		{ "id": "ssrb-duo-gray-white", "display_name": "菁英 SSRB Duo: Gray + White", "max_hp": 98, "gold": 58, "tier": "elite", "elite_tier": "mid", "scale": 0.92, "resource_base_path": "res://assets/enemies/ssrb/gray/", "secondary_resource_base_path": "res://assets/enemies/ssrb/white/", "actions": [{ "type": "attack", "damage": 19, "block": 0, "description": "雙重衝撞 19" }, { "type": "block", "damage": 0, "block": 16, "description": "雙層防線 16" }, { "type": "attack_block", "damage": 15, "block": 9, "description": "推進 15 + 防禦 9" }] },
		{ "id": "ssrb-duo-camouflage-white", "display_name": "菁英 SSRB Duo: Camouflage + White", "max_hp": 102, "gold": 60, "tier": "elite", "elite_tier": "late", "scale": 0.92, "resource_base_path": "res://assets/enemies/ssrb/camouflage/", "secondary_resource_base_path": "res://assets/enemies/ssrb/white/", "actions": [{ "type": "block", "damage": 0, "block": 18, "description": "雙層防線 18" }, { "type": "debuff", "damage": 0, "block": 0, "description": "壓迫：易傷 2", "status_id": "vulnerable", "status_value": 1, "status_duration": 2 }, { "type": "attack_block", "damage": 18, "block": 10, "description": "夾擊 18 + 防禦 10" }] },
		{ "id": "ssrb-duo-gold-glitch", "display_name": "菁英 SSRB Duo: Gold + Glitch", "max_hp": 104, "gold": 65, "tier": "elite", "elite_tier": "late", "scale": 0.92, "resource_base_path": "res://assets/enemies/ssrb/gray/", "secondary_resource_base_path": "res://assets/enemies/ssrb/camouflage/", "actions": [{ "type": "buff", "damage": 0, "block": 0, "description": "全場打氣：力量 +2", "status_id": "strength", "status_value": 2, "status_duration": 99 }, { "type": "debuff", "damage": 0, "block": 0, "description": "直播雜訊：虛弱 2", "status_id": "weak", "status_value": 1, "status_duration": 2 }, { "type": "attack", "damage": 23, "block": 0, "description": "金色衝撞 23" }] },
		{ "id": "youtube-kun", "display_name": "YouTube-kun", "encounter_tier": "mid", "max_hp": 56, "gold": 38, "scale": 1.0, "content_group": "meme_enemy", "resource_base_path": "res://assets/enemies/ssrb/camouflage/", "actions": [{ "type": "debuff", "damage": 0, "block": 0, "description": "技術事故：虛弱 2", "status_id": "weak", "status_value": 1, "status_duration": 2 }, { "type": "attack_block", "damage": 13, "block": 8, "description": "轉圈緩衝 13 + 防禦 8" }] },
		{ "id": "desk-kun", "display_name": "Desk-kun", "encounter_tier": "early", "max_hp": 52, "gold": 34, "scale": 1.0, "content_group": "meme_enemy", "resource_base_path": "res://assets/enemies/ssrb/gray/", "actions": [{ "type": "attack", "damage": 11, "block": 0, "description": "桌面震動 11" }, { "type": "attack_block", "damage": 9, "block": 11, "description": "硬撐 9 + 防禦 11" }] },
		{ "id": "korone-suki", "display_name": "ころね好き", "encounter_tier": "mid", "max_hp": 54, "gold": 36, "scale": 1.0, "content_group": "meme_enemy", "resource_base_path": "res://assets/enemies/korone_suki/", "actions": [{ "type": "attack", "damage": 12, "block": 0, "description": "咬咬衝撞 12" }, { "type": "debuff", "damage": 0, "block": 0, "description": "執著視線：虛弱 2", "status_id": "weak", "status_value": 1, "status_duration": 2 }, { "type": "attack_block", "damage": 8, "block": 8, "description": "貼身糾纏 8 + 防禦 8" }] },
		{ "id": "announcement-shadow", "display_name": "Announcement Shadow", "encounter_tier": "late", "max_hp": 64, "gold": 42, "scale": 1.0, "content_group": "meme_enemy", "resource_base_path": "res://assets/enemies/ssrb/white/", "actions": [{ "type": "block", "damage": 0, "block": 14, "description": "倒數預告 14" }, { "type": "debuff", "damage": 0, "block": 0, "description": "壓力：易傷 2", "status_id": "vulnerable", "status_value": 1, "status_duration": 2 }, { "type": "attack", "damage": 14, "block": 0, "description": "重大重擊 14" }] },
		{ "id": "ak-idol-unit", "display_name": "AK Idol Unit", "max_hp": 108, "gold": 68, "tier": "elite", "elite_tier": "late", "scale": 0.92, "content_group": "meme_enemy", "resource_base_path": "res://assets/enemies/ssrb/gray/", "secondary_resource_base_path": "res://assets/enemies/ssrb/white/", "actions": [{ "type": "attack", "damage": 20, "block": 0, "description": "偶像火力 20" }, { "type": "buff", "damage": 0, "block": 0, "description": "火力整隊：力量 +2", "status_id": "strength", "status_value": 2, "status_duration": 99 }, { "type": "attack_block", "damage": 18, "block": 12, "description": "舞台壓制 18 + 防禦 12" }] },
		{ "id": "kedama-elite", "display_name": "毛玉", "max_hp": 100, "gold": 62, "tier": "elite", "elite_tier": "late", "scale": 1.05, "content_group": "meme_enemy", "resource_base_path": "res://assets/enemies/kedama/", "actions": [{ "type": "attack", "damage": 18, "block": 0, "description": "毛玉衝刺 18" }, { "type": "block", "damage": 0, "block": 16, "description": "毛玉護牆 16" }, { "type": "debuff", "damage": 0, "block": 0, "description": "纏住：易傷 2", "status_id": "vulnerable", "status_value": 1, "status_duration": 2 }, { "type": "attack_block", "damage": 14, "block": 8, "description": "翻滾夾擊 14 + 防禦 8" }] },
		{ "id": "recommendation-watcher", "display_name": "Recommendation Watcher", "chapter_id": CHAPTER_2_ID, "encounter_tier": "early", "max_hp": 68, "gold": 44, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/camouflage/", "pressure_tags": ["anti_cycle", "debuff_pressure"], "tests_archetypes": ["cheap_chain", "marker_loop", "route_explore"], "counterplay_hint": "不要每回合都把手牌打空，保留爆發回合並讓連段換到實質 payoff。", "actions": [{ "type": "attack", "damage": 12, "block": 0, "description": "推薦監看 12" }, { "type": "debuff", "damage": 0, "block": 0, "description": "節奏審核：虛弱 2", "status_id": "weak", "status_value": 1, "status_duration": 2 }, { "type": "attack_block", "damage": 9, "block": 8, "description": "演算法回推 9 + 防禦 8" }] },
		{ "id": "buffering-wall", "display_name": "Buffering Wall", "chapter_id": CHAPTER_2_ID, "encounter_tier": "early", "max_hp": 74, "gold": 42, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/white/", "pressure_tags": ["block_puzzle"], "tests_archetypes": ["two_cost_burst", "precision_control", "marker_loop"], "counterplay_hint": "高防禦回合先 setup 或轉防守，等低防回合或易傷窗口再爆發。", "actions": [{ "type": "block", "damage": 0, "block": 20, "description": "緩衝高牆 20" }, { "type": "attack", "damage": 14, "block": 0, "description": "掉幀反擊 14" }] },
		{ "id": "comment-flood", "display_name": "Comment Flood", "chapter_id": CHAPTER_2_ID, "encounter_tier": "mid", "max_hp": 82, "gold": 48, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/gray/", "pressure_tags": ["multi_hit_pressure", "debuff_pressure"], "tests_archetypes": ["tempo_block", "fortress_counter", "laplus_guard"], "counterplay_hint": "多段小傷害會吃掉零散格擋，穩定防守比單回合大 block 更重要。", "actions": [{ "type": "attack", "damage": 5, "hits": 4, "block": 0, "description": "留言洪流 5x4" }, { "type": "debuff", "damage": 0, "block": 0, "description": "情緒升溫：易傷 2", "status_id": "vulnerable", "status_value": 1, "status_duration": 2 }, { "type": "attack_block", "damage": 12, "block": 8, "description": "洗版壓制 12 + 防禦 8" }] },
		{ "id": "clip-mirror", "display_name": "Clip Mirror", "chapter_id": CHAPTER_2_ID, "encounter_tier": "mid", "max_hp": 78, "gold": 46, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/camouflage/", "pressure_tags": ["anti_cycle", "curse_tolerance"], "tests_archetypes": ["cheap_chain", "marker_loop", "route_explore"], "counterplay_hint": "高報酬事件留下的 curse 會拖慢回合，保持牌組 density 才能減壓。", "actions": [{ "type": "attack", "damage": 16, "block": 0, "description": "鏡像剪輯 16" }, { "type": "debuff", "damage": 0, "block": 0, "description": "回放雜訊：虛弱 2", "status_id": "weak", "status_value": 1, "status_duration": 2 }] },
		{ "id": "bitrate-phantom", "display_name": "Bitrate Phantom", "chapter_id": CHAPTER_2_ID, "encounter_tier": "mid", "max_hp": 86, "gold": 50, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/white/", "pressure_tags": ["delayed_burst", "debuff_pressure"], "tests_archetypes": ["fortress_counter", "precision_control", "tempo_block"], "counterplay_hint": "鋪墊回合會接大攻擊，Boss warning 前要優先防守或加速擊殺。", "actions": [{ "type": "debuff", "damage": 0, "block": 0, "description": "碼率下降：虛弱 2", "status_id": "weak", "status_value": 1, "status_duration": 2 }, { "type": "block", "damage": 0, "block": 16, "description": "訊號聚合 16" }, { "type": "attack", "damage": 26, "block": 0, "description": "位元爆裂 26" }] },
		{ "id": "archive-sentinel", "display_name": "Archive Sentinel", "chapter_id": CHAPTER_2_ID, "encounter_tier": "late", "max_hp": 96, "gold": 56, "scale": 1.0, "resource_base_path": "res://assets/enemies/ssrb/white/", "pressure_tags": ["block_puzzle", "scaling_clock"], "tests_archetypes": ["two_cost_burst", "multi_hit_strength", "marker_loop"], "counterplay_hint": "需要有效破防，不要用低傷多段餵它成長；把爆發留給低防或易傷窗口。", "actions": [{ "type": "block", "damage": 0, "block": 24, "description": "封存護壁 24" }, { "type": "buff", "damage": 0, "block": 0, "description": "資料增幅：力量 +2", "status_id": "strength", "status_value": 2, "status_duration": 99 }, { "type": "attack_block", "damage": 22, "block": 12, "description": "封存反擊 22 + 防禦 12" }] },
		{ "id": "algorithm-auditor", "display_name": "Algorithm Auditor", "chapter_id": CHAPTER_2_ID, "max_hp": 138, "gold": 82, "tier": "elite", "elite_tier": "mid", "scale": 1.05, "resource_base_path": "res://assets/enemies/ssrb/camouflage/", "secondary_resource_base_path": "res://assets/enemies/ssrb/white/", "pressure_tags": ["scaling_clock", "anti_cycle"], "tests_archetypes": ["cheap_chain", "two_cost_burst", "marker_loop"], "counterplay_hint": "cheap-chain 需要收束，不可只循環；每三回合會審核節奏並提高壓力。", "actions": [{ "type": "attack", "damage": 22, "block": 0, "description": "審核打擊 22" }, { "type": "buff", "damage": 0, "block": 0, "description": "節奏審核：力量 +3", "status_id": "strength", "status_value": 3, "status_duration": 99 }, { "type": "attack_block", "damage": 24, "block": 16, "description": "審核壓制 24 + 防禦 16" }] },
		{ "id": "notification-storm-elite", "display_name": "Notification Storm Elite", "chapter_id": CHAPTER_2_ID, "max_hp": 128, "gold": 78, "tier": "elite", "elite_tier": "late", "scale": 1.05, "resource_base_path": "res://assets/enemies/ssrb/gray/", "secondary_resource_base_path": "res://assets/enemies/ssrb/camouflage/", "pressure_tags": ["multi_hit_pressure", "debuff_pressure"], "tests_archetypes": ["tempo_block", "fortress_counter", "laplus_guard"], "counterplay_hint": "易傷與多段攻擊會連續壓血，保守處理 debuff 回合。", "actions": [{ "type": "attack", "damage": 7, "hits": 5, "block": 0, "description": "通知暴雨 7x5" }, { "type": "debuff", "damage": 0, "block": 0, "description": "通知疲勞：易傷 2", "status_id": "vulnerable", "status_value": 1, "status_duration": 2 }, { "type": "attack_block", "damage": 22, "block": 14, "description": "提醒壓制 22 + 防禦 14" }] },
		{ "id": "archive-hydra", "display_name": "Archive Hydra", "chapter_id": CHAPTER_2_ID, "max_hp": 134, "gold": 80, "tier": "elite", "elite_tier": "late", "scale": 1.08, "resource_base_path": "res://assets/enemies/ssrb/white/", "secondary_resource_base_path": "res://assets/enemies/ssrb/gray/", "pressure_tags": ["curse_tolerance", "delayed_burst"], "tests_archetypes": ["route_explore", "marker_loop", "fortress_counter"], "counterplay_hint": "事件拿 curse 的 deck 會付出真代價；蓄力前先清出防守回合。", "actions": [{ "type": "debuff", "damage": 0, "block": 0, "description": "封存雜訊：虛弱 2", "status_id": "weak", "status_value": 1, "status_duration": 2 }, { "type": "block", "damage": 0, "block": 22, "description": "多頭歸檔 22" }, { "type": "attack", "damage": 32, "block": 0, "description": "封存爆裂 32" }] },
		{ "id": "algorithm-core", "display_name": "Algorithm Core", "chapter_id": CHAPTER_2_ID, "max_hp": 168, "gold": 0, "scale": 1.5, "is_boss": true, "boss_danger_tag": "節奏審核", "boss_pattern": "先記錄玩家出牌節奏，再用虛弱、buff 與依節奏放大的 spike attack 懲罰無收束連打。", "boss_counterplay": "可以打連段，但要換到傷害、防守或抽牌 payoff；不要每回合無腦把低費牌全部打完。", "boss_spike_turn": 4, "resource_base_path": "res://assets/enemies/ssrb/camouflage/", "actions": [{ "type": "attack", "damage": 22, "block": 0, "description": "核心掃描 22" }, { "type": "debuff", "damage": 0, "block": 0, "description": "節奏審核：虛弱 2", "status_id": "weak", "status_value": 1, "status_duration": 2 }, { "type": "buff", "damage": 0, "block": 0, "description": "推薦權重：力量 +3", "status_id": "strength", "status_value": 3, "status_duration": 99 }, { "type": "attack", "damage": 34, "block": 0, "description": "審核爆發 34" }] },
		{ "id": "archive-phantom", "display_name": "Archive Phantom", "chapter_id": CHAPTER_2_ID, "max_hp": 162, "gold": 0, "scale": 1.5, "is_boss": true, "boss_danger_tag": "封存污染", "boss_pattern": "以封存雜訊拖慢牌組，並在玩家手牌污染時用高傷 spike 懲罰。", "boss_counterplay": "移除卡、升級核心牌、保持 deck density 都能降低壓力；Chapter start 的 Gold + curse 交易在這裡會變痛。", "boss_spike_turn": 4, "resource_base_path": "res://assets/enemies/ssrb/white/", "actions": [{ "type": "attack", "damage": 18, "block": 0, "description": "殘影刮痕 18" }, { "type": "debuff", "damage": 0, "block": 0, "description": "封存雜訊：易傷 2", "status_id": "vulnerable", "status_value": 1, "status_duration": 2 }, { "type": "block", "damage": 0, "block": 24, "description": "封存遮罩 24" }, { "type": "attack", "damage": 33, "block": 0, "description": "污染重擊 33" }] },
		{ "id": "notification-storm", "display_name": "Notification Storm", "chapter_id": CHAPTER_2_ID, "max_hp": 166, "gold": 0, "scale": 1.5, "is_boss": true, "boss_danger_tag": "連續壓力", "boss_pattern": "多段攻擊、debuff、attack_block 循環後接 spike multi-hit。", "boss_counterplay": "持續防守比只靠一次大防更可靠；身上有易傷時要保守或提前打進斬殺線。", "boss_spike_turn": 4, "resource_base_path": "res://assets/enemies/ssrb/gray/", "actions": [{ "type": "attack", "damage": 7, "hits": 4, "block": 0, "description": "通知連打 7x4" }, { "type": "debuff", "damage": 0, "block": 0, "description": "通知疲勞：易傷 2", "status_id": "vulnerable", "status_value": 1, "status_duration": 2 }, { "type": "attack_block", "damage": 22, "block": 14, "description": "通知壓制 22 + 防禦 14" }, { "type": "attack", "damage": 8, "hits": 5, "block": 0, "description": "暴雨轟炸 8x5" }] },
		{ "id": "ssrb-giant-gray", "display_name": "巨大 SSRB Gray", "max_hp": 118, "gold": 0, "scale": 1.5, "is_boss": true, "boss_danger_tag": "直傷壓迫", "boss_pattern": "直傷起手，接力量 buff，再用高傷攻防重擊收尾。", "boss_counterplay": "看到 buff 回合時優先補防或準備爆發，避免被 26 傷重擊直接穿透。", "boss_spike_turn": 3, "resource_base_path": "res://assets/enemies/ssrb/gray/", "actions": [{ "type": "attack", "damage": 18, "block": 0, "description": "衝撞 18" }, { "type": "buff", "damage": 0, "block": 0, "description": "巨大化：力量 +3", "status_id": "strength", "status_value": 3, "status_duration": 99 }, { "type": "attack_block", "damage": 26, "block": 8, "description": "爆炸衝撞 26 + 防禦 8" }] },
		{ "id": "ssrb-giant-camouflage", "display_name": "巨大 SSRB Camouflage", "max_hp": 112, "gold": 0, "scale": 1.5, "is_boss": true, "boss_danger_tag": "硬化循環", "boss_pattern": "普通攻擊後先堆高格擋，再進入高傷攻防循環。", "boss_counterplay": "不要把大招丟在硬化回合，等防禦結束再集中輸出。", "boss_spike_turn": 3, "resource_base_path": "res://assets/enemies/ssrb/camouflage/", "actions": [{ "type": "attack", "damage": 17, "block": 0, "description": "衝撞 17" }, { "type": "block", "damage": 0, "block": 14, "description": "硬化 14" }, { "type": "attack_block", "damage": 24, "block": 8, "description": "爆炸衝撞 24 + 防禦 8" }] },
		{ "id": "ssrb-giant-white", "display_name": "巨大 SSRB White", "max_hp": 122, "gold": 0, "scale": 1.5, "is_boss": true, "boss_danger_tag": "高防反打", "boss_pattern": "用高格擋撐住，再以更高數值的攻防重擊反打。", "boss_counterplay": "如果當回合打不穿護甲，優先轉防守，不要硬換血。", "boss_spike_turn": 3, "resource_base_path": "res://assets/enemies/ssrb/white/", "actions": [{ "type": "attack", "damage": 18, "block": 0, "description": "衝撞 18" }, { "type": "block", "damage": 0, "block": 20, "description": "硬化 20" }, { "type": "attack_block", "damage": 27, "block": 8, "description": "爆炸衝撞 27 + 防禦 8" }] },
		{ "id": "subaruto-duck", "display_name": "スバルトダック", "max_hp": 80, "gold": 0, "scale": 1.5, "is_boss": true, "boss_danger_tag": "干擾節奏", "boss_pattern": "普通攻擊後接虛弱干擾，再切回攻防混合壓迫玩家節奏。", "boss_counterplay": "被掛虛弱後不要硬拼輸出，先把手牌品質和防守補回來。", "boss_spike_turn": 3, "resource_base_path": "res://assets/enemies/subaruto_duck/", "fallback_resource_base_path": "res://assets/enemies/ssrb/white/", "actions": [{ "type": "attack", "damage": 10, "block": 0, "description": "攻擊 10" }, { "type": "debuff", "damage": 0, "block": 0, "description": "鴨式干擾：虛弱 2", "status_id": "weak", "status_value": 1, "status_duration": 2 }, { "type": "attack_block", "damage": 14, "block": 8, "description": "攻擊 14 + 防禦 8" }] },
		{ "id": "youtube-kun-core", "display_name": "YouTube-kun Core", "max_hp": 124, "gold": 0, "scale": 1.5, "is_boss": true, "content_group": "meme_boss", "boss_danger_tag": "事故干擾", "boss_pattern": "先上虛弱干擾，再開高格擋緩衝，最後用高傷攻防一波壓回來。", "boss_counterplay": "看到緩衝防線時先保牌，不要把高費爆發浪費在 22 格擋上。", "boss_spike_turn": 3, "resource_base_path": "res://assets/enemies/ssrb/camouflage/", "actions": [{ "type": "debuff", "damage": 0, "block": 0, "description": "平台事故：虛弱 2", "status_id": "weak", "status_value": 1, "status_duration": 2 }, { "type": "block", "damage": 0, "block": 22, "description": "緩衝防線 22" }, { "type": "attack_block", "damage": 27, "block": 10, "description": "壓縮重擊 27 + 防禦 10" }] },
		{ "id": "important-announcement", "display_name": "Important Announcement", "max_hp": 116, "gold": 0, "scale": 1.5, "is_boss": true, "content_group": "meme_boss", "boss_danger_tag": "蓄力爆發", "boss_pattern": "先倒數蓄力，再用易傷壓迫，最後進入 27 傷的大爆發回合。", "boss_counterplay": "倒數與易傷回合先守住血線，確保爆發回合前仍有格擋或減傷資源。", "boss_spike_turn": 3, "resource_base_path": "res://assets/enemies/ssrb/white/", "actions": [{ "type": "block", "damage": 0, "block": 18, "description": "重大告知倒數 18" }, { "type": "debuff", "damage": 0, "block": 0, "description": "全場屏息：易傷 2", "status_id": "vulnerable", "status_value": 1, "status_duration": 2 }, { "type": "attack", "damage": 27, "block": 0, "description": "壓力爆發 27" }] }
	]
	relics = [
		{ "id": "cheer-lightstick", "name": "應援螢光棒", "description": "戰鬥開始時獲得 3 點格擋。", "pool": "common", "source_rules": ["elite", "chest", "shop", "event", "debug"], "hooks": ["combat_start"], "hook": "combat_start", "effect": "block", "amount": 3 },
		{ "id": "duck-whistle", "name": "鴨鴨哨子", "description": "每場戰鬥第一次打出 0/1 費牌時，抽 1 張牌並獲得 2 點格擋。每回合第一次準備下一擊追加傷害時，獲得 3 點格擋。", "pool": "common", "source_rules": ["elite", "chest", "shop", "event", "debug"], "hooks": ["first_cheap_card_played"], "hook": "first_cheap_card_played", "cost_max": 1, "effect": "draw", "amount": 1, "effects": [{ "effect": "draw", "amount": 1 }, { "effect": "block", "amount": 2 }], "trigger": "next_attack_bonus_added", "limit": "once_per_turn", "condition": { "bonus_amount_at_least": 1 }, "trigger_effects": [{ "effect": "block", "amount": 3 }], "archetype_tags": ["cheap_chain", "tempo_block"], "role_tags": ["bridge", "defense"] },
		{ "id": "shishiro-crosshair", "name": "獅白準星", "description": "每場戰鬥第一次打出 2 費牌時，額外造成 3 點傷害。每回合第一次從棄牌堆取回攻擊牌時，獲得 4 點格擋。", "pool": "elite", "source_rules": ["elite", "chest", "debug"], "hooks": ["first_two_cost_played"], "hook": "first_two_cost_played", "effect": "bonus_damage", "amount": 3, "trigger": "discard_retrieved", "limit": "once_per_turn", "condition": { "retrieved_kind": "attack" }, "trigger_effects": [{ "effect": "block", "amount": 4 }], "archetype_tags": ["two_cost_burst", "fortress_counter"], "role_tags": ["payoff", "defense"] },
		{ "id": "energy-drink", "name": "開場能量飲", "description": "戰鬥開始時獲得 1 點能量。", "pool": "common", "source_rules": ["elite", "chest", "shop", "debug"], "hooks": ["combat_start"], "hook": "combat_start", "effect": "energy", "amount": 1 },
		{ "id": "healing-chat", "name": "聊天室補給", "description": "每個玩家回合開始時回復 1 HP，持續整場戰鬥。", "pool": "event", "source_rules": ["event", "debug"], "hooks": ["turn_start"], "hook": "turn_start", "effect": "heal", "amount": 1 },
		{ "id": "golden-superchat", "name": "金色 Superchat", "description": "戰鬥獎勵額外獲得 10 Gold。", "pool": "common", "source_rules": ["elite", "chest", "event", "debug"], "hooks": ["battle_reward"], "hook": "battle_reward", "effect": "gold_bonus", "amount": 10 },
		{ "id": "shop-coupon", "name": "商店折價券", "description": "商店移除卡服務降低 10 Gold。", "pool": "shop", "source_rules": ["shop", "debug"], "hooks": ["shop_enter"], "hook": "shop_enter", "effect": "shop_discount", "amount": 10 },
		{ "id": "route-stamp", "name": "推塔集章卡", "description": "進入非戰鬥房間時獲得 5 Gold。", "pool": "event", "source_rules": ["event", "chest", "debug"], "hooks": ["room_enter"], "hook": "room_enter", "effect": "room_gold", "amount": 5 },
		{ "id": "boss-spotlight", "name": "終局聚光燈", "description": "Boss 戰開始時獲得 2 層力量。", "pool": "boss", "source_rules": ["boss", "debug"], "hooks": ["combat_start"], "hook": "combat_start", "effect": "strength", "amount": 2 },
		{ "id": "yagoo-best-girl", "name": "YAGOO is Best Girl", "description": "進入非戰鬥房間時獲得 8 Gold。", "pool": "event", "source_rules": ["event", "boss", "debug"], "hooks": ["room_enter"], "hook": "room_enter", "effect": "room_gold", "amount": 8 },
		{ "id": "shishiro-button", "name": "Shishiro Button", "description": "每場戰鬥第一次打出 2 費牌時，額外造成 5 點傷害。", "pool": "elite", "source_rules": ["elite", "chest", "debug"], "hooks": ["first_two_cost_played"], "hook": "first_two_cost_played", "effect": "bonus_damage", "amount": 5 },
		{ "id": "superchat-reading", "name": "Superchat Reading", "description": "戰鬥獎勵額外獲得 12 Gold。", "pool": "common", "source_rules": ["elite", "chest", "event", "debug"], "hooks": ["battle_reward"], "hook": "battle_reward", "effect": "gold_bonus", "amount": 12 },
		{ "id": "x-funds-wallet", "name": "X Funds Wallet", "description": "商店移除卡服務降低 15 Gold。", "pool": "shop", "source_rules": ["shop", "debug"], "hooks": ["shop_enter"], "hook": "shop_enter", "effect": "shop_discount", "amount": 15 },
		{ "id": "ada-tv", "name": "Ada TV", "description": "進入非戰鬥房間時獲得 6 Gold。", "pool": "event", "source_rules": ["event", "chest", "debug"], "hooks": ["room_enter"], "hook": "room_enter", "effect": "room_gold", "amount": 6 },
		{ "id": "pamomi-signal", "name": "Pamomi Signal", "description": "每個玩家回合開始時回復 1 HP。", "pool": "event", "source_rules": ["event", "debug"], "hooks": ["turn_start"], "hook": "turn_start", "effect": "heal", "amount": 1 },
		{ "id": "blue-wave-badge", "name": "Blue Wave Badge", "description": "戰鬥開始時獲得 2 點格擋與 1 點能量。", "pool": "common", "source_rules": ["elite", "chest", "shop", "event", "debug"], "hooks": ["combat_start"], "hook": "combat_start", "effect": "energy", "amount": 1, "effects": [{ "effect": "block", "amount": 2 }, { "effect": "energy", "amount": 1 }] },
		{ "id": "unarchived-archive", "name": "Unarchived Archive", "description": "每場戰鬥第一次打出標記牌時，抽 1 張牌並獲得 1 點能量。每回合第一次建立攻擊臨時牌時，回復 Laplus 4 HP。", "pool": "boss", "source_rules": ["boss", "chest", "debug"], "hooks": ["first_marker_card_played"], "hook": "first_marker_card_played", "effect": "draw", "amount": 1, "effects": [{ "effect": "draw", "amount": 1 }, { "effect": "energy", "amount": 1 }], "trigger": "temporary_card_created", "limit": "once_per_turn", "condition": { "temporary_card_kind": "attack", "has_summon": true }, "trigger_effects": [{ "effect": "summon_heal", "amount": 4 }], "archetype_tags": ["marker_loop", "route_explore", "laplus_guard"], "role_tags": ["bridge", "defense"] },
		{ "id": "blood-pressure-meter", "name": "YAGOO Blood Pressure Meter", "description": "戰鬥開始時獲得 1 層力量。", "pool": "elite", "source_rules": ["elite", "boss", "debug"], "hooks": ["combat_start"], "hook": "combat_start", "effect": "strength", "amount": 1 }
	]
	events = _build_events()
	map_nodes = [
		{ "id": "start", "type": "start", "label": "開始" },
		{ "id": "enemy-1", "type": "battle", "label": "小怪 1", "enemy_id": "ssrb-gray" },
		{ "id": "event-1", "type": "event", "label": "事件 1", "event_id": "holostar-sponsor", "title": "遇到流離失所的 HoloStar 成員", "description": "是否要贊助資源給他", "body": "一位看起來剛結束長途漂流的 HoloStar 成員需要補給。你可以用 Gold 幫忙整備，也可以用自己的體力換來對方珍藏的 relic。" },
		{ "id": "enemy-2", "type": "battle", "label": "小怪 2", "enemy_id": "ssrb-guard-tutor" },
		{ "id": "chest", "type": "chest", "label": "寶箱" },
		{ "id": "elite-1", "type": "elite", "label": "菁英", "elite_enemy_ids": ["ssrb-duo-gray-camouflage", "ssrb-duo-gray-white", "ssrb-duo-camouflage-white", "ssrb-duo-gold-glitch", "ssrb-scaling-clock", "ak-idol-unit", "kedama-elite"] },
		{ "id": "shop", "type": "shop", "label": "商店" },
		{ "id": "event-2", "type": "event", "label": "事件 2", "event_id": "stream-incident-support", "title": "直播事故支援", "description": "突發狀況需要臨時幫手", "body": "塔內的直播設備突然亂成一團。你可以消耗體力協助收拾並獲得 Gold，也可以留下備用牌，讓接下來的路線更穩。" },
		{ "id": "enemy-3", "type": "battle", "label": "小怪 3", "enemy_id": "ssrb-striker-intent" },
		{ "id": "campfire", "type": "campfire", "label": "篝火" },
		{ "id": "enemy-4", "type": "battle", "label": "小怪 4", "enemy_id": "ssrb-gray" },
		{ "id": "event-3", "type": "event", "label": "事件 3", "event_id": "fan-cheer-prep", "title": "粉絲應援整隊", "description": "要把現場應援整理成資源嗎", "body": "一群粉絲正把應援道具堆成小山。你可以花 Gold 換一件可用的 relic，也可以幫忙整理現場並獲得少量 Gold。" },
		{ "id": "enemy-5", "type": "battle", "label": "小怪 5", "enemy_id": "ssrb-debuff-check" },
		{ "id": "boss", "type": "boss", "label": "Boss", "boss_enemy_ids": ["subaruto-duck", "ssrb-giant-gray", "ssrb-giant-camouflage", "ssrb-giant-white", "youtube-kun-core", "important-announcement"] }
	]
	_apply_v3_metadata()

func get_character(id: String) -> Dictionary:
	return find_character(id)

func get_enemy(id: String) -> Dictionary:
	return find_enemy(id)

func find_character(id: String) -> Dictionary:
	for character in characters:
		if str(character.get("id", "")) == id:
			return character
	return {}

func find_enemy(id: String) -> Dictionary:
	for enemy in enemies:
		if str(enemy.get("id", "")) == id:
			return enemy
	return {}

func find_card(id: String) -> Dictionary:
	var upgraded := id.ends_with("+")
	var base_id := id.substr(0, id.length() - 1) if upgraded else id
	var card: Dictionary = {}
	for card_def in cards:
		if str(card_def.get("id", "")) == base_id:
			card = card_def.duplicate(true)
			break
	if card.is_empty():
		return {}
	if upgraded:
		card["id"] = id
		card["name"] = "%s+" % str(card["name"])
		if card.has("upgrade_effects"):
			card["effects"] = card["upgrade_effects"].duplicate(true)
			card["description"] = str(card.get("upgrade_description", _describe_effects(card["effects"])))
			for effect in card["effects"]:
				_tag_effect_metadata(effect)
		else:
			for effect in card["effects"]:
				match str(effect.get("type", "")):
					"damage", "block":
						effect["amount"] = int(effect.get("amount", 0)) + 2
					"draw":
						effect["amount"] = int(effect.get("amount", 0)) + 1
					"draw_if_status":
						effect["amount"] = int(effect.get("amount", 0)) + 1
					"status":
						effect["value"] = int(effect.get("value", effect.get("amount", 0))) + 1
						effect["amount"] = int(effect.get("amount", 0)) + 1
			card["description"] = _describe_effects(card["effects"])
	return card

func get_card(id: String) -> Dictionary:
	return find_card(id)

func _describe_effects(effects: Array) -> String:
	var parts: Array[String] = []
	for effect in effects:
		match str(effect.get("type", "")):
			"damage":
				var hits := int(effect.get("hits", 1))
				if hits > 1:
					parts.append("造成 %d 點傷害 %d 次" % [int(effect.get("amount", 0)), hits])
				else:
					parts.append("造成 %d 點傷害" % int(effect.get("amount", 0)))
			"block":
				parts.append("獲得 %d 點格擋" % int(effect.get("amount", 0)))
			"draw":
				parts.append("抽 %d 張牌" % int(effect.get("amount", 0)))
			"draw_from_discard":
				var kind := str(effect.get("kind", ""))
				var kind_text := "指定類型" if kind == "" else kind
				parts.append("從棄牌堆取回 %d 張 %s 牌" % [int(effect.get("amount", 1)), kind_text])
			"next_attack_bonus":
				parts.append("下一張攻擊牌追加 %d 點傷害" % int(effect.get("amount", 0)))
			"temporary_card":
				parts.append("建立 %d 張臨時牌" % int(effect.get("amount", 1)))
			"draw_if_status":
				parts.append("若%s有%s，抽 %d 張牌" % [_target_label(str(effect.get("target", "enemy"))), _status_label(str(effect.get("status_id", ""))), int(effect.get("amount", 0))])
			"energy":
				parts.append("獲得 %d 點能量" % int(effect.get("amount", 0)))
			"status":
				parts.append(_describe_status_effect(effect))
			"conditional":
				parts.append("若達成條件，%s" % _describe_effects(effect.get("effects", [])).trim_suffix("。"))
			"summon_heal":
				parts.append("回復 Laplus %d HP" % int(effect.get("amount", 0)))
			"summon_hp_damage":
				var base := int(effect.get("base", 0))
				var per_hp := int(effect.get("per_hp", 1))
				if per_hp == 1:
					parts.append("造成 %d 點傷害，並追加等同 Laplus HP 的傷害" % base)
				else:
					parts.append("造成 %d 點傷害，並追加 Laplus HP x%d 的傷害" % [base, per_hp])
	return "%s。" % "，".join(parts)

func _describe_status_effect(effect: Dictionary) -> String:
	var status_id := str(effect.get("status_id", ""))
	var value := int(effect.get("value", effect.get("amount", 0)))
	var duration := int(effect.get("duration", 1))
	match status_id:
		"strength":
			return "獲得 %d 層力量" % value
		"weak":
			return "給予 %d 回合虛弱" % duration
		"vulnerable":
			return "給予 %d 回合易傷" % duration
		"regen":
			return "獲得 %d 回合回復 %d" % [duration, value]
		"marker":
			return "給予 %d 層標記" % duration
	return "套用 %s %d" % [status_id, value]

func _target_label(target: String) -> String:
	return "玩家" if target == "player" else "敵人"

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

func get_relic(id: String) -> Dictionary:
	return find_relic(id)

func find_relic(id: String) -> Dictionary:
	for relic in relics:
		if str(relic.get("id", "")) == id:
			return relic
	return {}

func resolve_cards(ids: Array[String]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in ids:
		result.append(get_card(id))
	return result

func get_event(id: String) -> Dictionary:
	for event_def in events:
		if str(event_def.get("id", "")) == id:
			return event_def
	return {}

func get_chapter_start_event(chapter_id: String) -> Dictionary:
	if chapter_id == CHAPTER_2_ID:
		return _chapter_2_support_desk_event()
	return {}

func draft_chapter_start_options(chapter_id: String, seed: int, current_gold: int = 0, curse_count: int = 0) -> Array[Dictionary]:
	var event_def := get_chapter_start_event(chapter_id)
	var available_options: Array[Dictionary] = []
	for option_variant in event_def.get("options", []):
		var option: Dictionary = option_variant
		if _chapter_start_option_available(option, current_gold):
			available_options.append(option.duplicate(true))
	var low_risk: Array[Dictionary] = []
	var resource_heavy: Array[Dictionary] = []
	var others: Array[Dictionary] = []
	for option in available_options:
		var risk_tier := str(option.get("risk_tier", "medium"))
		if risk_tier == "low":
			low_risk.append(option)
		elif option.get("tags", []).has("resource") or risk_tier == "high":
			resource_heavy.append(option)
		else:
			others.append(option)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var drafted: Array[Dictionary] = []
	_pick_weighted_option(low_risk, drafted, rng, curse_count)
	_pick_weighted_option(resource_heavy, drafted, rng, curse_count)
	var remaining := available_options.duplicate(true)
	while drafted.size() < 3 and not remaining.is_empty():
		_pick_weighted_option(remaining, drafted, rng, curse_count)
	return drafted

func generate_random_map(seed: int, chapter_id: String = CHAPTER_1_ID) -> Dictionary:
	var generator = RandomMapGeneratorScript.new()
	return generator.generate_map(self, seed, chapter_id)

func _chapter_2_support_desk_event() -> Dictionary:
	return {
		"id": "chapter-2-support-desk",
		"screen_id": "chapter_start_event",
		"chapter_id": CHAPTER_2_ID,
		"title": "Holo Support Desk",
		"description": "進入演算法深層前整理牌組與資源。",
		"body": "第一章 Boss 後，臨時支援台打開。選一項進入第二章前的整理方案。",
		"tags": ["chapter_start", "support"],
		"options": [
			{ "option_id": "support-claim-relic", "label": "領取支援 relic", "risk_tier": "low", "weight": 6, "tags": ["relic", "resource"], "outcomes": [{ "action": "grant_relic", "source": "event" }] },
			{ "option_id": "support-gold-dead-air", "label": "接受演算法補助：獲得 Gold 120，加入 Dead Air", "risk_tier": "high", "weight": 4, "tags": ["gold", "curse", "resource"], "outcomes": [{ "action": "gain_gold", "amount": 120 }, { "action": "add_card", "card_id": "curse-dead-air" }] },
			{ "option_id": "support-gold-bad-connection", "label": "接受不穩定贊助：獲得 Gold 140，加入 Bad Connection", "risk_tier": "high", "weight": 3, "tags": ["gold", "curse", "resource"], "outcomes": [{ "action": "gain_gold", "amount": 140 }, { "action": "add_card", "card_id": "curse-bad-connection" }] },
			{ "option_id": "support-gold-comment-fire", "label": "開放留言加速：獲得 Gold 110，加入 Comment Fire", "risk_tier": "high", "weight": 4, "tags": ["gold", "curse", "resource"], "outcomes": [{ "action": "gain_gold", "amount": 110 }, { "action": "add_card", "card_id": "curse-comment-fire" }] },
			{ "option_id": "support-remove-card", "label": "整理牌組：移除 1 張牌", "risk_tier": "low", "weight": 5, "tags": ["remove"], "outcomes": [{ "action": "remove_card", "amount": 1 }] },
			{ "option_id": "support-upgrade-card", "label": "強化核心牌：升級 1 張牌", "risk_tier": "low", "weight": 5, "tags": ["upgrade"], "outcomes": [{ "action": "upgrade_card", "amount": 1 }] },
			{ "option_id": "support-relic-for-curse", "label": "簽下深層合約：取得 relic，加入隨機 curse", "risk_tier": "high", "weight": 2, "tags": ["relic", "curse", "resource"], "outcomes": [{ "action": "grant_relic", "source": "event" }, { "action": "add_random_curse", "amount": 1 }] },
			{ "option_id": "support-gold-for-hp-cap", "label": "購買安全通行：失去 Gold 60，Max HP +6", "risk_tier": "medium", "weight": 3, "tags": ["max_hp"], "requirements": [{ "stat": "gold", "min": 60 }], "outcomes": [{ "action": "gain_gold", "amount": -60 }, { "action": "increase_max_hp", "amount": 6 }] }
		]
	}

func _chapter_start_option_available(option: Dictionary, current_gold: int) -> bool:
	for requirement in option.get("requirements", []):
		if str(requirement.get("stat", "")) == "gold" and current_gold < int(requirement.get("min", 0)):
			return false
	return true

func _pick_weighted_option(options: Array[Dictionary], drafted: Array[Dictionary], rng: RandomNumberGenerator, curse_count: int) -> void:
	var candidates: Array[Dictionary] = []
	var total_weight := 0
	for option in options:
		if _draft_has_option(drafted, str(option.get("option_id", ""))):
			continue
		var weight := int(option.get("weight", 1))
		if curse_count >= 2 and option.get("tags", []).has("curse"):
			weight = max(1, weight / 2)
		candidates.append({ "option": option, "weight": weight })
		total_weight += weight
	if candidates.is_empty():
		return
	var roll := rng.randi_range(1, total_weight)
	var cursor := 0
	for candidate in candidates:
		cursor += int(candidate["weight"])
		if roll <= cursor:
			var selected_option: Dictionary = candidate["option"]
			drafted.append(selected_option.duplicate(true))
			return

func _draft_has_option(drafted: Array[Dictionary], option_id: String) -> bool:
	for option in drafted:
		if str(option.get("option_id", "")) == option_id:
			return true
	return false

func _build_events() -> Array[Dictionary]:
	var base_events: Array[Dictionary] = [
		{
			"id": "holostar-sponsor",
			"title": "遇到流離失所的 HoloStar 成員",
			"description": "是否要贊助資源給他",
			"body": "一位看起來剛結束長途漂流的 HoloStar 成員需要補給。",
			"tags": ["heal", "relic"],
			"options": [
				{ "label": "贊助 30 Gold：回復 12 HP", "requirements": [{ "stat": "gold", "min": 30 }], "outcomes": [{ "action": "gain_gold", "amount": -30 }, { "action": "heal", "amount": 12 }] },
				{ "label": "分出體力：失去 8 HP，取得 relic", "outcomes": [{ "action": "lose_hp", "amount": 8 }, { "action": "grant_relic", "source": "event" }] }
			]
		},
		{
			"id": "stream-incident-support",
			"title": "直播事故支援",
			"description": "突發狀況需要臨時幫手",
			"body": "塔內的直播設備突然亂成一團。",
			"tags": ["gold", "card"],
			"options": [
				{ "label": "協助收拾：失去 6 HP，獲得 Gold 35", "outcomes": [{ "action": "lose_hp", "amount": 6 }, { "action": "gain_gold", "amount": 35 }] },
				{ "label": "留下備用牌：加入 1 張角色卡", "outcomes": [{ "action": "add_card", "amount": 1 }] }
			]
		},
		{
			"id": "fan-cheer-prep",
			"title": "粉絲應援整隊",
			"description": "要把現場應援整理成資源嗎",
			"body": "一群粉絲正把應援道具堆成小山。",
			"tags": ["relic", "gold"],
			"options": [
				{ "label": "投入 40 Gold：取得 relic", "requirements": [{ "stat": "gold", "min": 40 }], "outcomes": [{ "action": "gain_gold", "amount": -40 }, { "action": "grant_relic", "source": "event" }] },
				{ "label": "整理應援：獲得 Gold 25", "outcomes": [{ "action": "gain_gold", "amount": 25 }] }
			]
		},
		{
			"id": "archive-cleanup",
			"title": "剪輯檔案整理",
			"description": "移除一張拖慢節奏的牌",
			"body": "你找到一疊過期剪輯素材，整理後牌組變得更乾淨。",
			"tags": ["remove", "gold"],
			"options": [
				{ "label": "花 35 Gold：移除 1 張牌", "requirements": [{ "stat": "gold", "min": 35 }], "outcomes": [{ "action": "gain_gold", "amount": -35 }, { "action": "remove_card", "amount": 1 }] },
				{ "label": "賣出素材：獲得 Gold 20", "outcomes": [{ "action": "gain_gold", "amount": 20 }] }
			]
		},
		{
			"id": "training-stream",
			"title": "突發練習台",
			"description": "用體力換一張更適合角色的牌",
			"body": "臨時開台練習雖然消耗體力，但能讓節奏更明確。",
			"tags": ["card", "heal"],
			"options": [
				{ "label": "加練：失去 7 HP，加入 1 張角色卡", "outcomes": [{ "action": "lose_hp", "amount": 7 }, { "action": "add_card", "amount": 1 }] },
				{ "label": "保守調整：回復 8 HP", "outcomes": [{ "action": "heal", "amount": 8 }] }
			]
		},
		{
			"id": "quiet-merch-booth",
			"title": "安靜的周邊攤",
			"description": "用風險換一件奇妙 relic",
			"body": "攤位上只剩幾件未標價的周邊，攤主示意你自己決定代價。",
			"tags": ["relic", "remove"],
			"options": [
				{ "label": "承擔疲勞：失去 10 HP，取得 relic", "outcomes": [{ "action": "lose_hp", "amount": 10 }, { "action": "grant_relic", "source": "event" }] },
				{ "label": "整理攤位：移除 1 張牌", "outcomes": [{ "action": "remove_card", "amount": 1 }] }
			]
		},
		{
			"id": "important-announcement-countdown",
			"title": "重大告知倒數",
			"description": "壓力很高，但也可能提前看清路線",
			"body": "舞台燈突然轉暗，所有人都盯著倒數。你可以承受壓力換取稀有資源，或先穩住呼吸。",
			"tags": ["risk", "relic"],
			"options": [
				{ "label": "確認公告：失去 9 HP，取得 relic", "outcomes": [{ "action": "lose_hp", "amount": 9 }, { "action": "grant_relic", "source": "event" }] },
				{ "label": "先深呼吸：回復 10 HP", "outcomes": [{ "action": "heal", "amount": 10 }] }
			]
		},
		{
			"id": "en-curse-incident",
			"title": "EN Curse 事故台",
			"description": "技術事故換來臨時支援",
			"body": "設備突然全體不合作。你可以收拾殘局拿到 Gold，也可以把事故剪成一張可用的牌。",
			"tags": ["gold", "card"],
			"options": [
				{ "label": "救場剪輯：失去 5 HP，獲得 Gold 45", "outcomes": [{ "action": "lose_hp", "amount": 5 }, { "action": "gain_gold", "amount": 45 }] },
				{ "label": "留下備案：加入 1 張角色卡", "outcomes": [{ "action": "add_card", "amount": 1 }] }
			]
		},
		{
			"id": "twitter-jail",
			"title": "Twitter Jail",
			"description": "暫時停手整理牌組",
			"body": "發言被迫冷卻，反而有時間清掉拖慢節奏的牌。",
			"tags": ["remove", "gold"],
			"options": [
				{ "label": "安靜整理：移除 1 張牌", "outcomes": [{ "action": "remove_card", "amount": 1 }] },
				{ "label": "付費解鎖：花 25 Gold，加入 1 張角色卡", "requirements": [{ "stat": "gold", "min": 25 }], "outcomes": [{ "action": "gain_gold", "amount": -25 }, { "action": "add_card", "amount": 1 }] }
			]
		},
		{
			"id": "pineapple-pizza-war",
			"title": "Pineapple Pizza War",
			"description": "選邊站會改變這輪牌組方向",
			"body": "披薩議題讓現場分成兩派。攻勢派帶來火力，守備派帶來穩定。",
			"tags": ["card", "heal"],
			"options": [
				{ "label": "加入攻勢派：失去 4 HP，加入 1 張角色卡", "outcomes": [{ "action": "lose_hp", "amount": 4 }, { "action": "add_card", "amount": 1 }] },
				{ "label": "加入守備派：回復 6 HP，獲得 Gold 10", "outcomes": [{ "action": "heal", "amount": 6 }, { "action": "gain_gold", "amount": 10 }] }
			]
		},
		{
			"id": "superchat-time",
			"title": "Superchat Time",
			"description": "把熱度轉成金錢或牌組品質",
			"body": "聊天室突然刷起一片彩色訊息。你可以直接收下 Gold，也可以把資源投入牌組整理。",
			"tags": ["gold", "remove"],
			"options": [
				{ "label": "讀取訊息：獲得 Gold 50", "outcomes": [{ "action": "gain_gold", "amount": 50 }] },
				{ "label": "整理回饋：花 30 Gold，移除 1 張牌", "requirements": [{ "stat": "gold", "min": 30 }], "outcomes": [{ "action": "gain_gold", "amount": -30 }, { "action": "remove_card", "amount": 1 }] }
			]
		},
		{
			"id": "unarchived-karaoke",
			"title": "Unarchived Karaoke",
			"description": "不能留下完整紀錄，但能留下戰鬥節奏",
			"body": "短暫演出讓隊伍精神集中。沒有任何歌詞被記錄，只剩下一段可用的節奏。",
			"tags": ["card", "relic"],
			"options": [
				{ "label": "記住節奏：加入 1 張角色卡", "outcomes": [{ "action": "add_card", "amount": 1 }] },
				{ "label": "保存片段：失去 6 HP，取得 relic", "outcomes": [{ "action": "lose_hp", "amount": 6 }, { "action": "grant_relic", "source": "event" }] }
			]
		},
		{
			"id": "zen-loss-scene",
			"title": "全損現場",
			"description": "高風險整理，換取高價值補償",
			"body": "眼前的素材差點全數消失。你可以承擔損失換取補償，或保守離開。",
			"tags": ["risk", "gold"],
			"options": [
				{ "label": "硬救回來：失去 12 HP，獲得 Gold 70", "outcomes": [{ "action": "lose_hp", "amount": 12 }, { "action": "gain_gold", "amount": 70 }] },
				{ "label": "保守離開：回復 5 HP", "outcomes": [{ "action": "heal", "amount": 5 }] }
			]
		},
		{
			"id": "sudden-raid",
			"title": "突發 RAID",
			"description": "流量湧入，必須立刻接戰",
			"body": "聊天室突然湧入大量觀眾，氣氛變得不可控。你可以硬接這波流量，或花 Gold 請人協助控場。",
			"tags": ["battle", "risk"],
			"options": [
				{ "label": "硬接 RAID：進入額外戰鬥", "outcomes": [{ "action": "start_battle", "enemy_pool": "normal" }] },
				{ "label": "請 MOD 控場：失去 Gold 25", "outcomes": [{ "action": "gain_gold", "amount": -25 }] }
			]
		},
		{
			"id": "algorithm-punishment",
			"title": "演算法冷處理",
			"description": "沒有戰鬥，但資源會被吃掉",
			"body": "推薦流量突然消失，準備好的資源被迫拿去補洞。這不是立即危險，但會讓後面路線更緊。",
			"tags": ["risk", "gold"],
			"options": [
				{ "label": "補救曝光：失去 Gold 35", "outcomes": [{ "action": "gain_gold", "amount": -35 }] },
				{ "label": "硬撐內容：失去 9 HP", "outcomes": [{ "action": "lose_hp", "amount": 9 }] }
			]
		},
		{
			"id": "cursed-rebroadcast",
			"title": "重播事故",
			"description": "可以換錢，但會留下髒東西",
			"body": "不重要，先做效果。",
			"tags": ["risk", "curse"],
			"options": [
				{ "label": "硬上重播：獲得 Gold 60，加入 1 張 curse", "outcomes": [{ "action": "gain_gold", "amount": 60 }, { "action": "add_card", "card_id": "curse-dead-air" }] },
				{ "label": "直接放棄：失去 8 HP", "outcomes": [{ "action": "lose_hp", "amount": 8 }] }
			]
		},
		{
			"id": "fine-print-contract",
			"title": "贊助合約附註",
			"description": "條件很差，但東西是真的",
			"body": "不重要，先做效果。",
			"tags": ["risk", "relic"],
			"options": [
				{ "label": "簽下去：取得 relic，加入 1 張 curse", "outcomes": [{ "action": "grant_relic", "source": "event" }, { "action": "add_card", "card_id": "curse-bad-connection" }] },
				{ "label": "撤回條款：失去 Gold 25", "outcomes": [{ "action": "gain_gold", "amount": -25 }] }
			]
		},
		{
			"id": "moderation-collapse",
			"title": "控場崩潰",
			"description": "要嘛接戰，要嘛失血",
			"body": "不重要，先做效果。",
			"tags": ["battle", "risk"],
			"options": [
				{ "label": "自己收：進入額外戰鬥", "outcomes": [{ "action": "start_battle", "enemy_pool": "mid" }] },
				{ "label": "燒資源止血：失去 Gold 30", "outcomes": [{ "action": "gain_gold", "amount": -30 }] }
			]
		},
		{
			"id": "overbooked-stage",
			"title": "超載舞台",
			"description": "可以修牌，也可以被打",
			"body": "不重要，先做效果。",
			"tags": ["battle", "remove"],
			"options": [
				{ "label": "硬拆設備：失去 8 HP，移除 1 張牌", "outcomes": [{ "action": "lose_hp", "amount": 8 }, { "action": "remove_card", "amount": 1 }] },
				{ "label": "直接上台：進入額外戰鬥並加入 1 張 curse", "outcomes": [{ "action": "add_card", "card_id": "curse-comment-fire" }, { "action": "start_battle", "enemy_pool": "late" }] }
			]
		},
		{
			"id": "holomoms-support",
			"title": "HoloMoms 應援",
			"description": "穩定恢復與安心補給",
			"body": "溫柔的應援讓整隊重新整理呼吸。這不是爆發資源，而是穩定推進的補給。",
			"tags": ["heal", "gold"],
			"options": [
				{ "label": "接受便當：回復 16 HP", "outcomes": [{ "action": "heal", "amount": 16 }] },
				{ "label": "整理補給：獲得 Gold 25", "outcomes": [{ "action": "gain_gold", "amount": 25 }] }
			]
		}
	]
	base_events.append_array(_build_chapter_2_events())
	return base_events

func _build_chapter_2_events() -> Array[Dictionary]:
	return [
		{
			"id": "deep-archive-cleanup",
			"chapter_id": CHAPTER_2_ID,
			"title": "深層封存整理",
			"description": "移除負擔，或把封存資源換成 Gold",
			"body": "演算法深層的封存室堆滿過期片段。整理它會花時間，但牌組會更乾淨。",
			"tags": ["remove", "gold"],
			"options": [
				{ "label": "清掉冗餘：移除 1 張牌", "outcomes": [{ "action": "remove_card", "amount": 1 }] },
				{ "label": "賣出片段：獲得 Gold 45，加入 1 張 Dead Air", "outcomes": [{ "action": "gain_gold", "amount": 45 }, { "action": "add_card", "card_id": "curse-dead-air" }] }
			]
		},
		{
			"id": "recommendation-auction",
			"chapter_id": CHAPTER_2_ID,
			"title": "推薦欄競標",
			"description": "高經濟起跑，但會留下演算法負債",
			"body": "推薦欄突然開出一個短暫曝光位。價格很漂亮，條款卻很細。",
			"tags": ["gold", "curse"],
			"options": [
				{ "label": "買下曝光：獲得 Gold 90，加入 Bad Connection", "outcomes": [{ "action": "gain_gold", "amount": 90 }, { "action": "add_card", "card_id": "curse-bad-connection" }] },
				{ "label": "跳過競標：回復 10 HP", "outcomes": [{ "action": "heal", "amount": 10 }] }
			]
		},
		{
			"id": "notification-filter",
			"chapter_id": CHAPTER_2_ID,
			"title": "通知過濾器",
			"description": "升級核心牌，或硬吃一波通知壓力",
			"body": "過濾器能把通知整理成節奏，但啟用過程會讓系統短暫暴露。",
			"tags": ["upgrade", "risk"],
			"options": [
				{ "label": "調整過濾器：升級 1 張牌，失去 6 HP", "outcomes": [{ "action": "upgrade_card", "amount": 1 }, { "action": "lose_hp", "amount": 6 }] },
				{ "label": "關閉通知：獲得 Gold 30", "outcomes": [{ "action": "gain_gold", "amount": 30 }] }
			]
		},
		{
			"id": "algorithm-side-door",
			"chapter_id": CHAPTER_2_ID,
			"title": "演算法側門",
			"description": "可拿 relic，但要接受 curse 代價",
			"body": "一條側門通往短期優勢。門邊的小字說，代價會在抽牌時回來。",
			"tags": ["relic", "curse"],
			"options": [
				{ "label": "走側門：取得 relic，加入 Comment Fire", "outcomes": [{ "action": "grant_relic", "source": "event" }, { "action": "add_card", "card_id": "curse-comment-fire" }] },
				{ "label": "原路前進：Max HP +4", "outcomes": [{ "action": "increase_max_hp", "amount": 4 }] }
			]
		},
		{
			"id": "comment-moderation-room",
			"chapter_id": CHAPTER_2_ID,
			"title": "留言控場室",
			"description": "處理留言洪流，或進入額外戰鬥",
			"body": "控場工具卡住了。你可以花資源修好，也可以直接用戰鬥壓過留言洪流。",
			"tags": ["battle", "gold"],
			"options": [
				{ "label": "直接控場：進入額外戰鬥", "outcomes": [{ "action": "start_battle", "enemy_pool": "chapter_2_mid" }] },
				{ "label": "付費修復：失去 Gold 35，回復 12 HP", "requirements": [{ "stat": "gold", "min": 35 }], "outcomes": [{ "action": "gain_gold", "amount": -35 }, { "action": "heal", "amount": 12 }] }
			]
		},
		{
			"id": "bitrate-rescue",
			"chapter_id": CHAPTER_2_ID,
			"title": "碼率救援",
			"description": "保守補血或承擔風險換牌組品質",
			"body": "畫面一度糊成一團。穩住品質能換來下一段路線的喘息。",
			"tags": ["heal", "upgrade"],
			"options": [
				{ "label": "穩住訊號：回復 14 HP", "outcomes": [{ "action": "heal", "amount": 14 }] },
				{ "label": "壓縮重整：失去 8 HP，升級 1 張牌", "outcomes": [{ "action": "lose_hp", "amount": 8 }, { "action": "upgrade_card", "amount": 1 }] }
			]
		},
		{
			"id": "sponsor-fine-print",
			"chapter_id": CHAPTER_2_ID,
			"title": "贊助細則",
			"description": "Gold 很多，但 curse 會考驗後續 Boss",
			"body": "贊助方提出的數字很漂亮，只是每一行小字都像在往牌組裡塞雜訊。",
			"tags": ["gold", "curse"],
			"options": [
				{ "label": "簽收：獲得 Gold 100，加入隨機 curse", "outcomes": [{ "action": "gain_gold", "amount": 100 }, { "action": "add_random_curse", "amount": 1 }] },
				{ "label": "拒絕：移除 1 張牌", "outcomes": [{ "action": "remove_card", "amount": 1 }] }
			]
		},
		{
			"id": "archive-shortcut",
			"chapter_id": CHAPTER_2_ID,
			"title": "封存捷徑",
			"description": "跳過一段風險，換取長期污染",
			"body": "捷徑能避開眼前壓力，但通道裡全是過期資料。",
			"tags": ["risk", "curse"],
			"options": [
				{ "label": "走捷徑：回復 18 HP，加入 Dead Air", "outcomes": [{ "action": "heal", "amount": 18 }, { "action": "add_card", "card_id": "curse-dead-air" }] },
				{ "label": "清路前進：失去 7 HP，獲得 Gold 35", "outcomes": [{ "action": "lose_hp", "amount": 7 }, { "action": "gain_gold", "amount": 35 }] }
			]
		}
	]

func _apply_v3_metadata() -> void:
	for card in cards:
		_tag_card_metadata(card)
	for relic in relics:
		_tag_relic_metadata(relic)
	for event_def in events:
		_tag_event_metadata(event_def)
	for enemy in enemies:
		_tag_enemy_metadata(enemy)

func _tag_card_metadata(card: Dictionary) -> void:
	var card_id := str(card.get("id", ""))
	card["implementation_status"] = "implemented"
	if card_id.begins_with("curse-"):
		card["rarity"] = "curse"
	elif card_id in ["subaru-strike", "subaru-guard", "botan-shot", "botan-cover", "azki-map-shot", "azki-guard"]:
		card["rarity"] = "starter"
	elif not card.has("rarity"):
		card["rarity"] = "common"
	if card_id.begins_with("botan-"):
		card["character"] = "botan"
	elif card_id.begins_with("azki-"):
		card["character"] = "azki"
	elif card_id.begins_with("curse-"):
		card["character"] = "neutral"
	else:
		card["character"] = "subaru"
	card["content_group"] = str(card.get("kind", "card"))
	card["meme_source"] = _card_meme_source(card_id)
	if not card.has("archetype_tags"):
		card["archetype_tags"] = _default_card_archetype_tags(card)
	if not card.has("role_tags"):
		card["role_tags"] = _default_card_role_tags(card)
	if not card.has("floor_band"):
		card["floor_band"] = _default_card_floor_band(card)
	if not card.has("upgrade_plan"):
		card["upgrade_plan"] = _default_upgrade_plan(card)
	card["expected_art_path"] = _expected_card_art_path(card)
	if not card.has("art_status"):
		card["art_status"] = _default_card_art_status(card)
	if not card.has("art_path"):
		card["art_path"] = _resolved_card_art_path(card)
	for effect in card.get("effects", []):
		_tag_effect_metadata(effect)
	for effect in card.get("upgrade_effects", []):
		_tag_effect_metadata(effect)

func _tag_effect_metadata(effect: Dictionary) -> void:
	if str(effect.get("status_id", "")) != "" and str(effect.get("status_icon_path", "")) == "":
		effect["status_icon_path"] = _status_icon_path(str(effect.get("status_id", "")))
	if str(effect.get("type", "")) == "conditional":
		for nested_effect in effect.get("effects", []):
			_tag_effect_metadata(nested_effect)
	if str(effect.get("type", "")) == "temporary_card":
		var temp_card: Dictionary = effect.get("card", {})
		for nested_effect in temp_card.get("effects", []):
			_tag_effect_metadata(nested_effect)

func _default_card_archetype_tags(card: Dictionary) -> Array[String]:
	var card_id := str(card.get("id", ""))
	if card_id.begins_with("azki-"):
		if _card_applies_status(card, "marker") or _card_has_effect(card, "draw_if_status"):
			return ["marker_loop"]
		return ["route_explore"]
	if card_id.begins_with("botan-"):
		if int(card.get("cost", 0)) >= 2:
			return ["two_cost_burst"]
		if _card_applies_status(card, "weak") or _card_applies_status(card, "vulnerable"):
			return ["precision_control"]
		return ["fortress_counter"]
	if int(card.get("cost", 0)) <= 1:
		return ["cheap_chain", "tempo_block"]
	return ["multi_hit_strength"]

func _default_card_role_tags(card: Dictionary) -> Array[String]:
	var roles: Array[String] = []
	match str(card.get("kind", "")):
		"attack":
			roles.append("payoff")
		"defense":
			roles.append("defense")
		"support":
			roles.append("bridge")
		"mixed":
			roles.append("bridge")
	if _card_has_effect(card, "status"):
		roles.append("setup")
	if _card_has_effect(card, "draw") or _card_has_effect(card, "energy") or _card_has_effect(card, "draw_if_status"):
		roles.append("utility")
	if bool(card.get("exhaust_on_play", false)) or bool(card.get("unplayable", false)):
		roles.append("risk")
	if roles.is_empty():
		roles.append("utility")
	return roles

func _default_card_floor_band(card: Dictionary) -> String:
	match str(card.get("rarity", "common")):
		"starter", "common":
			return "early"
		"uncommon":
			return "mid"
		"rare":
			return "late"
		"curse":
			return "mid"
	return "early"

func _default_upgrade_plan(card: Dictionary) -> String:
	if card.has("upgrade_effects"):
		return "專屬升級：依牌張定位提高穩定度、爆發或條件 payoff。"
	return "通用升級：damage/block +2，draw 類 +1，status 類提高數值。"

func _default_card_art_status(card: Dictionary) -> String:
	if str(card.get("art_path", "")) != "":
		return "formal"
	if str(card.get("expected_art_path", "")) == "":
		return "generated_later"
	return "prototype_placeholder" if str(card.get("character", "")) == "azki" else "formal"

func _expected_card_art_path(card: Dictionary) -> String:
	var card_id := str(card.get("id", ""))
	if CARD_ART_PATHS.has(card_id):
		return str(CARD_ART_PATHS[card_id])
	var character_id := str(card.get("character", ""))
	match character_id:
		"azki":
			return "res://assets/cards/azki/%s.png" % card_id
		"subaru":
			return "res://assets/cards/subaru/%s.png" % card_id
		"botan":
			return "res://assets/cards/botan/%s.png" % card_id
	return ""

func _resolved_card_art_path(card: Dictionary) -> String:
	if str(card.get("art_status", "")) == "prototype_placeholder":
		return ""
	var expected_path := _expected_card_art_path(card)
	if expected_path != "" and ResourceLoader.exists(expected_path):
		return expected_path
	return ""

func _tag_relic_metadata(relic: Dictionary) -> void:
	var relic_id := str(relic.get("id", ""))
	relic["implementation_status"] = "implemented"
	relic["rarity"] = str(relic.get("pool", "common"))
	relic["content_group"] = str(relic.get("effect", "relic"))
	relic["meme_source"] = _relic_meme_source(relic_id)
	if not relic.has("archetype_tags"):
		relic["archetype_tags"] = _default_relic_archetype_tags(relic)
	if not relic.has("role_tags"):
		relic["role_tags"] = _default_relic_role_tags(relic)
	if not relic.has("expected_icon_path"):
		relic["expected_icon_path"] = str(RELIC_ICON_PATHS.get(relic_id, ""))
	if not relic.has("icon_status"):
		relic["icon_status"] = "integrated" if ResourceLoader.exists(str(relic["expected_icon_path"])) else "prototype_placeholder"
	if not relic.has("icon_path"):
		relic["icon_path"] = str(RELIC_ICON_PATHS.get(relic_id, ""))

func _tag_event_metadata(event_def: Dictionary) -> void:
	var event_id := str(event_def.get("id", ""))
	event_def["implementation_status"] = "implemented"
	event_def["rarity"] = "event"
	event_def["content_group"] = str(event_def.get("tags", ["event"])[0])
	event_def["meme_source"] = _event_meme_source(event_id)

func _tag_enemy_metadata(enemy: Dictionary) -> void:
	var enemy_id := str(enemy.get("id", ""))
	enemy["implementation_status"] = "implemented"
	enemy["rarity"] = "boss" if bool(enemy.get("is_boss", false)) else ("elite" if str(enemy.get("tier", "")) == "elite" else "common")
	if not enemy.has("content_group"):
		enemy["content_group"] = "boss" if bool(enemy.get("is_boss", false)) else ("elite" if str(enemy.get("tier", "")) == "elite" else "enemy")
	enemy["meme_source"] = _enemy_meme_source(enemy_id)
	if not enemy.has("pressure_tags"):
		enemy["pressure_tags"] = _default_enemy_pressure_tags(enemy)
	if not enemy.has("tests_archetypes"):
		enemy["tests_archetypes"] = _default_enemy_tests_archetypes(enemy)
	if not enemy.has("counterplay_hint"):
		enemy["counterplay_hint"] = _default_enemy_counterplay_hint(enemy)
	for action in enemy.get("actions", []):
		if not action.has("icon_path"):
			action["icon_path"] = str(INTENT_ICON_PATHS.get(str(action.get("type", "")), ""))
		if str(action.get("status_id", "")) != "" and str(action.get("status_icon_path", "")) == "":
			action["status_icon_path"] = _status_icon_path(str(action.get("status_id", "")))

func _card_has_effect(card: Dictionary, effect_type: String) -> bool:
	for effect in card.get("effects", []):
		if str(effect.get("type", "")) == effect_type:
			return true
		if str(effect.get("type", "")) == "conditional":
			for nested_effect in effect.get("effects", []):
				if str(nested_effect.get("type", "")) == effect_type:
					return true
	return false

func _card_applies_status(card: Dictionary, status_id: String) -> bool:
	for effect in card.get("effects", []):
		if str(effect.get("type", "")) == "status" and str(effect.get("status_id", "")) == status_id:
			return true
		if str(effect.get("type", "")) == "conditional":
			for nested_effect in effect.get("effects", []):
				if str(nested_effect.get("type", "")) == "status" and str(nested_effect.get("status_id", "")) == status_id:
					return true
	return false

func _default_relic_archetype_tags(relic: Dictionary) -> Array[String]:
	match str(relic.get("hook", "")):
		"first_cheap_card_played":
			return ["cheap_chain", "tempo_block"]
		"first_two_cost_played":
			return ["two_cost_burst"]
		"first_marker_card_played":
			return ["marker_loop", "route_explore"]
		"turn_start":
			return ["tempo_block", "laplus_guard"]
	return ["general"]

func _default_relic_role_tags(relic: Dictionary) -> Array[String]:
	match str(relic.get("effect", "")):
		"block", "heal", "regen":
			return ["defense"]
		"energy", "draw":
			return ["bridge"]
		"bonus_damage", "strength":
			return ["payoff", "scaling"]
	return ["utility"]

func _default_enemy_pressure_tags(enemy: Dictionary) -> Array[String]:
	var tags: Array[String] = []
	for action in enemy.get("actions", []):
		match str(action.get("type", "")):
			"block":
				tags.append("anti_burst_into_block")
			"attack", "attack_block":
				tags.append("attack_intent_test")
			"debuff":
				tags.append("debuff_resilience")
			"buff":
				tags.append("scaling_clock")
	if tags.is_empty():
		tags.append("attack_intent_test")
	return tags

func _default_enemy_tests_archetypes(enemy: Dictionary) -> Array[String]:
	if bool(enemy.get("is_boss", false)):
		return ["cheap_chain", "two_cost_burst", "marker_loop"]
	if str(enemy.get("tier", "")) == "elite":
		return ["scaling", "burst_window"]
	return ["survival", "tempo"]

func _default_enemy_counterplay_hint(enemy: Dictionary) -> String:
	var tags: Array = enemy.get("pressure_tags", [])
	if tags.has("anti_burst_into_block"):
		return "看到防禦意圖時保留爆發，改用 setup、抽牌或防守銜接。"
	if tags.has("debuff_resilience"):
		return "被上虛弱或易傷前先穩血線，避免低品質回合硬拼。"
	if tags.has("scaling_clock"):
		return "敵人會越拖越強，優先建立 scaling 或找爆發窗口。"
	return "攻擊意圖明確時優先補足格擋，再安排 payoff。"

func _status_icon_path(status_id: String) -> String:
	return str(STATUS_ICON_PATHS.get(status_id, ""))

func _card_meme_source(card_id: String) -> String:
	var sources := {
		"subaru-duck-tempo": "Subaru Duck",
		"subaru-teetee-guard": "Teetee",
		"subaru-desk-reaction": "Desk-kun -10 HP",
		"subaru-blue-wave": "Blue Wave",
		"subaru-new-oshi-call": "X is my new oshi",
		"botan-button-check": "Shishiro Button",
		"botan-clean-scope": "Clean your badges",
		"botan-calm-burst": "Botan calm fire",
		"botan-precise-cover": "Botan defense line",
		"botan-funds-prepared": "X Funds"
	}
	return str(sources.get(card_id, "legacy-card:%s" % card_id))

func _relic_meme_source(relic_id: String) -> String:
	var sources := {
		"yagoo-best-girl": "YAGOO is best girl",
		"shishiro-button": "Shishiro Button",
		"superchat-reading": "Superchat Time",
		"x-funds-wallet": "X Funds",
		"ada-tv": "Ada TV",
		"pamomi-signal": "id:entity Pamomi ver.",
		"blue-wave-badge": "Blue Wave",
		"unarchived-archive": "Unarchived Karaoke",
		"blood-pressure-meter": "YAGOO Blood Pressure"
	}
	return str(sources.get(relic_id, "legacy-relic:%s" % relic_id))

func _event_meme_source(event_id: String) -> String:
	var sources := {
		"important-announcement-countdown": "Important Announcement",
		"en-curse-incident": "EN Curse",
		"twitter-jail": "Twitter Jail",
		"pineapple-pizza-war": "Pineapple Pizza War",
		"superchat-time": "Superchat Time",
		"unarchived-karaoke": "Unarchived Karaoke",
		"zen-loss-scene": "Zen-loss",
		"holomoms-support": "HoloMoms"
	}
	return str(sources.get(event_id, "legacy-event:%s" % event_id))

func _enemy_meme_source(enemy_id: String) -> String:
	var sources := {
		"youtube-kun": "YouTube-kun",
		"desk-kun": "Desk-kun -10 HP",
		"announcement-shadow": "Important Announcement",
		"ak-idol-unit": "AKB48 to AK-47",
		"youtube-kun-core": "YouTube-kun",
		"important-announcement": "Important Announcement"
	}
	return str(sources.get(enemy_id, "legacy-enemy:%s" % enemy_id))
