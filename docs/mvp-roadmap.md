# Godot MVP 開發 Roadmap

最近更新：2026-05-09

本文件整理 `oshi-no-tower-godot` 從目前固定路線 MVP 走向類 Slay the Spire 結構的開發順序。原則是先保住可玩閉環，再逐步資料化，不一次導入所有大系統。

## 目前基準

目前已存在：

- Subaru / Botan playable。
- 固定路線：開始、小怪 1、事件 1、小怪 2、寶箱、菁英、商店、事件 2、小怪 3、篝火、小怪 4、事件 3、小怪 5、Boss、結算。
- 普通敵人：SSRB Gray、SSRB Camouflage、SSRB White。
- Boss pool：Subaruto Duck 與巨大 SSRB 變體。
- Combat UI、Debug 快捷鍵、headless 測試與 QA checklist。

目前先不做：

- 完整 relic 系統。
- 完整事件系統；目前已有固定事件池 v1。
- 隨機地圖。
- 多 Act。
- Power / Status / Curse 引擎。
- 多 playable 角色擴張。

## Phase 1：內容骨架與卡牌矩陣

目標：先定 Hololive 粉絲遊戲語氣、角色定位與卡牌內容方向。

產出：

- `docs/hololive-content-bible.md`
- `docs/card-pool-matrix.md`
- README 與狀態文件入口更新

完成條件：

- Subaru / Botan 的玩法差異能用文件講清楚。
- 卡牌命名與效果設計有共同規則。
- 下一輪要新增哪些卡牌，不需要重新討論大方向。

## Phase 2：卡牌資料擴充與角色差異

目標：在不新增大系統的前提下，讓 Subaru / Botan 的卡池更像兩個不同角色。

建議實作：

- 每位角色擴充到約 10-12 張可獎勵卡。
- 仍只使用現有效果：damage、block、draw、energy。
- 調整寶箱與商店卡牌來源，避免兩個角色拿到太不符合定位的牌。
- RuntimeDatabase 測試補上卡牌池數量、角色獎勵池與商店池檢查。

完成條件：

- Subaru 玩起來偏低費、多段、節奏型。
- Botan 玩起來偏高單發、防禦穩、射擊感。
- 不新增 Power / Status / Curse 也能感覺出角色差異。

## Phase 3：戰鬥獎勵流程改善

目標：讓戰鬥後獎勵更接近正式 run，而不是只靠目前簡化寶箱與商店。

建議實作：

- 普通戰勝利後可以進入卡牌獎勵選擇。
- Boss 戰勝利後仍進通關，但可預留 Boss reward flow。
- 卡牌獎勵允許 skip。
- Reward pool 先依角色分流，不做稀有度抽樣。

完成條件：

- 玩家能從戰鬥自然成長牌組。
- 固定路線仍可完整通關。
- 不引入 relic / potion / rare pity 等額外複雜度。

## Phase 4：簡版 relic

狀態：v0 已接入。

目標：驗證 relic 作為 run-level 被動效果的骨架。

建議實作：

- 已先做 3 個 Hololive 主題 relic。
- 目前只支援少數 hook：on pickup、combat start、turn start、card played。
- 目前先從寶箱、菁英戰、商店或 debug 給 relic，不做完整掉落池。
- UI 先用文字列表顯示，不急著做 icon 與 tooltip。

完成條件：

- RunState 能保存 relic。
- CombatEngine 能吃到簡單 relic modifier。
- 測試能驗證 relic hook 不破壞既有戰鬥。

## Phase 5：簡版 event

狀態：v1 已接入，目前固定路線放入 3 個不同事件節點。

目標：驗證非戰鬥決策節點。

建議實作：

- 先做固定事件節點或 debug event。
- 每個事件 2-3 個選項。
- outcome 先支援 lose hp、gain gold、add card、remove card、heal。
- 不做完整 `?` 節點解析與 Act event pool。

完成條件：

- 事件能修改 RunState。
- 事件結果能回到地圖流程。
- 至少 3 個 Hololive 主題事件可玩。

## Phase 6：隨機地圖

目標：在內容池足夠後，把固定路線替換成可 seed 重現的路線圖。

建議實作：

- 先做短版地圖，不必立刻 15 層。
- 支援 monster、chest、shop、campfire、boss。
- 固定事件池與 relic fallback 已穩定後，再進入 seed-based 短版隨機地圖。
- 保留 debug 快捷鍵，避免驗收變慢。

完成條件：

- 同 seed 可生成相同地圖。
- 玩家只能前往可連線節點。
- 固定路線可以作為 fallback 或 debug route 保留。

## 每輪固定驗收

每輪程式改動後固定跑：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_engine_tests.gd
```

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/runtime_database_tests.gd
```

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_ui_layout_tests.gd
```

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --quit
```

手動驗收依 `docs/manual-qa-checklist.md`，但完整流程只在卡牌、獎勵、地圖或 run state 改動後重跑。
