# Godot MVP 狀態紀錄

最近更新：2026-05-20

## 專案

- 專案路徑：`/Users/zhangzhipeng/MyProject/oshi-no-tower-godot`
- 引擎目標：Godot 4.6 專案格式
- 主場景：`res://scenes/main.tscn`
- 目前方向：以 Godot MVP 為主要實作。Unity 相關內容除非明確提到，否則視為歷史紀錄。
- 下一階段方向：在目前 16 floor Godot MVP 流程穩定的前提下，繼續豐富 single-act demo 內容與手感，並把 Chapter 2 runtime prototype 收斂成可驗收內容。優先順序為三角色 build variety、AZKi / Laplus / marker 卡牌頻率、relic hook 角色互動、事件 / encounter 差異化、戰鬥 UI motion 與第二章平衡；desktop build、Web build、第四角色仍等 manual full-run gate 或明確 release decision 後再排。
- 2026-05-20 Balance Cleanup / Playtest Prep 009 已落地：從 008 merged 後的 `main` 開 `009-balance-cleanup-and-playtest-prep`，不新增卡牌、不調敵人、不提高 Botan，也不做 GUI/manual QA。新增 `docs/production/balance-playtest-prep.md` 作為 006-008 後的平衡 / manual full-run 交接入口，記錄目前 headless guardrail 為 Subaru 5/10、Botan 7/10、AZKi 5/10，並列出 manual full-run 需回填的死亡樓層、敵人、deck/relic snapshot、Boss warning、tooltip、hand hover、event option overflow、AZKi Laplus FX overlap 等項目。新增 `production_docs_tests.gd` 保護該文件入口；`multiseed_balance_probe_tests.gd` 的最低門檻從三角色各 4/10 提升到各 5/10，避免後續平衡回退到 006 的低標。已通過 Production docs、Multiseed probe、Reward draft、RuntimeDatabase、CombatEngine、Archetype fixture。本輪仍不做 GUI/manual QA。
- 2026-05-20 AZKi Late Boss Stability 008 已落地：從 007 merged 後的 `main` 開 `008-azki-late-boss-stability`，不改 005 relic hook runtime，也不提高 Botan。baseline 顯示 AZKi 仍為 4/10，失敗集中在 floor 16 boss 與少量 floor 11 elite；其中多個 late boss 失敗 deck 已持有 `azki-phantom-route` / `azki-necro-recall`，但這兩張雖標記 `defense`，實際只補 Laplus HP、缺少直接格擋。這輪只小幅補 late stability bridge：`azki-phantom-route` 新增 4 block / 升級 6 block，`azki-necro-recall` 新增 4 block / 升級 6 block，保留原本臨時 marker、回收 support 與 Laplus HP 功能。新增 runtime database 測試鎖定 AZKi late stability 牌必須有直接 block。multiseed 結果提升為 Subaru 5/10、Botan 7/10、AZKi 5/10 抵達 `boss_reward`；AZKi 平均勝利 HP 由 21.0 提升到 28.0，且 seed 2026052306 從 floor 11 elite 死亡改善為抵達 `boss_reward`。已通過 RuntimeDatabase、Reward draft、CombatEngine、Archetype fixture、Multiseed probe。本輪仍不做 GUI/manual QA。
- 2026-05-20 Subaru Early Elite Stability 007 已落地：從 006 merged 後的 `main` 開 `007-subaru-early-elite-stability`，不改 005 relic hook runtime，也不提高 Botan。先以 multiseed baseline 確認 Subaru 仍為 4/10，失敗集中在 floor 7-11 elite / debuff pressure。嘗試過強制 early reward 第一順位補 tempo block，結果 Subaru 掉到 3/10，證明單純擠掉 `combo-boost` / 輸出節奏會退化；最後採用小幅卡牌數值調整：`subaru-desk-reaction` block 6 -> 8、`subaru-tsukkomi` 7x2 -> 8x2，補足早期 bridge 即時防守與 starter payoff 收束。新增 reward 防退化測試，要求 early elite 前 reward 可集中提供 `crowd-cover` / `rhythm-guard` / `new-oshi-call`，並新增 runtime database 測試鎖定 Subaru early elite 防守 / 收束下限。multiseed 結果提升為 Subaru 5/10、Botan 7/10、AZKi 4/10 抵達 `boss_reward`；已通過 Reward draft、RuntimeDatabase、CombatEngine、Archetype fixture、Multiseed probe。本輪仍不做 GUI/manual QA。
- 2026-05-20 Card Depth Natural Balance 006 已落地：從 `main` 開 `006-card-depth-natural-balance`，不改 005 relic hook runtime，改以自然 reward / 卡牌穩定度補強 AZKi 與保護 Subaru guardrail。`multiseed_balance_probe_tests.gd` 的最低門檻提升為三角色各至少 4/10 抵達第一章 `boss_reward`；baseline 紅燈為 AZKi 3/10。`CardRewardDraft` 新增 Subaru 中段已有防守後補收束、AZKi floor 7-11 marker + Laplus bridge 後提前推 payoff / 已有 payoff 後補穩定橋接的 scoring。卡牌數值上小幅補強 AZKi bridge 防守：`azki-safe-route` 9 -> 11 block，`azki-laplus-contract` 新增 4 block / 升級 6 block 並標記 `defense`，`azki-dark-tether` 新增 3 block / 升級 4 block 並標記 `defense`，避免已拿到 Laplus bridge / payoff 但在 floor 9-16 壓力中低血死亡。Reward draft 測試新增 Subaru early/mid bridge/payoff、AZKi mid-run payoff frontload、Botan 不推高 payoff 的防退化覆蓋。multiseed 結果提升為 Subaru 4/10、Botan 7/10、AZKi 4/10 抵達 `boss_reward`；本輪仍不做 GUI/manual QA。
- 2026-05-15 Relic Depth Hooks 005 已落地：不新增完整 relic 子系統，先把 004 後的卡牌深度 effect 接上三個可測的 relic context trigger。`CombatEngine` 新增 `next_attack_bonus_added`、`discard_retrieved`、`temporary_card_created` context resolver，並以 `trigger_effects` 和原本 `hook` / `effects` 分離，避免覆蓋既有 relic 行為；relic effect 也支援 `summon_heal`。`duck-whistle` 現在支援下一擊加成 setup 後補格擋，`shishiro-crosshair` 支援棄牌堆回收攻擊牌後補格擋，`unarchived-archive` 支援 AZKi 建立攻擊臨時牌後回復 Laplus HP。已通過 CombatEngine、RuntimeDatabase、Archetype fixture、Reward draft、Chapter 2 balance probe、AZKi early survival、Playable auto-run、Multiseed probe、Chapter 2 runtime、Shop/Campfire selection；multiseed 結果：Subaru 4/10、Botan 7/10、AZKi 3/10 抵達 `boss_reward`。本輪仍不做 GUI/manual QA。
- 2026-05-15 Card Depth Balance 004 已落地：新增 multiseed balance guardrail，要求 Subaru / Botan / AZKi 各 10 個固定 seed 至少 3 次抵達第一章 `boss_reward`，並讓 auto-play proxy 正確評價 `next_attack_bonus`、`draw_from_discard`、`temporary_card` 與既有 `next_attack_bonus` 後的攻擊牌。`CardRewardDraft` 現在會打斷 Botan `kill-zone / cover-reload / perfect-line` 重複循環，改補 `overwatch / clean-scope / flashbang / precise-cover` 等防守、控制或反擊橋接；AZKi 已有 Laplus payoff 後會轉向 `phantom-route / necro-recall / laplus-cover / laplus-reposition` 等穩定牌。數值上補強 Botan fortress 防守牌、AZKi Laplus guard / marker payoff，並小幅下修 `ssrb-giant-camouflage` 與 `important-announcement` 的 Boss 壓力。multiseed 結果：Subaru 4/10、Botan 6/10、AZKi 3/10 抵達 `boss_reward`；本輪仍不做 GUI/manual QA。
- 2026-05-15 Card Depth v1 已落地第一段：新增 `next_attack_bonus`、`draw_from_discard`、`temporary_card` 與 `conditional.condition.exhaust_count_at_least`，並以 `upgrade_signal` 標記新卡升級方向。三角色各補 3 張 prototype cards：Subaru 聚焦 `cheap_chain + tempo_block`，Botan 聚焦 `two_cost_burst + fortress_counter`，AZKi 聚焦 `marker_loop + laplus_guard`。`CardRewardDraft` 現在除了 archetype signal，也會看 deck role gap，補缺少的 `defense`、`payoff`、`scaling` 或 `bridge`。新增 `docs/production/card-depth-v1-plan.md` 與 `tests/headless/archetype_fixture_tests.gd`，用固定牌組 / 固定敵人驗證三角色 early / late formed 流派成立；已通過 CombatEngine、RuntimeDatabase、Reward draft、Archetype fixture、Chapter 2 balance probe、Playable auto-run、Multiseed probe、Chapter 2 runtime、Smoke、RandomMap、Shop/Campfire、Combat UI layout、Godot `--quit` 與 `git diff --check`。multiseed 結果仍顯示自然路線勝率偏低，後續需另開平衡分支調整 reward 密度 / 敵人壓力；本輪仍不做 GUI/manual QA。
- 2026-05-15 Balance Pass 3 已落地：針對 code review 後 `hits` 正確生效造成的生存壓力，新增 fixed-seed auto-run balance gate，要求 Subaru / Botan / AZKi 三角色都能在保守 auto-play proxy 抵達第一章 Boss reward。`CardRewardDraft` 現在會普遍降低非 starter 重複卡，Subaru mid-run 會優先補 tempo block，Botan 已有多張 rare payoff 時會轉向防守 / 反擊橋接，AZKi 有 Laplus bridge 後會更早拿 payoff，且已有 payoff 後轉回防守橋接或不同收束。數值上 Botan max HP 74 -> 80，`botan-medkit-cover` / `botan-clean-scope` / `botan-overwatch` 小幅補強；`ssrb-debuff-check`、`announcement-shadow` 與入門 Boss `subaruto-duck` 下修尖峰壓力，保留其他 Boss 作為高壓隨機池。固定 seed 結果：Subaru / Botan / AZKi 皆抵達 `boss_reward`，分別剩 57 / 9 / 17 HP；本輪仍不做 GUI/manual QA。
- 2026-05-15 Code Review Fix Pass 已落地：修正敵方 action `hits` 未結算的問題，現在 enemy `attack` / `attack_block` 會像玩家多段攻擊一樣逐段吃格擋與 overflow，讓 `comment-flood`、`notification-storm(-elite)` 等第二章多段壓力符合資料描述。CombatEngine 也會在打出 / 棄置 / 抽牌時清除 `_retained_from_previous_turn` runtime metadata，避免 Retain 卡洗回牌堆後被誤判為前回合保留。篝火升級與事件 `upgrade_card` 現在會排除 curse / unplayable / missing card，避免 `curse-dead-air+` 這類無意義升級。`RuntimeDatabase` 新增 `find_card` / `find_enemy` / `find_relic` safe lookup，並修正商店折扣 relic 描述只承諾降低移除卡服務，不再誤寫 relic 價格。已通過 CombatEngine、RuntimeDatabase、Shop/Campfire selection；本輪仍不做 GUI/manual QA。
- 2026-05-13 Production Skill Pack 已落地第一輪 source-of-truth：新增 `GAME_DESIGN.md`、`game_design_bible.json`，以及 `docs/production/` 下的 director plan、actor contracts、UI continuity report、audio feedback contract、technical QA report、creative director review。這輪只鎖定 Godot MVP playable demo，不新增第四角色、新章節或 Web build；audio 先做 manifest-only contract，正式 SFX / BGM asset deferred。
- 2026-05-13 Production contract 落地後自動 QA 已跑完：`combat_engine_tests.gd`、`runtime_database_tests.gd`、`combat_ui_layout_tests.gd`、`random_map_tests.gd`、`shop_campfire_selection_tests.gd`、`playable_demo_smoke_tests.gd` 與 Godot `--quit` 均通過；`game_design_bible.json` 與 `docs/production/actor-contracts.json` 也通過 JSON parse。`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。Technical QA 仍維持 manual full-run pending，Creative Director Review 仍需實機三角色 QA 後才能 accepted。
- 2026-05-13 Playable Demo Manual Gate 第一段已執行：重跑指定自動 QA 全通；新增 `docs/production/playable-demo-qa-results.md`。實機 spot check 已確認角色選擇可見、AZKi 可進 16 floor random map、當時版本 Boss hint 可讀、第一場普通戰可進、AZKi body / Laplus summon / Laplus HP label 可見、`marker` fallback 顯示繁中 `標記`，且 `map_marker_attack` / `kiss_attack` 未見明顯 UI 遮擋。2026-05-14 起 Boss hint 已從 random map 移除。尚未完成 Subaru / Botan / AZKi 三角色完整 16 floor manual run，`laplus_dash` / `laplus_crash`、Boss warning、tooltip、hand hover 與 event option overflow 仍需人工確認；Technical QA 維持 `needs_revision`，Desktop Build Readiness 維持 `not_ready`。
- 2026-05-13 Auto-Run QA Proxy 已落地：新增 `tests/headless/playable_demo_auto_run_tests.gd`，用固定 seed 對 Subaru / Botan / AZKi 各跑 deterministic auto-run，並輸出 `character_id`、`seed`、`final_screen`、`final_floor`、`boss_id`、HP / Gold / deck / relic / combat / elite / visited node 統計與 `result`。本輪結果三角色皆能進 random map、完成多個節點、處理 reward / elite relic / shop / campfire / event 保守流程，最後以 `defeated` 收束到 `run_end`，未卡在未知 screen 或 flow break；forced AZKi `laplus_dash` / `laplus_crash` screen smoke、marker fallback `標記`、combat `玩法：` 與 Boss `boss-warning` event proxy 皆通過。2026-05-14 起 map `Boss 提示：` 已依使用者要求移除，auto-run 改驗證該長文不存在。這是 `automated_proxy`，不取代 manual full-run / creative acceptance；下一個 blocker 仍是 Subaru / Botan / AZKi 三角色完整手動 run 與 tooltip / hand hover / Boss warning 實機 overlap 確認。
- 2026-05-13 Demo QA 入口已接入：角色選擇畫面新增 `Demo QA` 按鈕，快捷鍵 `D` 也可開啟。Demo QA 目前提供 Subaru / Botan / AZKi random run 快速入口、AZKi 四個展示 action (`map_marker_attack` / `kiss_attack` / `laplus_dash` / `laplus_crash`)、Boss warning showcase，以及 marker fallback showcase。新增 `tests/headless/demo_qa_mode_tests.gd` 覆蓋 Demo QA screen、AZKi / Laplus 必要 sprite / FX / HP label、Boss warning text 與 `boss-warning` event；`demo_qa_mode_tests.gd`、`playable_demo_smoke_tests.gd`、`combat_ui_layout_tests.gd`、`playable_demo_auto_run_tests.gd` 與 Godot `--quit` 均通過。這輪目標是讓手動驗收更有感，不代表 manual full-run 已完成。
- 2026-05-13 Content Pack 1A 已落地第一段：新增 `docs/production/content-pack-1a-report.md`，並更新 `GAME_DESIGN.md` / `game_design_bible.json`，把下一輪方向從單純 demo gate 轉為豐富既有 single-act 內容。Subaru 調整 `subaru-duck-tempo` 為 0 費抽牌連段 payoff，`subaru-blue-wave` 增加能量；Botan 調整 `botan-mark` 成為易傷 setup，`botan-funds-prepared` 增加抽牌並延長易傷；AZKi 強化 `azki-laplus-dash` / `azki-laplus-crash`，並新增 `azki-laplus-cover`、`azki-coordinate-barrage`、`azki-laplus-combo` 到 reward/shop pool。CombatEngine relic hook 現在支援 `effects` array、`first_cheap_card_played` 與 `first_marker_card_played`；`duck-whistle`、`blue-wave-badge`、`unarchived-archive` 已改成更支援角色 build。已通過 CombatEngine、RuntimeDatabase、Playable smoke、Demo QA、Auto-run proxy、Combat UI layout、RandomMap、Shop/Campfire selection 與 Godot `--quit`；既有 ObjectDB warning 維持 non-blocking。
- 2026-05-13 Content Pack 1B 已落地：新增 `docs/production/content-pack-1b-report.md`，並更新 `GAME_DESIGN.md` / `game_design_bible.json`。本輪不做 GUI/manual QA、不新增章節、不新增角色、不新增 relic icon；Subaru 強化 `subaru-cheer-loop` 與 `subaru-hype-call` 的抽牌 / 格擋 / buff 節奏，Botan 強化 `botan-steady-aim` 與 `botan-counter-line` 的易傷 setup 與 2 費反擊，AZKi 新增 `azki-marker-echo` / `azki-laplus-reposition` 到 reward/shop pool。CombatEngine 新增 `turn_start` relic resolution 與 `heal` relic effect；`healing-chat` / `pamomi-signal` 現在會在每個玩家回合開始直接回血，`duck-whistle` 與 `unarchived-archive` 改為更明確的多效果 build payoff。已通過 CombatEngine、RuntimeDatabase、Combat UI layout、Playable smoke、Auto-run proxy、Demo QA、Shop/Campfire selection、RandomMap、Godot `--quit` 與 `game_design_bible.json` JSON parse；執行 headless 時使用 `HOME=/private/tmp/oshi-godot-user` 避免本機 Godot `user://logs` 路徑崩潰。新章節可開始做 Chapter 2 source-of-truth 規劃，但正式 runtime 章節切換仍等三角色 manual full run gate 關閉後再做。
- 2026-05-14 Content Pack 2A / Card Depth System 已落地：新增 `docs/production/card-depth-framework.md` 與 `docs/production/content-pack-2a-report.md`，並更新 `GAME_DESIGN.md` / `game_design_bible.json`。本輪不做 GUI/manual QA、不新增章節、不新增第四角色、不新增正式素材；新增 Subaru / Botan / AZKi 各 4 張 prototype placeholder 卡，並把所有新卡接入 reward/shop pool。CombatEngine 新增 `conditional`、`retain`、`exhaust_on_play`、`summon_heal`、`cards_played_this_turn` 與 Relic trigger v2；RuntimeDatabase 新增 card / relic / enemy depth metadata 與 Upgrade v2；新增 `scripts/data/CardRewardDraft.gd`，reward 會依 deck / relic signal 給 build-relevant、survival/bridge、wildcard，shop 依 build relevance 排序。敵人新增 `ssrb-guard-tutor`、`ssrb-striker-intent`、`ssrb-debuff-check`、`ssrb-scaling-clock` 作為 encounter question，覆蓋 anti-burst、attack intent、防 debuff 與 scaling clock。Manual full-run gate 仍未關閉；新章節正式 runtime 實作仍需等該 gate 完成後再做。
- 2026-05-14 Combat Card Motion Polish 已落地：新增 `docs/production/combat-card-motion-polish.md`，並更新 `GAME_DESIGN.md` / `game_design_bible.json` / `docs/production/ui-continuity-report.md`。戰鬥手牌 hover 已改為 `0.5s` 放大、`0.3s` 縮回；回合結束時未使用手牌會往右側滑出棄牌；新抽到的卡會從畫面左側滑入，並維持 CombatEngine append 規則放在手牌最右側。這輪不做 GUI/manual QA、不新增 gameplay 規則、不新增素材。已通過 CombatEngine、RuntimeDatabase、Combat UI layout、Playable smoke、Auto-run proxy、Demo QA、Shop/Campfire selection、RandomMap、Godot `--quit` 與 `game_design_bible.json` JSON parse；既有 macOS CA certificate warning 與 ObjectDB warning 維持 non-blocking。
- 2026-05-14 Player-confirmed baseline 已補入 QA 文件：使用者回報第一章整體體感可以接受，Subaru 與 Botan 都已通關過；AZKi 因剛完成不久、卡牌強度 / 內容仍偏弱，目前尚未通關。UI 與內容仍需調整，但不是致命問題。`docs/production/playable-demo-qa-results.md` 與 `docs/production/technical-qa-report.md` 已改為 `conditioned_for_content_planning`：這足以作為下一步內容開發與 Chapter 2 design bible 的依據，但不等同 Desktop Build Readiness 或 Creative Director final acceptance。`AGENTS.md` 也補上限制：除非使用者明確要求，不主動用 GUI / Browser / Computer Use / Demo QA 畫面代做 manual QA。
- 2026-05-14 Chapter 2 Foundation Pack 已寫入文件：新增 `docs/production/chapter-2-design-bible.md`、`docs/production/chapter-transition-spec.md`、`docs/production/chapter-start-event-pool.md`、`docs/production/chapter-2-encounter-design.md`、`docs/production/chapter-2-boss-contracts.md`，並更新 `GAME_DESIGN.md`、`game_design_bible.json`、`docs/production/director-production-plan.md`。第二章暫定 `chapter_2_algorithm_depths` / `演算法深層`；目標流程為 Chapter 1 Boss reward 後進入角色中立 `chapter_start_event`，再生成 Chapter 2 random map。開場事件可提供 relic、Gold + curse、移除卡、升級卡等 3 選 1，但明確不做 AZKi 或任何單一角色專屬補強；AZKi 平衡留待後續卡牌 / reward pool 調整。這輪只做 source-of-truth，不接 runtime、不新增素材、不跑 GUI/manual QA。
- 2026-05-14 Chapter 2 Runtime Prototype 已接上：`RunState` 新增 `current_chapter_id` 與 `start_next_chapter()`，`RandomMapGenerator` / `RuntimeDatabase` 可依 `chapter_2_algorithm_depths` 生成第二章 16 floor random map；Chapter 1 `boss_reward` 現在會先進 `chapter_start_event` / `Holo Support Desk`，選完 3 選 1角色中立支援後生成第二章 map，Chapter 2 Boss reward 才進 demo clear。新增第二章 common enemy `recommendation-watcher`、`buffering-wall`、`comment-flood`、`clip-mirror`、`bitrate-phantom`、`archive-sentinel`，elite `algorithm-auditor`、`notification-storm-elite`、`archive-hydra`，Boss `algorithm-core`、`archive-phantom`、`notification-storm`，以及 8 個第二章事件。新增 `tests/headless/chapter_2_runtime_tests.gd` 覆蓋資料、map pool、Boss reward transition 與 chapter start event；已通過 Chapter 2 runtime、RuntimeDatabase、RandomMap、Event/Relic、Playable smoke、CombatEngine、Combat UI layout、Auto-run proxy 與 Godot `--quit`。本輪仍不新增正式第二章素材、不做 GUI/manual QA；既有 macOS CA certificate warning 與 ObjectDB warning 維持 non-blocking。
- 2026-05-14 Boss hint 移除與 Chapter 2 收斂：依使用者要求，random map 不再顯示 `Boss 提示：...` 長文，Boss data 也移除 `boss_hint` 欄位；地圖只保留 Boss 名稱與 `BOSS` node。戰鬥內 `Boss warning`、`boss_danger_tag`、`boss_pattern`、`boss_counterplay`、`boss_spike_turn` 保留，因為它們是 combat decision feedback，不是地圖 hint 功能。新增 `tests/headless/chapter_2_balance_probe_tests.gd`，以保守 headless proxy 檢查 Subaru / Botan / AZKi 對三個第二章重點 encounter 的基本可解性；`playable_demo_auto_run_tests.gd` 也新增 boosted Chapter 2 transition proxy，確認第一章 Boss reward 後可進 `chapter_start_event` 並處理第二章節點。
- 2026-05-14 Chapter 2 Balance Pass 1 已落地：`CardRewardDraft.gd` 在 AZKi marker build 已形成且進入中後段 floor 時，會把 `laplus_guard` 防守橋接與 payoff/scaling 卡往 reward/shop 前排推，避免第二章只繼續給 marker loop 而缺少 Laplus 生存與收束。`recommendation-watcher`、`buffering-wall`、`comment-flood`、`bitrate-phantom`、`archive-sentinel` 的 common enemy 數值已依 headless pressure guardrail 下修，降低第二章入口對未成形 deck 的硬壓。新增/更新 `reward_draft_tests.gd`、`chapter_2_runtime_tests.gd`、`chapter_2_balance_probe_tests.gd` 覆蓋這輪行為；本輪仍不是 manual balance acceptance。
- 2026-05-14 Chapter 2 Balance Pass 2 已落地：AZKi reward draft 的 `laplus_guard` 防守橋接 bonus 從原本 floor >= 8 且 marker_loop 已成形，提前到 floor >= 6 且已有初步 marker signal，讓第二章入口 reward 就能直接出 `azki-laplus-guard-order`。第二章 common 壓力小幅下修：`buffering-wall` 反擊 16 -> 14、`comment-flood` attack_block 防禦 10 -> 8、`clip-mirror` 普攻 18 -> 16。新增 reward / runtime guardrail，並更新 `docs/production/chapter-2-encounter-design.md`；這仍是 headless balance proxy，不是 manual acceptance。
- 2026-05-14 AZKi Early Survival Pass 已落地：新增 `tests/headless/azki_early_survival_tests.gd`，補 AZKi 第一章 early pressure proxy、早期防守數值 guardrail、固定 auto-run 第一個 reward 必須 frontload `azki-laplus-guard-order`。`CardRewardDraft.gd` 新增 AZKi floor 1-5 survival pre-pick，`azki-guard` 5 -> 6 block、`azki-route-strike` 3 -> 4 block；`playable_demo_auto_run_tests.gd` 死亡紀錄追加 `defeat_enemy_id`、`defeat_floor`、`combat_start_hp`、deck/relic snapshot。Random map 將第一個 elite 從 floor 4 延後，新增測試要求 elite 不早於 floor 6。固定 auto-run proxy 中 AZKi 已從 floor 4 elite 死亡改善為抵達 floor 16 Boss 後死亡；這是 automated proxy improvement，不代表 AZKi manual balance accepted。
- 2026-05-14 AZKi Laplus HP / Hover Hit-Test Pass 已落地：依使用者回報，Laplus 改為 `starting_hp=1`，不再用 `summon_max_hp` clamp 疊加，也不再於玩家回合開始自動補血 / 復活；Laplus HP 需透過 `summon_heal` 卡牌往上疊，UI 只顯示目前 HP 或 `DOWN`。AZKi 起始牌 `azki-map-shot` 5 -> 7、`azki-pinpoint` 3 -> 4、`azki-kiss` 10 -> 14、`azki-guard` 改為 7 block + Laplus 4 HP；`azki-laplus-cover` 追加 Laplus 2 HP。新增 `summon_hp_damage` effect 與 `azki-laplus-contract`、`azki-dark-tether`、`azki-laplus-overflow`，並讓 AZKi reward 對已持有的同名非 starter 卡有重複懲罰，減少只塞同一類橋接牌。Combat hover 已移除其他手牌透明 / 微暗效果，改用 hover 中暫停其他手牌 `mouse_filter` 來降低相鄰卡 hover 判定干擾。已通過 CombatEngine、RuntimeDatabase、Combat UI layout、Playable smoke、Reward draft、AZKi early survival、Chapter 2 balance proxy、Auto-run proxy、Card upgrade 與 Godot `--quit`；仍未做 GUI/manual QA。
- 2026-05-14 Event Remove Card Selection Fix 已落地：修正事件 outcome `remove_card` 仍走 `_remove_first_removable_card()` 的舊路徑，現在事件選項若包含 `remove_card`，會先結算其他非戰鬥 outcome，再開 `event_remove_selection` 牌組選擇畫面；玩家選定卡牌後才移除指定 index、完成事件節點並回地圖。新增 `shop_campfire_selection_tests.gd` 覆蓋事件移除卡不可直接移除第一張、不可未選牌就完成節點、選定後才回 map；`playable_demo_auto_run_tests.gd` 也能處理 `event_remove_selection`。已通過 Shop/Campfire selection、Event/Relic definition、Chapter 2 runtime、Playable smoke、Auto-run proxy 與 Godot `--quit`；仍未做 GUI/manual QA。
- 2026-05-14 Combat hand motion 追加打牌滑出：使用者實機確認回合結束未用手牌往右側移除動畫可見後，新增「打出手牌」單張滑出並淡出的動畫。`CombatHandView.gd` 新增 `animate_played_card_to_right()`，`Game.gd` 在 `play_card()` 成功後先播放該張卡滑出，再進既有角色攻擊 / 受擊 / 抽牌刷新流程；`combat_ui_layout_tests.gd` 已補單張打出卡測試。
- 2026-05-14 Combat Motion Polish 2 已落地：打出的手牌改為先短暫上浮，再往畫面右上方滑出、旋轉並淡出；回合結束未用手牌維持往右下棄牌，新抽牌維持從左側滑入。這輪只調整戰鬥手牌 motion，不新增 gameplay 規則、不新增素材、不做 GUI/manual QA；headless UI 測試已覆蓋上浮 metadata、右上滑出終點、動畫時間區間與淡出。
- 2026-05-14 Combat Hover Motion Polish 已落地：依使用者指定分鏡，hover 手牌時先用 `0.1s` 沿原本扇形角度抬起，再於 `0.3s` 內放大到前景；hover 全程不轉正，其他手牌不退位、不透明化，改為暫停滑鼠判定來避免 hover 干擾，hover out 回到原位置 / 原角度並恢復判定。`combat_ui_layout_tests.gd` 已覆蓋 hover lift duration、保留 base_rotation、其他手牌不透明、mouse_filter lock / restore 與縮回還原。
- 2026-05-14 Combat Motion QA Pack 已落地第一段：補上 hover 被打牌中斷的 edge-case 測試，並在 `CombatHandView.gd` 中讓 `play` / `discard` / `draw` 這類會接管手牌狀態的動畫開始前先清掉整組手牌 hover hit-test lock 與半透明狀態，避免 hover 中斷後留下不可選手牌。`docs/production/combat-card-motion-polish.md` 已新增 Motion Contract。
- 2026-05-13 Playable Demo Manual Gate 第二段已執行：重新跑 `combat_engine_tests.gd`、`runtime_database_tests.gd`、`combat_ui_layout_tests.gd`、`random_map_tests.gd`、`shop_campfire_selection_tests.gd`、`playable_demo_smoke_tests.gd`、`playable_demo_auto_run_tests.gd`、`demo_qa_mode_tests.gd` 與 Godot `--quit`，皆 exit 0；`runtime_database_tests` / `combat_ui_layout_tests` / `playable_demo_auto_run_tests` 仍只有既有 ObjectDB warning。Production Contract Gate 的 `game_design_bible.json` 與 `docs/production/actor-contracts.json` JSON parse 通過。新增 Subaru 實機 spot check：可從角色選擇進 random map，本次 seed `1778686866`、Boss `巨大 SSRB Gray`，當時版本 Boss hint 可讀，第一個 reachable battle 可進，首戰單張 hand hover 未見明顯遮住 HP / intent。2026-05-14 起 Boss hint 已從 random map 移除。這仍不是三角色完整 manual full-run；Technical QA 維持 `needs_revision`，Creative Director Review 維持 `deferred_until_manual_qa`，Desktop Build Readiness 維持 `not_ready`。
- 歷史來源：
  - 第一版測試：`/Users/zhangzhipeng/MyProject/oshi-no-tower`
  - 第二版 Unity MVP：`/Users/zhangzhipeng/MyProject/oshi-no-tower-unity`
  - 目前主開發環境：`/Users/zhangzhipeng/MyProject/oshi-no-tower-godot`

