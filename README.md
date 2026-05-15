# Oshi no Tower Godot MVP

這是 `oshi-no-tower` 目前正在開發的 Godot 版 MVP。  
早期曾先做網頁版原型與 Unity MVP，現在主要開發環境已切換到：

```text
/Users/zhangzhipeng/MyProject/oshi-no-tower-godot
```

## 專案狀態

- 引擎：Godot 4.6 專案格式
- 主場景：`res://scenes/main.tscn`
- 主流程：`scripts/Game.gd`
- 遊戲資料：`scripts/data/RuntimeDatabase.gd`
- 戰鬥核心：`scripts/core/CombatEngine.gd`
- 戰鬥測試：`tests/headless/combat_engine_tests.gd`
- 資料測試：`tests/headless/runtime_database_tests.gd`
- UI 版面測試：`tests/headless/combat_ui_layout_tests.gd`
- 隨機地圖資料測試：`tests/headless/random_map_tests.gd`
- Random run state 測試：`tests/headless/run_state_random_map_tests.gd`
- Status 測試：`tests/headless/combat_status_tests.gd`
- Event / Relic 定義測試：`tests/headless/event_relic_definition_tests.gd`
- 升級卡測試：`tests/headless/card_upgrade_tests.gd`
- 遊戲流程洗牌測試：`tests/headless/gameplay_shuffle_tests.gd`
- 訊息自動清除測試：`tests/headless/debug_message_timeout_tests.gd`
- V3 內容 metadata 測試：`tests/headless/content_metadata_tests.gd`
- V3 商店 / 篝火選擇測試：`tests/headless/shop_campfire_selection_tests.gd`
- V3 meme 敵人測試：`tests/headless/enemy_meme_behavior_tests.gd`
- 手動驗收：`docs/manual-qa-checklist.md`
- 內容骨架：`docs/hololive-content-bible.md`
- 開發路線：`docs/mvp-roadmap.md`
- 隨機地圖規格：`docs/random-map-v1-plan.md`
- 卡池矩陣：`docs/card-pool-matrix.md`
- MVP-v4 規劃：`docs/v4-roadmap.md`
- MVP-v4 平衡 QA：`docs/v4-balance-qa.md`
- MVP-v4.1 UI 元件抽取規劃：`docs/v4.1-combat-ui-component-extraction.md`
- 角色圖片重製規格：`docs/character-art-spec.md`
- 延續開發紀錄：`docs/godot-mvp-status.md`
- Agent 接手規則：`AGENTS.md`
- Web 設計文件封存：`archive/legacy-docs/`

## 目前功能

- 可選擇兩名角色：
  - Subaru：低費、多段、節奏與應援防守牌組，MVP-v3 追加 Duck Tempo、Teetee、Desk-kun、Blue Wave、New Oshi 方向卡。
  - Botan：高單發、防禦穩、控制與精準射擊牌組，MVP-v3 追加 Shishiro Button、Clean Scope、Calm Burst、Precise Cover、X Funds 方向卡。
- MVP-v2 隨機路線：
  - 選擇角色後會進入 seed-based random map。
  - 地圖顯示可選路線、已走過節點、不可到達節點與本局 Boss 預告。
  - 目前 random map 是 16 floor Boss 的單 Act 長路線；普通戰會依 early / mid / late encounter tier 漸進抽更高壓敵人。
  - 玩家只能點目前可到達節點；固定路線仍保留為 debug fallback。
- 固定路線 fallback：
  - 開始 -> 小怪 1 -> 事件 1 -> 小怪 2 -> 寶箱 -> 菁英 -> 商店 -> 事件 2 -> 小怪 3 -> 篝火 -> 小怪 4 -> 事件 3 -> 小怪 5 -> Boss -> 結算。
