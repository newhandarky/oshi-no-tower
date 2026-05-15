# MVP 開發計畫（Godot 調整版）

本文件由 Web 版 `docs/mvp-development-plan.md` 搬入並調整。原始計畫描述 Web / Phaser 開發階段；目前改以 Godot 版現況為準。

## 1. MVP 目標

MVP 必須提供一段短流程、可完整遊玩的 run。

核心優先順序：

1. 完整遊戲流程可玩。
2. 每個必要節點都有實際功能。
3. 戰鬥流程清楚且穩定。
4. 角色與 Boss 在畫面上可辨識。
5. 達成 MVP 驗收後停止擴張。

## 2. 目前狀態

現行 Godot 版已完成：

- Godot 專案骨架。
- 主場景 `res://scenes/main.tscn`。
- 動態 UI 主流程 `scripts/Game.gd`。
- Runtime 資料庫 `scripts/data/RuntimeDatabase.gd`。
- Combat engine `scripts/core/CombatEngine.gd`。
- Subaru / Botan 可遊玩。
- 固定路線。
- 普通戰、Boss 戰、寶箱、商店、篝火、通關、失敗流程。
- Combat / Map 背景。
- SSRB 與 Subaruto Duck 敵人素材。
- 戰鬥資訊面板與卡牌顏色。
- Debug / 驗收快捷鍵。
- CombatEngine headless 測試。
- `README.md`、`AGENTS.md`、`docs/godot-mvp-status.md`。

## 3. 已完成階段

| 階段 | 狀態 | 備註 |
| --- | --- | --- |
| 規格補完 | 已完成 | 已由 Web 文件與 Godot 狀態文件承接。 |
| 專案骨架 | 已完成 | Godot 專案可 headless 載入。 |
| Placeholder 完整流程 | 已完成 | 目前已非純 placeholder。 |
| 戰鬥核心 | 已完成 MVP 版 | 已有 CombatEngine headless 測試。 |
| 卡牌與角色內容 | 已完成 MVP 版 | Subaru / Botan 定位已初步分化。 |
| 敵人、Boss、節點內容 | 已完成 MVP 版 | Boss 保留隨機選擇邏輯。 |
| 素材替換 | 已完成 MVP 版 | 主要角色、敵人、Boss、背景已接入。 |
| 驗收與 polish | 進行中 | 仍需實機視窗檢查與 UI 微調。 |

## 4. 下一步建議

### 4.1 擴充 Godot 測試

目前已補 `CombatEngine.gd` 的 headless 測試。後續可擴充：

- 完整路線流程測試。
- Debug 快捷鍵流程測試。
- RuntimeDatabase 資料完整性測試。
- 卡牌平衡 smoke test。

### 4.2 UI 實機驗收

用 Godot 視窗手動檢查：

- 戰鬥資訊面板是否清楚。
- 手牌區是否遮擋角色與背景。
- 卡牌文字是否太擠。
- Boss 名稱是否足夠明顯。
- Debug 提示是否影響正式遊玩畫面。

### 4.3 卡牌平衡第二輪

維持目前方向：

- Subaru：低費、多段、節奏型。
- Botan：高單發、防禦穩、射擊感。

暫時只調整現有卡，不新增複雜系統。

### 4.4 UI 結構整理

等戰鬥 UI 版面穩定後，再考慮把 `scripts/Game.gd` 的 UI helper 拆出，避免太早抽象造成來回改動。

## 5. 暫不做事項

- Relic。
- 隨機地圖。
- 事件。
- 存檔。
- 多 Act。
- 大型卡池。
- 正式平衡系統。
- Unity 移植。

## 6. 驗收流程

完整手動路線：

```text
開始 -> 小怪 1 -> 寶箱 -> 小怪 2 -> 商店 -> 小怪 3 -> 篝火 -> Boss -> 結算
```

快速驗收：

- `F2` 測 Subaru。
- `F3` 測 Botan。
- `F4` 測普通戰。
- `F5` / `F6` 測指定 Boss。
