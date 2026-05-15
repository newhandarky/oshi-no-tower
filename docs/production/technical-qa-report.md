# Technical QA Report

最近更新：2026-05-14

## Source

- GAME_DESIGN：`GAME_DESIGN.md`
- game_design_bible：`game_design_bible.json`
- owner skill：`technical-director-qa`

## Audit Status

`conditioned_for_content_planning`

原因：source-of-truth、department contracts、本輪指定自動 QA、Auto-Run Proxy、AZKi 實機 spot check、Subaru 首戰 spot check 與玩家回報已足以建立第一章開發 baseline。玩家已確認 Subaru / Botan 曾通關，第一章整體體感可接受；AZKi 尚未通關，主要視為內容強度 / 角色成熟度 backlog，而不是第一章流程致命 blocker。Desktop build readiness 與 release-level acceptance 仍需更完整 manual evidence 或明確 release decision。

## Required Audits

| audit_id | result | owner_skill | required action |
|---|---|---|---|
| `game_design_traceability` | passed | `game-design` | `GAME_DESIGN.md` 與 `game_design_bible.json` scope 對齊 `godot_mvp_playable_demo` |
| `runtime_feasibility` | passed | `technical-director-qa` | 指定 headless tests 與 Godot `--quit` 已通過 |
| `automated_full_run_proxy` | passed | `technical-director-qa` | Subaru / Botan / AZKi 皆能自動推進多個節點並死亡收束，未卡在未知 screen 或 flow break |
| `demo_qa_entry` | passed | `technical-director-qa` | 角色選擇可進 Demo QA，並可直接開 AZKi / Laplus showcase 與 Boss warning showcase |
| `visual_runtime_safe_area` | manual pending | `game-art-ui-continuity` | 實機確認 Boss warning / tooltip / hand hover 不重疊；random map 不再顯示 Boss hint 長文 |
| `azki_laplus_fx_overlap` | automated proxy passed, manual pending | `game-actor-pipeline` | forced action smoke 已覆蓋 `laplus_dash` / `laplus_crash` 必要節點存在；仍需實機打出確認體感與 overlap |
| `audio_event_coverage` | passed for manifest-only | `game-audio-feedback-pipeline` | 正式音檔 deferred；保留 cue contract |
| `manual_full_run` | partially player-confirmed, blocked for desktop build | human QA | Subaru / Botan 已由玩家回報通關；AZKi 尚未通關，需內容補強或後續玩家確認 |

## Automated QA Commands

```bash
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_engine_tests.gd
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/runtime_database_tests.gd
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_ui_layout_tests.gd
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/random_map_tests.gd
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/shop_campfire_selection_tests.gd
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/playable_demo_smoke_tests.gd
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/playable_demo_auto_run_tests.gd
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/reward_draft_tests.gd
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/chapter_2_runtime_tests.gd
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/chapter_2_balance_probe_tests.gd
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/demo_qa_mode_tests.gd
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --quit
```

## Automated QA Results

2026-05-14 已通過：

- `combat_engine_tests: ok`
- `runtime_database_tests: ok`
- `combat_ui_layout_tests: ok`
- `random_map_tests: ok`
- `shop_campfire_selection_tests: ok`
- `playable_demo_smoke_tests: ok`
- `playable_demo_auto_run_tests: ok`
- `reward_draft_tests: ok`
- `chapter_2_runtime_tests: ok`
- `chapter_2_balance_probe_tests: ok`
- `demo_qa_mode_tests: ok`
- Godot `--quit` exit code 0
- `python3 -m json.tool game_design_bible.json` 通過
- `python3 -m json.tool docs/production/actor-contracts.json` 通過

`runtime_database_tests`、`combat_ui_layout_tests` 與 `playable_demo_auto_run_tests` 仍出現既有 `ObjectDB instances leaked` warning，與專案狀態紀錄一致，暫列 non-blocking。

## Automated Proxy Evidence

`tests/headless/playable_demo_auto_run_tests.gd` 目前定位為 `automated_proxy`，不是 manual / creative acceptance 的替代品。

| character_id | seed | proxy_result | final_screen | final_floor | boss_id | combat_count | elite_count | visited_node_count | issue |
|---|---:|---|---|---:|---|---:|---:|---:|---|
| `subaru` | 2026051341 | `defeated` | `run_end` | 4 | `subaruto-duck` | 4 | 1 | 3 | none |
| `botan` | 2026051342 | `defeated` | `run_end` | 8 | `ssrb-giant-camouflage` | 3 | 1 | 7 | none |
| `azki` | 2026051343 | `defeated` | `run_end` | 4 | `ssrb-giant-gray` | 3 | 1 | 3 | none |

Additional proxy checks：

- `game-actor-pipeline`：forced `laplus_dash` / `laplus_crash` screen smoke passed；必要 actor / summon / FX / HP label 節點存在。
- `game-art-ui-continuity`：map 不顯示 `Boss 提示：` 長文、combat `玩法：`、AZKi marker fallback `標記`、Boss 高傷 `boss-warning` event passed。
- `technical-director-qa`：Chapter 2 Balance Pass 1 guardrails passed；AZKi Chapter 2 reward/shop proxy 現在要求 marker、Laplus guard bridge、payoff/scaling 共同出現在 draft / shop 前排。
- Manual visual overlap remains pending；headless proxy 不宣稱 tooltip、hand hover、Boss warning 實機排版已 accepted。

## Manual / In-App Results

詳見 `docs/production/playable-demo-qa-results.md`。

目前已完成：

- Godot editor run project 可進入角色選擇。
- Subaru 可從角色選擇進入 16 floor random map；本次 seed `1778686866`，Boss 為 `巨大 SSRB Gray`。
- Subaru 可從 random map 點擊第一個 reachable battle 進入普通戰；首戰手牌 hover 可讀，未見明顯遮住角色 HP / 敵方意圖。
- AZKi 可進入 16 floor random map。
- 2026-05-13 歷史 spot check 曾確認 Map Boss hint 可讀；2026-05-14 已依使用者要求移除地圖 Boss hint 長文，後續只需確認 Boss 名稱與 Boss node 可讀。
- AZKi 第一場普通戰可進入。
- AZKi body、Laplus summon、Laplus HP label 可見。
- `map_marker_attack` 與 `kiss_attack` 可播放，未見明顯遮擋 runtime text。
- `marker` fallback 顯示繁中 `標記`。

2026-05-14 玩家補充：

- 第一章整體體感可以接受。
- Subaru 與 Botan 都已通關過。
- AZKi 尚未通關，原因偏向新角色剛完成、卡牌強度 / 內容仍不足。
- UI 與內容仍需調整，但目前不是致命問題。

仍未完成或仍需 release 前確認：

- AZKi 通關或明確 balance target。
- `laplus_dash` / `laplus_crash` 實機手動打出。
- Boss warning、tooltip、多角色 / 多手牌 hand hover 與 event option overflow 的完整人工檢查。

## Blocking Policy

- Existing `ObjectDB instances leaked` warning：non-blocking if same as prior records.
- New test failure, parse error, missing runtime asset path, or layout overlap：blocking.
- Chapter 2 design bible / source-of-truth planning may proceed from the player-confirmed baseline.
- Desktop build readiness requires no blocking issue plus release-level manual QA or explicit release decision.
