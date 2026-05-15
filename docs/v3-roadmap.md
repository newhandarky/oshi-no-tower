# MVP-v3 規劃：Meme Content Expansion

更新日期：2026-05-09

## 目標定位

MVP-v3 的核心不是再做一輪大型系統重寫，而是把 MVP-v2 已經接起來的隨機路線、事件、商店、篝火、Boss reward 與 status 系統，擴充成「內容有梗、玩法有差異、重複度可控」的版本。

本階段會參考 `docs/meme.md` 作為事件、卡片、relic、敵人與 Boss 的內容素材池，但不會把同一個 meme 反覆套成相同效果。每個新內容都需要有明確 gameplay 用途，並標註來源 meme 或內容群組，方便後續檢查重複。

## V3 完成定義

- 事件池從 MVP-v2 的 6 個擴充到至少 12 個。
- Relic 池從 MVP-v2 的 9 個擴充到至少 16 個。
- Subaru 與 Botan 各新增至少 4 張角色牌，並讓兩人的 build 方向更明顯。
- 新增至少 3 種 meme 主題敵人或精英敵人，並新增至少 1 個非「巨大 SSRB White」的 Boss 候選。
- 商店移除卡與篝火升級卡改為玩家可選，而不是自動選第一張。
- 新增內容資料需包含 `meme_source`、`content_group` 或等價欄位，用於去重與後續 QA。
- 新增 headless 測試檢查內容 id 不重複、meme source 不過度集中、升級/商店選擇流程可用。
- 更新 `docs/manual-qa-checklist.md`，加入 V3 meme 內容、商店、篝火、Boss 候選驗收項目。

## 內容去重規則

V3 會把 `docs/meme.md` 視為「素材池」，不是直接照單全收。

- 同一個 meme 在同一版內優先只承擔一種主要系統責任。
  - 例：`Shishiro Button` 若用於 Botan 控制 relic，就不要同時再做成效果相近的事件與卡片。
- 若同一 meme 必須跨類型使用，需要有不同玩法責任。
  - 例：`Superchat Time` 可以同時是 Gold 事件與 economy relic，但事件負責一次性選擇，relic 負責長期經濟回饋。
- 避免新增只改數字的重複內容。
  - 不新增「造成 X 傷害」與「獲得 X 格擋」的純數值卡，除非它有 status、抽牌、能量、升級或 relic synergy。
- 避免與 MVP-v2 事件重複。
  - MVP-v2 已有 HP 換 Gold、Gold 換 relic、加角色卡、休息/補血、簡單 merch 獎勵等功能，V3 新事件應優先做選邊、高風險、延遲代價、路線情報或 build 轉向。
- 不使用歌詞、長篇直播台詞或真人隱私內容。
- 對真人與團體維持粉絲向、輕度惡搞，不做惡意化描寫。

## 事件範圍

V3 事件應從「拿資源」擴展到「做選擇」。建議新增 6 到 8 個事件，讓事件池達到至少 12 個。

| 事件候選 | 來源 meme | 主要玩法 | 避免重複方式 |
| --- | --- | --- | --- |
| 重大告知倒數 | Important Announcement | 高壓選擇：取得 Boss 情報、稀有獎勵或承受 HP/Gold 代價 | 不做單純獎勵事件，主打風險與預告 |
| EN Curse 事故台 | EN Curse / YouTube-kun | 下一場戰鬥起始弱化，換取 relic 或高額 Gold | 作為 temporary run modifier，不只是扣血 |
| Twitter Jail | Twitter Jail | 封印一張牌一場戰鬥，或付 Gold 移除牌 | 對應 deck 操作，不做一般商店折扣 |
| Pineapple Pizza War | Pineapple Pizza War | 選攻擊陣營或防守陣營，各給不同卡與代價 | 選邊事件，強化 build 分歧 |
| Superchat Time | Superchat Time | 一次性 Gold 爆發，或把 Gold 轉換成升級/卡牌 | 經濟轉換事件，不直接等同商店 |
| Unarchived Karaoke | Unarchived Karaoke | 取得一次性強化、升級卡或短期 buff | 僅用泛化演出文案，不引用歌詞 |
| Zen-loss 全損現場 | Zen-loss | 失去 Gold/卡/relic 換強力補償 | 高風險事件，保留拒絕選項 |
| HoloMoms 應援 | HoloMoms | 恢復、保護或清除負面狀態 | 作為溫和 recovery，不再複製 V2 補血事件 |

