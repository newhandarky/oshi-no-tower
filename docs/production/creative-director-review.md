# Creative Director Review

最近更新：2026-05-14

## Source

- GAME_DESIGN：`GAME_DESIGN.md`
- game_design_bible：`game_design_bible.json`
- owner skill：`creative-director-review`

## Review Status

`deferred_until_manual_qa`

Source-of-truth、department contracts、自動 QA、AZKi 首場 spot check 與 Subaru 首戰 spot check 已能維持同一個 demo 方向；但 creative acceptance 需要三角色完整 run 與更多實機畫面檢查後才能改為 `accepted`。

## Review Dimensions

| dimension | judgement | note |
|---|---|---|
| GAME_DESIGN fit | passed for contract | Demo 方向鎖定 16 floor MVP，不擴新章節或新角色 |
| Actor continuity | partial | Subaru 首戰可讀出低費節奏提示；Botan 定位仍需完整 run；AZKi / Laplus 首場 spot check 通過，dash / crash 尚待人工確認 |
| UI continuity | partial | marker fallback 與 Subaru 首戰 hand hover spot check 通過；地圖 Boss hint 已依使用者要求移除；Boss warning / tooltip / 多情境 hand hover 尚待人工確認 |
| Audio continuity | deferred | Audio 目前是 manifest-only，不能視為正式音效完成 |
| Scene performance | pending manual QA | 需確認 entrance、hold、reveal、confirm 在 combat / Boss / reward 流程順暢 |
| Player flow clarity | pending manual QA | 需三角色完整 run 驗證 route、event battle、Boss reward 與 failure flow |

## Verification Notes

- 2026-05-13 指定 headless QA 已通過，沒有新的 parse error 或 runtime data failure。
- 2026-05-13 Subaru 實機 spot check 通過：角色選擇、random map、Boss hint、第一場普通戰與單張手牌 hover 未見明顯阻塞；2026-05-14 後地圖 Boss hint 已移除，該項改由 automated proxy 檢查不存在。
- 2026-05-13 AZKi 首場實機 spot check 通過：角色選擇、random map、Boss hint、第一場普通戰、Laplus HP label、marker fallback、`map_marker_attack`、`kiss_attack` 未見明顯阻塞；2026-05-14 後地圖 Boss hint 已移除，該項改由 automated proxy 檢查不存在。
- Creative gate 仍不升級為 `accepted`，因為 `laplus_dash` / `laplus_crash`、Boss warning 字距、Botan 實機 run 與三角色 16 floor run 尚未由人工確認。

## Creative Notes

- Subaru 應讀起來像低費節奏角色，不要被 Botan 的高單發語言覆蓋。
- Botan 應讀起來像冷靜射擊與 2 費爆發角色，不要變成抽牌連段角色。
- AZKi 的展示核心是「標記 -> 追擊 -> Laplus 協作」，四個 demo action 是本輪 review 重點。
- Boss warning 應服務玩家決策，不應像 debug metadata 或純長文說明；地圖不再顯示 Boss hint 長文。
- Deferred audio 必須明確標為 deferred；demo 不應對外宣稱完整 audio pass。

## Current Decision

`revise_after_manual_qa`

需要 manual QA 後再決定：

- `accepted`：可進 desktop build readiness。
- `revise`：小修 UI / FX / wording 後再驗。
- `retake`：AZKi / Laplus / Boss warning 表演讀不清，需要重做該部門成果。
- `defer`：非 demo blocker，但要記入 `docs/godot-mvp-status.md`。
