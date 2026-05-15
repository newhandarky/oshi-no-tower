# 長期實作路線圖（Godot 調整版）

本文件由 Web 版 `docs/full-implementation-roadmap.md` 搬入並調整。原始版本一度以 Unity 2D 作為正式實作方向；目前 Unity 不再採用，正式方向改為 Godot。

## 1. 專案定位

Oshi no Tower 是 Hololive fan game / 非商業原型。玩法參考 Slay the Spire 的 deckbuilding roguelite，但目前目標仍是小型可玩 MVP。

第一原則：

1. 先確保能啟動。
2. 再確保能完整跑一輪。
3. 再做角色、卡牌、敵人差異。
4. 最後才做 UI polish、音效、更多內容。

## 2. 目前階段

目前 Godot 版約位於「MVP 已可玩，進入驗收與 polish」階段。

已完成：

- Godot 專案骨架。
- 固定路線。
- Subaru / Botan 可遊玩。
- Combat engine MVP。
- 普通戰與 Boss 戰。
- 寶箱、商店、篝火。
- 通關與失敗。
- 主要 sprite 與背景。
- Debug / 驗收快捷鍵。
- CombatEngine headless 測試。
- README / AGENTS / 狀態文件。

尚未完成：

- 完整 UI / 流程自動測試。
- 實機 UI 細調。
- 穩定的卡牌平衡。
- credits / disclaimer / 素材授權整理。
- 音效與 BGM。
- 發布流程。

## 3. Godot 開發路線

| Phase | 名稱 | 目標 |
| --- | --- | --- |
| Phase 0 | 歷史文件整理 | 把 Web 設計文件搬入 Godot，統一現況描述。 |
| Phase 1 | MVP 穩定化 | 修 UI、修阻塞問題、保持完整路線可玩。 |
| Phase 2 | Combat 測試 | 已建立 CombatEngine headless 測試，後續擴充流程測試。 |
| Phase 3 | UI / UX Polish | 調整戰鬥資訊、卡牌文字、Boss 呈現。 |
| Phase 4 | 卡牌平衡 | 只調現有卡，強化 Subaru / Botan 差異。 |
| Phase 5 | 素材與授權紀錄 | 整理已使用素材來源、prompt、pipeline metadata。 |
| Phase 6 | Demo 準備 | 補 README、操作說明、build / export 流程。 |
| Phase 7 | 後續擴充 | 只有在 MVP 穩定後才考慮新系統。 |

## 4. 不再採用 Unity 路線

Unity 版已停止作為後續方向，原因是目前專案規模與迭代節奏更適合 Godot。

不再需要：

- Unity 場景架構。
- Unity `MonoBehaviour` UI 實作。
- Unity `Library` 快取。
- Unity-specific porting notes。

可保留為歷史參考的只有：

- 曾經的 C# combat engine 分離思路。
- EditMode test 的測試案例方向。
- 部分 runtime-ready 素材。

## 5. Combat Engine 測試路線

目前已建立 CombatEngine headless 測試。後續可繼續擴充以下測試或 headless check：

- `start_combat` 初始化玩家、敵人、能量、手牌。
- `try_play_card` 成功與失敗條件。
- Damage / Block / Draw / Energy 效果。
- Enemy intent：attack、block、attack_block。
- Victory / defeat。
- 抽牌堆與棄牌堆循環。

## 6. UI / UX 路線

近期重點：

- 戰鬥資訊面板可讀。
- 手牌區不要擋住角色。
- 卡牌文字不要太擠。
- Boss 名稱與 BOSS 標籤明顯。
- Debug 提示不干擾正式遊玩。

暫不做：

- 大量 UI skin。
- 複雜動畫 timeline。
- 完整設定選單。
- 多解析度完整支援。

## 7. 內容擴充規則

在 MVP 穩定前不新增：

- Relic。
- 隨機事件。
- 隨機地圖。
- 多 Act。
- 大量卡池。
- 存檔。
- Meta progression。

若未來要新增，必須先有：

- 明確驗收條件。
- 不破壞目前固定路線。
- 不讓 `scripts/Game.gd` 繼續無限制膨脹。

## 8. 發布前需要補齊

- 繁中 README。
- Fan game disclaimer。
- 素材來源與授權紀錄。
- 操作說明。
- Debug 功能是否保留或隱藏的決策。
- Godot export 設定。
- 最小 QA checklist。
