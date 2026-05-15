# Godot V2 規劃

最近更新：2026-05-09

本文件根據目前 `docs/` 內的 MVP 狀態、Roadmap、隨機地圖 v1 規格、卡池矩陣、事件指南、遺物設計、狀態設計與手動 QA checklist，整理 `oshi-no-tower-godot` 的 V2 開發範圍。V2 的目標不是重做 MVP，而是把已可玩的固定路線 MVP 推進成更接近正式爬塔遊戲的短版可展示版本。

## 目前實作狀態

MVP-v2 已完成第一輪接入：

- Random map 已成為 Subaru / Botan 正常 run 主流程。
- RunState 已支援 active_map、map_seed、current_node_id、visited_node_ids、available_node_ids。
- Map UI 已能顯示 seed-based 節點、可到達狀態與 Boss 預告。
- Boss 戰使用 random map 生成時選定的 Boss id。
- CombatEngine 已支援 `strength`、`weak`、`vulnerable`、`regen`。
- Event pool 已資料化並擴到 6 個。
- Relic pool 已擴到 9 個，含 source_rules、pool、hooks metadata。
- 商店支援買卡、買 relic、移除卡。
- 篝火支援休息或升級卡牌。
- Boss 勝利後進入 Boss reward / run summary 前置畫面。
- 自動測試已新增 random run state、combat status、event / relic definition 覆蓋。

## V2 定位

V2 主軸：短版隨機地圖 run + 第一輪系統深度。

目前 MVP 已具備 Subaru / Botan、固定路線、普通戰、菁英、Boss pool、事件 v1、Relic v0、寶箱、商店、篝火、戰鬥後卡牌獎勵與 debug 驗收入口。V2 應該把 `RandomMapGenerator` 已完成的資料骨架接到正式 Map UI，並同步擴充內容池、run 成長、事件 / relic 資料模型與第一批簡版狀態效果，讓每局不只是路線不同，而是決策理由也不同。

V2 成功後，玩家應該可以：

- 選擇 Subaru 或 Botan 開始一場 seed-based 短版 run。
- 在地圖上看到多條可選路線，而不是只能沿固定線性節點前進。
- 只能點選目前節點連到的下一層節點。
- 提前看到本局 Boss 身分，並用路線、卡牌、relic 與商店決策準備 Boss 戰。
- 經歷普通戰、事件、菁英、寶箱、商店、篝火與 Boss，並完成通關或失敗流程。
- 在戰鬥中看到第一批簡版 buff / debuff / status icon 或文字列。
- 透過更完整的 relic / event / shop / reward 流程調整牌組與 run 方向。
- 打到至少 2 種有不同規則壓力的 Boss 或 Boss phase。
- 使用 debug 快捷鍵快速驗收固定戰鬥、事件、Boss、寶箱、商店與 relic 流程。

## 非目標

V2 擴大範圍，但仍不做以下內容，避免版本範圍失控：

- 多 Act。
- 存檔與繼續遊戲。
- 完整 Power / Curse 引擎。
- 完整藥水系統。
- 完整 Boss relic 大池與長期平衡。
- 複雜 rare pity 或升級卡獎勵。
- 新 playable 角色。
- 大規模 UI scene 拆分與完整架構重寫。
- 完整平衡定稿。

這些可以放到 V3 或更後面的版本。V2 可以引入小而明確的版本，例如簡版 status、簡版 boss reward、簡版 relic pool，但不要一次追求完整 Slay the Spire 規模。

## V2 範圍層級

V2 分成三個層級，避免「擴大」變成沒有邊界。

### 必做

- Random map 接入主流程。
- Boss 預告與固定 Boss id。
- RunState 支援 random map 節點推進。
- Map UI 顯示可選路線、不可到達節點與已走過節點。
- Event / Relic / Reward 的資料結構整理到足以擴充。
- 新增第一批內容池：event、relic、敵人 / Boss 行動變體。
- 手動 QA 與文件更新。