## 溝通與文件規則

- 專案文件、開發紀錄、TODO、狀態摘要，預設使用繁體中文。
- Agent 回覆使用者時，預設使用繁體中文。
- 技術名詞、檔案路徑、Godot API、程式碼符號、錯誤訊息可保留英文原文。
- 專案根目錄新增 `AGENTS.md`，作為新對話或新 agent 接手時的溝通規則入口。

## 目前完成內容

- 可遊玩角色：
  - Subaru：低費、多段、節奏型牌組；MVP-v3 追加 Duck Tempo、Teetee、Desk-kun、Blue Wave、New Oshi 方向卡。2026-05-10 追加角色被動「節奏守備」：每回合第一次打出 0/1 費牌時獲得 3 點格擋。
  - Botan：高單發、防禦穩、射擊感牌組；MVP-v3 追加 Shishiro Button、Clean Scope、Calm Burst、Precise Cover、X Funds 方向卡。2026-05-10 追加角色被動「狙擊開場」：每回合第一次打出 2 費攻擊牌時追加 6 點傷害。
  - AZKi：MVP-v5 第一段新增第三可玩角色，主軸為標記與追擊。被動「開拓者的座標」：每回合第一次給予敵人標記時抽 1 張牌。第一版包含 10 張起始牌與 15 張 reward/shop pool 候選，部分卡牌以 ラプラス・ダークネス 作為助攻動畫表現。
  - 2026-05-13 為三位角色補上資料化輪廓 metadata：`identity_focus_tags` 與 `signature_card_ids`。目前 Subaru 鎖定 `cheap_chain` / `tempo_block`，Botan 鎖定 `two_cost_burst` / `setup_control`，AZKi 鎖定 `marker_setup` / `marker_payoff`，用於後續測試與內容擴充時維持角色差異。
