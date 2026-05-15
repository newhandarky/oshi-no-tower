# GAME_DESIGN

最近更新：2026-05-14

本文件是 Godot MVP playable demo 的創意與 production source of truth。下游 production skill、runtime QA 與後續素材修正都必須對齊本文件與 `game_design_bible.json`，不得自行擴寫新章節、新角色或改變角色定位。

## Production Scope

- Production scope：`godot_mvp_playable_demo`
- Demo cut：目前 playable runtime 支援 Chapter 1 單 Act、16 floor、seed-based random map、隨機 Boss；Chapter 2 已接入 runtime prototype，包含章節開場事件、第二章 random map、第二章敵人 / 事件 / Boss pool。
- 目標平台：Godot 4.6 desktop playable demo。Web build 本輪暫不處理。
- 本輪重點：在既有 Chapter 1 playable baseline 上，完成 Chapter 2 runtime prototype 與第一輪 headless balance pass，讓 Chapter 1 Boss reward 後可進入 `chapter_start_event`，再生成 `演算法深層` random map。
- 明確不做：第四位可玩角色、第二章正式新素材、完整音效素材產線、Web build、完整第二章手動平衡驗收。

## Content Expansion Phase

`content_pack_2a_card_depth_system` 已落地，原則是只深化現有 single-act demo，不擴章節、不新增可玩角色、不要求新素材一次補完。

本階段優先順序：

1. 讓每位角色的 build 方向更明顯，而不是只增加卡牌數量。
2. 優先調整玩家每局最常看到的卡牌 / relic / reward pool。
3. 新 prototype 卡可用 `art_status = "prototype_placeholder"` 與 `ART` placeholder，但必須預留 `expected_art_path`。
4. 每輪內容擴充都必須跑 automated QA 與 auto-run proxy，避免 playable flow 回退。

Content Pack 1A 已鎖定：

- Subaru：強化 0/1 費連段、抽牌與節奏守備互動。
- Botan：強化 `Funds Prepared` / `botan-mark` 作為 2 費爆發前置。
- AZKi：新增 Laplus / marker reward cards，讓 `laplus_dash` 更容易在一般 auto-run 中出現。
- Relic：支援 multi-effect relic 與角色 build hook，例如 0/1 費、2 費、marker card。

Content Pack 1B 已鎖定：

- Subaru：強化 `subaru-cheer-loop` / `subaru-hype-call`，讓抽牌、格擋與低費節奏更容易接成回合。
- Botan：強化 `botan-steady-aim` / `botan-counter-line`，讓易傷 setup 與 2 費反擊更清楚。
- AZKi：新增 `azki-marker-echo` 與 `azki-laplus-reposition` 到 reward/shop pool，繼續提高 marker / Laplus payoff 出現率。
- Relic：`duck-whistle`、`unarchived-archive` 改為更明確的多效果 payoff；`healing-chat` / `pamomi-signal` 的 `turn_start` runtime 已補上。

Content Pack 2A 已鎖定：

- Card Depth Framework：所有卡牌資料補 `archetype_tags`、`role_tags`、`rarity`、`floor_band`、`upgrade_plan`；新卡必須有 `upgrade_effects` / `upgrade_description`。
- Reward Draft v2：戰鬥獎勵 3 選 1 依 deck / relic signal 給 build-relevant、survival/bridge、wildcard；商店卡牌依 build relevance 排序。
- Combat 深度積木：支援 `conditional`、`retain`、`exhaust_on_play`、`summon_heal`、`cards_played_this_turn` 與 Relic trigger v2。
- Subaru：新增 `subaru-opening-quack`、`subaru-crowd-cover`、`subaru-table-slam-loop`、`subaru-unstoppable-cheer`，聚焦 `cheap_chain` / `tempo_block` / `multi_hit_strength`。
- Botan：新增 `botan-range-finder`、`botan-overwatch`、`botan-piercing-round`、`botan-perfect-line`，聚焦 `two_cost_burst` / `precision_control` / `fortress_counter`。
- AZKi：新增 `azki-route-marker`、`azki-laplus-guard-order`、`azki-singing-coordinate`、`azki-necrobinder-finale`，聚焦 `marker_loop` / `laplus_guard` / `route_explore`。
- Enemy question：新增 `ssrb-guard-tutor`、`ssrb-striker-intent`、`ssrb-debuff-check`、`ssrb-scaling-clock`，用 `pressure_tags` 定義 encounter 想測的 deck 能力。

## Chapter 2 Runtime Prototype

