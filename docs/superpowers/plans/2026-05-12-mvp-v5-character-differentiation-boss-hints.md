# MVP-v5 角色差異強化與 Boss 提示改善 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 強化 Subaru / Botan / AZKi 的玩法辨識度，並補上最小版 Boss 提示，讓目前已可玩的 16 floor MVP 在不擴大系統範圍的前提下更容易感受到角色差異與 Boss 壓力。

**Architecture:** 本階段不重做整個戰鬥系統，而是在既有 `RuntimeDatabase` 卡池與角色被動上補明確的玩法支點，並讓 `CombatEngine` 與 `Game.gd` 顯示這些支點的觸發結果。Boss 提示則維持資料驅動，將提示文案與簡短危險標籤掛在 Boss 定義或地圖節點，避免把規則硬編在 UI。所有變更都必須先由 headless tests 失敗再補最小實作。

**Tech Stack:** Godot 4.x、GDScript、動態 UI (`scripts/Game.gd`、`scripts/ui/ActorStatusView.gd`)、headless tests (`tests/headless/*.gd`)

---

## Scope

- 包含：
  - 強化三位角色的玩法差異，但以調整既有卡/被動/少量資料欄位為主，不擴大量新卡圖需求。
  - 顯示角色差異的戰鬥提示，例如被動命中、標記追擊、2 費爆發、低費連段價值。
  - 在 map / combat / boss encounter 前加入最小可讀 Boss 提示。
  - 補強對應 headless tests 與狀態文件。
- 不包含：
  - AZKi 卡圖與 icon 補完。
  - 新增完整新狀態系統，例如 `burn`、`poison`、`stun`。
  - 重做 random map 長度或 encounter 分布。
  - 新增新 Act、存檔或大型 UI 重構。

## File Map

- Modify: `scripts/data/RuntimeDatabase.gd`
  - 角色被動、卡牌描述、Boss metadata、提示文字與最小玩法支點資料。
- Modify: `scripts/core/CombatEngine.gd`
  - 支援新的角色差異觸發邏輯與戰鬥內提示需要的 state。
- Modify: `scripts/core/CombatState.gd`
  - 若需要額外的當回合旗標或提示資料，在此補最小 state 欄位。
- Modify: `scripts/Game.gd`
  - 地圖 Boss 提示、Boss 戰前提示、戰鬥中角色特色提示文案。
- Modify: `scripts/ui/ActorStatusView.gd`
  - 若提示需要穩定的 icon / label 位置，在此補最小渲染支援。
- Modify: `tests/headless/runtime_database_tests.gd`
  - 驗證角色卡池輪廓、Boss 提示 metadata、文案存在性。
- Modify: `tests/headless/combat_engine_tests.gd`
  - 驗證角色差異強化後的被動/支點規則。
- Modify: `tests/headless/combat_ui_layout_tests.gd`
  - 驗證 Boss 提示與戰鬥提示不破版、角色提示可見。
- Modify: `docs/godot-mvp-status.md`
  - 紀錄 MVP-v5 下一步規劃與實作結果。

## Design Constraints

- Subaru 應更明顯偏向低費、連段、抽牌、以節奏換取防禦/補牌。
- Botan 應更明顯偏向 2 費爆發、瞄準、控制後收頭。
- AZKi 應更明顯偏向標記鋪場、追擊、標記帶來的額外收益。
- Boss 提示必須短，不可把完整攻略文字塞進畫面。
- 不依賴 AZKi 正式卡圖才能完成這一輪。

### Task 1: 鎖定角色差異支點與 Boss 提示資料

**Files:**
- Modify: `scripts/data/RuntimeDatabase.gd`
- Test: `tests/headless/runtime_database_tests.gd`
- Docs: `docs/godot-mvp-status.md`

- [ ] **Step 1: 先寫會失敗的資料測試**