- 戰鬥系統：
  - 玩家 HP、格擋、能量。
  - 敵人 HP、格擋、意圖。
  - 抽牌、棄牌、手牌、能量消耗。
  - 卡牌效果包含傷害、格擋、抽牌、能量與簡版 status。
  - Subaru 被動：每回合第一次打出 0/1 費牌時獲得 3 點格擋。
  - Botan 被動：每回合第一次打出 2 費攻擊牌時追加 6 點傷害。
  - 角色被動會在角色選擇畫面與戰鬥中顯示，觸發時會出現短暫提示。
  - 簡版 status 支援 `strength`、`weak`、`vulnerable`、`regen`。
  - 普通戰勝利後取得少量 Gold 並進入 3 選 1 卡牌獎勵。
  - 菁英戰勝利後取得較多 Gold 與 relic，獎勵說明會標示菁英戰。
  - 寶箱依 Slay the Spire 原則固定隨機取得 1 個 relic，不提供卡牌 / Gold 多選。
  - Boss 勝利後進入 Boss reward，可選升級版卡牌、Boss relic 或直接通關結算。
  - HP 歸零會進入挑戰失敗畫面。
- 事件：
  - MVP-v3 使用資料化事件池，目前至少 16 個事件。
  - 事件 1：`遇到流離失所的 HoloStar 成員`，問題為 `是否要贊助資源給他`。
  - 事件 2：`直播事故支援`，可用 HP 換 Gold，或加入一張角色卡。
  - 事件 3：`粉絲應援整隊`，可用 Gold 換 relic，或整理應援取得 Gold。
  - 新增剪輯檔案整理、突發練習台、安靜的周邊攤。
  - MVP-v3 新增重大告知倒數、EN Curse 事故台、Twitter Jail、Pineapple Pizza War、Superchat Time、Unarchived Karaoke、全損現場、HoloMoms 應援。
  - random map 事件完全從 event pool 抽取；固定路線 debug fallback 仍保留原三個事件。
  - 事件 outcome 支援 Gold、HP、加牌、移除卡、取得 relic、額外戰鬥。
  - 事件、卡牌、relic、敵人資料會標註 `meme_source`、`content_group`、`rarity`、`implementation_status`，用於去重與 QA。
- Relic：
  - 開局不固定持有 relic，run 中可透過寶箱、菁英戰、商店、事件或 debug 取得。
  - 商店卡牌依 `rarity` / `kind` / `cost` 計算價格，relic 依 `pool` 計算價格；每個商店節點固定有一個特價商品，同一節點重開不刷新庫存或特價，購買後商品會從該商店移除。本輪不調整起始 Gold、移除卡價格或篝火休息量。
  - MVP-v2 relic pool 擴到 9 個，包含應援螢光棒、鴨鴨哨子、獅白準星、開場能量飲、聊天室補給、金色 Superchat、商店折價券、推塔集章卡、終局聚光燈。
  - MVP-v3 relic pool 擴到 18 個，追加 YAGOO is Best Girl、Shishiro Button、Superchat Reading、X Funds Wallet、Ada TV、Pamomi Signal、Blue Wave Badge、Unarchived Archive、YAGOO Blood Pressure Meter。
  - relic 已全數取得時，寶箱、菁英與事件的 relic 獎勵會改給 Gold 25。
  - 支援 combat start、turn start、first attack、first two cost、battle reward、shop enter、room enter 等簡版 hook。
- 敵人與 Boss：
  - 普通戰使用 SSRB Gray、SSRB Camouflage、SSRB White、SSRB Gold、SSRB Glitch，MVP-v3 追加 YouTube-kun、Desk-kun、Announcement Shadow。
  - 普通敵人資料包含 early / mid / late encounter tier，長地圖後段會自然抽到更高壓 encounter。
  - 菁英戰追加 AK Idol Unit。
  - `ころね好き` 與 `毛玉` 已列為下一批待接敵人；目前等待圖片放入 `assets/enemies/korone_suki/` 與 `assets/enemies/kedama/` 後再接入資料與 encounter pool。
  - Boss 戰會由 random map 先決定並預告 Subaruto Duck、巨大 SSRB 變體、YouTube-kun Core 或 Important Announcement。
  - Boss 戰有 BOSS 標示、Boss 名稱與暗色 overlay。