Chapter 2 已從 source-of-truth 進入 runtime prototype。目標不是宣告第二章最終完成，而是讓章節轉場、開場事件、第二章 map pool、enemy question 與 random Boss policy 能在 headless tests 中成立。

- Chapter 2：`chapter_2_algorithm_depths` / `演算法深層`。
- Chapter 1 Boss reward 後，runtime 會進入 `chapter_start_event`，再進 Chapter 2 map。
- `chapter_start_event` 採 `Holo Support Desk` 語意，每次 draft 3 個角色中立選項，例如 relic、Gold + curse、移除卡、升級卡、Max HP trade。
- Chapter 2 不在開場事件補償 AZKi 或任何單一角色；AZKi 平衡另排卡牌 / reward pool 調整。
- Chapter 2 Balance Pass 1 已把 AZKi 的 marker build reward/shop consistency 收斂為：marker setup、Laplus guard bridge、payoff/scaling 三者至少要能在第二章中後段被 draft / shop 前排看見。
- Chapter 2 early/mid common enemy 已加入 pressure guardrail，避免未成形 deck 在第二章入口被過高 attack / block / multi-hit 直接壓死。
- 第二章敵人以 deck question 為主：`anti_cycle`、`block_puzzle`、`debuff_pressure`、`multi_hit_pressure`、`delayed_burst`、`scaling_clock`、`curse_tolerance`。
- 第二章 Boss 已接入 `algorithm-core`、`archive-phantom`、`notification-storm` 三個 random Boss。

Chapter 2 Foundation Pack 文件：

- `docs/production/chapter-2-design-bible.md`
- `docs/production/chapter-transition-spec.md`
- `docs/production/chapter-start-event-pool.md`
- `docs/production/chapter-2-encounter-design.md`
- `docs/production/chapter-2-boss-contracts.md`

## Player Fantasy And Core Loop

玩家扮演 Hololive 粉絲向 roguelite 牌組角色，沿著「推塔」路線處理直播事故、謎因敵人、資源取捨與 Boss 壓力。每位角色都應有明確玩法節奏：Subaru 以低費連動與格擋節奏取勝，Botan 以 2 費爆發與穩定防線取勝，AZKi 以標記、追擊與 Laplus summon 表演取勝。

核心 loop：

1. 選擇 Subaru / Botan / AZKi。
2. 生成 16 floor random map，提前看到本局 Boss 名稱。
3. 在普通戰、事件、菁英、寶箱、商店、篝火之間做路線與資源決策。
4. 透過卡牌、relic、事件代價與戰鬥獎勵強化 run。
5. 進入 Boss 戰，依 Boss warning 與 counterplay 決定輸出或防守。
6. 勝利後進入 Boss reward / run summary，或 HP 歸零進入失敗畫面。

## Tone And World Rules

- 整體語氣：Hololive 粉絲向、輕 roguelite、直播事故與謎因壓力混合，避免指向真人負面描述。
- 世界規則：塔內事件是抽象化直播、粉絲應援、平台事故與 mascot 概念，不是真實人物衝突。
- UI 文字：玩家可見效果描述預設繁體中文；角色名、Boss 名、卡名與特殊梗可保留英文或日文原文。
- Forbidden drift：不把 MVP 轉成嚴肅黑暗劇情；不讓下游 skill 發明新主角定位；不把 deferred audio / art 假裝已完成。

## Chapter Contract

### Chapter 1

- `chapter_id`：`mvp_single_act_tower`
- 章節定位：目前 playable vertical slice，用來展示三角色玩法差異與 16 floor random map 是否成立。
- Route：Boss floor 16，Boss 前包含普通戰、事件、菁英、寶箱、商店、篝火候選。
- Boss pool：`subaruto-duck`、`ssrb-giant-gray`、`ssrb-giant-camouflage`、`ssrb-giant-white`、`youtube-kun-core`、`important-announcement`。
- Random Boss 設計保留；地圖預告與實際 Boss 戰必須使用同一個 Boss id。

### Chapter 2

- `chapter_id`：`chapter_2_algorithm_depths`
- 章節定位：runtime prototype；第一章 Boss reward 後的下一個章節。
- Route：Boss floor 16，沿用 seed-based random map，但使用 Chapter 2 enemy / event / boss pool。
- Entry：`boss_reward` -> `chapter_start_event` -> Chapter 2 random map。
- Chapter start event：`chapter-2-support-desk`，角色中立，不補償特定角色。
- Boss contracts：`algorithm-core`、`archive-phantom`、`notification-storm`。

## Actor Seeds