```gdscript
func _test_character_identity_hooks_and_boss_hints_are_defined() -> void:
	var subaru := database.get_character("subaru")
	var botan := database.get_character("botan")
	var azki := database.get_character("azki")
	_expect_not_empty(str(subaru.get("identity_hint", "")), "Subaru 應定義角色定位提示")
	_expect_not_empty(str(botan.get("identity_hint", "")), "Botan 應定義角色定位提示")
	_expect_not_empty(str(azki.get("identity_hint", "")), "AZKi 應定義角色定位提示")
	_expect_true(subaru.get("passive", {}).has("preview_text"), "Subaru 被動需提供戰鬥提示短文")
	_expect_true(botan.get("passive", {}).has("preview_text"), "Botan 被動需提供戰鬥提示短文")
	_expect_true(azki.get("passive", {}).has("preview_text"), "AZKi 被動需提供戰鬥提示短文")
	for boss_id in ["subaruto-duck", "youtube-kun-core", "important-announcement", "ssrb-giant-gray", "ssrb-giant-camouflage", "ssrb-giant-white"]:
		var boss := database.get_enemy(boss_id)
		_expect_not_empty(str(boss.get("boss_hint", "")), "%s 需提供 Boss 提示" % boss_id)
		_expect_not_empty(str(boss.get("boss_danger_tag", "")), "%s 需提供 Boss 危險標籤" % boss_id)
```

- [ ] **Step 2: 跑資料測試確認目前會失敗**

Run:

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/runtime_database_tests.gd
```

Expected: FAIL，缺少 `identity_hint`、`preview_text`、`boss_hint` 或 `boss_danger_tag`。

- [ ] **Step 3: 在資料層補最小支點欄位**

```gdscript
{
	"id": "subaru",
	"display_name": "大空昴",
	"identity_hint": "低費連段與節奏守備，適合靠抽牌與連打滾雪球。",
	"passive": {
		"id": "subaru-tempo-guard",
		"name": "節奏守備",
		"description": "每回合第一次打出 0/1 費牌時獲得 3 點格擋。",
		"preview_text": "先用 0/1 費牌起手，白拿格擋再展開。"
	}
}

{
	"id": "important-announcement",
	"display_name": "Important Announcement",
	"is_boss": true,
	"boss_danger_tag": "蓄力爆發",
	"boss_hint": "看到倒數或易傷回合時，優先保資源準備接 30 傷重擊。"
}
```

- [ ] **Step 4: 重新跑資料測試確認通過**

Run:

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/runtime_database_tests.gd
```

Expected: PASS，或只剩既有 `ObjectDB instances leaked` warning。

- [ ] **Step 5: Commit**

```bash
git add scripts/data/RuntimeDatabase.gd tests/headless/runtime_database_tests.gd docs/godot-mvp-status.md
git commit -m "docs: define v5 identity hooks and boss hint metadata"
```

### Task 2: 用最小規則拉開三位角色的玩法辨識度

**Files:**
- Modify: `scripts/core/CombatEngine.gd`
- Modify: `scripts/core/CombatState.gd`
- Modify: `scripts/data/RuntimeDatabase.gd`
- Test: `tests/headless/combat_engine_tests.gd`
- Test: `tests/headless/runtime_database_tests.gd`

- [ ] **Step 1: 先寫會失敗的規則測試**

```gdscript
func _test_subaru_signature_turn_rewards_cheap_chain() -> void:
	var passive := database.get_character("subaru").get("passive", {})
	var state = engine.start_combat(30, 30, _deck(["subaru-draw-breath", "subaru-duck-tempo", "subaru-strike"]), _enemy_attack(1, 40), [], false, passive)
	engine.try_play_card(state, 0)
	engine.try_play_card(state, 0)
	_expect_true(state.player_block >= 3, "Subaru 低費起手後應維持明顯節奏收益")

func _test_botan_signature_turn_rewards_two_cost_finisher() -> void:
	var passive := database.get_character("botan").get("passive", {})
	var state = engine.start_combat(30, 30, _deck(["botan-funds-prepared", "botan-heavy-shot"]), _enemy_attack(1, 50), [], false, passive)
	engine.try_play_card(state, 0)
	engine.try_play_card(state, 0)
	_expect_true(state.enemy_hp <= 26, "Botan 應能清楚感受到 2 費收頭爆發")

func _test_azki_marker_payoff_remains_visible_after_follow_up_attack() -> void:
	var passive := database.get_character("azki").get("passive", {})
	var state = engine.start_combat(30, 30, _deck(["azki-map-search", "azki-map-shot"]), _enemy_attack(1, 30), [], false, passive)
	engine.try_play_card(state, 0)
	engine.try_play_card(state, 0)
	_expect_eq(state.enemy_hp, 23, "AZKi 應維持標記追擊的清楚回報")
	_expect_true(state.turn_events.size() >= 1, "AZKi 追擊應留下可供 UI 顯示的事件")
```

