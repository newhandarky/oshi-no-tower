# MVP-v4 平衡 QA 紀錄

更新日期：2026-05-12

## 目標

MVP-v4 的平衡目標不是正式定稿，而是確認 16 floor 單 Act random run 有自然推進的壓力曲線，且 Subaru / Botan / AZKi 的角色差異能被玩家感受到。

## 自動檢查基準

- `tests/headless/runtime_database_tests.gd`
  - Subaru 維持大量 0/1 費牌、抽牌 / 循環與多段攻擊。
  - Botan 攻擊牌平均輸出高於 Subaru，且保留弱化 / 易傷控制。
  - 普通敵人需標記 early / mid / late `encounter_tier`，並各自落在對應壓力區間。
  - 菁英與 Boss 的最大傷害與 HP 落在長路線後段壓力區間內。
  - 商店 relic 價格固定 200 Gold；移除卡、篝火休息與起始 Gold 不作為本輪加難手段。
- `tests/headless/combat_engine_tests.gd`
  - Subaru 被動每回合第一次 0/1 費牌給 3 格擋。
  - Botan 被動每回合第一次 2 費攻擊追加 6 傷害。
- `tests/headless/combat_ui_layout_tests.gd`
  - 角色被動在角色選擇與戰鬥中可見。
  - 被動觸發提示會短暫出現。
  - 敵人意圖 icon placeholder 與文字 fallback 同時存在。

## 手動 QA 節奏

每次做數值調整後，至少跑以下流程：

1. Subaru random map 一輪。
2. Botan random map 一輪。
3. Debug `3` 輪替普通敵人，確認普通戰 1 到 3 回合可結束。
4. Debug `6` 進菁英戰，確認需要看意圖並做防禦 / 爆發選擇。
5. Debug `4` / `5` 輪替 Boss，確認 Boss 至少 3 到 5 回合，有蓄力、debuff 或攻防節奏。
6. 在 random map 遇到事件戰鬥時，確認勝利後回到地圖並完成原事件節點。

## 目前 V4 平衡結論

- Subaru 定位：低費、抽牌、格擋節奏。被動讓 0/1 費牌有防禦價值，鼓勵節奏牌起手。
- Botan 定位：2 費爆發、弱化 / 易傷控制、穩定防線。被動讓第一張 2 費攻擊成為回合重點。
- 普通戰 early：最大壓力 9 到 15，HP 不超過 58，讓前 3 floor 仍可穩定建立牌組。
- 普通戰 mid：最大壓力 10 到 20，HP 不超過 66，開始加入 buff / debuff 與攻防混合。
- 普通戰 late：最大壓力 14 到 24，HP 不超過 72，用於 floor 9 之後提高消耗與決策壓力。
- 菁英戰：最大壓力 18 到 24，HP 92 到 108，維持高於普通戰且需要看意圖行動。
- Boss：最大壓力 24 到 32，HP 112 到 132，保留明顯威脅但仍可透過格擋、debuff 與爆發節奏應對。

## 調整原則

- 若玩家無視意圖也能輕鬆通關，先提高菁英 / Boss 的攻防混合回合，而不是單純加 HP。
- 若普通戰拖太久，優先降低普通敵人 HP，而不是增加玩家輸出。
- 若 Subaru 太弱，優先加強 0/1 費牌的循環或格擋。
- 若 Botan 太弱，優先加強 2 費牌的回報或控制牌穩定性。
- 若 relic 造成滾雪球，先調整取得來源或數值，不直接砍角色基礎牌；商店 relic 價格目前固定 200。
- 若長路線仍過於簡單，優先增加後段 encounter pool 與事件風險，不調低起始 Gold、移除卡、篝火休息或一般補給。