## 卡片範圍

V3 卡片要讓 Subaru 與 Botan 的差異更明顯。新增卡不只補數量，而是補 build 方向。

### Subaru：節奏、支援、元氣防守

Subaru 牌組方向建議強化低費連動、格擋後反擊、Teetee/應援型支援。

| 卡牌方向 | 來源 meme | 效果概念 |
| --- | --- | --- |
| Duck Tempo | 鴨 / 社團感 | 低費攻擊，若本回合已獲得格擋則抽 1 張 |
| Teetee Guard | Teetee | 獲得格擋，若敵人有 weak/vulnerable 額外獲得能量或抽牌 |
| Desk-kun Reaction | Desk-kun -10 HP | 造成小傷害並獲得格擋，升級後追加 vulnerable |
| Blue Wave Cheer | Blue Wave | 小恢復或 regen，附帶抽牌，作為稀有防守牌 |
| New Oshi Call | X is my new oshi | 加入一張臨時支援牌或複製本回合第一張技能牌的輕量效果 |

### Botan：精準、控制、穩定火力

Botan 牌組方向建議強化 weak/vulnerable、精準多段、控制後增益。

| 卡牌方向 | 來源 meme | 效果概念 |
| --- | --- | --- |
| Button Check | Shishiro Button | 給 weak，若目標已有 debuff 則抽 1 張 |
| Clean Scope | Clean your badges | 獲得格擋並清除自己 1 層負面狀態，升級後追加能量 |
| Calm Burst | Botan 冷靜火力 | 高費高傷，若敵人有 vulnerable 則降低費用或追加傷害 |
| Precise Cover | 獅子 / 防線 | 獲得格擋，下一張攻擊牌追加傷害 |
| Funds Prepared | X Funds | 花 Gold 取得臨時強化或本場戰鬥 bonus damage |

## Relic 範圍

V3 relic 要避免重複 MVP-v2 的「戰鬥開始加格擋/抽牌/加傷」單純效果。建議新增 7 到 9 個 relic，讓 relic 池達到至少 16 個。

| Relic 候選 | 來源 meme | 效果概念 | 主要類型 |
| --- | --- | --- | --- |
| YAGOO is Best Girl | YAGOO is best girl | 事件負面代價首次降低，或 Boss reward 多一個選項 | 稀有事件 relic |
| Shishiro Button | Shishiro Button | 每場第一次給 enemy weak/vulnerable 時抽 1 張 | Botan/control |
| Superchat Reading | Superchat Time | 戰鬥勝利後若 HP 未損失，額外 Gold | Economy |
| X Funds Wallet | X Funds | 商店第一次購買打折，或移除卡折扣 | Shop |
| Ada TV | Ada TV | 事件選項多一個低風險路線，或事件獎勵小幅提升 | Event |
| Pamomi Signal | id:entity Pamomi ver. | 每場第一次獲得 regen 時額外抽牌/格擋 | Recovery |
| Blue Wave Badge | Blue Wave | 每次進入寶箱或事件後小恢復 | Sustain |
| Unarchived Archive | Unarchived Karaoke | 每場第一張升級牌額外觸發輕量效果 | Upgrade synergy |
| YAGOO Blood Pressure Meter | YAGOO 血壓 | 若一回合打出 4 張以上牌，獲得 bonus damage 但失去少量格擋 | Risk/reward |

## 敵人與 Boss 範圍

V3 需要讓路線上的戰鬥不只是 SSRB 變體。新增敵人應優先使用 meme 梗的「系統效果」，而不是只換名字。