- 固定路線：
  - 開始 -> 小怪 1 -> 事件 1 -> 小怪 2 -> 寶箱 -> 菁英 -> 商店 -> 事件 2 -> 小怪 3 -> 篝火 -> 小怪 4 -> 事件 3 -> 小怪 5 -> Boss -> 結算。
- MVP-v2 隨機路線：
  - Subaru / Botan 正常開始 run 時會生成 seed-based random map。
  - Map UI 依 floor / lane 顯示節點，只有目前可到達節點可點。
  - 本局 Boss 在地圖上先決定並顯示，進 Boss 戰時使用同一個 Boss id。
  - 2026-05-12 起 random map 改為單 Act 長路線：Boss floor 16，Boss 前包含更多普通戰、事件、菁英、商店、篝火與寶箱候選；固定路線仍保留為 debug fallback。
  - random map 事件不再依 floor 固定指定前三個事件，而是完全從 event pool 抽取。
  - 2026-05-12 長地圖 UI 從橫向改為可上下捲動的直式 ScrollContainer：起點在下方、Boss 在上方、一般節點以左右 lane 垂直排列；內容高度大於可視區，玩家可上下滾動查看路線；Boss 節點文字簡化為 `BOSS`，避免長名稱把節點擠爆。
  - 固定路線資料仍存在，用於 debug fallback 與資料測試。
- 敵人：
  - 普通戰使用 SSRB Gray、SSRB Camouflage、SSRB White，MVP-v2 另加入 SSRB Gold 與 SSRB Glitch 作為 status / buff 教學型 encounter。2026-05-12 起普通敵人標記 `encounter_tier`，random map 會依 early / mid / late 樓層抽不同壓力池；本輪新增 `ころね好き` 作為中段普通敵人。
  - 中段菁英戰使用 SSRB Duo 假雙敵人資料，MVP-v2 已擴到四組菁英 encounter，其中 Gold + Glitch 會使用 buff / debuff 壓力。本輪新增單體菁英 `毛玉`，並補上 `elite_tier` 供後段菁英 pool 使用。
  - 普通戰給少量 Gold，菁英戰給較多 Gold 與 relic；戰鬥獎勵畫面會顯示本場取得 Gold。
  - MVP-v3 追加 YouTube-kun、Desk-kun、Announcement Shadow、AK Idol Unit，並讓 normal / elite pool 可抽到 meme 主題敵人。
  - Boss 節點會隨機選 Subaruto Duck、巨大 SSRB 變體、YouTube-kun Core 或 Important Announcement；Boss 數值已配合 16 floor 長路線提高到後段壓力區間。
  - 2026-05-13 Boss metadata 曾補成兩層；2026-05-14 依使用者要求移除 map hint 長文與 `boss_hint` 欄位，保留 `boss_danger_tag`、`boss_pattern`、`boss_counterplay`、`boss_spike_turn` 作為戰鬥 warning 與 QA metadata。
- 視覺素材：
  - SSRB idle / attack / hurt sheet 位於 `res://assets/enemies/ssrb/`。
  - 2026-05-12 SSRB Gray / Camouflage / White 的 `idle`、`attack`、`guard`、`hurt`、`defeat` 已更新為 3x3 / 9 幀 sheet；正式素材位於 `assets/enemies/ssrb/{gray,camouflage,white}/{idle,attack,guard,hurt,defeat}/`，每組保留 `sheet-transparent.png`、frame PNG、`animation.gif`、`pipeline-meta.json` 與 prompt 紀錄，生成來源保留於 `generated/sprites/ssrb-*-3x3-v1/`。2026-05-12 復查 metadata 時，部分 SSRB sheet 的 `edge_touch_frames` 非空，包含三組 attack，需實機或 GIF 目視確認是否要重切。
  - 2026-05-12 新增敵人素材：一般敵人 `ころね好き` 位於 `assets/enemies/korone_suki/{idle,guard,hurt,defeat,attack}/`，菁英敵人 `毛玉` 位於 `assets/enemies/kedama/{idle,guard,hurt,defeat,attack}/`；兩者各 5 組 3x3 / 9 幀 sheet，皆保留 `sheet-transparent.png`、9 張 frame PNG、`animation.gif`、`pipeline-meta.json` 與 prompt 紀錄，生成來源保留於 `generated/sprites/korone_suki-*-3x3-v1/` 與 `generated/sprites/kedama-*-3x3-v1/`。本輪已接入 `RuntimeDatabase` 與隨機地圖敵人池。
  - Subaruto Duck idle / attack / hurt sheet 位於 `res://assets/enemies/subaruto_duck/`。
  - Combat 與 Map 背景位於 `res://assets/backgrounds/`。
  - Subaru 與 Botan 動作 sheet 位於 `res://assets/characters/`。
  - 2026-05-12 AZKi / ラプラス・ダークネス 角色素材已重做為無鎖鏈版：AZKi 六組 3x3 / 9 幀動作位於 `assets/characters/azki_necromancer/{idle,defense,hurt,defeat,map_marker_attack,kiss_attack}/`；召喚獸 ラプラス・ダークネス 六組 3x3 / 9 幀動作位於 `assets/characters/laplus_darkness_summon/{idle,defense,hurt,defeat,dash_attack,crash_attack}/`。每組皆保留 `sheet-transparent.png`、9 張 frame PNG、`animation.gif`、`pipeline-meta.json` 與 prompt 紀錄，生成來源保留於 `generated/sprites/azki-laplus-no-chain-v1/`。這版取消所有可見鎖鏈 / leash / tether；Laplus 可保留項圈造型但不接鎖鏈；`kiss_attack` 的「雑魚❤️」對話框只出現在攻擊中段幀。正式 sheet 已做 cell alpha 邊界檢查，12 組 `edge_touch_frames` 皆為空陣列。
  - 2026-05-13 為 AZKi 卡圖接線先補好 fallback-ready 規則：所有 `azki-*` 卡都會預留 `expected_art_path = res://assets/cards/azki/<card_id>.png`；若正式檔已存在，`RuntimeDatabase` 會自動把 `art_path` 接上，若檔案尚未落地則維持 `ART` placeholder，不需要再逐張改程式碼。
  - 2026-05-12 AZKi / ラプラス・ダークネス 已追加 necrobinder pair + 獨立 FX 試作版：8 組角色本體 sheet 位於 `assets/characters/azki_necromancer/{idle,defense,hurt,defeat,cast_marker,cast_kiss,command_dash,command_crash}/`，每張為 1152x1152、3x3、每格 384x384，9 格都同時包含 AZKi 與 Laplus；4 組 FX-only sheet 位於 `assets/fx/azki_necrobinder/{map_marker_projectile,kiss_heart_projectile,laplus_dash_trail,laplus_crash_impact}/`，每張為 768x768、3x3、每格 256x256。生成來源保留於 `generated/sprites/azki-laplus-necrobinder-pair-v1/`，所有 `prompt-used.txt` 使用繁體中文並明確禁止鎖鏈 / leash / tether。`generated/.gdignore` 已加入，避免 Godot 把生成來源當正式資源匯入而產生 UID duplicate warning。
  - 2026-05-13 AZKi runtime 已改回分離素材管理：正式戰鬥顯示使用 AZKi 單人 sheet、`assets/characters/laplus_darkness_summon/` 的 Laplus summon sheet，以及 `assets/fx/azki_necrobinder/` 的獨立 FX。2026-05-12 的 pair body sheet 保留為素材試作紀錄，但不再作為正式 runtime 顯示路徑。
  - 2026-05-13 AZKi / Laplus 正式分離素材已重做並覆蓋 runtime 路徑：AZKi 10 組 body sheet 位於 `assets/characters/azki_necromancer/{idle,defense,hurt,defeat,cast_marker,cast_kiss,map_marker_attack,kiss_attack,command_dash,command_crash}/`，Laplus 6 組 body sheet 位於 `assets/characters/laplus_darkness_summon/{idle,defense,hurt,defeat,dash_attack,crash_attack}/`；每張皆為 1152x1152、3x3、每格 384x384。生成來源保留於 `generated/sprites/azki-separated-body-v2/` 與 `generated/sprites/laplus-separated-body-v2/`。本輪只重做角色本體，保留 `assets/fx/azki_necrobinder/` 既有 FX-only 投射物 / 軌跡 / impact；`kiss_attack` 的「雑魚❤️」對話框以後處理固定在第 4-6 幀，避免模型跨格裁切或 9 格全出現。16 組正式 sheet 的 `edge_touch_frames` 皆為空陣列，目視 QC 未見 AZKi / Laplus 混圖、上方殘片或角色碎片。
  - 2026-05-13 AZKi 新分離素材已接入 runtime action mapping：`map_marker_attack` 會讓 `AZKiBodySprite` 播 `map_marker_attack` 並疊 `map_marker_projectile` FX；`kiss_attack` 會播 `kiss_attack` 並疊 `kiss_heart_projectile` FX；`laplus_dash` / `laplus_crash` 會讓 AZKi 分別播 `command_dash` / `command_crash`，Laplus 分別播 `dash_attack` / `crash_attack`，並保留既有 dash trail / crash impact FX。卡牌 `animation` id、CombatEngine 召喚物規則與 FX-only 素材皆未改。
  - 2026-05-13 playable demo 收斂第一段：四個 AZKi 驗收 action (`map_marker_attack` / `kiss_attack` / `laplus_dash` / `laplus_crash`) 的 FX anchor / size 已明確化並納入 Combat UI layout 測試。FX 現在固定落在 Laplus 右側、往敵人方向延展：marker / kiss 使用 `Vector2(0.54, 0.48)` + `Vector2(300, 170)`，dash 使用 `Vector2(0.52, 0.52)` + `Vector2(300, 160)`，crash 使用 `Vector2(0.54, 0.54)` + `Vector2(280, 220)`。這只修 runtime 擺位與顯示空間；若後續仍覺得投射物本身飛行距離不對，需重做或後處理 FX sheet。
  - 2026-05-13 playable demo 收斂第二段：新增 `tests/headless/playable_demo_smoke_tests.gd`，作為不方便手動測試時的最低限度自動替代 QA。此測試會用固定 seed 分別啟動 Subaru / Botan / AZKi random run，確認 16 floor map、Boss 名稱、可捲動地圖、第一個普通戰進場、手牌、敵方 HP、角色玩法提示與角色專屬牌組 prefix；2026-05-14 起額外確認 map 不顯示 `Boss 提示：` 長文。AZKi 額外檢查 AZKi 本體、Laplus summon、Laplus HP label、summon 初始 HP，以及四個 demo action 的 AZKi / FX z-order 與 FX 位於 Laplus 右側。
  - 2026-05-13 素材資料夾整理：正式 `assets/characters/`、`assets/enemies/`、`assets/fx/` 動畫資料夾改為只保留 runtime 需要的 `sheet-transparent.png` 與對應 `.import`，以及 `pipeline-meta.json` / `prompt-used.txt` 紀錄；raw sheet、拆幀 PNG、GIF 預覽、舊命名 frame 與 `.DS_Store` 已確認不影響 runtime 並移除，避免 Godot 匯入大量不會被遊戲讀取的殘留圖片。`.godot/imported` 快取也已重建，只保留目前 127 個正式圖片對應的匯入結果。`generated/` 生成來源暫時保留，因其屬於素材追溯與重產來源，不參與 runtime 匯入。
  - 2026-05-11 Subaru idle / defense / hurt 三組角色動作圖已替換為 3x3 / 9 幀 sheet；`assets/characters/subaru/idle/`、`assets/characters/subaru/defense/`、`assets/characters/subaru/hurt/` 皆保留 `sheet-transparent.png`、9 張 frame PNG、`animation.gif`、`pipeline-meta.json` 與 prompt 紀錄，生成來源保留於 `generated/sprites/subaru-action-refresh-v1/`。三組 `pipeline-meta.json` 的 `edge_touch_frames` 皆為空陣列。
  - 2026-05-11 追加 Botan 新攻擊參考素材：小招手槍 3x3 sheet 位於 `assets/characters/botan/pistol_attack/`，大招蹲姿狙擊 3x3 sheet 位於 `assets/characters/botan/sniper_ultimate/`；兩者皆保留 `sheet-transparent.png`、9 張 frame PNG、`animation.gif`、`pipeline-meta.json` 與 prompt 紀錄，生成來源保留於 `generated/sprites/botan-pistol-attack-v1/`、`generated/sprites/botan-sniper-ultimate-v1/`。
  - 2026-05-11 Botan idle / defense / hurt 三組角色動作圖已替換為 3x3 / 9 幀 sheet；`assets/characters/botan/idle/`、`assets/characters/botan/defense/`、`assets/characters/botan/hurt/` 皆保留 `sheet-transparent.png`、9 張 frame PNG、`animation.gif`、`pipeline-meta.json` 與 prompt 紀錄，生成來源保留於 `generated/sprites/botan-idle-3x3-v1/`、`generated/sprites/botan-guard-3x3-v1/`、`generated/sprites/botan-hit-3x3-v1/`。正式 sheet 已做 final alpha 邊界與底部對齊檢查。
