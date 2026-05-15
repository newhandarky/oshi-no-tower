# Content Pack 1A Report

最近更新：2026-05-13

## Scope

`content_pack_1a_build_variety`

本輪目標是豐富既有 16 floor Godot MVP，不新增可玩角色、不新增章節、不做 desktop build，也不要求新增正式卡圖 / relic icon。核心方向是讓三角色 build identity 在一般 run 中更容易被感受到。

## Implemented

### Subaru

| item | change | intent |
|---|---|---|
| `subaru-duck-tempo` | cost `1 -> 0`，傷害 `5 -> 4`，保留抽 1 | 讓 Subaru 有更明確的 0 費連段 payoff，能觸發節奏守備並接續手牌 |
| `subaru-blue-wave` | 增加 `energy +1` | 讓抽牌 / 回復牌更像節奏回合的加速器 |

### Botan

| item | change | intent |
|---|---|---|
| `botan-mark` | 改為格擋 7、傷害 12、給 1 回合易傷 | 讓它成為 2 費爆發前置，而不是單純混合牌 |
| `botan-funds-prepared` | 增加抽 1，易傷延長到 2 回合 | 讓 Botan 更容易接上下一張 2 費攻擊 |

### AZKi / Laplus

| item | change | intent |
|---|---|---|
| `azki-laplus-dash` | 增加 1 層 marker | 讓 Laplus dash 不只是傷害，也能接 marker loop |
| `azki-laplus-crash` | 傷害 16 -> 18，易傷 1 -> 2 回合，若敵人有 marker 抽 1 | 讓 crash 成為清楚的 marker payoff |
| `azki-laplus-cover` | 新增 reward/shop card | 防守 + marker 狀態抽牌，支援 Laplus 協作回合 |
| `azki-coordinate-barrage` | 新增 reward/shop card | 多段攻擊 + marker，強化 marker payoff 可見度 |
| `azki-laplus-combo` | 新增 reward/shop card | Laplus dash 連段 payoff，讓 Laplus 行為更常出現 |

### Relic Hooks

| item | change | intent |
|---|---|---|
| `CombatEngine` | 支援 relic `effects` array | relic 可同時給 block / energy / draw 等多重效果 |
| `duck-whistle` | hook 改為 `first_cheap_card_played` | 支援 Subaru 0/1 費節奏，不再只看 attack |
| `blue-wave-badge` | 實作 block 2 + energy 1 的多效果 | 修正描述與 runtime 效果不一致 |
| `unarchived-archive` | hook 改為 `first_marker_card_played` | 支援 AZKi marker build |

## QA

已通過：

- `combat_engine_tests.gd`
- `runtime_database_tests.gd`
- `playable_demo_smoke_tests.gd`
- `demo_qa_mode_tests.gd`
- `playable_demo_auto_run_tests.gd`
- `combat_ui_layout_tests.gd`
- `random_map_tests.gd`
- `shop_campfire_selection_tests.gd`
- Godot `--quit`

既有 `ObjectDB instances leaked` warning 仍出現在部分 headless tests，依目前 policy 維持 non-blocking。

## Notes

- Auto-run proxy 本輪 AZKi 已打出 `laplus_dash`，代表 Laplus card frequency 有初步改善。
- Subaru / Botan 本輪未新增卡牌 id，避免缺卡圖破壞既有 art-path gate；先用既有正式卡圖卡牌做 gameplay revision。
- AZKi 新卡使用既有 placeholder-ready path policy，正式卡圖可後續用 asset pass 補上。
