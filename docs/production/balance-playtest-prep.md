# Balance / Playtest Prep

最近更新：2026-05-21

## 目的

本文件整理 006-019 後的 headless 平衡基準，作為下一輪 manual full-run 前的交接入口。這輪不做 GUI/manual QA，也不把 automated proxy 當成 creative acceptance。

## 目前 headless guardrail

`tests/headless/multiseed_balance_probe_tests.gd` 在 006 後要求三角色各至少 4/10 抵達第一章 `boss_reward`。007 / 008 後的實際固定 seed 結果已提升到：

| 角色 | 目前結果 | 重點 |
| --- | --- | --- |
| Subaru | Subaru 7/10 | 015 補基礎中段防守；018 再補 `subaru-encore-recall` / `subaru-afterimage-table` 的防守安全性，不新增能量。 |
| Botan | Botan 7/10 | 006 後維持較高穩定度；009 不主動 buff Botan。 |
| AZKi | AZKi 7/10 | 015 補 boss 收束效率；018 再補 `azki-laplus-combo` / `azki-necrobinder-finale` 的 late payoff，不 buff starter。 |

009 起，後續若再動平衡，應至少維持 `Subaru >= 5/10`、`Botan >= 5/10`、`AZKi >= 5/10`。若某角色跌破此基準，需先解釋是刻意換取體感、敵人壓力或 reward 密度調整，而不是無意退化。

## Manual full-run gate

manual full-run 仍是 Desktop Build Readiness 與 Creative Director final acceptance 的前置條件。執行時建議記錄：