- UI：
  - 主流程目前由 `scripts/Game.gd` 動態建立。
  - Combat 使用生成背景、玩家/敵人動畫 sheet、固定資訊面板與類 Slay the Spire 的卡牌框架。
  - Combat UI 目前只在玩家資訊列顯示 HP、格擋、能量、角色被動；抽牌與棄牌數不顯示。
  - 玩家與敵方 HP / 格擋 / 能量數值只保留文字，不再顯示深色文字底色。
  - 2026-05-12 戰鬥畫面隱藏玩家 / 敵方名稱，避免長名稱把上方資訊列擠壞；Boss 戰上方只保留 `BOSS` 標示，不再顯示完整 Boss 名稱。
  - 2026-05-12 relic icon 放大到原本約 1.5 倍；relic / status / intent icon 改用自訂 tooltip，hover 說明字體放大為原本約 2 倍。
  - 2026-05-12 SSRB 類敵人勝利後的 `defeat` 演出不再重播第二次；首次播完後只保留最終靜止幀等待玩家進 reward。
  - 敵方意圖文字區塊底色已移除；MVP-v4 已加入第一版 symbol placeholder，例如 `⚔`、`▣`、`⚔▣`、`↑`、`↓`，並保留文字 fallback；一般 UI 文字加上深色陰影與輕量描邊，提高背景上的可讀性。
  - 玩家與敵人的簡版狀態列位於角色下方；目前 active status 會顯示小 icon 與數值 / 回合，沒有狀態時保留 `狀態：無` 文字，icon path 無效時回到純文字 fallback。
  - 2026-05-13 marker 尚無正式 icon 時，戰鬥 status UI 會以繁中 fallback 顯示 `標記 value/duration`，不再裸顯英文 `marker`。若未來補上 `assets/icons/status/marker.png`，再把 `STATUS_ICON_PATHS` 接上即可，不需要改 marker 規則。
  - 戰鬥手牌已試改為 3:4 直式卡牌，費用只顯示數字，不顯示「費用」字樣；卡面包含外框、左上費用 badge、卡名、圖片預留區、類別與下半部效果說明。
  - 戰鬥手牌未 hover 時以畫面中央為核心，維持中間較高、左右較低的底部扇形排列；手牌數量減少時也會往中央集中。hover 時單張卡牌會以底部為 pivot 放大、轉正、底部貼齊畫面下緣並置頂，且改用實際尺寸重排文字而非 `scale` 整張縮放，降低文字模糊並保留較完整描述區比例。
  - 下方手牌區不再顯示「手牌」標題文字。
  - 戰鬥狀態區與手牌區的大型深色底板已移除；戰鬥與獎勵卡牌仍使用固定安全文字區，降低跑版與重疊；戰鬥獎勵卡牌不啟用 hover 放大。
  - 寶箱節點依 Slay the Spire 原則固定隨機取得 1 個 relic，不提供卡牌 / Gold 多選；寶箱使用獨立 `chest_reward` screen，避免 debug/reward 訊息刷新時被一般卡牌獎勵覆蓋。
  - Boss 戰會顯示 BOSS 標示與暗色 overlay。
  - 小範圍美術接線準備已完成第一段：卡牌資料會預留 `art_path`，relic 資料會預留 `icon_path`，敵方 action / intent 會預留 `icon_path`，帶 status 的 action / card effect 會預留 `status_icon_path`。目前預設皆可為空字串，避免沒有正式素材時影響流程；卡牌圖片槽在沒有有效 `art_path` 時會顯示淡色 `ART` placeholder，方便實機判斷卡圖預留位置。
  - 第一批狀態 icon 已接入正式素材路徑：`assets/icons/status/strength.png`、`weak.png`、`vulnerable.png`、`regen.png`，來源為 `generated/sprites/status-icons-v1/final/`。
  - MVP-v4.2 展示版視覺打磨已接入第一批起始牌組卡圖、敵方 intent icon 與 18 個 relic icon。卡圖位於 `assets/cards/subaru/`、`assets/cards/botan/`；intent icon 位於 `assets/icons/intent/`；relic icon 位於 `assets/icons/relic/`。
  - MVP-v4.3 卡牌主視覺補完已接入剩餘 27 張卡圖；目前 Subaru / Botan 全部 37 張卡牌都有正式 `art_path`，reward / shop 中的非起始牌也會顯示正式卡圖而不是 `ART` placeholder。生成來源保留於 `generated/sprites/v4.3-card-art-subaru-v1/` 與 `generated/sprites/v4.3-card-art-botan-v1/`。
- Event v2：
  - 事件 1：`遇到流離失所的 HoloStar 成員`，可用 Gold 回復 HP，或用 HP 換 relic。
  - 事件 2：`直播事故支援`，可用 HP 換 Gold，或加入一張角色卡。
  - 事件 3：`粉絲應援整隊`，可用 Gold 換 relic，或整理應援取得 Gold。
  - MVP-v2 新增資料化事件池，共 6 個事件，新增剪輯檔案整理、突發練習台、安靜的周邊攤。
  - MVP-v3 事件池擴到 14 個，新增重大告知倒數、EN Curse 事故台、Twitter Jail、Pineapple Pizza War、Superchat Time、Unarchived Karaoke、全損現場、HoloMoms 應援。
  - 2026-05-12 事件池擴到 16 個以上，新增高風險 / 不利事件，例如 Sudden RAID 額外戰鬥、Algorithm Punishment 失去 Gold 或 HP。
  - 2026-05-12 再追加一批高風險事件，開始支援指定加入 curse 卡、事件額外戰鬥後保留該場戰鬥獎勵，以及更明確的長期代價。
  - 事件、卡牌、relic、敵人資料會補 `meme_source`、`content_group`、`rarity`、`implementation_status` metadata，用於去重測試與後續 QA。
  - 事件選項使用標準 outcome action：gain gold、lose hp、heal、add card、remove card、grant relic、start battle。`add_card` 可額外指定 `card_id` 直接加入特定卡，例如 curse。`remove_card` 現在會開啟事件專用牌組選擇畫面，玩家選定卡牌後才完成事件節點。`start_battle` 可指定 enemy id 或 normal / early / mid / late / elite enemy pool；事件戰鬥勝利後會先進入該場戰鬥獎勵，再完成事件節點回到地圖。
- Relic v2：
  - 開局不固定持有 relic。
  - 寶箱、菁英戰、商店、事件與 debug 可取得 relic。
  - MVP-v2 relic pool 擴到 9 個：應援螢光棒、鴨鴨哨子、獅白準星、開場能量飲、聊天室補給、金色 Superchat、商店折價券、推塔集章卡、終局聚光燈。
  - MVP-v3 relic pool 擴到 18 個，新增 YAGOO is Best Girl、Shishiro Button、Superchat Reading、X Funds Wallet、Ada TV、Pamomi Signal、Blue Wave Badge、Unarchived Archive、YAGOO Blood Pressure Meter。
  - relic 已全數取得時，寶箱、菁英與事件的 relic 獎勵會改給 Gold 25。
  - relic metadata 已加入 pool、source_rules、hooks；支援 combat start、turn start、first attack、first two cost、battle reward、shop enter、room enter 等 hook。
- Status v2：
  - CombatEngine 支援 `strength`、`weak`、`vulnerable`、`regen`。
  - 玩家與敵人都能持有狀態，狀態會影響傷害、回合開始恢復與 duration 衰減。
  - `RuntimeDatabase` 會為目前支援的 4 種 status 自動補 `status_icon_path`；戰鬥 UI 會用 `ActorStatusView` 在 active status 顯示 icon，無效路徑時保留文字 fallback。
- Status v5：
  - 2026-05-12 新增 AZKi 專屬 `marker` / 標記狀態。標記是層數，不會隨回合自然衰減；玩家攻擊造成未被格擋的傷害時，額外造成 2 點傷害並消耗 1 層標記。`marker` 暫無正式 icon，UI 會走文字 fallback。
- 角色被動：
  - CombatEngine 支援角色被動資料 `character_passive`，目前包含每回合一次觸發旗標。
  - Subaru `subaru-tempo-guard`：每回合第一次打出 0/1 費牌時獲得 3 點格擋。
  - Botan `botan-sniper-opening`：每回合第一次打出 2 費攻擊牌時追加 6 點傷害。
  - AZKi `azki-pioneer-coordinate`：每回合第一次給予敵人標記時抽 1 張牌。
  - MVP-v4 起，角色選擇畫面會顯示被動名稱與說明，戰鬥中會顯示目前被動名稱，被動觸發時會顯示短暫提示。
  - 2026-05-13 補上角色定位短文 `identity_hint` 與被動提示短文 `preview_text` metadata；戰鬥中除被動名稱外，還會顯示角色玩法提示，例如 Subaru 的低費連段、Botan 的 2 費爆發、AZKi 的標記追擊。
  - 2026-05-13 `CombatState.turn_events` 已補成較一致的提示來源，事件至少包含 `id`、`text`、`kind`、`source`；目前已接角色被動提示、AZKi 標記追擊，以及 Boss 大招前 warning。
- 非戰鬥節點 v2：
  - 商店支援購買卡牌、購買 relic、移除第一張可移除卡。
  - 商店商品區已改成 ScrollContainer，上下滾動呈現，避免商品與底部選項重疊。
  - 商店卡牌、relic 與移除卡服務會在左上角顯示價格 badge，卡面下方顯示功能說明。
  - 2026-05-12 起商店卡牌會依 `rarity`、`kind`、`cost` 計算價格，relic 會依 `pool` 計算價格；每個商店節點固定有一個特價商品。同一商店節點重開不會刷新卡牌、relic 或特價商品；購買卡牌 / relic 後會從該商店庫存移除。折扣 relic 先只影響移除卡服務；商店移除卡價格、篝火休息量與起始 Gold 本輪不調整。
  - 篝火支援休息恢復 HP 或升級卡。
  - 升級卡牌的 `+`、數值與描述會同步更新。
  - Boss 勝利後進入 Boss reward，可選升級版高價值卡、取得 Boss relic，或直接進結算。
