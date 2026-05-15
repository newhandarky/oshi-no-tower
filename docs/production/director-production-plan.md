# Director Production Plan

最近更新：2026-05-14

## Script Source

- GAME_DESIGN：`GAME_DESIGN.md`
- game_design_bible：`game_design_bible.json`
- production depth：MVP playable demo + Chapter 2 runtime prototype
- narrative depth：light chapter story with planned second chapter transition
- art order：actor readability first, UI safe text second, audio manifest third
- human acceptance gate：三角色完整 16 floor random run 手動 QA

## Production Mode

- scope：`godot_mvp_playable_demo`
- MVP cut：Subaru / Botan / AZKi、16 floor random map、random Boss、AZKi / Laplus / FX readability gate。
- deferred content：Chapter 2 final art / balance polish、new character、web build、full audio asset generation。
- subagent parallelism：本輪不啟動 parallel subagents；先鎖 source-of-truth 與 production contracts。

## Cast

| actor_id | role | required template | status |
|---|---|---|---|
| `subaru` | protagonist | MVP performance pack | ready |
| `botan` | protagonist | MVP performance pack | ready |
| `azki` | protagonist | full battle readability pack | focus |
| `laplus` | companion summon | companion battle pack | focus |
| `ssrb-*` | enemy / boss | existing runtime pack | manual QC pending |
| `youtube-kun-core` | boss | Boss warning pack | ready |
| `important-announcement` | boss | Boss warning pack | ready |

## Art Departments

| department | responsibility | delegated skill | status |
|---|---|---|---|
| Actor performance | AZKi / Laplus / FX layer readability and action meaning | `game-actor-pipeline` | contract ready |
| UI continuity | Combat safe text, Boss warning, marker fallback, tooltip safe area | `game-art-ui-continuity` | contract ready |
| Audio feedback | MVP event cue / music context manifest | `game-audio-feedback-pipeline` | manifest only |
| Technical QA | Automated tests, manual QA checklist, build readiness gate | `technical-director-qa` | auto QA pending |
| Creative review | Consistency check across actor/UI/FX/deferred audio | `creative-director-review` | review pending |

## Screen / Stage Sequence

| sequence_id | type | depends_on | preview_required | status |
|---|---|---|---|---|
| `character_select` | screen | `script_lock` | yes | ready |
| `random_map_16_floor` | screen | `character_select` | yes | ready |
| `normal_combat` | screen | `random_map_16_floor` | yes | ready |
| `azki_laplus_combat` | screen | `normal_combat` | yes | focus |
| `event_choice` | screen | `random_map_16_floor` | manual | ready |
| `shop_campfire_chest` | screen | `random_map_16_floor` | manual | ready |
| `boss_combat` | screen | `boss_warning_contract` | yes | focus |
| `boss_reward_summary` | screen | `boss_combat` | manual | ready |
| `chapter_start_event` | screen | `chapter_1_boss_reward` | headless + manual later | runtime prototype |
| `chapter_2_random_map` | screen | `chapter_start_event` | headless + manual later | runtime prototype |

## Event Feedback Map

| event_id | visual_fx | sfx_cue | music_context | status |
|---|---|---|---|---|
| `ui_select_character` | selected state | `ui_confirm_soft` | `music_context_ui` | contract only |
| `map_node_enter` | node focus/pressed | `map_node_confirm` | `music_context_map` | contract only |
| `card_played` | card hover/play state | `card_play_generic` | `music_context_combat` | contract only |
| `status_marker_applied` | `map_marker_projectile` | `marker_apply_ping` | `music_context_combat` | contract ready |
| `marker_payoff_damage` | hit flash / marker consume | `marker_payoff_hit` | `music_context_combat` | contract ready |
| `azki_laplus_dash` | `laplus_dash_trail` | `laplus_dash_whoosh` | `music_context_combat` | contract ready |
| `azki_laplus_crash` | `laplus_crash_impact` | `laplus_crash_impact` | `music_context_combat` | contract ready |
| `boss_warning` | warning label | `boss_warning_pulse` | `music_context_boss` | contract ready |
| `battle_victory` | reward transition | `battle_victory_stinger` | `music_context_reward` | contract only |
| `chapter_transition` | chapter title / map transition | `chapter_transition_stinger` | `music_context_map` | runtime prototype |
| `chapter_start_event_selected` | selected option applies before Chapter 2 map | `event_choice_confirm` | `music_context_event` | runtime prototype |

## Milestones

1. Script Lock：建立 `GAME_DESIGN.md` 與 `game_design_bible.json`。
2. Department Ready：建立 actor / UI / audio / QA / creative review contracts。
3. Scene Playability：跑 demo smoke 與核心 headless tests。
4. Manual Full-Run QA：Subaru / Botan / AZKi 各跑一局 16 floor random run。
5. Technical QA：整理 automatic + manual gate，標記 blocking / non-blocking。
6. Creative Director Review：確認 demo 一致性與 deferred content 沒有被誤認完成。
7. Desktop Build Readiness：只有 Technical QA 無 blocking 且三角色 run 記錄完成後才進入。
8. Chapter 2 Runtime Prototype：接上第二章設計文件、章節轉場、開場事件、敵人考題與 Boss contracts。

## Decision Log

- 採 MVP playable demo，不升級成 full game plan。
- 音效採 manifest-only contract，正式素材 deferred。
- 角色不新增，Boss random 設計保留。
- Desktop build 等三角色 manual QA 後再做。
- Chapter 2 已進 runtime prototype；第一章 Boss reward 後會進入角色中立 `chapter_start_event`，再進第二章 map。
- Chapter 2 開場事件不做 AZKi 專屬補償；AZKi 強度之後由卡牌 / reward pool 平衡輪次處理。