- [ ] **Step 2: 跑戰鬥規則測試確認失敗**

Run:

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_engine_tests.gd
```

Expected: FAIL，缺少 `turn_events`、角色支點不夠明確，或新斷言數值未命中。

- [ ] **Step 3: 以最小變更補規則與提示事件**

```gdscript
# scripts/core/CombatState.gd
var turn_events: Array[Dictionary] = []

# scripts/core/CombatEngine.gd
func _push_turn_event(state, event_id: String, text: String) -> void:
	state.turn_events.append({ "id": event_id, "text": text })

func _apply_card_played_passive(state, card: Dictionary) -> void:
	# 既有 passive 邏輯保留
	# 觸發時補 turn event，讓 Game.gd 可顯示「節奏守備」「狙擊開場」

func _trigger_enemy_marker_damage(state) -> void:
	# 既有標記額外傷害保留
	_push_turn_event(state, "azki-marker-payoff", "標記追擊：追加 2 傷害")
```

如需拉開差異但不新增大系統，優先調整既有卡牌數值與描述，而不是加很多新卡：

```gdscript
{ "id": "subaru-duck-tempo", "description": "造成 5 點傷害，抽 1 張牌。若本回合已觸發節奏守備，再獲得 2 點格擋。", ... }
{ "id": "botan-heavy-shot", "description": "造成 18 點傷害。若本回合已獲得易傷收益，追加 4 點傷害。", ... }
```

若採這種條件效果，必須同步在 `CombatEngine` 用明確旗標支援，不可只改文案。

- [ ] **Step 4: 跑規則測試與資料測試確認通過**

Run:

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_engine_tests.gd
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/runtime_database_tests.gd
```

Expected: PASS，既有 passive / marker / curse 規則不回歸。

- [ ] **Step 5: Commit**

```bash
git add scripts/core/CombatEngine.gd scripts/core/CombatState.gd scripts/data/RuntimeDatabase.gd tests/headless/combat_engine_tests.gd tests/headless/runtime_database_tests.gd
git commit -m "feat: strengthen character gameplay identities"
```

### Task 3: 接入最小版 Boss 提示與戰鬥中角色特色提示

**Files:**
- Modify: `scripts/Game.gd`
- Modify: `scripts/ui/ActorStatusView.gd`
- Test: `tests/headless/combat_ui_layout_tests.gd`

- [ ] **Step 1: 先寫會失敗的 UI 測試**

```gdscript
func _test_random_map_shows_boss_hint_summary() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame
	app.run_state.start_run(app.database, "subaru")
	app.show_map()
	await process_frame
	_expect_true(_screen_text(app).contains("Boss 提示"), "地圖畫面需顯示本局 Boss 提示")
	app.queue_free()

func _test_combat_shows_character_identity_hint() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	await process_frame
	app.run_state.start_run(app.database, "botan")
	app.start_combat(app.database.map_nodes[1])
	await process_frame
	_expect_true(_screen_text(app).contains("2 費爆發"), "戰鬥畫面需顯示角色特色短提示")
	app.queue_free()
```

- [ ] **Step 2: 跑 UI 測試確認目前失敗**