- 非戰鬥節點 v3：
  - 商店移除卡改為玩家可選牌，使用 ScrollContainer 呈現牌組。
  - 篝火升級卡改為玩家可選牌，已升級卡不會出現在升級清單。
- 本輪 UI / 行為修正：
  - 2026-05-13 MVP-v5 第二段第一版曾在 random map 標題區下方顯示本局 `Boss 提示`；2026-05-14 起此 map hint 長文已移除。戰鬥畫面左側保留角色 `玩法：...` 提示，中央上方可顯示來自 `CombatState.turn_events` 的短提示，例如角色被動觸發、AZKi 標記追擊與 Boss warning，讓角色差異不只存在於數值與卡名。
  - 2026-05-13 MVP-v5 第二段第二版：當 Boss 下一個玩家回合面對的是高傷 `attack` / `attack_block` 意圖時，`CombatEngine.end_player_turn()` 會自動推入 `boss-warning` 事件，讓戰鬥畫面在玩家回合開始時能顯示 `Boss 警告`。
  - 2026-05-13 提示系統驗收與小修：Boss warning 文字現在會帶入 Boss metadata 的 `boss_counterplay`，讓高傷提示除了危險標籤與意圖描述外，也包含可操作的應對方向；2026-05-14 起 random map Boss hint 長文移除，戰鬥中的 turn event 提示仍保留兩行換行區域，降低長 warning 被裁切的風險。
  - 2026-05-13 AZKi / Laplus 圖層修正：AZKi 戰鬥 sprite 現在明確設定 `AZKiBodySprite.z_index = 2`、`LaplusSummonSprite.z_index = 1`、`PlayerActionFxSprite.z_index = 3`，讓 AZKi 本體與 marker / kiss / dash / crash 等動作 FX 顯示在 Laplus 上方，避免特效與動作被 summon 蓋住。Combat UI layout 測試已補四種 AZKi 攻擊 action 的 z-order 檢查。
  - 2026-05-13 AZKi 攻擊圖切換：依實機畫面回饋，`map_marker_attack` 與 `kiss_attack` 的 AZKi 本體動畫改回使用 `assets/characters/azki_necromancer/map_marker_attack/sheet-transparent.png` 與 `assets/characters/azki_necromancer/kiss_attack/sheet-transparent.png`；`cast_marker` / `cast_kiss` 保留為素材檔，但不再作為這兩張攻擊牌的 runtime body mapping。既有 FX 疊加與 Laplus summon 規則不變。
  - 2026-05-12 事件風險深化第一段：新增 3 張最小版 curse 卡 `curse-dead-air`、`curse-bad-connection`、`curse-comment-fire`，目前皆為高費幾乎無法打出的負面牌，並已接入最小實戰副作用。`Dead Air` 抽到時失去 1 點能量，`Bad Connection` 若回合結束仍留在手上會失去 3 HP，`Comment Fire` 抽到時會給玩家 1 回合易傷。事件池新增數個高風險事件，包含直接塞 curse、失去資源、移除牌換血，以及觸發 mid / late 額外戰鬥。事件戰鬥勝利後不再直接回地圖，而是保留該場普通 / 菁英戰獎勵流程。
  - 2026-05-12 curse 第二段規則：三張 curse 現在都標記為 `unplayable`，不能像一般卡一樣打出；其中 `Comment Fire` 額外具有 `ethereal`，若回合結束仍在手上會直接進 `exhaust_pile`，不再回到棄牌堆輪抽。
  - 2026-05-12 直式地圖 / 戰鬥資訊列 / tooltip / SSRB defeat 動畫修正：random map 改為可上下捲動的直式 ScrollContainer；戰鬥資訊列隱藏玩家與敵方名稱；relic icon 放大；relic / status / intent icon 改用大字 tooltip；勝利後敵方 `defeat` 不再重播第二次。
  - 2026-05-12 後段難度曲線細化與新敵人接入：`RandomMapGenerator` 的普通戰改為分成 floor 1-3、4-6、7-9、10-12、13-15 五段抽敵；floor 13-15 只會抽後段高壓普通敵人。菁英戰改為依樓層抽 mid / late elite pool；floor 11 菁英不再回抽前段 duo。`ころね好き` 已作為中段普通敵人接入 normal pool 與 debug 普通戰輪替；`毛玉` 已作為後段菁英接入 elite pool、固定 elite 候選與 debug 菁英輪替。
  - 2026-05-12 商店節點庫存持久化：`RunState` 新增每節點 shop inventory，`show_shop()` 不再每次 render 重新生成商品與特價；同一商店離開再進入會保留原本商品、特價與已售出狀態。`shop_campfire_selection_tests.gd` 新增同節點庫存不刷新與購買後移除商品的覆蓋。
  - 2026-05-12 商店價格差異與特價第一版：移除固定單一卡牌價格與固定 relic 200 Gold，改為規則計價；common / event / shop / elite / boss relic 分別對應不同價格區間；每次 `show_shop()` 會將第一個商店卡牌標為「特價」並用同一價格扣款。
  - 2026-05-12 地圖長度、事件風險與難度曲線調整：random map 改為 16 floor Boss 的單 Act 長路線；event node 完全從 event pool 隨機抽取；新增 `start_battle` 事件 outcome 與高風險事件；普通敵人加入 early / mid / late encounter tier；菁英與 Boss 數值配合長路線提高。AZKi / Laplus 角色動作 sheet 已在預期路徑，`assets/cards/azki/` 尚未找到卡圖，因此未做卡圖接線。
  - 2026-05-12 Debug 快捷鍵重整：角色切換不再用每個角色一個快捷鍵，改為 `2` 統一回到角色選擇畫面；其他數字鍵維持功能測試入口，依序為 `3` 普通戰、`4` 切 Boss、`5` Boss 戰、`6` 菁英戰、`7` 寶箱、`8` 商店、`9` 篝火、`0` / `=` 事件、`-` 取得 relic。後續新增角色只需要出現在角色選擇畫面，不需要再新增 debug 角色快捷鍵。
  - 2026-05-12 MVP-v5 第一段 AZKi 角色資料接入：角色選擇畫面新增 AZKi；`RuntimeDatabase` 新增 AZKi 起始牌、reward/shop pool 與被動資料；CombatEngine 新增 `marker` 層數狀態、標記追加傷害、`draw_if_status` 效果與 AZKi 每回合第一次標記抽牌被動。`Game.gd` 已接 `map_marker_attack`、`kiss_attack`、`laplus_dash`、`laplus_crash` 動作路徑。AZKi 卡牌主視覺尚未生成，第一版會顯示 `ART` placeholder。
  - 2026-05-12 AZKi 攻擊動畫改為 pair body + transient FX 疊加：`map_marker_attack` 播 `cast_marker` 本體並同步疊 `map_marker_projectile` FX；`kiss_attack` 播 `cast_kiss` 本體並疊 `kiss_heart_projectile` FX；`laplus_dash` / `laplus_crash` 分別播 `command_dash` / `command_crash` 本體並疊 Laplus 衝刺 / 墜擊 FX。卡牌規則與數值未改，只改 `Game.gd` 的視覺路徑、AZKi 戰鬥 sprite 顯示尺寸，以及新增 `PlayerActionFxSprite`。
  - 2026-05-14 AZKi / Laplus 召喚物規則已更新：`CombatState` 保留 `summon_*` 狀態，AZKi 戰鬥開始建立 Laplus `1` HP；敵方攻擊先被玩家格擋擋住，剩餘傷害由 Laplus 攔截，overflow 才扣 AZKi HP。Laplus 不再有 10 HP 上限、不再回合開始自動補血 / 復活，必須透過卡牌 `summon_heal` 往上疊 HP。`Game.gd` 同時顯示 `AZKiBodySprite`、`LaplusSummonSprite` 與必要時的 `PlayerActionFxSprite`，Laplus 頭上顯示目前 summon HP 或 `DOWN`。
  - 2026-05-12 戰鬥勝利後改為手動進入 reward：玩家打出致命牌後會先停在戰鬥畫面播放敵方 `defeat`，右下原「結束回合」按鈕改為「結束對戰」；按下後才發放戰鬥 Gold / 菁英 relic，並進入一般戰鬥 reward 或 Boss reward。Combat UI layout 測試已補勝利後停留 combat、按鈕文字、未按前不發 Gold、按下後才進 reward 的流程覆蓋。
  - 2026-05-12 AZKi / ラプラス・ダークネス 新角色素材重做：使用 `$generate2dsprite` 生成無鎖鏈版 AZKi 的 idle、defense、hurt、defeat、map_marker_attack、kiss_attack 六組 3x3 sheet，以及召喚獸 ラプラス・ダークネス 的 idle、defense、hurt、defeat、dash_attack、crash_attack 六組 3x3 sheet。AZKi cost1 為紅色地圖標記魔力彈，cost2 為飛吻＋對話框「雑魚❤️」；`kiss_attack` 對話框只在中段幀顯示，其餘 AZKi 動作不含對話框。Laplus cost1 為趴地衝刺，cost2 為中二暗紫墜擊；這版視覺設定為「死靈歌姬 + 獨立召喚獸」，沒有 hand-held chain、leash、collar chain、dangling metal chain 或兩人 tether。素材目前已放入 `assets/characters/`，尚未接入角色選擇、牌組資料或戰鬥 runtime。
  - 2026-05-12 SSRB attack 動作圖更新：Gray / Camouflage / White 的 `attack` 已由舊 2x2 / 4 幀替換為 768x768、3x3 / 9 幀彈跳衝撞動畫；正式素材已補 9 張 frame PNG、GIF、metadata 與 prompt 紀錄。Combat UI layout 測試已將 SSRB 檢查擴充為 `idle`、`attack`、`guard`、`hurt`、`defeat` 全部 9 幀。三組 attack 的 `edge_touch_frames` 皆非空：gray / camouflage 為 `[1,2]`，white 為 `[0,1]` 與 `[1,2]`。
  - 2026-05-12 SSRB 敵方動作圖更新：Gray / Camouflage / White 的 `idle`、`guard`、`hurt`、`defeat` 已替換 / 新增為 768x768、3x3 / 9 幀；`Game.gd` 已將敵方 `block` / `guard` 映射到 `guard`，擊破勝利時會播放 `defeat`，敵方非 idle 動作改用 12fps non-loop 播放。RuntimeDatabase 測試新增 SSRB `guard` / `defeat` 素材存在檢查。
  - 2026-05-12 動畫 sheet 預設規則更新：之後新動畫圖預設以 3x3 / 9 幀執行；`Game._sprite_sheet_grid()` 已改為大型正方形 sheet 固定讀取 3x3，舊 `256x256` / `512x512` sheet 維持 2x2 相容，非正方形 sheet 仍 fallback 2x2。Combat UI layout 測試補上 `1024x1024` 預設 3x3 與 `512x512` 舊素材 2x2 相容檢查。
  - 2026-05-12 Subaru / Botan 角色動圖幀數與受傷動畫確認：正式角色 sheet 中 Subaru idle / normal_attack / tsukkomi / defense / hurt 與 Botan idle / defense / hurt / pistol_attack / sniper_ultimate 皆為 768x768、3x3 / 9 幀；Combat UI layout 測試已補 Subaru defense / hurt 幀數覆蓋。Subaru hurt 顯示不完整的根因不是 2x2 切格，而是受傷分支仍用預設 6fps loop 且敵人回合受傷畫面只停 0.25 秒；已改為受傷動畫同樣使用 12fps、non-loop，且實際受傷時停留 `CARD_ANIMATION_SECONDS`。
  - 2026-05-12 戰鬥 relic icon 顯示與 tooltip：戰鬥畫面的 relic summary 改為玩家名稱上方的 icon-only row，icon 尺寸與 status icon 一致約 `18x18`，不再顯示 relic 名稱文字；status / intent / relic icon 皆補上 Godot 原生 `tooltip_text`，hover 時可顯示說明內容。Map / 非戰鬥 relic summary 維持小 icon + 名稱文字。
  - 2026-05-12 狀態 / 意圖 icon 顯示比例與多狀態間距修正：status / intent icon 從原 icon 槽寬高 0.75 調大為 0.9；意圖文字起點右移，避免與放大後的 intent icon 重疊；多個 status 顯示時每組狀態間距加大到 128px，避免 icon / 文字互相覆蓋。卡牌 `CardArtTexture` 維持 `ImageSlot` 寬高 1.25 不變。
  - 2026-05-12 卡圖 / icon 顯示比例第二次微調：依實機畫面回饋，status / intent icon 從原 icon 槽寬高 1/2 調大為 0.75；卡牌 `CardArtTexture` 從 `ImageSlot` 寬高 0.625 調大為 1.25，仍掛在 `ImageSlot` 內並由 `clip_contents` 裁切。
  - 2026-05-12 卡圖 / icon 顯示比例微調：依實機畫面回饋，status / intent icon 從原 icon 槽寬高 1/3 調大為 1/2；卡牌 `CardArtTexture` 從 `ImageSlot` 寬高 1/4 調大為 0.625，仍置中並限制在圖片槽內。
  - 2026-05-11 卡圖 / icon 顯示比例修正：`CombatCardView` 的 `CardArtTexture` 改掛在 `ImageSlot` 內並啟用 `clip_contents`，卡圖顯示尺寸縮為圖片槽寬高的 1/4（面積約 1/16）且置中；`ActorStatusView` 的 status / intent icon 啟用 `ignore_texture_size` 並縮為原 icon 槽寬高的 1/3（面積約 1/9），避免 128/512 原圖尺寸外溢到角色與卡牌 UI。
  - 2026-05-11 Subaru idle / defense / hurt 角色動作素材更新：使用 `$generate2dsprite` 以既有 idle 與 tsukkomi sheet 作為參考，生成三張 3x3 / 9 幀新 sheet；idle 為穩定站立待機，defense 為半蹲手臂防禦，hurt 為受擊後仰並帶漫畫泡泡「テメ！！」。已覆蓋 `assets/characters/subaru/idle/sheet-transparent.png`、`assets/characters/subaru/defense/sheet-transparent.png`、`assets/characters/subaru/hurt/sheet-transparent.png`，並同步保留 frames / GIF / metadata。
  - 2026-05-11 MVP-v4.3 卡牌主視覺補完：使用 `$generate2dsprite` 生成並後處理剩餘 27 張 Subaru / Botan 卡圖，正式檔放在 `assets/cards/subaru/` 與 `assets/cards/botan/`；`RuntimeDatabase.CARD_ART_PATHS` 已補完所有目前卡牌，RuntimeDatabase 測試會要求每張卡都有有效 `art_path`，Combat UI layout 測試會檢查 reward / shop 的非起始牌顯示 `CardArtTexture`。
  - 2026-05-11 Botan 攻擊卡動畫規則補齊：Botan 帶傷害的 cost 1 卡片使用 `pistol_attack`，cost 2 卡片使用 `sniper_ultimate`；`Game.gd` 已新增 `pistol_attack` / `sniper_ultimate` player sheet path 映射，Botan idle / defense / hurt 也已更新為 3x3 / 9 幀 sheet。
  - 2026-05-11 MVP-v4.2 展示版視覺打磨：使用 `$generate2dsprite` 生成並後處理 10 張起始牌組卡圖、5 張 intent icon 與 18 張 relic icon，三批 `pipeline-meta.json` 皆為 `edge_touch_frames: []`。`RuntimeDatabase` 會自動為第一批卡牌補 `art_path`、為 enemy action 補 `icon_path`、為 relic 補 `icon_path`；戰鬥 header relic summary 會顯示小 icon + 名稱，商店 relic 商品會顯示 relic icon。
  - 2026-05-11 Subaru 攻擊動畫播放修正：確認 `assets/characters/subaru/normal_attack/sheet-transparent.png` 已正確覆蓋並 import，且 hash 與 `generated/sprites/subaru-shout-attack-v3b/processed-256-final-aligned/sheet-transparent.png` 相同；實機看不到文字 / 聲波的根因是打牌動畫只停 0.35 秒、9 幀 sheet 以 6fps 播放時只會看到前 2-3 幀。現在非 idle 玩家打牌動畫改為 12fps、非 loop，並將打牌動畫停留時間調整為 0.85 秒，讓 normal_attack / tsukkomi 都能播到主要效果幀。
  - 2026-05-11 狀態 icon 第一批接線：將 `strength`、`weak`、`vulnerable`、`regen` 四張 AI 生成 icon 從 `generated/sprites/status-icons-v1/final/` 複製到 `assets/icons/status/` 並用 Godot headless editor 重新 import；`RuntimeDatabase` 會自動補 card / enemy status 的 `status_icon_path`，`ActorStatusView` 會在玩家 / 敵方 active status 顯示 icon + 數值 / 回合，缺圖時保留文字 fallback。
  - 2026-05-11 Subaru 攻擊卡動畫規則更新：Subaru 帶傷害的 cost 1 卡片使用 `normal_attack`，cost 2 卡片使用 `tsukkomi`；本輪同步調整 `subaru-duck-step`、`subaru-team-rush`、`subaru-desk-reaction`。
  - 2026-05-11 Subaru `normal_attack` 動作圖已再次替換為有往前聲波效果、且第 4 幀腳底已對齊的 3x3 / 9 幀 sheet，來源為 `generated/sprites/subaru-shout-attack-v3b/processed-256-final-aligned/sheet-transparent.png`，已覆蓋 `assets/characters/subaru/normal_attack/sheet-transparent.png` 並用 Godot headless editor 重新 import。
  - 2026-05-11 Subaru `normal_attack` 動作圖已替換為 3x3 / 9 幀的往前吼叫版 sheet，來源為 `generated/sprites/subaru-shout-attack-v2/processed-256-exact-text/sheet-transparent.png`，已覆蓋 `assets/characters/subaru/normal_attack/sheet-transparent.png` 並用 Godot headless editor 重新 import 對應 `.ctex`。Combat UI layout 測試已補覆蓋 `normal_attack` 9 幀。
  - 2026-05-11 美術接線準備：`CombatCardView` 支援有效 `card.art_path` 時在 `ImageSlot` 內顯示 `CardArtTexture`，無效或空 path 時保留原本卡圖 placeholder 並顯示 `ART` 標記；`ActorStatusView` 支援有效 enemy intent `icon_path` 時顯示 `IntentIconTexture`，無效或空 path 時保留 `⚔` / `▣` / `↑` / `↓` 文字 fallback。`RuntimeDatabase` 會補齊 `art_path` / `icon_path` / `status_icon_path` metadata slot。
  - 2026-05-11 Subaru `tsukkomi` 動作圖替換為 3x3 / 9 幀 sheet 後，`scripts/Game.gd` 的 `_add_sprite_sheet()` 改為依 256px 單格自動推斷方形 sprite sheet 行列數；既有 512x512 sheet 維持 2x2 / 4 幀，新 768x768 sheet 會播放 3x3 / 9 幀。Combat UI layout 測試已補覆蓋 idle 4 幀與 tsukkomi 9 幀。
  - 2026-05-11 reward refresh 修正：修正 debug/relic 訊息自動清除時，`current_screen == "reward"` 會呼叫無參數 `show_reward()`，導致戰鬥 / 菁英卡牌獎勵畫面被預設標題「寶箱獎勵」與新抽卡重建的問題。現在 reward 畫面會保存 title、subtitle、random flag 與已抽出的 reward card ids，刷新訊息時只重畫同一個 reward context。
  - 2026-05-11 MVP-v4.1 第三段：新增 `scripts/ui/ActorStatusView.gd`，將玩家 / 敵方名稱、HP、格擋、玩家能量、被動文字、敵方意圖 icon placeholder 與角色下方 status summary 從 `scripts/Game.gd` 抽出；`Game.gd` 保留 `_add_combat_status_panels`、`_add_character_status_labels`、`_intent_icon_text`、`_add_stat_box` 相容入口並委派給 component。
  - 2026-05-11 MVP-v4.1 第二段：新增 `scripts/ui/CombatHandView.gd`，將戰鬥手牌建立、3:4 卡牌預設尺寸、底部扇形位置、rotation / z-index 設定與 hover 放大 / 還原邏輯從 `scripts/Game.gd` 抽出；`Game.gd` 保留 `_add_combat_hand_ui`、`_combat_hand_card_position`、`_configure_combat_hand_card`、`_set_card_hovered` 相容入口並委派給 component。
  - 2026-05-11 MVP-v4.1 第一段：新增 `scripts/ui/CombatCardView.gd`，將戰鬥手牌、獎勵、商店與牌組選擇共用的卡牌外框、費用 / 價格 badge、卡名、圖片預留區、類別與描述文字排版從 `scripts/Game.gd` 抽出；`Game.gd` 保留流程、hover 位置與手牌扇形排列控制。
  - Random map Boss 節點加寬並壓縮 Boss 名稱換行，降低地圖右側文字跑版。
  - 遊戲流程進戰鬥時會洗牌，不再固定抽牌組前 5 張；headless 單元測試仍可保留 deterministic 行為。
  - 戰鬥資訊格改成單行格式，例如 `抽牌 5`、`棄牌 0`、`能量 3/3`。
  - Debug 訊息會在約 2 秒後自動清除，不再永久停留畫面。
  - 取得 relic、relic fallback、事件獎勵等非 debug 快捷鍵訊息也會走同一套自動清除流程。
  - 2026-05-10 UI 試改：移除戰鬥狀態區 / 手牌區大型深色底板、隱藏抽牌 / 棄牌欄位、狀態文字移到角色下方、戰鬥手牌改 3:4 直式、費用改為只顯示數字。
  - 2026-05-10 卡牌 UI 試改：戰鬥手牌改成非透明卡面、類 StS 外框與圖片預留區、底部扇形排列；hover 於原位置放大後置於最上層。
  - 2026-05-10 戰鬥 UI 清理：移除人物狀態欄文字底色、敵方意圖底色與下方「手牌」標題文字，並為一般 UI 文字加上陰影 / 描邊。
  - 2026-05-10 QA / 平衡 / 角色被動：新增 Subaru / Botan 被動、微調 Subaru/Botan 部分卡牌、提高 SSRB Gray / SSRB Duo Camouflage+White / Subaruto Duck 壓力，並新增平衡輪廓測試。
  - 2026-05-10 卡牌 hover 清晰度修正：戰鬥手牌 hover 改為實際放大尺寸並重排字級；戰鬥獎勵卡牌不再 hover 放大。
  - 2026-05-10 商店 / 手牌 UI 修正：商店商品補上價格 badge 與功能說明；戰鬥手牌少於 5 張時仍以畫面中央為核心排列；hover 大卡描述區保留較完整比例。
  - 2026-05-10 MVP-v4 第一版：戰鬥 UI helper 分區為 header、actor sprites、hand layout、intent icon、passive display；角色被動可視化；敵方意圖 icon placeholder；建立 `docs/v4-balance-qa.md` 與 `docs/character-art-spec.md`。