### 應做

- 第一批 status / buff / debuff：例如 `strength`、`weak`、`vulnerable`、`regen` 或其他 Hololive 主題狀態。
- 戰鬥 UI 顯示狀態列與 tooltip / 短描述。
- Boss 戰加入至少一個特殊節奏或 phase。
- 商店加入更明確的服務：移除卡、購買 relic、購買卡牌。
- 篝火加入第二個選項：休息或升級卡牌。
- Boss 戰後加入簡版高價值獎勵，例如稀有卡三選一或 Boss relic 三選一的最小版本。

### 可選

- Seed 輸入 UI。
- 簡版圖鑑 / run summary。
- 音效、按鈕 hover polish、更多背景差異。
- 更多角色專屬 relic。
- 更多事件戰鬥。

## V2 功能範圍

### 1. 隨機地圖接入主流程

現況：

- `scripts/data/RandomMapGenerator.gd` 已可用 seed 產生短版地圖。
- `RuntimeDatabase.generate_random_map(seed)` 已存在。
- `tests/headless/random_map_tests.gd` 已驗證同 seed 可重現、節點可連到 Boss、內容類型完整。
- `scripts/Game.gd` 的 Map UI 仍使用 `database.map_nodes` 與 `RunState.current_node_index`。

V2 要做：

- `RunState` 新增 run map 狀態，例如 `active_map`、`current_node_id`、`visited_node_ids`、`available_node_ids`、`map_seed`。
- 開始 run 時生成 random map，並把 `start` 設為目前節點。
- Map UI 改為讀取 active random map。
- 節點按鈕依 `floor` / `lane` 排版，顯示可點、已走過、不可到達三種狀態。
- 玩家完成節點後，更新目前節點與下一批可到達節點。
- 固定路線資料保留為 fallback，不刪除 `database.map_nodes`。

驗收條件：

- 同一 seed 的地圖節點與連線一致。
- 起點只能走到第一層可到達節點。
- 玩家不能點不可連線節點。
- 完成節點後可前往下一層連線節點。
- 可以沿任一路線打到 Boss 並進入結算。

### 2. Boss 預告與 run 方向

現況：

- Boss 節點會從 Subaruto Duck 與巨大 SSRB 變體中隨機。
- Debug 可用 `5` / `6` 指定 Boss 驗收。
- `RandomMapGenerator` 的 boss node 目前複製固定 boss 節點，實際進戰鬥時仍可能由 `Game.gd` 隨機挑選。

V2 要做：

- 生成 random map 時決定本局 Boss id，存到 boss node，例如 `enemy_id` 或 `selected_boss_enemy_id`。
- Map UI 顯示本局 Boss 名稱，讓玩家能提前知道終點。
- 正常路線進 Boss 時使用本局固定 Boss，不在進戰鬥當下再重新隨機。
- Debug Boss override 保留，但只影響 debug 入口，不污染正常 run。

驗收條件：

- 一場 run 的 Boss 從地圖預告到戰鬥畫面一致。
- 重新開始新 run 時 Boss 可再次隨機。
- `5` / `6` 仍能獨立驗收所有 Boss。

### 3. 路線風險與獎勵辨識

現況：

- 節點類型已有普通戰、事件、菁英、寶箱、商店、篝火與 Boss。
- 菁英戰有較多 Gold 與 relic。
- 寶箱、商店、事件可取得 card / gold / relic。

V2 要做：

- Map UI 用清楚的文字與色彩區分節點類型。
- 菁英、商店、篝火、Boss 在地圖上比普通戰更醒目。
- 節點 hover / 選取區域不必做複雜 tooltip，但按鈕文字要能看出節點類型。
- 路線設計維持短版：Boss 前 10-12 層，每層 2 個候選節點。

驗收條件：

- 玩家一眼可辨識普通戰、事件、菁英、寶箱、商店、篝火、Boss。
- 菁英路線看起來像高風險高報酬選項。
- 節點文字在 960x540 基準畫面不明顯重疊。