Run:

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_ui_layout_tests.gd
```

Expected: FAIL，畫面上尚未出現 Boss 提示或角色特色短提示。

- [ ] **Step 3: 在 map / combat 補最小提示**

```gdscript
# scripts/Game.gd
func _random_map_boss_hint() -> String:
	var boss := _random_map_boss_enemy()
	if boss.is_empty():
		return ""
	return "Boss 提示：[%s] %s" % [str(boss.get("boss_danger_tag", "")), str(boss.get("boss_hint", ""))]

func _character_identity_text() -> String:
	var character := database.get_character(run_state.character_id)
	return "玩法：%s" % str(character.get("identity_hint", ""))
```

建議顯示規則：

```gdscript
_add_label(_random_map_boss_hint(), Vector2(40, 74), Vector2(860, 26), 13, HORIZONTAL_ALIGNMENT_LEFT, Color(1.0, 0.88, 0.62))
_add_label(_character_identity_text(), Vector2(36, 138), Vector2(320, 42), 12, HORIZONTAL_ALIGNMENT_LEFT, Color(0.84, 0.94, 1.0))
```

如畫面過擠，優先把提示做成兩行內短文，不新增大型 panel。

- [ ] **Step 4: 跑 UI 測試確認版面仍穩定**

Run:

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_ui_layout_tests.gd
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --quit
```

Expected: PASS，提示存在且不擠壞現有 header、角色下方狀態列或 map scroll layout。

- [ ] **Step 5: Commit**

```bash
git add scripts/Game.gd scripts/ui/ActorStatusView.gd tests/headless/combat_ui_layout_tests.gd
git commit -m "feat: show boss hints and character identity guidance"
```

### Task 4: 補手動 QA 與狀態文件收尾

**Files:**
- Modify: `docs/godot-mvp-status.md`
- Optional Modify: `docs/manual-qa-checklist.md`

- [ ] **Step 1: 先補文件驗收點**

```md
- 需手動確認 Subaru 開局能明顯用 0/1 費牌起手滾節奏。
- 需手動確認 Botan 的 2 費攻擊回合有明顯爆發提示與收頭感。
- 需手動確認 AZKi 標記命中後，玩家能理解追擊額外傷害來自標記。
- 需手動確認 map 畫面可讀到本局 Boss 提示，且不影響節點點擊。
```

- [ ] **Step 2: 跑最小回歸測試**

Run:

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_engine_tests.gd
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/runtime_database_tests.gd
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_ui_layout_tests.gd
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --quit
```

Expected: 全數 PASS，僅可接受既有 `ObjectDB instances leaked` warning。

- [ ] **Step 3: 更新狀態文件**

```md
- 2026-05-12 已建立 `docs/superpowers/plans/2026-05-12-mvp-v5-character-differentiation-boss-hints.md`。
- 下一輪開發主題鎖定為角色差異強化與最小版 Boss 提示；AZKi 視覺補完待新圖完成後另行接線與驗收。
```

- [ ] **Step 4: Commit**

```bash
git add docs/godot-mvp-status.md docs/manual-qa-checklist.md docs/superpowers/plans/2026-05-12-mvp-v5-character-differentiation-boss-hints.md
git commit -m "docs: record v5 implementation plan and qa focus"
```

## Self-Review

- Spec coverage:
  - 角色差異強化：Task 1、Task 2
  - 最小版 Boss 提示：Task 1、Task 3
  - QA / 文件銜接：Task 4
- Placeholder scan:
  - 無 `TODO` / `TBD`
  - 每個 task 都含測試、實作、驗證與 commit
- Type consistency:
  - 規劃中的新欄位統一使用 `identity_hint`、`preview_text`、`boss_hint`、`boss_danger_tag`、`turn_events`

## Execution Notes

- 若實作時發現 `turn_events` 會讓 `CombatState` 過度膨脹，可退一步只記錄 `last_feedback_text`；但欄位名稱要全局一致，不可一半用 `turn_events`、一半改叫 `feedback_queue`。
- 若角色差異要靠條件卡牌效果而不是純數值調整，請先補 combat tests，再實作條件旗標，避免只改描述文字。
- AZKi 視覺補完不在本 plan 範圍內，除非新圖已完成且使用者明確要求一起接線。