| 敵人候選 | 來源 meme | 戰鬥角色 |
| --- | --- | --- |
| YouTube-kun | YouTube-kun / EN Curse | 技術事故敵人，會施加 weak、降低抽牌或干擾能量 |
| Desk-kun | Desk-kun -10 HP | 反擊型敵人，玩家攻擊後可能觸發小反傷 |
| Announcement Shadow | Important Announcement | 蓄力型敵人，明確 telegraph 大招 |
| AK-47 Idol Unit | AKB48 → AK-47 | 精英敵人，短回合高火力壓力，命名與演出保持輕度惡搞 |

Boss 候選建議新增至少 1 個：

- `YouTube-kun Core`：以技術事故、延遲、debuff 為主題。
- `Important Announcement`：以蓄力告知、假警報、壓力選擇為主題。

Boss 文案需要避免指向真人負面描述，主體應是舞台事故、平台事故或抽象化 meme。

## 系統補強

V3 不建議先做完整多 Act 或存檔，應優先補目前內容擴充會遇到的資料與 UI 問題。

### 內容資料 metadata

事件、卡牌、relic、敵人定義建議補上：

- `meme_source`：來自 `docs/meme.md` 的梗名。
- `content_group`：例如 `economy`、`control`、`recovery`、`risk_reward`、`shop`。
- `rarity`：用於商店、寶箱與 reward pool。
- `character`：卡牌限定 Subaru、Botan 或通用。
- `implementation_status`：`planned`、`implemented`、`qa_passed`。

### Reward 與選擇 UI

- 篝火升級卡：改成玩家選一張可升級卡。
- 商店移除卡：改成玩家選一張要移除的卡。
- Boss reward：保留卡、Boss relic、結算選項，但補上更清楚的可選狀態與禁用狀態。
- Debug/reward toast：延續 MVP-v2 的自動消失規則，新增事件與 relic 都不得留下永久提示。

### 測試

新增或擴充 headless 測試：

- `content_metadata_tests.gd`：檢查新增內容都有 `meme_source` 或等價 metadata。
- `content_duplicate_tests.gd`：檢查 id 不重複、同一 `meme_source` 不過度集中於同一效果。
- `campfire_selection_tests.gd`：篝火可選升級卡，升級後數值與描述同步。
- `shop_remove_selection_tests.gd`：商店移除卡可選目標，Gold 與 deck 正確更新。
- `enemy_meme_behavior_tests.gd`：新敵人的 intent 與 status 效果可執行。

## 非目標

MVP-v3 暫不包含：

- 新 playable 角色。
- 完整多 Act 地圖。
- 完整存檔/讀檔。
- 完整 potion、power、curse 大系統。
- 大型動畫演出與音效系統。
- 歌詞、長篇直播台詞或未確認私人梗。
- 惡意描寫真人或社群成員。

## 建議實作順序

1. 補內容 metadata 與去重測試，先讓內容擴充有檢查基準。
2. 實作商店移除卡選擇與篝火升級卡選擇，解決目前自動選第一張的 UX 限制。
3. 擴充事件池到至少 12 個，優先做 `Important Announcement`、`EN Curse`、`Twitter Jail`、`Pineapple Pizza War`。
4. 擴充 Subaru/Botan 卡池，各新增至少 4 張並接升級版。
5. 擴充 relic 池到至少 16 個，優先做 economy、event、control、recovery 四類。
6. 新增 meme 主題敵人與 1 個 Boss 候選，接入 random map Boss pool。
7. 更新 manual QA，跑完整 headless 測試與 Subaru/Botan 手動驗收。

## 驗收重點

- Subaru 與 Botan 開局後，路線、事件、relic、Boss 候選仍可透過 seed 重現。
- 新事件不會大量重複同一種「付出 A 獲得 B」公式。
- 新卡牌在卡面上維持單行數值呈現，例如 `抽牌 1`、`能量 1`，不要回到換行版式。
- 新 relic 的提示訊息會自動消失。
- 商店商品可滾動，且商品、按鈕、debug 訊息不重疊。
- 篝火升級與商店移除卡由玩家選擇，取消或離開時狀態不壞掉。
- Boss 區塊文字不跑版，長名稱可壓縮或換行但不能超出面板。
- 新 meme 內容能看出來源，但不需要玩家懂梗才能理解效果。