- Debug / 驗收入口：
  - `1`：顯示或隱藏 debug 快捷鍵說明。
  - `2`：回到角色選擇畫面，切換角色時從這裡重新選。
  - `3`：直接進入普通戰測試，每按一次輪替 SSRB 與 V3 meme 普通敵人。
  - `4`：切換指定 Boss，依序輪替 Subaruto Duck、巨大 SSRB 變體與 V3 meme Boss。
  - `5`：直接進入目前指定 Boss 的 Boss 戰。
  - `6`：直接進入菁英 SSRB Duo 戰。
  - `7`：直接進入寶箱獎勵。
  - `8`：直接進入商店。
  - `9`：直接進入篝火。
  - `0` / `=`：直接進入事件，連續按會在事件 1 / 事件 2 / 事件 3 之間輪替。
  - `-`：取得下一個未持有 relic。
- 自動測試：
  - `tests/headless/combat_engine_tests.gd` 可用 Godot headless 測 CombatEngine 核心規則。
  - `tests/headless/runtime_database_tests.gd` 可用 Godot headless 測角色、卡牌、敵人、Boss pool、固定路線與素材路徑。
  - `tests/headless/runtime_database_tests.gd` 也覆蓋美術 metadata slot：card `art_path`、relic `icon_path`、enemy action `icon_path`，以及 status action `status_icon_path`；並驗證目前支援的 4 種 status icon 正式路徑、所有目前卡牌都有有效正式卡圖，以及 Subaru cost 1 / cost 2 攻擊牌動畫規則。
  - `tests/headless/runtime_database_tests.gd` 也覆蓋角色被動資料、Subaru / Botan 卡池輪廓、early / mid / late / elite / boss 敵人壓力門檻、商店卡牌 / relic 規則計價，以及事件戰鬥勝利後回到地圖的流程。
  - `tests/headless/combat_ui_layout_tests.gd` 可用 Godot headless 測戰鬥手牌區位置、寬度與高度、卡牌框架結構、扇形排列、少量手牌置中、hover 放大置頂、hover 描述比例、角色被動 UI、敵方意圖 icon placeholder，以及商店商品價格 / 說明顯示。
  - `tests/headless/combat_ui_layout_tests.gd` 也覆蓋有效 / 無效 `card.art_path`、enemy intent `icon_path` 與 active status icon path 的 texture 顯示與 fallback 行為，並確認缺卡圖時會顯示 `CardArtPlaceholder` / `ART`，且 reward / shop 非起始牌會顯示正式 `CardArtTexture`。
  - 2026-05-11 起，`tests/headless/combat_ui_layout_tests.gd` 也會檢查 MVP-v4.1 `CombatCardView` component 是否存在並提供 `create_button` / `render_button`，`CombatHandView` component 是否存在並提供 `add_hand` / `card_position` / `configure_card` / `set_card_hovered`，以及 `ActorStatusView` component 是否存在並提供 `add_combat_status_panels` / `add_status_labels` / `intent_icon_text`。
  - `tests/headless/random_map_tests.gd` 可用 Godot headless 測 seed-based 隨機地圖資料骨架，包含 16 floor Boss、足夠房型候選、所有節點可通 Boss、事件來自 pool 且不再 floor-locked，並驗證後段普通戰 / 菁英戰會落在較高壓 pool。
  - `tests/headless/run_state_random_map_tests.gd` 可測 random map run state 推進。
  - `tests/headless/combat_status_tests.gd` 可測 strength、weak、vulnerable、regen 與 debuff action。
  - `tests/headless/event_relic_definition_tests.gd` 可測 event outcome 與 relic metadata 合法性。
  - `tests/headless/card_upgrade_tests.gd` 可測升級卡數值與描述同步。
  - `tests/headless/gameplay_shuffle_tests.gd` 可測遊戲流程戰鬥抽牌會洗牌。
  - `tests/headless/debug_message_timeout_tests.gd` 可測取得 relic 訊息會自動消失，並覆蓋 reward 畫面在訊息清除後不可退回 `show_reward()` 預設寶箱標題。
  - `tests/headless/content_metadata_tests.gd` 可測 V3 內容數量、metadata、id 去重與 meme source 分散度。
  - `tests/headless/shop_campfire_selection_tests.gd` 可測商店移除卡與篝火升級卡可指定目標、選擇畫面可滾動，以及同一商店節點庫存 / 特價不刷新、購買後商品會從庫存移除。
  - `tests/headless/enemy_meme_behavior_tests.gd` 可測 YouTube-kun、Announcement Shadow 與 V3 meme Boss pool。