- 視覺：
  - Combat 與 Map 使用生成背景圖。
  - Subaru / Botan / SSRB / Subaruto Duck 使用 sprite sheet 動畫。
  - 敵人 idle、attack、hurt 動畫會在戰鬥中切換。
  - 敵人攻擊時會向玩家方向位移。
  - 玩家受擊時會有簡單受擊顯示。
- UI：
  - 戰鬥資訊目前顯示玩家名稱、HP、格擋、能量、被動，以及敵人名稱、HP、格擋、意圖。
  - 玩家與敵人的 status 文字列顯示在角色下方，後續可替換成 icon。
  - 玩家資訊區不顯示抽牌與棄牌數。
  - 玩家與敵方 HP / 格擋 / 能量數值不再顯示深色文字底色。
  - 敵方意圖文字區塊不再顯示深色底色；意圖有第一版 icon / symbol placeholder 與文字 fallback；一般 UI 文字加上深色陰影與輕量描邊。
  - Debug / reward 訊息會在約 2 秒後自動消失。
  - 戰鬥狀態區與手牌區的大型深色底板已移除，下方不顯示「手牌」標題。
  - 戰鬥手牌試改為 3:4 直式卡牌，費用只顯示數字。
  - 戰鬥卡牌採類 Slay the Spire 結構：外框、左上費用 badge、卡名、圖片預留區、類別與下半部效果說明。
  - 手牌未 hover 時以畫面中央為核心，維持中間較高、左右較低的底部扇形排列；手牌數量減少時也會往中央集中。
  - 戰鬥手牌 hover 改用實際尺寸重排，不用 `scale` 整張縮放，降低文字模糊；放大後描述區保留較完整比例，戰鬥獎勵卡牌不啟用 hover 放大。
  - 卡牌依類型使用不同背景色，卡面不透明。
  - 商店卡牌、relic 與移除卡服務會在左上角顯示金額，並在卡面下方顯示功能說明。
  - 商店移除卡與篝火升級卡改成玩家可選目標，並使用可上下滾動的牌組選擇畫面；已升級卡不會出現在篝火升級清單。
  - 主要顯示文字以繁體中文為主。
- 測試：
  - CombatEngine 可用 Godot headless 腳本測核心戰鬥規則。
  - RuntimeDatabase 可用 Godot headless 腳本測角色、卡牌、敵人、Boss pool、固定路線與素材路徑。
  - Combat UI layout 可用 Godot headless 腳本測手牌區位置、寬度與高度、卡牌框架結構、扇形排列、hover 放大置頂、角色被動 UI、敵方意圖 icon 與商店商品說明。
- 內容規劃：
  - Hololive 內容骨架已整理在 `docs/hololive-content-bible.md`。
  - 後續開發順序已整理在 `docs/mvp-roadmap.md`。
  - 隨機地圖 v1 前置規格已整理在 `docs/random-map-v1-plan.md`，並已於 MVP-v2 接入主流程。
  - Subaru / Botan 第一輪卡池方向已整理在 `docs/card-pool-matrix.md`。
  - MVP-v4 第一版已落地在 `docs/v4-roadmap.md`，主軸為戰鬥 UI helper 分區、角色被動可視化、敵人意圖 icon placeholder、平衡 QA 與人物圖片重製準備。
  - MVP-v4.1 已規劃在 `docs/v4.1-combat-ui-component-extraction.md`，主軸為抽取 CombatCardView、CombatHandView、ActorStatusView，保留目前 V4 視覺與互動行為。

## Debug / 驗收快捷鍵

遊戲執行中可使用以下快捷鍵快速測試，避免每次都從頭跑完整路線。

- `1`：顯示或隱藏 debug 快捷鍵說明。
- `2`：回到角色選擇畫面，切換角色時從這裡重新選。
- `3`：直接進入普通戰測試，每按一次輪替 SSRB 與 V3 meme 普通敵人。
- `4`：切換指定 Boss，依序輪替 Subaruto Duck、巨大 SSRB 變體與 V3 meme Boss。
- `5`：直接進入目前指定 Boss 的 Boss 戰。
- `6`：直接進入菁英 SSRB Duo 戰。
- `7`：直接進入寶箱獎勵。
- `8`：直接進入商店。
- `9`：直接進入篝火。
- `0` / `=`：直接進入事件，連續按會在事件 1 / 事件 2 / 事件 3 之間輪替。
- `-`：取得下一個未持有 relic。

