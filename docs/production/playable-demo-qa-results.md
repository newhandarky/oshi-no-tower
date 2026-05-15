# Playable Demo QA Results

最近更新：2026-05-14

## Source

- GAME_DESIGN：`GAME_DESIGN.md`
- game_design_bible：`game_design_bible.json`
- director plan：`docs/production/director-production-plan.md`
- owner gate：`technical-director-qa`
- creative review owner：`creative-director-review`

## Gate Summary

`player_confirmed_conditionally_acceptable`

自動 QA、Auto-Run Proxy、兩段實機 spot check 與玩家回報已建立第一章 baseline。玩家已確認 Subaru 與 Botan 都曾通關，第一章整體體感可接受；AZKi 因剛完成不久、卡牌強度 / 內容仍偏弱，目前尚未通關。UI 與內容仍有調整空間，但玩家回報沒有致命 blocker。

此狀態足以作為下一步內容開發與 Chapter 2 source-of-truth / runtime prototype 規劃依據；但不等同 Desktop Build Readiness，也不等同 Creative Director Review fully accepted。Chapter 2 runtime prototype 已可接在 Chapter 1 Boss reward 後；正式素材、平衡與手動 QA 仍需後續處理。

## Automated Baseline

2026-05-13 重跑結果：

| check | result | note |
|---|---|---|
| `combat_engine_tests.gd` | passed | `combat_engine_tests: ok` |
| `runtime_database_tests.gd` | passed | `runtime_database_tests: ok`，既有 `ObjectDB instances leaked` warning |
| `combat_ui_layout_tests.gd` | passed | `combat_ui_layout_tests: ok`，既有 `ObjectDB instances leaked` warning |
| `random_map_tests.gd` | passed | `random_map_tests: ok` |
| `shop_campfire_selection_tests.gd` | passed | `shop_campfire_selection_tests: ok` |
| `playable_demo_smoke_tests.gd` | passed | `playable_demo_smoke_tests: ok` |
| `playable_demo_auto_run_tests.gd` | passed | `playable_demo_auto_run_tests: ok`，三角色皆死亡收束，未卡在 blocking screen |
| `demo_qa_mode_tests.gd` | passed | `demo_qa_mode_tests: ok`，Demo QA 入口、AZKi / Laplus showcase、Boss warning showcase 可直接進入 |
| Godot `--quit` | passed | exit code 0 |

Non-blocking warning：

- `runtime_database_tests.gd`、`combat_ui_layout_tests.gd` 與 `playable_demo_auto_run_tests.gd` 仍出現既有 `ObjectDB instances leaked` warning，與 prior status 相符，暫不阻塞 demo gate。

## Automated Auto-Run Proxy Results

此 gate 是 `automated_proxy`，用於在 manual full-run 不方便執行時提供流程證據；通過不等於 manual gate passed，也不代表 Creative Director Review accepted。

固定策略：每位角色使用固定 seed 啟動 16 floor random map；地圖選第一個可用節點；戰鬥依手牌順序打出可支付且非 curse 的牌，無牌可打就結束回合；reward 取第一張角色卡；shop 離開；campfire 休息；event 優先選不開戰的可用保守選項。

| character_id | seed | result | final_screen | final_floor | boss_id | hp | gold | deck_count | relic_count | event_battle_count | combat_count | elite_count | visited_node_count |
|---|---:|---|---|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `subaru` | 2026051341 | `defeated` | `run_end` | 4 | `subaruto-duck` | 0 | 158 | 13 | 0 | 0 | 4 | 1 | 3 |
| `botan` | 2026051342 | `defeated` | `run_end` | 8 | `ssrb-giant-camouflage` | 0 | 153 | 12 | 2 | 0 | 3 | 1 | 7 |
| `azki` | 2026051343 | `defeated` | `run_end` | 4 | `ssrb-giant-gray` | 0 | 90 | 12 | 0 | 0 | 3 | 1 | 3 |

Auto-run 判定：