- 手動驗收：
  - 2026-05-12 curse 第二段規則接線後，自動 QA 已跑完：CombatEngine、RuntimeDatabase、Event / Relic definition、Content metadata 與 Godot `--quit` 均通過；`runtime_database_tests` 仍有既有 `ObjectDB instances leaked` warning。需手動確認三張 curse 都不能打出、`Comment Fire` 回合結束會 exhaust、`Dead Air` 抽到會扣能量、`Bad Connection` 留手回合結束會扣 HP，並確認事件額外戰鬥後仍會進戰鬥獎勵、拿完獎勵才完成事件節點。
  - 2026-05-12 直式地圖 / 戰鬥資訊列 / tooltip / SSRB defeat 動畫修正後，自動 QA 已跑完：Combat UI layout、RuntimeDatabase、RandomMap 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。地圖目前是可上下捲動的直式 ScrollContainer，需手動確認滾動手感、節點可讀性、hover tooltip 大字體、relic icon 放大後不互擠，以及 SSRB 擊敗時不再出現雙重爆炸感。
  - 2026-05-12 後段難度曲線細化與 `ころね好き` / `毛玉` 接入後，自動 QA 已跑完：RandomMap、RuntimeDatabase、Enemy meme behavior、Combat UI layout 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。需手動確認 `3` 可輪到 `ころね好き`，`6` 可輪到 `毛玉`，以及 floor 11 後菁英體感明顯高於前段。
  - 2026-05-12 商店節點庫存持久化後，自動 QA 已跑完：Shop / Campfire selection、RuntimeDatabase、Combat UI layout、Debug message timeout 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。需手動確認同一商店節點重開不刷新商品 / 特價，購買後商品不會回補。
  - 2026-05-12 `ころね好き` / `毛玉` 敵人素材草案落地後，自動 QA 已跑完：10 組正式 sheet 皆為 768x768、3x3 / 9 幀，alpha 邊界 / 底部對齊檢查通過；Godot headless editor reimport 與 Godot `--quit` 均通過。Godot reimport 仍有既有 AZKi / Laplus 生成來源與正式素材重複 UID warning，與本輪新敵人素材無關。這批尚未接入敵人資料 / random pool。
  - 2026-05-12 商店價格差異與特價第一版後，自動 QA 已跑完：RuntimeDatabase 與 Combat UI layout 通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。需手動進商店確認卡牌價格不再全同、relic 價格依 pool 顯示、每次有一個「特價」商品且扣款正確。
  - 2026-05-12 地圖長度、事件風險與難度曲線調整後，自動 QA 已跑完：RandomMap、RunState random map、RuntimeDatabase、Event / Relic definition、CombatEngine、Combat UI layout、CombatStatus、Gameplay shuffle 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。尚需手動完整跑一次 Subaru / Botan / AZKi random map，確認 16 floor 地圖可讀、事件戰鬥回地圖、relic 200 Gold 與後段壓力體感。
  - 2026-05-12 Debug 快捷鍵重整後，自動 QA 已跑完：RuntimeDatabase、Combat UI layout 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。需手動確認 `2` 可回角色選擇並可重新選 Subaru / Botan / AZKi，`3` 到 `0` 仍能快速進入各功能測試。
  - 2026-05-12 MVP-v5 第一段 AZKi 角色資料與 marker 規則接入後，自動 QA 已跑完：CombatEngine、RuntimeDatabase、Combat UI layout、CombatStatus、Gameplay shuffle 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。需手動驗收 AZKi 起手戰鬥、marker 文字 fallback、Laplus 助攻動畫體感與卡牌 placeholder 可接受度。
- 2026-05-12 戰鬥勝利後手動進 reward 流程修正後，自動 QA 已跑完：Combat UI layout、RuntimeDatabase、CombatEngine、Debug message timeout 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
- 2026-05-13 角色差異提示與 Boss warning 接線後，自動 QA 需至少跑 `combat_engine_tests.gd`、`runtime_database_tests.gd`、`combat_ui_layout_tests.gd` 與 Godot `--quit`；預期可接受既有 `ObjectDB instances leaked` warning，但不應有新的規則或 layout failure。2026-05-14 起手動驗收改確認 random map 不顯示 Boss hint 長文、Boss 名稱可讀、Botan 戰鬥中會顯示「2 費爆發」類型提示、AZKi 標記追擊提示會在命中時出現。
- 2026-05-13 提示系統補強後，自動 QA 新增檢查：`turn_events` 需保留 `kind` / `source`，Boss 切到高傷意圖前需自動生成 `boss-warning`；Boss metadata 需具備 `boss_pattern`、`boss_counterplay`、`boss_spike_turn`。
  - 2026-05-13 角色輪廓資料測試補強後，自動 QA 也會驗證 `identity_focus_tags` 與 `signature_card_ids` 是否存在，且招牌卡真的符合對應角色定位，避免後續改卡把角色特色改沒。
  - 2026-05-13 提示系統驗收與小修後，自動 QA 新增檢查：Boss warning 需帶入 `boss_counterplay`；2026-05-14 起自動 QA 改檢查 random map 不顯示 `Boss 提示：` 長文，戰鬥 Boss warning label 仍需有兩行高度並啟用 `TextServer.AUTOWRAP_WORD_SMART`。本輪仍需手動確認實機字距、提示是否過長，以及 Boss warning 是否太搶畫面。
  - 2026-05-13 AZKi / Laplus 正式分離素材重做後，自動 QA 已跑完：16 組正式 body sheet metadata 皆為 3x3 / 9 幀、cell size 384、`edge_touch_frames=[]`；Godot `--quit`、RuntimeDatabase、Combat UI layout 與 CombatEngine 均通過。`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。手動 QC 需在實機確認 AZKi 戰鬥中 `AZKiBodySprite`、`LaplusSummonSprite` 與既有 FX-only sprite 同步播放體感，以及 Laplus dash / crash 是否需要後續再加更強的獨立 FX。
  - 2026-05-13 AZKi 新分離素材 runtime mapping 接線後，自動 QA 已跑完：Combat UI layout 測試先確認舊映射紅燈，再改為 `cast_marker` / `cast_kiss` / `command_dash` / `command_crash` 後通過；RuntimeDatabase、CombatEngine 與 Godot `--quit` 也通過。`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。仍建議手動打出 `map_marker_attack`、`kiss_attack`、`laplus_dash`、`laplus_crash`，確認三層 sprite 同步播放體感。
  - 2026-05-13 playable demo 收斂第一段後，自動 QA 已跑完：Combat UI layout、RuntimeDatabase、CombatEngine、RandomMap、Shop / Campfire selection 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。這輪補上四個 AZKi action 的 FX anchor / size 測試、AZKi / FX 高於 Laplus 的既有 z-order 測試仍通過，並新增 marker 無 icon 時的繁中 fallback 測試。
  - 2026-05-13 playable demo smoke test 接入後，自動 QA 已跑完：`playable_demo_smoke_tests.gd`、Combat UI layout、RuntimeDatabase、CombatEngine、RandomMap、Shop / Campfire selection 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。這個 smoke test 不等同完整手動 run，也不會驗證玩家決策體感或 Boss reward 實際抵達，但能在不開 UI 的情況下保護三角色 demo 入口與 AZKi 核心視覺不斷線。
  - 2026-05-12 AZKi / ラプラス・ダークネス 無鎖鏈版素材重做後，自動 QA 已跑完：12 組正式 sheet 皆為 768x768、3x3、每格 256x256，9 張 frame PNG / GIF / metadata / prompt 紀錄皆存在，cell alpha 邊界檢查皆通過，Godot `--quit` 通過。目視 QC：AZKi / Laplus 全部動作都沒有可見鎖鏈；Laplus 為獨立召喚獸，項圈沒有延伸鎖鏈；`kiss_attack` 只有中段幀顯示「雑魚❤️」。這批目前是素材落地，尚未接 runtime 資料與角色選擇流程。
  - 2026-05-12 AZKi / Laplus necrobinder pair + 獨立 FX 試作版自動 QA 已跑完：8 組本體 sheet 皆為 1152x1152、3x3、每格 384x384；4 組 FX sheet 皆為 768x768、3x3、每格 256x256；每組皆有 9 張 frame PNG、GIF、metadata 與繁體中文 prompt 紀錄；cell alpha 邊界檢查皆通過。Godot headless editor reimport、Godot `--quit`、RuntimeDatabase 與 Combat UI layout 測試通過；Combat UI 測試已覆蓋四個 AZKi 攻擊動作會同時建立 `PlayerActorSprite` 與 non-loop `PlayerActionFxSprite`。`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-14 AZKi / Laplus HP 規則更新後，自動 QA 已跑完：CombatEngine、RuntimeDatabase、Combat UI layout、Playable smoke、Reward draft、AZKi early survival、Chapter 2 balance proxy、Auto-run proxy、Card upgrade 與 Godot `--quit` 通過；既有 ObjectDB warning 維持 non-blocking。測試覆蓋 Laplus 初始 1 HP、`summon_heal` 可超過 max_hp 疊加、倒下後需靠卡牌恢復、`summon_hp_damage` 依目前 Laplus HP 追加傷害、非 AZKi 不建立 summon，以及戰鬥畫面同時建立 AZKi / Laplus / FX 與 Laplus 頭上 HP label。
  - 2026-05-12 SSRB 三色 attack 素材更新後，自動 QA 已跑完：Godot headless editor reimport、Godot `--quit`、RuntimeDatabase、Combat UI layout 與 CombatEngine 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。三組 attack 的 `edge_touch_frames` 皆非空，需實機或 GIF 目視確認是否要重切。
  - 2026-05-12 SSRB 三色 idle / guard / hurt / defeat 素材更新與接線後，自動 QA 已跑完：Godot headless editor reimport、Godot `--quit`、RuntimeDatabase、Combat UI layout 與 CombatEngine 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。復查時發現 4 組 SSRB `pipeline-meta.json` 的 `edge_touch_frames` 非空，需實機或 GIF 目視確認是否要重切。
  - 2026-05-12 動畫 sheet 預設 3x3 / 9 幀規則更新後，自動 QA 已跑完：Combat UI layout、RuntimeDatabase 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-12 Subaru / Botan 角色動圖幀數與 Subaru hurt 動畫播放修正後，自動 QA 已跑完：Combat UI layout、RuntimeDatabase 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-12 戰鬥 relic icon 顯示與 tooltip 修正後，自動 QA 已跑完：Combat UI layout、RuntimeDatabase 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-12 狀態 / 意圖 icon 顯示比例與多狀態間距修正後，自動 QA 已跑完：Combat UI layout、RuntimeDatabase 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-12 卡圖 / icon 顯示比例第二次微調後，自動 QA 已跑完：Combat UI layout、RuntimeDatabase 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-12 卡圖 / icon 顯示比例微調後，自動 QA 已跑完：Combat UI layout、RuntimeDatabase 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-11 卡圖 / icon 顯示比例修正後，自動 QA 已跑完：Combat UI layout、RuntimeDatabase 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-11 Subaru idle / defense / hurt 三組 3x3 素材替換後，自動 QA 已跑完：Godot `--quit`、RuntimeDatabase 與 Combat UI layout 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-11 MVP-v4.3 卡牌主視覺補完後，自動 QA 已跑完：Godot headless editor reimport、RuntimeDatabase、Combat UI layout、CombatEngine 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-11 Subaru 攻擊動畫播放修正後，自動 QA 已跑完：Combat UI layout、CombatEngine 與 Godot `--quit` 均通過；`combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-11 狀態 icon 與 Subaru 攻擊動畫規則接線後，自動 QA 已跑完：RuntimeDatabase、Combat UI layout、CombatEngine、CombatStatus 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-11 Subaru `normal_attack` 有聲波版本替換與 reimport 後，自動 QA 已跑完：Combat UI layout、RuntimeDatabase 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-11 Subaru `normal_attack` 3x3 sheet 替換與 reimport 後，自動 QA 已跑完：Combat UI layout、RuntimeDatabase 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-11 美術接線準備後，自動 QA 已跑完：RuntimeDatabase、Combat UI layout、CombatEngine 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-11 Subaru `tsukkomi` 3x3 sheet 支援修正後，自動 QA 已跑完：Combat UI layout、RuntimeDatabase 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - 2026-05-11 本輪自動 QA 已跑完：debug message timeout、RuntimeDatabase、Combat UI layout、CombatEngine 與 Godot `--quit` 均通過；`runtime_database_tests` / `combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning。
  - `docs/manual-qa-checklist.md` 是正式手動 QA 入口，涵蓋完整路線、Subaru / Botan、普通戰、Boss 戰、失敗 / 通關流程與 UI 可讀性。
  - 2026-05-10 本輪自動 QA 已跑完：CombatEngine、RuntimeDatabase、Combat UI layout、random map、RunState random map、status、event/relic、card upgrade、gameplay shuffle、debug message timeout、content metadata、shop/campfire selection、enemy meme behavior 與 Godot `--quit` 均通過；`runtime_database_tests` 仍有既有 `ObjectDB instances leaked` warning。
- 內容規劃：
  - `docs/hololive-content-bible.md` 定義 Hololive 粉絲遊戲世界觀、語氣、謎因使用與命名規則。
  - `docs/mvp-roadmap.md` 定義從固定路線 MVP 到類 StS 系統的分階段開發順序。
  - `docs/card-pool-matrix.md` 定義 Subaru / Botan 第一輪卡池方向；本輪已將候選卡加入資料庫與 reward/shop pool。
  - `docs/v2-roadmap.md` 定義擴大版 V2 範圍：短版隨機地圖 run、Boss 預告、Map UI 接線、RunState random map 狀態、簡版 status、event / relic 資料化、商店 / 篝火深化、Boss reward、內容池擴充與 V2 QA。
  - `docs/v3-roadmap.md` 定義 MVP-v3 範圍：參考 `docs/meme.md` 擴充事件、卡牌、relic、敵人與 Boss，同時加入 `meme_source` / `content_group` 等 metadata 與去重檢查，避免同一 meme 或同質玩法過度重複。
  - `docs/v4-roadmap.md` 記錄 MVP-v4 第一版落地內容：戰鬥 UI helper 分區、角色被動可視化、敵人意圖 icon、平衡 QA 與人物圖片重製準備。
  - `docs/v4-balance-qa.md` 記錄 MVP-v4 平衡 QA 目標、流程與目前結論。
  - `docs/v4.1-combat-ui-component-extraction.md` 規劃 MVP-v4.1：抽取 CombatCardView、CombatHandView、ActorStatusView，保留目前 V4 視覺與互動行為。
  - `docs/v4.2-visual-polish.md` 記錄展示版視覺打磨素材規格、接線範圍與下一批建議。
  - `docs/v4.3-card-art-completion.md` 記錄卡牌主視覺補完清單、生成來源、正式素材路徑與驗收方式。
  - `docs/superpowers/plans/2026-05-12-mvp-v5-character-differentiation-boss-hints.md` 記錄下一輪實作計畫，主軸是角色差異強化與最小版 Boss 提示；AZKi 視覺補完不在這一輪範圍。
  - `docs/visual-asset-integration-guide.md` 記錄後續新增卡圖、intent icon、relic icon、status icon 與角色動作圖的放置路徑、RuntimeDatabase 接線方式與驗收指令。
  - `docs/visual-asset-size-reference.md` 記錄目前人物、敵人、Boss、卡牌、status / intent / relic icon 與背景的來源尺寸、sheet layout 與 UI 顯示尺寸，是後續建立圖片素材的尺寸參考入口。
  - `docs/character-art-spec.md` 定義 Subaru / Botan 角色圖片重製規格、路徑、尺寸、動作與驗收方式。

## 如何啟動與操作

1. 用 Godot 開啟 `/Users/zhangzhipeng/MyProject/oshi-no-tower-godot`。
2. 從 `res://scenes/main.tscn` 執行專案。
3. 選擇 Subaru 或 Botan。
4. 在隨機地圖上點選目前可到達節點；灰掉的節點不可點。
5. 若要快速驗收，可使用 `1` 顯示 debug 快捷鍵，`2` 回角色選擇，再用 `3` / `4` / `5` / `6` / `7` / `8` / `9` / `0` / `=` 測試普通戰、Boss 戰、菁英、寶箱、商店、篝火與事件。
6. 完整手動驗收請依 `docs/manual-qa-checklist.md` 逐項確認。