## 如何啟動

1. 用 Godot 開啟本資料夾：

   ```text
   /Users/zhangzhipeng/MyProject/oshi-no-tower-godot
   ```

2. 執行主場景：

   ```text
   res://scenes/main.tscn
   ```

3. 選擇 Subaru 或 Botan 開始遊玩。

## 手動驗收流程

正式手動驗收入口：

```text
docs/manual-qa-checklist.md
```

MVP-v2 正常流程為 random map。固定路線仍作為 debug fallback 與資料驗收參考：

```text
開始 -> 小怪 1 -> 事件 1 -> 小怪 2 -> 寶箱 -> 菁英 -> 商店 -> 事件 2 -> 小怪 3 -> 篝火 -> 小怪 4 -> 事件 3 -> 小怪 5 -> Boss -> 結算
```

建議驗收項目：

- Subaru 與 Botan 都能開始路線。
- 地圖只能點選可到達節點，Boss 預告需與實際 Boss 一致。
- 五場普通戰能顯示 SSRB 敵人。
- 中段菁英戰能顯示 SSRB Duo。
- Boss 戰能顯示 BOSS 標示、Boss 名稱與暗色 overlay。
- 卡牌區未 hover 時以畫面中央為核心維持底部扇形排列，hover 時單張戰鬥手牌會貼齊畫面下緣並向上放大查看完整卡面；戰鬥獎勵卡牌不 hover 放大。
- HP、格擋、能量、意圖資訊可讀，狀態文字顯示在角色下方。
- 角色被動在角色選擇與戰鬥中可讀，觸發提示不會永久停留。
- 敵人意圖 icon 與文字 fallback 可讀。
- 玩家 HP 歸零時會進入挑戰失敗畫面。
- 普通戰勝利後會顯示取得 Gold，並進入 3 選 1 卡牌獎勵，可選牌或跳過。
- 菁英戰 Gold 明顯高於普通戰，並會額外取得 relic。
- 寶箱會固定隨機取得 1 個 relic，沒有卡牌 / Gold 多選。
- 商店可購買卡牌、購買未持有 relic、移除卡；商品需顯示金額與功能說明。
- 篝火可休息或升級卡牌。
- 戰鬥 status 顯示與 strength / weak / vulnerable / regen 效果可讀。
- 擊敗 Boss 後會進入通關成功畫面。
- 每次調整戰鬥 UI、卡牌平衡、Boss 或流程後，依 `docs/manual-qa-checklist.md` 重新驗收。

## 自動測試

目前有不依賴額外測試框架的 Godot headless 測試腳本：

```text
tests/headless/combat_engine_tests.gd
tests/headless/runtime_database_tests.gd
tests/headless/combat_ui_layout_tests.gd
tests/headless/random_map_tests.gd
tests/headless/run_state_random_map_tests.gd
tests/headless/combat_status_tests.gd
tests/headless/event_relic_definition_tests.gd
tests/headless/card_upgrade_tests.gd
tests/headless/gameplay_shuffle_tests.gd
tests/headless/debug_message_timeout_tests.gd
tests/headless/content_metadata_tests.gd
tests/headless/shop_campfire_selection_tests.gd
tests/headless/enemy_meme_behavior_tests.gd
```

CombatEngine 測試：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_engine_tests.gd
```

RuntimeDatabase 測試：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/runtime_database_tests.gd
```