### 4. RunState 與固定路線 fallback

現況：

- `RunState` 只保存角色、線性節點 index、HP、Gold、deck、relic。
- Debug 快捷鍵多處依賴 `database.map_nodes` 的固定 index。

V2 要做：

- `RunState` 同時支援 random map 與固定路線 fallback。
- 新增 helper 取得目前節點、可到達節點、完成節點後的下一步。
- Debug 快捷鍵維持能直接進入指定畫面，不要求一定有 random map 上下文。
- 固定路線 fallback 可用於測試或緊急回退，但正常 `2` / `3` 開始 run 預設使用 random map。

驗收條件：

- `2` / `3` 開始的是 random map run。
- Debug `4` / `6` / `7` / `8` / `9` / `0` / `=` / `-` 不因 random map 狀態而壞掉。
- 固定路線資料測試仍通過。

### 5. V2 內容微擴充

V2 的內容擴充不只支撐隨機 run，也要讓玩家開始感覺到 deck building、路線風險與角色差異。

必做內容：

- Event pool 從 3 個擴到至少 6 個。
- Relic pool 從 3 個擴到至少 8 個。
- 普通敵人或普通敵人行動變體擴到至少 5 種 encounter。
- 菁英 encounter 至少 3 種，且不只是素材組合不同，行動壓力也不同。
- Boss pool 至少 2 種具有不同戰鬥規則壓力的 Boss。
- Subaru / Botan 各補 2-3 張能搭配 V2 新狀態或 relic 的卡牌。

應做內容：

- 每個角色至少有 2 個明確 build 方向。
- Event outcome 支援至少 6 種 action：gain gold、lose hp、heal、add card、remove card、grant relic。
- Relic hook 支援至少 6 種 timing：combat start、turn start、card played、battle reward、shop enter、room enter。
- 敵人 intent 至少分 attack、block、attack_block、debuff、buff / special。

驗收條件：

- 隨機 run 至少連續玩兩局時，路線與事件體感不完全相同。
- 新內容都能透過 RuntimeDatabase 或 headless 測試檢查資料完整性。
- 不破壞 Subaru / Botan 現有定位。

### 6. 簡版 Status / Buff / Debuff

現況：

- `CombatEngine` 目前主要支援 damage、block、draw、energy。
- 敵人行動目前是 attack / block / attack_block。
- 戰鬥 UI 目前顯示 HP、格擋、能量、抽牌、棄牌與意圖，尚未有正式狀態列。

V2 要做：

- 建立最小狀態資料模型，例如 `id`、`name`、`kind`、`value`、`duration`、`stack_mode`、`description`。
- 先支援少量公式型狀態：
  - `strength`：造成攻擊傷害增加。
  - `weak`：造成攻擊傷害降低。
  - `vulnerable`：受到攻擊傷害增加。
  - `regen` 或 Hololive 主題恢復狀態：回合開始恢復少量 HP。
- 玩家與敵人都能持有狀態。
- Combat UI 顯示狀態名稱與數值，icon 可先用文字或簡化符號，正式 icon 可延後。
- 敵人 intent 能預告 debuff / buff / special。

驗收條件：

- 狀態可套用、堆疊、衰減。
- 狀態會影響傷害或回合開始效果。
- UI 能清楚看到玩家與敵人的狀態。
- 自動測試覆蓋至少 strength、weak、vulnerable 的核心公式。

### 7. Event / Relic 資料化

現況：

- Event 邏輯目前主要寫在 `Game.gd` 的分支中。
- Relic v0 已有三個 hook，但發放與效果仍偏硬編碼。

V2 要做：