- 012 起，結算畫面會顯示截圖友善的 `QA 回報摘要`，可直接截圖取得角色、結果、seed、Boss、死亡樓層、死亡敵人、死亡前 HP、主要 deck/relic、體感問題與 UI 問題。畫面上的 deck/relic 以中文名稱摘要顯示，完整 card / relic id 仍保留在 headless `qa_report`。
- 011 起，headless `playable_demo_auto_run_log` 與 `multiseed_balance_probe_log` 也會輸出同格式的 `qa_report` / `qa_report_text`，玩家回報與自動測試可用同一套欄位比對。
- 使用者實機回報時，優先補充畫面摘要沒有自動知道的「體感問題」與「UI 問題」。
- 角色：Subaru / Botan / AZKi 各至少一輪 16 floor random run。
- 體感：是否常見「能活但殺不掉」、「能殺但擋不住」、「reward 看起來沒有成形方向」。
- UI：Boss warning、tooltip、hand hover、event option 是否有遮擋或文字 overflow。
- 012 起，事件與 Chapter start event 會顯示 HP / Gold / Deck / Relic 狀態列；手測事件選項時可直接看畫面判斷代價是否合理。
- 012 起，戰鬥手牌 hover 改為非互動 `CombatHoverPreview`，原卡 hitbox 固定；手測時仍需留意是否有實機點擊抖動，但 headless guard 已會擋主要跑版與 hover hitbox 回退。
- AZKi 額外項目：`laplus_dash` / `laplus_crash` 實機打出時，AZKi body、Laplus summon、FX 與 Laplus HP label 是否互相遮擋；Laplus 在敵方回合倒下後，下一個玩家回合應以 1 HP 復活。
- 013 起，`multiseed_balance_probe_tests.gd` 會額外輸出 `multiseed_balance_probe_failure_cases`，集中列出每個死亡 seed 的角色、seed、Boss、死亡樓層、死亡敵人、中文 deck/relic 摘要與可複製 QA report text。這是 headless 端的分群入口，可用來對照玩家截圖，不需要再從 30 筆逐局 log 裡人工撈失敗案例。
- 014 起，`multiseed_balance_probe_tests.gd` 也會輸出 `multiseed_balance_probe_failure_analysis`，把失敗案例聚合成角色別 `repeated_defeat_floors`、`repeated_defeat_enemy_ids`、`boss_failures`、`midrun_failures`、`curse_seen` 與 `likely_issues`。這是判讀輔助，不是自動調平衡指令；任何數值調整仍需看玩家體感或明確 repeated pattern。
- 015 起，multiseed guard 會額外保護兩個 repeated pattern：AZKi 死於 `ssrb-giant-camouflage` 不可超過 2 次，Subaru 死於 `ssrb-debuff-check` 不可超過 1 次。manual full-run 時優先確認 AZKi boss 節奏是否仍拖太長，以及 Subaru 中段防守是否變穩但沒有能量過多感。
- 016 起，`playable_demo_auto_run_log` 與 `multiseed_balance_probe_log` 都會輸出 `energy_summary`，包含 `combat_count`、`turns_total`、`average_unspent_energy`、`max_turn_end_energy`、`high_unspent_energy_turns`、`energy_spent`、`energy_gained`、`cards_played` 與 `economy_flags`。若 Subaru 同 seed 的 `average_unspent_energy >= 1.5` 且 `high_unspent_energy_turns >= 8`，會標記 `subaru_energy_overflow_watch` 供下一輪分析，但不會直接讓測試失敗或自動 nerf。
- 016 multiseed 觀測結果：Subaru 6/10、Botan 7/10、AZKi 7/10 仍通過 guardrail；Subaru 角色層級 `average_unspent_energy` 約 0.15、`max_turn_end_energy` 為 2、`high_unspent_energy_turns` 為 8，未觸發 `subaru_energy_overflow_watch`。若手測仍覺得能量太多，請保留 seed，之後可用同 seed 的 `energy_summary` 對照是「能量真的花不完」還是「回合節奏 / 抽牌密度讓玩家感覺資源過剩」。
- 017 起，`playable_demo_auto_run_log` 與 `multiseed_balance_probe_log` 會輸出更完整的 pacing telemetry：`combat_summaries` 記錄每場戰鬥的 enemy、floor、node type、turns、start/end HP、damage taken、cards played、average unspent energy 與 result；`boss_pacing_summary` 記錄 boss id、boss turns、boss start/end HP 與是否超過 pacing threshold；`route_risk_summary` 記錄 event 數、event battle 數、curse 增加、事件失血、事件花費 Gold 與事件取得 relic；`run_health_flags` 只做觀察標記，不直接讓測試失敗。
- 017 watch flags：AZKi boss 戰 `turns >= 12` 會標記 `azki_boss_pacing_watch`；Boss 戰開始 HP 低於 18 且事件失血 >= 14 會標記 `event_risk_compounding_watch`；Subaru floor 7-11 死亡或戰後 HP <= 10 會標記 `subaru_midrun_hp_pressure_watch`。這些 flag 是下輪判讀線索，不是自動 nerf / buff 指令。
- 018 起，AZKi 只補 late payoff，不 buff starter：`azki-laplus-combo` 10x2 -> 11x2，`azki-necrobinder-finale` 22+10 -> 24+12 / 升級 26+12 -> 28+14。Subaru 只補中段防守與 payoff 安全性，不加能量：`subaru-encore-recall` block 4/7 -> 6/9，`subaru-afterimage-table` 條件 block 5/7 -> 6/9。Reward draft 也會在 AZKi late 缺 payoff、Subaru 中段 cheap-chain 但防守 / bridge 不足時更積極推對應 bridge / payoff；Botan 僅保留 guardrail，不主動 buff。
- 018 multiseed 觀測結果：Subaru 7/10、Botan 7/10、AZKi 7/10 皆通過 guardrail；AZKi 死於 `ssrb-giant-camouflage` 維持 2 次內，Subaru 死於 `ssrb-debuff-check` 維持 1 次內。仍觀察到 `azki_boss_pacing_watch` 1 次、`subaru_midrun_hp_pressure_watch` 4 次、`event_risk_compounding_watch` 1 次，所以下輪 manual full-run 優先看這三類體感。
- 019 起，UI 自檢重點是不把 `boss_pacing_summary`、`route_risk_summary`、`run_health_flags` 直接塞進結算畫面，避免再次造成長文跑版；畫面保留截圖可讀的 `QA 回報摘要`，完整分析資料留在 headless structured log。

## 下一步建議

1. 下一輪若能 manual QA，直接截取結算畫面的 `QA 回報摘要`，再補體感 / UI 問題；我可用截圖與 failure cases / failure analysis / energy_summary / boss_pacing_summary / route_risk_summary 對照。
2. 優先手測 AZKi boss turns 是否仍拖太長、Subaru floor 7-11 是否仍低血硬撐、事件路線是否因失血 / curse / Gold 花費疊加而讓 boss 前資源過低，以及 Subaru 是否仍有能量過多感。
3. 若繼續自動化，下一步適合做 reward path density probe 或 event-risk tuning；不要在沒有玩家新回報時大幅調整敵人或 Botan。