Combat UI layout 測試：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_ui_layout_tests.gd
tests/headless/random_map_tests.gd
```

CombatEngine 測試覆蓋：

- 開戰抽 5 張。
- 玩家起始 3 能量。
- 出牌消耗能量。
- 傷害、格擋、抽牌、能量效果。
- 敵人 attack、block、attack_block 行動。
- 勝利與失敗判定。
- 抽牌堆空時回收棄牌堆。

RuntimeDatabase 測試覆蓋：

- Subaru / Botan 起始牌組與角色素材路徑。
- 卡牌 id、類型、費用、效果與動畫素材路徑。
- SSRB、Subaruto Duck 與 Boss 變體的行動資料與動畫素材路徑。
- 固定路線節點順序與 battle node 敵人參照。
- Boss pool 內敵人必須存在、標記 `is_boss`，且顯示比例至少 `1.5`。
- 寶箱固定 relic 獎勵、商店卡牌清單與戰鬥後 3 選 1 必須參照現有資料。
- Relic 資料、寶箱 / 菁英 / 商店 / 事件 / debug relic 取得、拿滿 fallback 與三種戰鬥 hook。
- 普通戰 / 菁英戰 Gold 節奏必須維持差異，寶箱固定 relic 獎勵必須只發放一次並能推進節點。


RandomMap 測試：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/random_map_tests.gd
```

RandomMap 測試覆蓋：

- 同一 seed 產生相同地圖。
- 不同 seed 產生不同配置。
- 起點與所有節點都能連到 Boss。
- Boss 位於 floor 16，地圖包含足夠普通戰、事件、菁英、寶箱、商店、篝火與 Boss 候選。
- Boss node 保存本局預告 Boss。
- 事件候選來自 event pool，random map 不再 floor-locked 指定前三個事件。

RunState random map 測試：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/run_state_random_map_tests.gd
```

Combat status 測試：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_status_tests.gd
```

Event / Relic definition 測試：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/event_relic_definition_tests.gd
```

Card upgrade 測試：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/card_upgrade_tests.gd
```

Gameplay shuffle 測試：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/gameplay_shuffle_tests.gd
```

Debug / reward message timeout 測試：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/debug_message_timeout_tests.gd
```

Combat UI layout 測試覆蓋：

- 戰鬥起始手牌按鈕數量。
- 戰鬥手牌位置必須維持在下方區域，且比例接近 3:4。
- 戰鬥卡牌必須有外框、費用 badge、圖片預留區、類別與描述區。
- 戰鬥手牌未 hover 時必須以畫面中央為核心扇形排列，手牌變少也要往中央集中。
- 戰鬥手牌 hover 不使用 `scale`，改用實際 `size` 與文字重排；描述區需維持足夠比例，戰鬥獎勵卡牌不啟用 hover 放大。
- 角色被動 UI 與敵方意圖 icon placeholder 需由 Combat UI layout 測試覆蓋。
- 商店商品需顯示價格 badge 與功能說明，包含卡牌、relic 與移除卡服務。
- Subaru / Botan 角色被動需由 CombatEngine 測試覆蓋。
- RuntimeDatabase 測試覆蓋角色卡池輪廓與敵人壓力門檻。
- 玩家資訊區不顯示抽牌 / 棄牌。
- 玩家與敵方 HP / 格擋 / 能量文字沒有深色底色，敵方意圖底色移除，戰鬥下方不顯示「手牌」標題。
- 一般 UI 文字具備陰影與描邊，以維持背景圖上的可讀性。
- 狀態文字位於角色下方。
- 戰鬥狀態區與手牌區沒有大型深色底板。

## 開發備忘

- 每次接續開發前，先讀 `AGENTS.md` 與 `docs/godot-mvp-status.md`。
- 每次需要手動驗收時，使用 `docs/manual-qa-checklist.md`。
- 進行 Hololive 內容、卡牌、事件或遺物設計前，先讀 `docs/hololive-content-bible.md`。
- 擴充 Subaru / Botan 卡牌前，先讀 `docs/card-pool-matrix.md`。
- 規劃系統開發順序時，先讀 `docs/mvp-roadmap.md`。
- 需要追溯 Web 版原始設計時，讀 `archive/legacy-docs/README.md`。
- 完成重要功能或決策後，更新 `docs/godot-mvp-status.md`。
- MVP-v2 已接入 random map 主流程、簡版 status、event / relic v2、商店移除卡、篝火升級卡與 Boss reward；正式平衡、存檔、多 Act、完整 Power / Curse 與藥水系統延後。
- 目前這個 workspace 看到的 Godot 專案目錄不是 git repository。