- 新增 event definition 結構，至少包含 `id`、`title`、`body`、`tags`、`options`、`outcomes`。
- Event option 使用標準 outcome action，而不是每個事件都寫一組專用 function。
- 新增 relic definition 欄位：`pool`、`tags`、`source_rules`、`hook` 或 `hooks`、`effect`、`amount`、`description`。
- Relic 發放依來源區分：elite、chest、shop、event、boss。
- relic 拿滿 fallback 保留，但應由發放服務統一處理。

驗收條件：

- 新增 event 不需要改大量 UI 分支。
- 新增 relic 不需要改多處戰鬥流程。
- RuntimeDatabase 測試可檢查 event option outcome 與 relic hook 合法性。

### 8. 商店、篝火與 Boss Reward 深化

現況：

- 商店可買卡牌與 relic。
- 篝火目前主要是恢復。
- Boss 勝利後直接通關。

V2 要做：

- 商店加入移除卡服務，價格先固定，例如 75 Gold。
- 商店卡牌與 relic 以本次進店生成的 inventory 顯示，不要每次 refresh 都完全重抽。
- 篝火加入休息 / 升級卡牌二選一。
- 卡牌可支援簡版 upgraded 數值，例如傷害 +2、格擋 +2、抽牌 +1 或費用降低只限少數牌。
- Boss 勝利後進入簡版 Boss reward 畫面：
  - 若仍是單 Act 短版，可顯示高價值卡牌獎勵與 run summary。
  - 若導入 Boss relic，先做 3 選 1、只影響當前短版 run 的最小版本。

驗收條件：

- 商店移除卡能正確修改 deck。
- 篝火升級卡能正確修改 deck 中指定卡牌。
- Boss 戰後不只是直接跳結算，而是有明確終局獎勵或 summary。

### 9. 手動 QA 與文件更新

V2 必須更新現有驗收入口，否則後續接手會不清楚目前是固定路線還是隨機地圖。

要更新：

- `docs/manual-qa-checklist.md`：新增 V2 random map 驗收區塊。
- `docs/godot-mvp-status.md`：更新下一階段方向與 V2 進度。
- `README.md`：等實作完成後更新啟動、Debug、目前功能描述。
- `docs/random-map-v1-plan.md`：若規格被 V2 實作取代，標註已接入主流程。

驗收條件：

- 新對話只讀 `AGENTS.md` 與 `docs/godot-mvp-status.md` 就能知道 V2 目前狀態。
- QA checklist 可明確區分固定路線 fallback 與 random map 正常流程。

## 建議實作階段

### Phase V2-1：資料狀態打底

目標：讓 `RunState` 能保存 random map run，但先不大改 UI。

工作：

- 在 `RunState` 加入 active map、seed、current node id、visited、available。
- 新增開始 random run 的方法。
- 新增取得 node by id、完成節點、取得可到達節點的 helper。
- 補 headless 測試驗證節點推進。

完成條件：

- 不進 Godot UI，也能測試 random map run state 從 start 推進到下一層。
- 現有四個 headless 測試仍通過。

### Phase V2-2：Map UI 接 random map

目標：讓正常開始 run 進入 random map UI。

工作：

- `Game.gd.show_map()` 改讀 active map。
- 依 floor / lane 排版節點。
- 只讓 available 節點可點。
- 點節點後依 type 進入戰鬥、事件、寶箱、商店或篝火。
- 完成節點後回到 map，更新下一層可選節點。

完成條件：

- Subaru / Botan 都能從 random map 開始並推進至少 3 層。
- 不可到達節點不能點。
- Debug 快捷鍵仍可使用。

### Phase V2-3：Boss 固定與預告

目標：讓每場 run 的 Boss 在地圖上先決定，並與戰鬥一致。

工作：

- random map 生成時選定 boss enemy id。
- Map UI 顯示本局 Boss 名稱。
- Boss 戰使用 node 上的 boss enemy id。
- 補測試確認 boss id 被保存。

完成條件：

- 地圖顯示的 Boss 與戰鬥敵人一致。
- 多次新 run 可看到不同 Boss。

### Phase V2-4：Status 與 Combat 深化

