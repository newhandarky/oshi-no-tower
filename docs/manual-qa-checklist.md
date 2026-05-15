# Godot MVP 手動 QA Checklist

最近更新：2026-05-13

本文件是 `oshi-no-tower-godot` 的手動驗收入口。每次調整戰鬥 UI、卡牌平衡、Boss、角色差異或流程前後，都先用這份 checklist 做基本回歸確認。

## 測試前準備

- [ ] 用 Godot 開啟專案：`/Users/zhangzhipeng/MyProject/oshi-no-tower-godot`
- [ ] 執行主場景：`res://scenes/main.tscn`
- [ ] 確認主畫面可進入角色選擇。
- [ ] 確認主要文字為繁體中文；技術名稱、角色名、Boss 日文名可保留原文。
- [ ] 確認視窗大小至少能完整看到 960x540 基準畫面比例。

## 自動測試先跑

手動測試前先跑以下三個 headless 檢查。

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_engine_tests.gd
```

- [ ] 輸出包含 `combat_engine_tests: ok`

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/runtime_database_tests.gd
```

- [ ] 輸出包含 `runtime_database_tests: ok`

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/random_map_tests.gd
```

- [ ] 輸出包含 `random_map_tests: ok`

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --quit
```

- [ ] 指令 exit code 為 0，沒有 Godot script parse error。

MVP-v3 內容與選擇流程另需跑以下三個 headless 檢查。

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/content_metadata_tests.gd
```

- [ ] 輸出包含 `content_metadata_tests: ok`

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/shop_campfire_selection_tests.gd
```

- [ ] 輸出包含 `shop_campfire_selection_tests: ok`

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/enemy_meme_behavior_tests.gd
```

- [ ] 輸出包含 `enemy_meme_behavior_tests: ok`

戰鬥 UI 調整後另需跑以下 headless 檢查。

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_ui_layout_tests.gd
```

- [ ] 輸出包含 `combat_ui_layout_tests: ok`