- `technical-director-qa`：`passed` for `automated_full_run_proxy`。三角色都能進入 random map、完成多個節點、進戰鬥、處理 reward / elite reward / relic flow，最後以死亡收束到 `run_end`。
- `game-actor-pipeline`：`passed` for forced AZKi Laplus action smoke。`laplus_dash` / `laplus_crash` 均能強制顯示 `AZKiBodySprite`、`LaplusSummonSprite`、`PlayerActionFxSprite`、`LaplusSummonHpLabel`。Auto-run 本身未抽到或打出兩張 Laplus 卡，因此仍保留 manual feel check。
- `game-art-ui-continuity`：`passed` for automated UI proxy。Map 不再包含 `Boss 提示：` 長文，combat 包含 `玩法：`，AZKi marker fallback screen text 包含 `標記`，Boss 高傷 intent 會在 `turn_events` 產生 `boss-warning`。視覺 overlap 仍為 manual pending，不在 headless 中假判定。

## In-App Spot Check

使用 Godot editor run project 視窗進行 spot check。

| area | result | owner_skill | note |
|---|---|---|---|
| `character_select` | passed | `game-art-ui-continuity` | Subaru / Botan / AZKi 三角色與被動提示可見，首屏未見明顯重疊 |
| Subaru map start | passed | `technical-director-qa` | 由角色選擇選 Subaru 後可進入 16 floor random map；本次 seed `1778686866`，Boss 為 `巨大 SSRB Gray`；Boss hint spot check 為 2026-05-13 歷史結果，2026-05-14 已移除地圖 hint 長文 |
| Subaru first reachable battle | passed | `technical-director-qa` | 從 map 點擊第一個 reachable battle 可進入普通戰；手牌 hover 放大可讀，未見明顯遮住角色 HP / 敵方意圖 |
| AZKi map start | passed | `game-art-ui-continuity` | 選 AZKi 後可進入 16 floor random map |
| Boss name on map | automated passed, pending latest manual | `game-art-ui-continuity` | 2026-05-14 後地圖只保留 Boss 名稱與 `BOSS` node，不再顯示 Boss hint 長文 |
| First reachable battle | passed | `technical-director-qa` | 點擊第一個 reachable battle 可進入戰鬥 |
| AZKi / Laplus initial combat | passed | `game-actor-pipeline` | AZKi body、Laplus summon、Laplus HP `10/10` 可見 |
| Marker fallback | passed | `game-art-ui-continuity` | `精準標記` 後可見 `標記` 文字與提示，不裸顯英文 `marker` |
| `map_marker_attack` | passed | `game-actor-pipeline` | 標記投射 FX 可見，未遮住手牌或 runtime text |
| `kiss_attack` | passed | `game-actor-pipeline` | 飛吻 / heart-like FX 可見，未見明顯 UI 遮擋 |
| Laplus HP label during enemy turn | passed | `game-actor-pipeline` | 敵方回合後 Laplus HP label 仍可讀 |

## Player-Confirmed Manual Evidence

2026-05-14 使用者回報：

- 第一章整體體感可以接受。
- Subaru 已通關過。
- Botan 已通關過。
- AZKi 因角色剛完成不久，卡牌目前可能還不夠強，尚未通關。
- UI 與內容還需要調整，但不是致命問題。
- 使用者不希望 Codex 代為執行 GUI/manual QA 或操作測試畫面；後續應以使用者回報作為 manual evidence 來源，由 Codex 負責整理文件。

判定：

- 第一章 single-act demo 可作為下一步開發依據。
- Chapter 2 可進入 design bible / source-of-truth 規劃。
- AZKi balance / reward pool / Laplus payoff 仍應列入第一章內容補強項。
- Desktop build readiness 與 Creative Director final acceptance 仍需更完整的玩家確認紀錄或明確 release decision。

## Demo QA Entry

本輪新增可見的 demo QA 入口，目標是降低手動驗收摩擦，而不是新增正式遊戲內容。

| entry | status | owner_skill | note |
|---|---|---|---|
| `Demo QA` button on character select | automated passed | `game-art-ui-continuity` | 角色選擇畫面可直接進入 Demo QA；快捷鍵 `D` 也可開啟 |
| Subaru / Botan / AZKi random run shortcuts | automated passed | `technical-director-qa` | Demo QA 可直接啟動三角色 random run |
| AZKi action showcase | automated passed | `game-actor-pipeline` | 可直接查看 `map_marker_attack`、`kiss_attack`、`laplus_dash`、`laplus_crash` |
| Boss warning showcase | automated passed | `game-art-ui-continuity` | 可直接進 Important Announcement 高傷 warning 畫面 |
| marker fallback showcase | automated passed | `game-art-ui-continuity` | 可直接查看 `標記` fallback |