## 測試指令

CombatEngine headless 測試：

```bash
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_engine_tests.gd
```

RuntimeDatabase headless 測試：

```bash
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/runtime_database_tests.gd
```

Combat UI layout headless 測試：

```bash
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_ui_layout_tests.gd
```

Godot 專案載入檢查：

```bash
HOME=/private/tmp/oshi-godot-user /Users/zhangzhipeng/MyProject/tools/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --quit
```

## 重要檔案

- `project.godot`: Godot project configuration.
- `README.md`: 專案功能、啟動方式、Debug 快捷鍵與驗收流程。
- `AGENTS.md`: 專案溝通規則與接手指示。
- `archive/legacy-docs/`: 從 Web 版搬入並調整成 Godot 現況的設計文件。
- `scenes/main.tscn`: app entry scene。
- `scripts/Game.gd`: 畫面流程、動態 UI、戰鬥呈現、卡牌按鈕、sprite 動畫與 debug 快捷鍵。
- `scripts/ui/CombatCardView.gd`: MVP-v4.1 抽出的卡牌 UI component，負責卡牌外框、badge、卡名、圖片預留區、類別與描述文字排版。
- `scripts/ui/CombatHandView.gd`: MVP-v4.1 抽出的戰鬥手牌 UI component，負責手牌建立、扇形位置、hover 放大 / 還原與 z-index。
- `scripts/ui/ActorStatusView.gd`: MVP-v4.1 抽出的角色狀態 UI component，負責玩家 / 敵方名稱、HP、格擋、能量、被動、敵方意圖與 status summary 文字呈現。
- `scripts/data/RuntimeDatabase.gd`: 角色、卡牌、敵人、Boss pool 與路線資料。
- `scripts/core/CombatEngine.gd`: 回合處理、卡牌效果、敵人行動、抽牌/棄牌。
- `scripts/core/RunState.gd`: 選擇角色、HP、金錢、牌組與路線進度。
- `tests/headless/combat_engine_tests.gd`: CombatEngine headless 測試。
- `tests/headless/runtime_database_tests.gd`: RuntimeDatabase 資料完整性 headless 測試。
- `tests/headless/combat_ui_layout_tests.gd`: Combat UI layout headless 測試。
- `docs/godot-mvp-status.md`: 未來接續開發的狀態紀錄。
- `docs/manual-qa-checklist.md`: 完整路線與戰鬥 UI 手動驗收 checklist。
- `GAME_DESIGN.md`: Godot MVP playable demo 的 production source-of-truth。
- `game_design_bible.json`: 給下游 Game Production skills 使用的 machine-readable handoff。
- `docs/production/`: Production Skill Pack 產出的導演計畫、actor/UI/audio contracts、technical QA 與 creative review。
- `docs/hololive-content-bible.md`: Hololive 內容骨架與命名規則。
- `docs/mvp-roadmap.md`: MVP 後續開發 Roadmap。
- `docs/v2-roadmap.md`: Godot V2 規劃，原主軸為短版 seed-based 隨機地圖 run 加第一輪系統深度；目前 random map 已延伸為 16 floor 單 Act 長路線。
- `docs/v3-roadmap.md`: Godot V3 規劃，主軸為 meme content expansion、內容去重、玩家可選升級 / 移除卡 UI 與敵人 / Boss 擴充。
- `docs/v4-roadmap.md`: Godot V4 規劃，主軸為 combat feel、UI componentization、角色被動可視化、意圖 icon、平衡 QA 與人物圖片重製準備。
- `docs/v4-balance-qa.md`: MVP-v4 平衡 QA 入口。
- `docs/v4.1-combat-ui-component-extraction.md`: MVP-v4.1 Combat UI Component Extraction 規劃。
- `docs/v4.2-visual-polish.md`: MVP-v4.2 展示版視覺打磨素材與接線紀錄。
- `docs/v4.3-card-art-completion.md`: MVP-v4.3 卡牌主視覺補完清單、生成來源與驗收方式。
- `docs/visual-asset-integration-guide.md`: 後續新增視覺素材的路徑、接線、reimport 與測試指南。
- `docs/visual-asset-size-reference.md`: 目前人物、敵人、Boss、卡牌、icon 與背景的來源尺寸、sheet layout 與 UI 顯示尺寸參考。
- `docs/character-art-spec.md`: 角色圖片重製規格。
- `docs/card-pool-matrix.md`: Subaru / Botan 卡池矩陣。
- `docs/random-map-v1-plan.md`: 隨機地圖 v1 前置規格與目前資料骨架狀態。
- `scripts/data/RandomMapGenerator.gd`: seed-based 單 Act 隨機地圖資料生成器，目前 Boss floor 16。
- `tests/headless/random_map_tests.gd`: 隨機地圖資料 headless 測試。
- `tests/headless/run_state_random_map_tests.gd`: random map run state headless 測試。
- `tests/headless/combat_status_tests.gd`: status / buff / debuff headless 測試。
- `tests/headless/event_relic_definition_tests.gd`: event / relic metadata headless 測試。
- `tests/headless/card_upgrade_tests.gd`: 升級卡數值與描述同步 headless 測試。
- `tests/headless/gameplay_shuffle_tests.gd`: 遊戲流程洗牌 headless 測試。
- `tests/headless/debug_message_timeout_tests.gd`: debug / reward 訊息自動清除 headless 測試。
- `tests/headless/content_metadata_tests.gd`: V3 內容 metadata 與去重 headless 測試。
- `tests/headless/shop_campfire_selection_tests.gd`: V3 商店 / 篝火選擇流程 headless 測試。
- `tests/headless/enemy_meme_behavior_tests.gd`: V3 meme 敵人與 Boss pool headless 測試。

## 目前設計原則

- 目前主流程是 16 floor 單 Act random map；仍暫不做多 Act、存檔、完整 Power / Curse、藥水或正式平衡系統。
- Godot 版保留 Subaru、Botan 與 AZKi 皆可遊玩；目前 production contract 鎖定三角色 demo，不新增第四角色。
- 保留隨機 Boss 設計，但必須讓當前 Boss 身分在戰鬥中清楚可見。
- 在戰鬥 UI 穩定前，優先改善 `scripts/Game.gd` 內的動態 UI，不急著拆成大量 scene script。
- Production Skill Pack 的 gate order 是 Script Lock -> Department Ready -> Scene Playability -> Technical QA -> Creative Director Review；desktop build readiness 必須等三角色完整 run QA 後再判定。

## 已知問題

- 目前有 CombatEngine、RuntimeDatabase 與 Combat UI layout headless 測試，並有 `docs/manual-qa-checklist.md` 作為 UI / 流程手動驗收入口。
- 正常流程的 Boss 會在 random map 生成時決定並顯示在地圖上；可用 `5` / `6` 指定 Boss 做單點手動驗收。
- 卡牌與敵人平衡已加入第一輪資料門檻與 CombatEngine 測試，但仍需要實機手動遊玩確認體感。
- 動態 UI 適合 MVP 快速迭代，但未來穩定後適合拆成 reusable scene/components。
- 2026-05-15 已初始化 git repository，remote 指向 `https://github.com/newhandarky/oshi-no-tower.git`，`main` 已推送到 `origin/main`。
- 2026-05-15 已依使用者要求將圖片 / 視覺二進位素材與 Godot 圖片 import metadata 加入 `.gitignore`；目前 repo 只追蹤文字、腳本、場景、文件與素材 pipeline metadata，不追蹤 PNG / SVG / generated 圖片輸出。
- Web 版設計文件已搬到 `archive/legacy-docs/` 並調整成 Godot 現況版。
- Web 版素材原始參考圖與角色 sprite 的 prompt / pipeline metadata 由使用者另行備份，不在本專案此次搬移範圍。
- Unity 版是中途移植工程，含大量 Unity `Library` 快取與未提交檔案；目前不建議作為後續開發來源。

## 下一步 TODO

- 從角色選擇各完整跑一次 Subaru / Botan / AZKi random map，確認 16 floor 地圖可讀、前中後段 enemy tier 體感有差、事件可能出現額外戰鬥、Boss reward / 結算可正常抵達。每次記錄 Boss 前 HP / Gold / relic 數量、是否遇到事件戰鬥、菁英是否明顯比普通戰危險、Boss warning 是否有幫助。
- 跑完 `docs/manual-qa-checklist.md` 的 Production Contract Gate、Playable Demo Random Run Gate 與 AZKi / Laplus / FX Demo Gate 後，再回填 `docs/production/technical-qa-report.md` 與 `docs/production/creative-director-review.md`。目前這兩份文件應維持 manual QA pending，不可先標為 final accepted。
- 手動打出 AZKi 四個驗收 action：`map_marker_attack`、`kiss_attack`、`laplus_dash`、`laplus_crash`。確認 AZKi 本體與 FX 都在 Laplus 上方、FX 主視覺不被 Laplus 蓋住、`kiss_attack` 對話框只在合理幀出現、Laplus HP label 不遮 AZKi 臉或主要特效。
- 用 `4` 輪替 YouTube-kun、Desk-kun、Announcement Shadow，手動確認 intent、status、扇形手牌 hover 放大與文字可讀。
- 用 `5` / `6` 驗收 YouTube-kun Core 與 Important Announcement Boss，確認 BOSS 標籤與長名稱不跑版。
- `docs/superpowers/plans/2026-05-12-mvp-v5-character-differentiation-boss-hints.md` 的第一輪大多已落地，但 2026-05-14 已依使用者要求移除 map Boss hint 長文與 `boss_hint` 欄位。下一輪優先做實機手動確認：Boss warning 的 counterplay 是否太長、Botan / AZKi 的玩法提示是否真的能引導出牌，以及 random map Boss 名稱 / `BOSS` node 是否足夠清楚。
- 用 `8` 驗收商店商品畫面：卡牌 / relic / 移除卡左上角顯示金額，卡牌與 relic 價格不再全部固定同價，至少一個商品顯示「特價」，同一商店節點重開時商品 / 特價不刷新，購買後商品會從該商店庫存移除，卡面下方顯示功能說明；移除卡選擇畫面可滾動、可返回、Gold 扣除正確、指定卡被移除。
- 用 `7` 驗收寶箱：進入後只固定取得 1 個 relic，不出現卡牌 / Gold 多選，提示刷新後不跳回一般卡牌獎勵畫面。
- 用 `9` 驗收篝火升級卡選擇畫面：可滾動、已升級卡不出現在清單、指定卡數值與描述同步。
- 等 AZKi 新圖完成後，把正式 PNG 放進 `assets/cards/azki/`，跑 Godot reimport、RuntimeDatabase 與 Combat UI layout 測試，確認 `expected_art_path` 自動接線成功。目前 `assets/cards/azki/` 尚未存在，AZKi 卡牌仍會顯示 `ART` placeholder。
- 若 marker icon 完成，新增 `assets/icons/status/marker.png` 並接入 `RuntimeDatabase.STATUS_ICON_PATHS` / `ActorStatusView.STATUS_ICON_PATHS`；目前 marker 文字 fallback 已通過測試，可先不阻塞完整 run QA。
- 在三角色完整 run QA 通過前，不建議擴事件、敵人、Boss 或新系統。若仍無法手動測試，下一輪純自動前進的優先題目是做 deterministic auto-run simulator：用簡單出牌策略讓 Subaru / Botan / AZKi 各跑到 Boss 前或死亡，輸出 HP / Gold / relic / floor / 事件戰鬥紀錄，作為平衡調整前的數據基準。
- desktop build 輸出等三角色完整 run QA 與小範圍修正完成後再做：先建立 macOS export preset，再確認 `.app` 可雙擊執行並能進角色選擇、開始 random map、進普通戰、打出 AZKi 動作、結束或關閉程式。
- 每次完成一輪開發後，都要更新本文件。