Playable demo 收斂或 production contract 調整後另需跑以下 headless 檢查。

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/playable_demo_smoke_tests.gd
```

- [ ] 輸出包含 `playable_demo_smoke_tests: ok`

## Production Contract Gate

- [ ] `GAME_DESIGN.md` 存在，且 scope 鎖定 `godot_mvp_playable_demo`。
- [ ] `game_design_bible.json` 可被 JSON parser 讀取，且 `production_scope` 為 `godot_mvp_playable_demo`。
- [ ] `docs/production/director-production-plan.md` 有 6 個 demo milestone：source-of-truth、AZKi / Laplus / FX、三角色完整 run、小範圍 UI/平衡、Technical QA / Creative Review、desktop readiness。
- [ ] `docs/production/actor-contracts.json` 有 Subaru / Botan / AZKi / Laplus 的 actor contract。
- [ ] `docs/production/ui-continuity-report.md` 明確列出 Boss warning、marker fallback、tooltip safe area 與 hand hover 不重疊要求。
- [ ] `docs/production/audio-feedback-contract.md` 明確標記本輪 audio 為 manifest-only，正式 SFX / BGM asset deferred。
- [ ] `docs/production/technical-qa-report.md` 不把未完成 manual QA 標成 passed。
- [ ] `docs/production/creative-director-review.md` 不把 deferred audio 或未完成三角色 run 說成已 accepted。

## Debug 快捷鍵

遊戲執行中可用以下快捷鍵縮短驗收時間。

- [ ] `1`：顯示或隱藏 debug 快捷鍵說明。
- [ ] `2`：回到角色選擇畫面，切換角色時從這裡重新選。
- [ ] `3`：直接進入普通戰測試，每按一次輪替 SSRB、V3 meme 普通敵人與 `ころね好き`。
- [ ] `4`：切換指定 Boss，依序輪替 Subaruto Duck、巨大 SSRB 變體與 V3 meme Boss。
- [ ] `5`：直接進入目前指定 Boss 的 Boss 戰。
- [ ] `6`：直接進入菁英戰測試，輪替 SSRB Duo、`毛玉` 與其他 elite。
- [ ] `7`：直接進入寶箱獎勵。
- [ ] `8`：直接進入商店。
- [ ] `9`：直接進入篝火。
- [ ] `0` / `=`：直接進入事件，連續按會在事件 1 / 事件 2 / 事件 3 之間輪替，再回到事件 1。
- [ ] `-`：取得下一個未持有 relic。

## Playable Demo Random Run Gate

本段是 desktop build 前的正式手動 gate。三位角色都要從角色選擇開始，不使用 debug 直接跳 Boss。

- [ ] Subaru 完整跑一局 16 floor random map，記錄 Boss、Boss 前 HP、Gold、relic 數、是否遇到事件戰鬥、死亡或通關結果。
- [ ] Subaru run 中地圖 Boss 名稱與 `BOSS` node 可讀，且地圖不顯示 Boss hint 長文；Boss warning 對決策有幫助，低費節奏與被動觸發能被玩家理解。
- [ ] Botan 完整跑一局 16 floor random map，記錄 Boss、Boss 前 HP、Gold、relic 數、是否遇到事件戰鬥、死亡或通關結果。
- [ ] Botan run 中 2 費攻擊爆發與穩定防線有明顯角色差異，不像 Subaru 的抽牌連段玩法。
- [ ] AZKi 完整跑一局 16 floor random map，記錄 Boss、Boss 前 HP、Gold、relic 數、是否遇到事件戰鬥、死亡或通關結果。
- [ ] AZKi run 中 marker fallback 以 `標記` 顯示，不裸顯英文 `marker`。
- [ ] AZKi run 中 Laplus summon HP label 可讀，Laplus 承傷與倒下後復活規則可理解。
- [ ] 三角色 run 都能進入普通戰、事件、菁英、寶箱、商店、篝火與 Boss 其中主要路徑，沒有 blocking flow break。
- [ ] 三角色 run 若失敗，失敗畫面可抵達；若通關，Boss reward / summary 可抵達。
- [ ] Desktop build readiness 只有在本段完成且 technical QA 無 blocking issue 後才可勾選。

## AZKi / Laplus / FX Demo Gate

- [ ] 打出 `map_marker_attack`：AZKi 播放 `map_marker_attack`，`map_marker_projectile` 從 Laplus 右側往敵人方向延展，不遮 Boss warning 或手牌文字。
- [ ] 打出 `kiss_attack`：AZKi 播放 `kiss_attack`，`kiss_heart_projectile` 可讀，`雑魚❤️` 對話框只在合理中段幀出現。
- [ ] 打出 `laplus_dash`：AZKi 播放 `command_dash`，Laplus 播放 `dash_attack`，dash trail 與角色同步。
- [ ] 打出 `laplus_crash`：AZKi 播放 `command_crash`，Laplus 播放 `crash_attack`，crash impact 不蓋住 Laplus HP label。
- [ ] 四個 action 中 AZKi 本體、Laplus summon、FX-only sprite 的 z-order 合理，FX 主視覺不被 Laplus 蓋住。
- [ ] 四個 action 播放後都能回到可操作戰鬥狀態，不卡住 turn 或 reward flow。

## Subaru 完整路線驗收

路線：`開始 -> 小怪 1 -> 事件 1 -> 小怪 2 -> 寶箱 -> 菁英 -> 商店 -> 事件 2 -> 小怪 3 -> 篝火 -> 小怪 4 -> 事件 3 -> 小怪 5 -> Boss -> 結算`

- [ ] 選擇 Subaru 後可以進入地圖。
- [ ] 地圖顯示固定路線節點，且目前節點可進入。
- [ ] 小怪 1 顯示 SSRB Gray。
- [ ] 事件 1 顯示 HoloStar 贊助事件。
- [ ] 小怪 2 顯示 SSRB Camouflage。
- [ ] 寶箱固定隨機取得 1 個 relic，按繼續後回到地圖。
- [ ] 菁英戰顯示 SSRB Duo，勝利後取得較多 Gold 與 relic。
- [ ] 商店可購買卡牌或離開，金錢不足時不能購買。
- [ ] 商店可用商品標示價格購買一個未持有 relic。
- [ ] 事件 2 顯示直播事故支援事件。
- [ ] 小怪 3 顯示 SSRB White。
- [ ] 篝火可恢復 HP 並回到地圖。
- [ ] 小怪 4 顯示 SSRB Gray。
- [ ] 事件 3 顯示粉絲應援整隊事件。
- [ ] 小怪 5 顯示 SSRB Camouflage。
- [ ] Boss 節點可進入 Boss 戰。
- [ ] 擊敗 Boss 後進入通關成功畫面。
- [ ] Subaru 牌組體感符合低費、多段、節奏型方向。

## Botan 完整路線驗收

路線：`開始 -> 小怪 1 -> 事件 1 -> 小怪 2 -> 寶箱 -> 菁英 -> 商店 -> 事件 2 -> 小怪 3 -> 篝火 -> 小怪 4 -> 事件 3 -> 小怪 5 -> Boss -> 結算`

- [ ] 選擇 Botan 後可以進入地圖。
- [ ] 地圖顯示固定路線節點，且目前節點可進入。
- [ ] 小怪 1 顯示 SSRB Gray。
- [ ] 事件 1 顯示 HoloStar 贊助事件。
- [ ] 小怪 2 顯示 SSRB Camouflage。
- [ ] 寶箱固定隨機取得 1 個 relic，按繼續後回到地圖。
- [ ] 菁英戰顯示 SSRB Duo，勝利後取得較多 Gold 與 relic。
- [ ] 商店可購買卡牌或離開，金錢不足時不能購買。
- [ ] 商店可用商品標示價格購買一個未持有 relic。
- [ ] 事件 2 顯示直播事故支援事件。
- [ ] 小怪 3 顯示 SSRB White。
- [ ] 篝火可恢復 HP 並回到地圖。
- [ ] 小怪 4 顯示 SSRB Gray。
- [ ] 事件 3 顯示粉絲應援整隊事件。
- [ ] 小怪 5 顯示 SSRB Camouflage。
- [ ] Boss 節點可進入 Boss 戰。
- [ ] 擊敗 Boss 後進入通關成功畫面。
- [ ] Botan 牌組體感符合高單發、防禦穩、射擊感方向。

## 菁英戰驗收

- [ ] 菁英節點位於路線中段。
- [ ] 菁英戰名稱顯示 SSRB Duo。
- [ ] 菁英戰從 Gray + Camouflage、Gray + White、Camouflage + White 三組中隨機出現。
- [ ] 菁英輪替中可進入毛玉，且單體菁英素材可正常顯示。
- [ ] 菁英戰畫面上能看出兩隻 SSRB。
- [ ] 菁英戰勝利後顯示取得 Gold，且 Gold 明顯高於普通戰。
- [ ] 菁英戰勝利後會額外取得 relic。
- [ ] 菁英戰勝利後進入 3 選 1卡牌獎勵，可選牌或跳過。

## 普通戰驗收

可用 `4` 快速輪替普通戰。

- [ ] SSRB Gray 顯示正確名稱與素材。
- [ ] SSRB Camouflage 顯示正確名稱與素材。
- [ ] SSRB White 顯示正確名稱與素材。
- [ ] YouTube-kun 顯示正確名稱，第一回合會施加技術事故類 debuff。
- [ ] ころね好き 顯示正確名稱與素材，作為中段普通敵人可正常進入戰鬥。
- [ ] Desk-kun 顯示正確名稱，行動帶有攻擊或攻防混合壓力。
- [ ] Announcement Shadow 顯示正確名稱，先預告再重擊。
- [ ] 普通敵人尺寸約為一般敵人大小，沒有 Boss 的 BOSS 標籤。
- [ ] 敵人平時播放 idle 動畫。
- [ ] 敵人攻擊時播放 attack 動畫，並向玩家方向短距離位移後回到原位。
- [ ] 敵人受傷時播放 hurt 動畫。
- [ ] 玩家受擊時有短暫受擊效果，例如變色或位移。
- [ ] 勝利後顯示取得 Gold，並進入 3 選 1卡牌獎勵。
- [ ] 普通戰 Gold 屬於少量獎勵。
- [ ] 勝利後會回到地圖或下一個正確畫面。
- [ ] 玩家 HP 歸零時會進入挑戰失敗畫面。

## 事件驗收

- [ ] 固定 fallback 地圖上有 3 個事件節點；random map 會完全從資料化事件池抽事件，不依 floor 固定指定前三個事件。
- [ ] `=` 可直接進入事件；連續按會輪替事件 1、事件 2、事件 3，再回到事件 1。
- [ ] 三個事件都沒有離開選項。
- [ ] 事件 1 標題顯示 `遇到流離失所的 HoloStar 成員`。
- [ ] 事件 1 描述包含 `是否要贊助資源給他`。
- [ ] 事件 1 Gold 贊助：花費 30 Gold，回復 12 HP，並前進到下一節點。
- [ ] 事件 1 Gold 不足時，不扣錢、不回血、不前進節點。
- [ ] 事件 1 HP 贊助：失去 8 HP，取得 relic 或 relic 滿時取得 Gold 25，並前進到下一節點。
- [ ] 事件 2 標題顯示 `直播事故支援`。
- [ ] 事件 2 協助收拾：失去 6 HP，取得 Gold 35，並前進到下一節點。
- [ ] 事件 2 留下備用牌：加入 1 張當前角色卡，並前進到下一節點。
- [ ] 事件 3 標題顯示 `粉絲應援整隊`。
- [ ] 事件 3 投入 Gold：花費 40 Gold，取得 relic 或 relic 滿時返還 Gold 25，並前進到下一節點。
- [ ] 事件 3 整理應援：取得 Gold 25，並前進到下一節點。
- [ ] event pool 至少 16 個，且資料中有 `meme_source` 與 `content_group`。
- [ ] random map 中可遇到重大告知倒數、EN Curse 事故台、Twitter Jail、Pineapple Pizza War、Superchat Time、Unarchived Karaoke、全損現場或 HoloMoms 應援。
- [ ] random map 中可遇到 Sudden RAID 或 Algorithm Punishment 這類不利 / 高風險事件。
- [ ] random map 中可遇到會直接加入 curse 的事件，且 curse 會進入牌組。
- [ ] random map 改成可上下捲動的直式地圖後，16 floor 節點可透過滾動清楚瀏覽，不會再被硬塞進同一個畫面。
- [ ] Boss 節點只顯示 `BOSS`，不需要把長 Boss 名稱塞進節點按鈕。
- [ ] 三張 curse 目前都不可打出，不會因為能量夠就被正常使用。
- [ ] `Dead Air` 抽到時會立刻失去 1 點能量。
- [ ] `Bad Connection` 若回合結束仍留在手上，會失去 3 HP。
- [ ] `Comment Fire` 抽到時會立刻給玩家 1 回合易傷。
- [ ] `Comment Fire` 若回合結束仍在手上，會直接 exhaust，不會回到棄牌堆。
- [ ] 事件若觸發額外戰鬥，勝利後會回到地圖並完成原事件節點。
- [ ] 事件若觸發額外戰鬥，勝利後會先進入該場戰鬥獎勵，拿完獎勵後才回地圖並完成事件節點。
- [ ] 新事件不是全部都只有 HP 換 Gold；應包含移除卡、加卡、relic、恢復、風險獎勵、額外戰鬥等不同選擇。

## 寶箱獎勵驗收

- [ ] 寶箱畫面不顯示 3 選 1 卡牌。
- [ ] 寶箱不顯示 Gold 40 選項。
- [ ] 寶箱不顯示 relic 多選按鈕。
- [ ] 進入寶箱畫面時固定隨機取得 1 個 relic。
- [ ] 菁英戰也可作為 relic 取得來源。
- [ ] 商店也可作為 relic 取得來源，且不會賣已持有 relic。
- [ ] 商店 relic 價格依 pool 顯示不同金額；持有折扣 relic 時不會降低 card / relic 商品價格。
- [ ] 寶箱畫面只需要確認結果並按 `繼續` 回到地圖。
- [ ] 取得 relic 後 relic 清單會增加。
- [ ] relic 已全數取得時，寶箱或菁英 relic 獎勵會改給 Gold 25。
- [ ] 提示訊息刷新後，寶箱畫面不會閃跳成一般卡牌獎勵畫面。

## Boss 戰驗收

可用 `5` 切換指定 Boss，再用 `6` 直接進 Boss 戰。正常路線仍保留隨機 Boss 設計。

- [ ] Subaruto Duck 可被指定並進入 Boss 戰。
- [ ] 巨大 SSRB Gray 可被指定並進入 Boss 戰。
- [ ] 巨大 SSRB Camouflage 可被指定並進入 Boss 戰。
- [ ] 巨大 SSRB White 可被指定並進入 Boss 戰。
- [ ] YouTube-kun Core 可被指定並進入 Boss 戰。
- [ ] Important Announcement 可被指定並進入 Boss 戰。
- [ ] Boss 戰顯示明顯 `BOSS` 標籤。
- [ ] Boss 名稱清楚可讀，隨機或指定 Boss 都能辨識當前敵人。
- [ ] Boss 戰有暗色 overlay，氣氛與普通戰不同。
- [ ] Boss 顯示大小約為一般敵人的 1.5 倍。
- [ ] Boss idle / attack / hurt 動畫可見。
- [ ] Boss 攻擊時有短距離位移演出。
- [ ] 擊敗 Boss 後進入通關成功畫面。

## MVP-v3 內容驗收

- [ ] Subaru 被動「節奏守備」存在：每回合第一次打出 0/1 費牌時獲得 3 點格擋。
- [ ] Botan 被動「狙擊開場」存在：每回合第一次打出 2 費攻擊牌時追加 6 點傷害。
- [ ] 角色選擇畫面可看到 Subaru / Botan 被動名稱與一句說明。
- [ ] 戰鬥中玩家狀態區可看到目前角色被動名稱。
- [ ] 被動觸發時會出現短暫提示，例如 `被動觸發：節奏守備`。
- [ ] Subaru 實戰手感偏低費、抽牌、格擋節奏。
- [ ] Botan 實戰手感偏 2 費爆發、控制、穩定防線。
- [ ] SSRB Gray 普通戰攻擊壓力為 9 點，完全不防禦時會造成可感扣血。
- [ ] 普通戰可感受到 early / mid / late encounter tier 差異，後段敵人比前 3 floor 更有壓力。
- [ ] 菁英 SSRB Duo: Camouflage + White 的夾擊壓力提高到 18 + 防禦 10。
- [ ] スバルトダック Boss 的攻防回合壓力提高到 24 + 防禦 8。
- [ ] Subaru 獎勵或商店中可看到 V3 新牌，例如鴨群節拍、てぇてぇ守備、桌面反應、Blue Wave 應援、新推號召。
- [ ] Botan 獎勵或商店中可看到 V3 新牌，例如 Button Check、Clean Scope、冷靜爆發、精準掩護、Funds Prepared。
- [ ] 新卡牌卡面維持安全文字區，數值呈現維持單行格式，不回到 `抽牌` 與數字分行。
- [ ] relic pool 至少 16 個，且可看到 YAGOO is Best Girl、Shishiro Button、Superchat Reading、X Funds Wallet、Ada TV、Pamomi Signal、Blue Wave Badge、Unarchived Archive、YAGOO Blood Pressure Meter 等 V3 relic。
- [ ] 取得 V3 relic 時提示會顯示並約 2 秒後消失。
- [ ] 新內容能看出 meme 來源，但效果文字不需要玩家懂梗也能理解。
- [ ] 沒有歌詞、長篇直播台詞或惡意真人描寫。

## Relic 驗收

- [ ] 開局不固定持有 relic。
- [ ] `-` 可取得下一個未持有 relic。
- [ ] 地圖或戰鬥畫面可看到目前持有 relic 摘要。
- [ ] 戰鬥畫面左上 relic icon 已放大約 1.5 倍，但仍不會互相重疊。
- [ ] 應援螢光棒：戰鬥開始時獲得 3 點格擋。
- [ ] 鴨鴨哨子：每場戰鬥第一次打出攻擊牌時抽 1 張牌。
- [ ] 獅白準星：每場戰鬥第一次打出 2 費牌時額外造成 3 點傷害。
- [ ] 取得 relic 時 debug / 提示文字會顯示取得的 relic 名稱。
- [ ] relic 拿滿後再次取得 relic 來源時，提示會顯示改獲得 Gold 25。

## 戰鬥 UI 可讀性驗收

- [ ] 左上玩家資訊可讀：HP、格擋、能量。
- [ ] 戰鬥畫面不再顯示玩家與敵方名稱，避免長名稱擠壞版面。
- [ ] 玩家與敵方 HP / 格擋 / 能量數值沒有深色文字底色。
- [ ] 玩家資訊區不顯示抽牌與棄牌數。
- [ ] 右上敵人資訊面板可讀：名稱、HP、格擋、意圖。
- [ ] 右上敵人資訊面板即使不顯示名稱，HP、格擋、意圖仍可讀。
- [ ] 玩家與敵方的狀態文字顯示在角色下方。
- [ ] 敵方意圖文字區塊沒有深色底色。
- [ ] relic / status / intent icon 的 hover tooltip 字體明顯放大，不會再小到難讀。
- [ ] 敵方意圖有第一版 icon / symbol placeholder，例如 `⚔`、`▣`、`⚔▣`、`↑`、`↓`。
- [ ] 敵人意圖文字不被截斷到無法理解。
- [ ] 主要 UI 文字有陰影或描邊，在背景圖上仍清楚可讀。
- [ ] 戰鬥狀態區與下方手牌區沒有大型深色底板。
- [ ] 下方手牌區不顯示「手牌」標題文字。
- [ ] 手牌區不明顯遮住玩家與敵人主要身體。
- [ ] 卡牌名稱可讀。
- [ ] 卡牌效果說明可讀，不會太擠或嚴重溢出。
- [ ] 戰鬥手牌為高度大於寬度的 3:4 直式比例。
- [ ] 戰鬥手牌費用只顯示數字，不顯示 `費用` 兩字。
- [ ] 戰鬥手牌有明確外框，左上角有費用小區塊。
- [ ] 卡牌上半部保留圖片區，目前可為空白或色塊 placeholder。
- [ ] 卡名位於圖片上方，卡牌類別位於圖片下方。
- [ ] 卡牌下半部顯示簡短效果說明。
- [ ] 卡牌本體不透明，能和背景清楚分離。
- [ ] 未 hover 時，手牌在畫面下方以畫面中央為核心排列；不管 1 到 5 張手牌，都維持中間較高、左右較低的扇形，部分重疊可以接受。
- [ ] Hover 單張卡時會以底部為 pivot 放大、轉正、底部貼齊畫面下緣且置於最上層。
- [ ] Hover 放大時文字清晰，不是整張卡片被 `scale` 放大後的模糊文字。
- [ ] Hover 放大後卡牌下半部效果說明仍可看見，描述區比例合理，盡可能完整呈現效果文字且不會被畫面底部切掉。
- [ ] 戰鬥獎勵畫面的 3 選 1 卡牌不會 hover 放大。
- [ ] 攻擊牌背景為紅色系。
- [ ] 防禦牌背景為藍色系。
- [ ] 抽牌 / 能量 / 輔助牌背景為綠色或黃色系。
- [ ] 混合效果牌背景為紫色系。
- [ ] 卡牌文字與背景對比足夠。
- [ ] `結束回合` 按鈕位置清楚，不卡到手牌閱讀。

## MVP-v4 驗收

- [ ] 戰鬥 UI helper 已分出 header、actor sprites、hand layout、intent icon、passive display 等邊界。
- [ ] `docs/v4-balance-qa.md` 已更新為本輪平衡 QA 入口。
- [ ] `docs/character-art-spec.md` 已定義人物圖片重製路徑、尺寸、動作與驗收方式。
- [ ] Debug `3` 輪替普通敵人時，attack / block / attack_block / buff / debuff 都有 icon 與文字 fallback。
- [ ] Debug `2` 回角色選擇後，分別選 Subaru / Botan / AZKi 確認被動顯示與觸發提示。

## 失敗流程驗收

- [ ] 進入任一戰鬥。
- [ ] 持續結束回合或少防禦，直到玩家 HP 歸零。
- [ ] HP 歸零時進入挑戰失敗畫面。
- [ ] 挑戰失敗文字為繁體中文。
- [ ] 從失敗畫面可以回到重新開始或主流程入口。

## 通關流程驗收

- [ ] 從角色選擇開始完整跑一輪。
- [ ] 路線順序維持：開始、小怪 1、事件 1、小怪 2、寶箱、菁英、商店、事件 2、小怪 3、篝火、小怪 4、事件 3、小怪 5、Boss、結算。
- [ ] 每個節點完成後都推進到正確下一節點。
- [ ] 擊敗 Boss 後進入通關成功畫面。
- [ ] 通關成功文字為繁體中文。
- [ ] 通關後可以回到重新開始或主流程入口。

## MVP-v2 隨機地圖驗收

- [ ] 選擇 Subaru 後進入隨機地圖，而不是固定單一路線。
- [ ] 選擇 Botan 後進入隨機地圖，而不是固定單一路線。
- [ ] 選擇 AZKi 後進入隨機地圖，而不是固定單一路線。
- [ ] 地圖顯示 Seed、HP、Gold、Deck、Relic 與 Boss 預告。
- [ ] 地圖為 16 floor Boss 的單 Act 長路線；960x540 畫面下節點與 Boss 名稱不重疊。
- [ ] 只有目前可到達節點可點擊；未連線節點不可點。
- [ ] 完成節點後，下一層可到達節點正確更新。
- [ ] Boss 預告名稱與實際 Boss 戰敵人一致。
- [ ] 隨機地圖可進入普通戰、事件、菁英、寶箱、商店、篝火與 Boss。
- [ ] random map 至少能看到多個普通戰、2 個以上菁英候選、2 個以上商店、2 個以上篝火、事件與寶箱候選。
- [ ] 固定 debug 快捷鍵仍可單點進入普通戰、菁英、Boss、寶箱、商店、篝火、事件與 relic。
- [ ] random map floor 13-15 的普通戰只會出現後段高壓敵人，floor 11 後菁英不會回抽前段 duo。

## MVP-v2 系統深化驗收

- [ ] 戰鬥面板能看到玩家與敵人的狀態文字列。
- [ ] `strength` 會增加攻擊傷害。
- [ ] `weak` 會降低攻擊傷害。
- [ ] `vulnerable` 會增加受到的攻擊傷害。
- [ ] `regen` 會在回合交接時恢復 HP 並衰減。
- [ ] 商店可以購買卡牌。
- [ ] 商店卡牌左上角顯示依功能計算的購買金額，不再全部固定同價，也不和卡牌費用混在一起。
- [ ] 商店每次至少有一個商品顯示「特價」，且購買扣款符合標示價格。
- [ ] 同一個商店節點重開時，卡牌、relic 與特價商品維持不變，不會刷新。
- [ ] 購買卡牌或 relic 後，該商品會從同一商店節點的庫存移除，不會因重開商店回補。
- [ ] 商店卡牌下方顯示功能說明，能看出商品效果。
- [ ] 商店可以購買 relic，且不重複販售已持有 relic。
- [ ] 商店 relic 商品左上角顯示依 pool 計算的金額，下方顯示 relic 功能說明。
- [ ] 商店可以移除卡，Gold 不足時不可移除。
- [ ] 商店移除卡服務左上角顯示金額，下方顯示「選擇 1 張牌從牌組移除」。
- [ ] 商店移除卡會進入牌組選擇畫面，可上下滾動並指定要移除的卡。
- [ ] 篝火可選擇休息回復 HP。
- [ ] 篝火可進入牌組選擇畫面，可上下滾動並指定要升級的卡。
- [ ] 已升級過的 `+` 卡不會出現在篝火升級清單。
- [ ] Boss 勝利後進入 Boss 獎勵畫面，而不是直接結算。
- [ ] Boss 獎勵可選升級版卡牌、Boss relic，或直接進入結算。
- [ ] Event pool 至少有 16 個事件；事件選項能正確修改 HP、Gold、Deck、Relic，或觸發額外戰鬥。
- [ ] Relic pool 至少有 8 個 relic；relic 拿滿後 fallback Gold 顯示合理。

## 驗收紀錄

| 日期 | 版本 / 變更摘要 | 角色 | 結果 | 問題紀錄 |
| --- | --- | --- | --- | --- |
| 2026-05-12 | 後段難度曲線細化與ころね好き / 毛玉接入 | Subaru / Botan / AZKi | 自動測試通過；待手動驗收 | 需確認普通戰 / 菁英 debug 輪替可見新敵人，並實機感受 floor 11 後壓力提升 |
| 2026-05-12 | 商店節點庫存持久化 | Subaru / Botan / AZKi | 自動測試通過；待手動驗收 | 同一商店節點重開不刷新商品 / 特價；購買後商品不回補 |
| 2026-05-12 | 商店價格差異與特價第一版 | Subaru / Botan / AZKi | 自動測試通過；待手動驗收 | 需進商店確認卡牌 / relic 價格差異、特價顯示與扣款體感 |
| 2026-05-12 | 16 floor 長地圖、事件風險、relic 200 | Subaru / Botan / AZKi | 自動測試通過；待完整手動驗收 | 需完整跑 random map，確認地圖可讀、事件戰鬥回地圖、後段壓力與 relic 價格體感 |
| 2026-05-08 | 建立 QA checklist | Subaru / Botan | 未執行 | 待第一次完整手動驗收 |
| 2026-05-08 | Debug 快捷鍵驗收；完整流程沿用先前測試結果 | Subaru / Botan | `1` 到 `6` 測試 OK；本次未重跑完整流程 | 下一輪需驗收 Combat UI 細修後的卡牌區與資訊面板可讀性 |
| 2026-05-08 | Combat UI 細修驗收 | Subaru / Botan | 手牌不擋角色；卡牌文字可看出已調整，較不會跑版 | 本輪 Combat UI 可先視為通過；下一輪進入角色卡牌平衡 |
| 2026-05-08 | 獎勵節奏整理 | Subaru / Botan | 自動測試通過；菁英 Gold 較多已手動確認 | 歷史紀錄：當時寶箱仍有 Gold 40 流程，後續已改為固定 relic |
| 2026-05-08 | 卡牌文字安全區修正 | Subaru / Botan | 自動測試通過；待手動驗收 | 需確認戰鬥卡牌與獎勵卡牌不再溢出或重疊 |
| 2026-05-09 | MVP-v3 內容擴充與選卡 UI | Subaru / Botan | 自動測試通過；待手動驗收 | 需手動跑 random map，確認 V3 事件、敵人、Boss 與選擇 UI 觀感 |
| 2026-05-09 | 寶箱固定 relic 與升級清單修正 | Subaru / Botan | 自動測試通過；待手動驗收 | 寶箱不再多選；已升級卡不再顯示於篝火升級清單 |
| 2026-05-10 | 戰鬥 UI 試改 | Subaru / Botan | 自動測試通過；待手動驗收 | 移除大型深色底板、隱藏抽牌 / 棄牌、狀態移到角色下方、手牌改 3:4 直式 |
| 2026-05-10 | 類 StS 卡牌 UI 試改 | Subaru / Botan | 自動測試通過；待手動驗收 | 卡牌外框、費用 badge、圖片預留區、類別與描述區已建立；手牌改底部扇形排列，hover 原地放大置頂 |
| 2026-05-10 | QA / 平衡 / 角色被動 / V4 規劃 | Subaru / Botan | 自動 QA 通過；待實機手動試玩 | 新增 Subaru / Botan 被動、微調卡牌與敵人壓力、建立 `docs/v4-roadmap.md` |
| 2026-05-10 | MVP-v4 第一版落地 | Subaru / Botan | 自動測試通過；待實機手動試玩 | 戰鬥 UI helper 分區、角色被動可視化、敵方意圖 icon placeholder、平衡 QA 文件與人物圖片規格已完成 |
| 2026-05-08 | Debug 快捷鍵補強 | Subaru / Botan | 自動測試通過；待手動驗收 | 新增 `8` 寶箱、`9` 商店、`0` 篝火快速入口 |
| 2026-05-08 | Relic v0 | Subaru / Botan | 自動測試通過；待手動驗收 | 寶箱 / 菁英 / 商店 / debug 可取得 relic，三個簡版 hook 已接入 |
| 2026-05-08 | Event v0 | Subaru / Botan | 自動測試通過；待手動驗收 | 新增固定 HoloStar 贊助事件，沒有離開選項 |
| 2026-05-09 | Event v1 / Relic fallback / 隨機地圖規格 | Subaru / Botan | 自動測試通過；待手動驗收 | 三個事件節點改為不同事件；relic 拿滿改給 Gold 25；新增 random map v1 規格 |
| 2026-05-09 | 隨機地圖 v1 資料骨架 | N/A | 自動測試通過；尚未接 UI | 新增 RandomMapGenerator 與 random_map_tests；固定路線仍是目前遊戲主流程 |
| 2026-05-09 | MVP-v2 接入 | Subaru / Botan | 自動測試通過；待完整手動驗收 | Random map 主流程、Boss 預告、簡版 status、event / relic v2、商店移除卡、篝火升級卡、Boss reward 已接入 |

## 問題記錄格式

發現問題時，建議用以下格式記錄到對話或 issue：

```text
畫面：
角色：
節點：
操作：
預期：
實際：
是否可重現：
截圖或補充：
```