| actor_id | role | gameplay identity | performance focus |
|---|---|---|---|
| `subaru` | protagonist | `cheap_chain` / `tempo_block` / `multi_hit_strength` | 低費起手、連段、多段攻擊、元氣防守 |
| `botan` | protagonist | `two_cost_burst` / `precision_control` / `fortress_counter` | 2 費攻擊爆發、控場後收頭、防守反擊 |
| `azki` | protagonist | `marker_loop` / `laplus_guard` / `route_explore` | 標記循環、Laplus HP 資源、地圖座標探索 |
| `laplus` | companion summon | AZKi battle companion | 承傷、dash、crash、與 AZKi / FX 分層同步 |
| `ssrb-*` | enemy / boss variants | mascot pressure | 普通戰教學、菁英壓力、巨大 Boss 收束 |
| `youtube-kun-core` / `important-announcement` | boss | platform / announcement pressure | debuff、硬化、蓄力大傷與 Boss warning |

## Screen And Player Flow

本輪要覆蓋的 screens：

- `character_select`：三角色可選，顯示角色玩法提示。
- `random_map`：16 floor 直式 scroll map，Boss 節點顯示 `BOSS`，標題區只顯示 Boss 名稱，不再顯示 Boss hint 長文。
- `chapter_start_event`：Chapter 1 Boss reward 後進入的章節開場事件，提供 3 個角色中立交易選項。
- `combat`：卡牌、角色 sprite、enemy / Boss、status、intent、relic、Boss warning、AZKi / Laplus / FX 分層；手牌 hover 需用滑順放大 / 縮小，回合結束未用手牌往右側棄掉，新抽卡從左側進場並排到最右側。
- `reward`：戰鬥後卡牌獎勵與 Gold。
- `chest_reward`：固定 relic / fallback Gold。
- `shop`：卡牌、relic、移除卡、特價與價格狀態。
- `campfire`：恢復 / 升級選擇。
- `event`：事件選擇、風險、curse、額外戰鬥。
- `boss_reward` / `run_summary`：Chapter 1 Boss reward 會導向 Chapter 2；Chapter 2 Boss reward 目前導向 demo clear 結算。
- `failure`：HP 歸零失敗收束。

## Event Feedback Contract

Audio assets 可延後，但事件 contract 必須先定義。每個玩家可感知事件需有 `event_id`，並指定 `sfx_cue` 或 `silent_intentional`。

核心事件：

- `ui_select_character`
- `map_node_enter`
- `combat_start`
- `card_played`
- `status_marker_applied`
- `marker_payoff_damage`
- `azki_laplus_dash`
- `azki_laplus_crash`
- `boss_warning`
- `battle_victory`
- `chapter_transition`
- `chapter_start_event_selected`
- `battle_defeat`
- `reward_claimed`
- `shop_purchase`
- `campfire_rest`
- `event_choice_selected`

本輪音效策略：manifest / event cue 先完成，正式 SFX / BGM asset generation deferred。

## Asset Demands And Owners

| demand_id | owner_skill | status | note |
|---|---|---|---|
| `azki_laplus_fx_readability` | `game-actor-pipeline` | production focus | 確認 AZKi、Laplus、FX 三層同步與不遮 UI |
| `combat_ui_safe_text` | `game-art-ui-continuity` | production focus | Boss warning、marker fallback、tooltip 不重疊 |
| `event_audio_manifest` | `game-audio-feedback-pipeline` | contract only | 定義 event cue，不要求正式音檔 |
| `technical_demo_gate` | `technical-director-qa` | required | 自動 QA + manual QA gate |
| `creative_demo_gate` | `creative-director-review` | required | 判定是否像同一款作品 |

## Acceptance Gates

1. Script Lock：`GAME_DESIGN.md` 與 `game_design_bible.json` 不矛盾。
2. Department Ready：actor / UI / audio contracts 可交給下游 skill，不需要猜測角色定位或事件語意。
3. Scene Playability：Subaru / Botan / AZKi 都能進入 16 floor random run，且 demo smoke test 保護入口。
4. Technical QA：指定 headless tests 通過；既有 `ObjectDB instances leaked` warning 可標為 non-blocking；新增 failure / parse error / layout overlap 為 blocking。
5. Creative Director Review：三角色、UI、FX、Boss warning 與 deferred audio 狀態一致，不假裝未完成內容已完成。

## Deferred

- 第二章正式素材、背景、UI polish 與完整平衡收斂。
- 新角色、完整劇情 arc。
- 完整音效與 BGM asset generation。
- Web build。
- 大規模平衡重做。
- 重做 SSRB / Boss 全部素材，除非 manual QC 判定 blocked。
