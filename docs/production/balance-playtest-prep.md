# Balance / Playtest Prep

最近更新：2026-05-21

## 目的

本文件整理 006-008 後的 headless 平衡基準，作為下一輪 manual full-run 前的交接入口。這輪不做 GUI/manual QA，也不把 automated proxy 當成 creative acceptance。

## 目前 headless guardrail

`tests/headless/multiseed_balance_probe_tests.gd` 在 006 後要求三角色各至少 4/10 抵達第一章 `boss_reward`。007 / 008 後的實際固定 seed 結果已提升到：

| 角色 | 目前結果 | 重點 |
| --- | --- | --- |
| Subaru | Subaru 5/10 | 007 補 `subaru-desk-reaction` 與 `subaru-tsukkomi`，改善前中段菁英穩定度。 |
| Botan | Botan 7/10 | 006 後維持較高穩定度；009 不主動 buff Botan。 |
| AZKi | AZKi 5/10 | 008 補 `azki-phantom-route` / `azki-necro-recall` 直接格擋，改善後段 Boss 與部分 floor 11 壓力。 |

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

## 下一步建議

1. 先完成 013 並保留 `multiseed_balance_probe_failure_cases`，讓後續平衡討論可直接看失敗 seed 分群。
2. 下一輪若轉 manual QA，直接截取結算畫面的 `QA 回報摘要`，再補體感 / UI 問題；我可用截圖與 failure cases 對照。
3. 下一輪若繼續自動化，可把 failure cases 進一步整理成「重複死亡敵人 / 樓層 / 牌組缺口」的建議表，但不要在沒有玩家新回報時大幅調整敵人或 Botan。