目標：引入第一批簡版 buff / debuff，讓敵人與卡牌不再只靠 damage / block 區分。

工作：

- 在 CombatState / CombatEngine 增加玩家與敵人狀態列表。
- 支援 `strength`、`weak`、`vulnerable`、`regen`。
- 更新傷害公式與回合開始 / 結束衰減。
- Combat UI 顯示狀態文字列。
- 新增測試覆蓋狀態套用與公式。

完成條件：

- 玩家與敵人都可持有狀態。
- 敵人可用 intent 預告 debuff / buff。
- 狀態不會破壞現有卡牌與 relic。

### Phase V2-5：Event / Relic 資料化

目標：降低新增內容時對 `Game.gd` 的硬編碼依賴。

工作：

- 建立 event definition 與 outcome action。
- 將現有 3 個 event 轉成資料驅動或半資料驅動。
- 擴充 relic definition 欄位與來源 pool。
- 建立 relic grant helper，統一處理 elite / chest / shop / event / boss。
- 補 RuntimeDatabase 測試。

完成條件：

- Event pool 至少 6 個。
- Relic pool 至少 8 個。
- 新 event / relic 有資料完整性測試。

### Phase V2-6：商店、篝火與 Boss Reward

目標：讓非戰鬥節點變成真正的 run 決策，而不是功能入口。

工作：

- 商店加入固定 inventory 與移除卡服務。
- 篝火加入休息 / 升級卡牌。
- Card definition 支援 upgraded 版本或 upgrade modifier。
- Boss 勝利後加入 Boss reward / run summary。
- 補測試與 QA checklist。

完成條件：

- 商店能買卡、買 relic、移除卡。
- 篝火能休息或升級卡。
- Boss 勝利後有清楚的 V2 終局流程。

### Phase V2-7：內容池擴充

目標：補足 random map 重複遊玩的基本內容密度。

工作：

- 新增到至少 6 個 event。
- 新增到至少 8 個 relic。
- 新增或調整到至少 5 種普通 encounter。
- 新增或調整到至少 3 種菁英 encounter。
- 讓至少 2 個 Boss 有不同戰鬥規則壓力。
- 更新 RuntimeDatabase 測試。
- 更新 `docs/hololive-content-bible.md` 或新增內容文件段落。

完成條件：

- random map 事件池至少 6 個事件。
- relic pool 至少 8 個。
- encounter pool 足以支撐連續兩局不完全重複。
- 新資料都有測試覆蓋。

### Phase V2-8：完整 QA 與文件收斂

目標：把 V2 從「可跑」變成「可交付給下一輪開發」。

工作：

- 更新 `docs/manual-qa-checklist.md`。
- 完整跑 Subaru random map run。
- 完整跑 Botan random map run。
- 驗收 Boss 預告、事件、菁英、寶箱、商店、篝火、relic fallback、失敗流程。
- 驗收 status 顯示、商店移除卡、篝火升級卡、Boss reward / run summary。
- 更新 `docs/godot-mvp-status.md`、`README.md`、`docs/random-map-v1-plan.md`。

完成條件：

- 自動測試全數通過。
- 手動 QA 記錄至少有一次 V2 Subaru / Botan 結果。
- 文件清楚標示 V2 已接入或剩餘問題。

## 測試策略