## Manual Full-Run Gate

已由玩家回報補上部分通關證據，但尚未形成完整三角色通關紀錄；因此改為 conditionally acceptable for content planning，不標為 desktop/release passed。

| actor_id | status | required evidence |
|---|---|---|
| `subaru` | player-confirmed cleared | 使用者回報 Subaru 已通關過；若進 release gate，再補 Boss / relic / HP 摘要即可 |
| `botan` | player-confirmed cleared | 使用者回報 Botan 已通關過；若進 release gate，再補 Boss / relic / HP 摘要即可 |
| `azki` | player-confirmed not cleared | 使用者回報 AZKi 目前尚未通關，疑似卡牌強度 / 內容成熟度不足；列為內容補強，不阻塞 Chapter 2 規劃 |

## AZKi / Laplus / FX Demo Gate

| action_id | status | owner_skill | note |
|---|---|---|---|
| `map_marker_attack` | passed by spot check | `game-actor-pipeline` | FX 可見，未發現首場戰鬥 UI overlap |
| `kiss_attack` | passed by spot check | `game-actor-pipeline` | FX 可見，未發現首場戰鬥 UI overlap |
| `laplus_dash` | automated proxy passed, pending manual | `game-actor-pipeline` | forced action smoke 覆蓋存在；仍需實機打出驗收體感 |
| `laplus_crash` | automated proxy passed, pending manual | `game-actor-pipeline` | forced action smoke 覆蓋存在；仍需實機打出驗收體感 |

## UI Continuity Gate

| item | status | owner_skill | note |
|---|---|---|---|
| Boss name readability | automated passed, pending latest manual | `game-art-ui-continuity` | map 不再顯示 Boss hint 長文；保留 Boss 名稱與 `BOSS` node |
| Boss warning readability | automated event proxy passed, pending manual | `game-art-ui-continuity` | `boss-warning` event 存在；仍需進 Boss 戰或 debug Boss 戰目視確認 |
| marker fallback | passed by spot check and automated proxy | `game-art-ui-continuity` | 顯示繁中 `標記` |
| hand hover overlap | partial | `game-art-ui-continuity` | Subaru 首戰 hover 單張卡可讀，未見明顯遮住 HP / intent；仍需多角色、多手牌數、Boss warning 同屏確認 |
| tooltip overlap | pending manual | `game-art-ui-continuity` | 需 hover relic / status / intent 確認 |
| event option overflow | pending manual | `game-art-ui-continuity` | 需進事件畫面確認 |

## Issues

| issue_id | severity | owner_skill | status | required action |
|---|---|---|---|---|
| `manual-full-run-missing` | blocking for desktop build, non-blocking for content planning | `technical-director-qa` | partially resolved by player report | Subaru / Botan 已由玩家回報通關；AZKi 尚未通關，需內容補強或後續玩家確認 |
| `azki-clear-rate-low` | content priority | `technical-director-qa` / `game-design` | open | 補強 AZKi 卡牌強度、reward consistency、Laplus payoff 或 early survivability |
| `laplus-dash-crash-manual-missing` | non-blocking for current docs, blocking for creative acceptance | `game-actor-pipeline` | open | 實機打出 `laplus_dash` / `laplus_crash`，確認三層同步與 HP label 不遮擋 |
| `boss-warning-manual-missing` | non-blocking for current docs, blocking for creative acceptance | `game-art-ui-continuity` | open | 進 Boss 戰確認 Boss warning 字距、位置與可讀性 |
| `tooltip-hover-manual-missing` | non-blocking | `game-art-ui-continuity` | open | 手動 hover relic / status / intent / hand cards |

## Decision

- Technical QA：`conditioned_for_content_planning`
- Creative Director Review：`deferred_for_release_acceptance`
- Desktop Build Readiness：`not_ready`

下一個可執行步驟可改為 Chapter 2 design bible / source-of-truth 規劃，並同步把 AZKi 補強列為第一章內容 backlog。正式 desktop build 或 Chapter 2 runtime 章節切換，仍需另行做 release-level decision。
