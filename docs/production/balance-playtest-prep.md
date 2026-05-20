# Balance / Playtest Prep

最近更新：2026-05-20

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

- 010 起，結算畫面會顯示 `QA 回報摘要`，可直接抄出角色、結果、seed、Boss、死亡樓層、死亡敵人、死亡前 HP、Deck、Relic。
- 使用者實機回報時，優先補充畫面摘要沒有自動知道的「體感問題」與「UI 問題」。
- 角色：Subaru / Botan / AZKi 各至少一輪 16 floor random run。
- 體感：是否常見「能活但殺不掉」、「能殺但擋不住」、「reward 看起來沒有成形方向」。
- UI：Boss warning、tooltip、hand hover、event option 是否有遮擋或文字 overflow。
- AZKi 額外項目：`laplus_dash` / `laplus_crash` 實機打出時，AZKi body、Laplus summon、FX 與 Laplus HP label 是否互相遮擋。

## 下一步建議

1. 先 merge 009，保持 headless guardrail 與文件入口乾淨。
2. 下一輪若轉 manual QA，直接截取或抄寫結算畫面的 `QA 回報摘要`，再補體感 / UI 問題。
3. 下一輪若繼續自動化，可把相同摘要格式延伸到 auto-run log，讓 headless 與玩家回報使用同一套欄位。
