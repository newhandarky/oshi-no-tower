# MVP-v4：Combat Feel & UI Componentization

更新日期：2026-05-10

## 目標定位

MVP-v4 的重點不是再一次大量擴內容，而是把 MVP-v3 已經可玩的短版 random run 收斂成更穩定、可維護、可手動驗收的版本。

本階段優先處理戰鬥手感、UI component 化、角色差異可視化、敵人行為深度與下一輪素材替換準備。新內容可以少量加入，但必須服務於「可讀、可玩、可維護」。

## V4 完成狀態

- 已完成 `scripts/Game.gd` 戰鬥 UI helper 分區：header、actor sprites、hand layout、intent icon、passive display。
- 已完成戰鬥 UI layout headless 測試：卡牌、手牌排列、hover、商店商品、角色被動、敵方意圖 icon。
- 已完成 Subaru / Botan 被動可視化：角色選擇畫面、戰鬥狀態區、觸發短訊息。
- 已完成敵方意圖第一版 symbol placeholder：攻擊、防禦、攻防、buff、debuff。
- 已建立 `docs/v4-balance-qa.md` 作為平衡 QA 紀錄入口。
- 已建立 `docs/character-art-spec.md` 作為人物圖片重製規格。
- 已保留 MVP-v2 / v3 的 random map、寶箱固定 relic、商店/篝火選擇 UI、Boss reward。

## 主要範圍

### 1. 戰鬥 UI component 化

目前 `scripts/Game.gd` 是 MVP 快速迭代用的大型動態 UI。V4 建議先拆戰鬥相關部分，不急著重構所有畫面。

已拆分的 helper 邊界：

- `_add_combat_header_ui()`：Boss overlay、狀態資訊、relic summary。
- `_add_combat_actor_sprites()`：玩家 / 敵人 sprite 與受擊、攻擊演出位置。
- `_add_combat_hand_ui()`：手牌建立與 hover 設定。
- `_combat_hand_card_position()`：以畫面中央為核心的扇形手牌排列。
- `_intent_icon_text()`：敵方意圖 icon placeholder + 文字 fallback。
- `_passive_display_text()`：角色被動顯示文字。

驗收條件：

- 拆分後 `combat_ui_layout_tests.gd` 通過。
- hover 不閃爍，放大後說明文字不被底部裁切。
- 移除大型底板後，文字仍透過陰影/描邊維持可讀。

### 2. 角色被動可視化

目前角色被動已接入戰鬥核心：

- Subaru：每回合第一次打出 0/1 費牌時獲得 3 格擋。
- Botan：每回合第一次打出 2 費攻擊牌時追加 6 傷害。

V4 已補上：

- 角色選擇畫面顯示被動名稱與一句說明。
- 戰鬥中在人物附近或狀態區顯示被動名稱。
- 被動觸發時有短暫提示，不永久停留。
- headless 測試確認角色資料、CombatEngine 行為與 UI 顯示一致。

### 3. 敵人行為與意圖 icon

目前意圖以文字顯示。V4 建議先用簡單符號或 icon placeholder，而不是馬上做完整美術。

第一版規格已採用文字 symbol placeholder：

- attack：`⚔`，加傷害數字。
- block：`▣`，加格擋數字。
- attack_block：`⚔▣`，加傷害 / 格擋數字。
- debuff：`↓`，加文字 fallback。
- buff：`↑`，加文字 fallback。

驗收條件：

- 所有現有敵人 action 都能轉成 icon + 文字 fallback。
- 長描述仍可讀，不和 Boss 名稱或角色 sprite 重疊。
- debug `4` / `6` 可快速檢查普通敵人與 Boss。

### 4. 平衡 QA

V4 平衡不追求正式商業級數值，而是讓短版 run 有基本壓力曲線。

平衡目標：

- 普通戰：1 到 3 回合內能結束，但若完全不防禦會有明顯扣血。
- 菁英戰：需要看意圖並選擇防禦/爆發，不應只是無腦輸出。
- Boss：至少需要 3 到 5 回合，有明確蓄力或 debuff 回合。
- Subaru：手感偏低費、抽牌、格擋節奏。
- Botan：手感偏 2 費爆發、控制、穩定防線。

驗收方式：

- 保留 `runtime_database_tests.gd` 的角色卡池輪廓與敵人壓力門檻。
- 使用 `docs/v4-balance-qa.md` 記錄 Subaru / Botan 各跑一次 random map 的體感。
- 每次調整數值都跑 CombatEngine、RuntimeDatabase、Combat UI layout、status、shuffle、shop/campfire 測試。

### 5. 人物圖片重製準備

角色圖建議在 V4 中後段做，原因是目前戰鬥 UI、卡牌 hover、狀態位置已比較穩定，接下來替換角色圖比較不會反覆重切。

已建立規格：

- 詳見 `docs/character-art-spec.md`。
- 每個角色至少 idle / normal_attack / defense / hurt / signature action。
- sheet 命名沿用目前路徑。
- 確認 960x540 基準畫面中角色不壓到狀態文字與手牌 hover。

## 非目標

- 不做完整多 Act。
- 不做正式存檔系統。
- 不做完整 Power / Curse / Potion 大系統。
- 不大幅新增 meme 內容池，除非用於測試敵人行為或角色被動。
- 不在 UI 尚未拆分前大量導入複雜動畫。

## 建議實作順序

1. 已完成：拆戰鬥 UI helper，先處理卡牌與手牌 layout。
2. 已完成：補角色被動 UI 顯示與觸發提示。
3. 已完成：做敵方意圖 icon placeholder。
4. 已完成：擴充平衡 QA 測試與手動紀錄入口。
5. 已完成：設定人物圖片重製規格。
6. 待後續決定是否進入 MVP-v5：多 Act、存檔、完整事件變體、更多角色。

## V4 驗收重點

- 戰鬥畫面在無底板狀態下仍可讀。
- 手牌 hover 與點擊穩定，不閃爍、不遮住必要按鈕。
- Subaru / Botan 被動確實改變出牌決策。
- 敵人意圖能快速辨識，不只靠讀長文字。
- 平衡紀錄可說明每次數值調整的理由。
- 後續角色圖片重製有明確規格，不會打亂 UI layout。