每輪程式改動固定跑：

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
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/random_map_tests.gd
```

新增 V2 測試建議：

- `tests/headless/run_state_random_map_tests.gd`
  - start run 後有 active map。
  - start 的 outgoing 成為 available nodes。
  - 完成可到達節點後 visited 更新。
  - 下一層 available nodes 來自該節點 outgoing。
  - 不可到達節點不能完成。
- `tests/headless/runtime_database_tests.gd` 擴充：
  - random map boss node 必須有固定 boss enemy id 或可解析 boss pool。
  - event pool 數量符合 V2 目標。
  - relic pool 數量符合 V2 目標。
- `tests/headless/combat_status_tests.gd`
  - strength 增加攻擊傷害。
  - weak 降低攻擊傷害。
  - vulnerable 增加受到的攻擊傷害。
  - duration 狀態會正確衰減。
- `tests/headless/event_relic_definition_tests.gd`
  - event option outcomes 都是合法 action。
  - relic source pool 與 hook 都是合法值。
  - boss / elite / chest / shop / event 發放不會重複給已持有唯一 relic。

手動 QA 新增重點：

- Subaru / Botan 各跑一局 random map。
- 同一 seed 地圖可重現。
- 不同 run 的路線或 Boss 有變化。
- Boss 預告與實際戰鬥一致。
- Map UI 文字不重疊，可辨識節點狀態。
- Status / buff / debuff 在玩家與敵人面板上可讀。
- 商店移除卡、篝火升級卡、Boss reward / run summary 都可完成。
- 固定 debug 快捷鍵仍可驗收單一功能。

## 風險與處理

### 風險：`Game.gd` 持續膨脹

目前 `Game.gd` 已負責流程、UI、戰鬥呈現、debug、獎勵與事件。V2 可以先在同檔維持 MVP 速度，但新增 random map helper 時要避免把地圖資料邏輯全部寫死在 UI 裡。

處理方式：

- Run 推進邏輯優先放在 `RunState`。
- 地圖生成仍放在 `RandomMapGenerator`。
- `Game.gd` 只負責讀狀態、畫按鈕、進入節點畫面。

### 風險：隨機地圖讓 QA 變慢

處理方式：

- 保留 debug 快捷鍵。
- 保留固定路線 fallback。
- 支援固定 seed 測試。
- QA checklist 分成 random map 完整跑與單點 debug 驗收。

### 風險：V2 範圍擴大導致無法收斂

處理方式：

- 先完成必做層級，再做應做層級。
- Status 只做 3-4 個代表狀態，不做完整 Power / Curse。
- Boss reward 先做最小版本，不做完整多 Act 轉場。
- 內容池以數量門檻收斂：6 event、8 relic、5 normal encounter、3 elite encounter、2 Boss。

### 風險：狀態、relic、event 互相影響造成測試缺口

處理方式：

- 每個新系統都要有 headless tests。
- Event outcome 與 relic hook 使用合法值檢查。
- 狀態效果先走明確公式，不做任意腳本執行。

## V2 完成定義

V2 可視為完成時，必須同時滿足：

- Subaru 與 Botan 都能從 random map 正常開始、推進、擊敗 Boss 或失敗。
- Map UI 支援路線選擇，且不可點未連線節點。
- 本局 Boss 有預告，且預告與戰鬥一致。
- 普通戰、菁英、事件、寶箱、商店、篝火、Boss 都能在 random map 中正常運作。
- Event pool 至少 6 個，Relic pool 至少 8 個。
- 至少 5 種普通 encounter、3 種菁英 encounter、2 種具不同壓力的 Boss。
- 第一批 status / buff / debuff 可在戰鬥中生效並顯示。
- 商店支援買卡、買 relic、移除卡。
- 篝火支援休息與升級卡。
- Boss 勝利後有 Boss reward 或 run summary。
- Debug 快捷鍵仍可用於單點驗收。
- 自動測試全部通過。
- `docs/manual-qa-checklist.md` 有 V2 驗收區塊。
- `docs/godot-mvp-status.md` 已更新 V2 狀態與下一步。

## V2 後續方向

V2 完成後，下一階段可以再決定走哪條線：

- V3A：戰鬥深度，加入完整 Power / Curse、更多 Boss gimmick。
- V3B：內容密度，增加角色卡池、事件池、relic pool、敵人池與 Act 變化。
- V3C：產品化，加入存檔、設定、教學、音效、主選單 polish。
- V3D：架構整理，把 `Game.gd` 逐步拆成 reusable screen / controller。
