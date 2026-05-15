# Content Pack 1B Report

最近更新：2026-05-13

## Scope

`content_pack_1b_relic_and_card_identity`

本輪繼續豐富既有 16 floor Godot MVP，不新增章節、不新增可玩角色、不做 desktop build，也不新增 Subaru / Botan 卡牌 id 或 relic icon。核心方向是強化三角色 build identity，並補齊既有 `turn_start` relic 的 runtime 行為。

## Implemented

### Subaru

| item | change | intent |
|---|---|---|
| `subaru-cheer-loop` | 抽 2 之外增加 3 格擋 | 讓 Subaru 抽牌循環同時支援節奏守備，不只是補手牌 |
| `subaru-hype-call` | 力量 2 改為力量 1 + 抽 1 | 讓 buff 牌更容易接續低費連段，降低空過回合感 |

### Botan

| item | change | intent |
|---|---|---|
| `botan-steady-aim` | 抽 1 + 能量 1 之外增加 1 回合易傷 | 讓 Botan 的低費 setup 更容易銜接 2 費爆發 |
| `botan-counter-line` | 格擋 8 -> 10，敵人有易傷時抽 1 | 讓防守後反擊更清楚，並獎勵先 setup 再出 2 費牌 |

### AZKi / Laplus

| item | change | intent |
|---|---|---|
| `azki-marker-echo` | 新增 reward/shop card | 若敵人已有 marker 則抽 2，再補 1 層 marker，讓 marker loop 更穩 |
| `azki-laplus-reposition` | 新增 reward/shop card | marker 狀態抽牌、格擋與補 marker，強化 Laplus 防守協作感 |

### Relic Hooks

| item | change | intent |
|---|---|---|
| `CombatEngine` | 新增 `turn_start` relic resolution | 讓資料中既有 turn_start relic 不再只是 metadata |
| `CombatEngine` | 新增 relic effect `heal` | 直接回復 HP 並限制不超過 `player_max_hp` |
| `duck-whistle` | 第一次 0/1 費牌抽 1 並獲得 2 格擋 | 更貼近 Subaru 低費節奏與防守 identity |
| `unarchived-archive` | 第一次 marker card 抽 1 並獲得 1 能量 | 讓 AZKi marker build 有節奏 payoff，而不是只有補手牌 |
| `healing-chat` / `pamomi-signal` | `turn_start` 改為 direct heal | 避免每回合疊加 regen 狀態，行為更直覺可測 |

## QA

本輪只執行 headless / 非 GUI 驗證，不做 manual UI 操作。

已通過：

- `combat_engine_tests.gd`
- `runtime_database_tests.gd`
- `combat_ui_layout_tests.gd`
- `playable_demo_smoke_tests.gd`
- `playable_demo_auto_run_tests.gd`
- `demo_qa_mode_tests.gd`
- `shop_campfire_selection_tests.gd`
- `random_map_tests.gd`
- Godot `--quit`
- `game_design_bible.json` JSON parse

執行時使用 `HOME=/private/tmp/oshi-godot-user` 避免本機 Godot `user://logs` 路徑崩潰。Godot headless 仍輸出 macOS `get_system_ca_certificates` warning；`runtime_database_tests`、`playable_demo_auto_run_tests`、`combat_ui_layout_tests` 仍有既有 `ObjectDB instances leaked` warning，依目前 policy 維持 non-blocking。

## Notes

- AZKi 新卡沿用 placeholder-ready path policy：`expected_art_path` 會指向 `res://assets/cards/azki/<card_id>.png`，正式卡圖尚未落地時 `art_path` 維持空字串並顯示 `ART` placeholder。
- Subaru / Botan 本輪只調整既有卡牌，避免新增卡牌 id 造成卡圖 gate 阻塞。
- 新章節可以在本輪完成後開始規劃 source-of-truth，但正式 runtime 章節切換仍應等三角色 manual full run gate 關閉。
