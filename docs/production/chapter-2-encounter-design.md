# Chapter 2 Encounter Design

最近更新：2026-05-14

## Summary

Chapter 2 的 encounter 不以「血量和傷害變大」為主要差異，而是把敵人做成 deck question。每個敵人應明確測一種 deck 能力，讓玩家感覺第二章是第一章之後的進階考題。

本文件是 enemy contract。2026-05-14 runtime prototype 已新增第二章 enemy data，正式素材仍未新增，先重用既有 enemy sprite。Balance Pass 1 已對 early / mid common enemy 加入 headless pressure guardrail，避免第二章入口對未成形 deck 過度懲罰。

## Pressure Tags

| pressure_tag | purpose | player question |
|---|---|---|
| `anti_cycle` | 限制無腦低費連打 | deck 是否只有抽牌 / 低費，缺乏收束？ |
| `block_puzzle` | 高格擋窗口 | 玩家是否會等 vulnerable / burst window？ |
| `debuff_pressure` | 施加 weak / vulnerable / energy loss | deck 是否有足夠防守與節奏緩衝？ |
| `multi_hit_pressure` | 連續小傷害 | 防守是否只靠單次大 block？ |
| `delayed_burst` | 明確蓄力回合 | 玩家是否能在 warning 前做準備？ |
| `scaling_clock` | 敵人逐回合變強 | deck 是否能在一定回合內收束？ |
| `curse_tolerance` | 污染手牌 / 懲罰 curse deck | 事件交易是否真的有代價？ |
| `summon_pressure` | 多段 / overflow 壓力 | 召喚物承傷與玩家血線是否能被管理？ |

## Common Enemy Contracts

| enemy_id | band | pressure_tags | pattern | counterplay_hint |
|---|---|---|---|---|
| `recommendation-watcher` | early | `anti_cycle`, `debuff_pressure` | 玩家前一回合打出 4 張以上牌時，下回合施加 weak；否則普通攻擊 | 不要每回合都把手牌打空，保留爆發回合 |
| `buffering-wall` | early | `block_puzzle` | 高 block 與低傷攻擊交替；高 block 回合打進去效率差 | 等低防回合或先建立 vulnerable |
| `comment-flood` | mid | `multi_hit_pressure`, `debuff_pressure` | 多段小傷害，偶爾施加 vulnerable | 穩定 block 比單回合爆發更重要 |
| `clip-mirror` | mid | `anti_cycle`, `curse_tolerance` | 若玩家手牌含 curse 或 retained card，追加小傷害 | 避免為了高報酬累積太多長期負債 |
| `bitrate-phantom` | mid | `delayed_burst`, `debuff_pressure` | 兩回合鋪墊後大攻擊，鋪墊時施加 weak | warning 前優先防守或加速擊殺 |
| `archive-sentinel` | late | `block_puzzle`, `scaling_clock` | 每次受未破防傷害後增加下回合 block；每三回合 buff | 需要有效破防，不要用低傷多段餵它成長 |

## Balance Pass 1-2 Guardrails

這輪 guardrail 只保護第二章 common enemy 的可讀壓力，不代表第二章最終平衡完成。

| enemy_id | guarded value |
|---|---|
| `recommendation-watcher` | early attack <= 12；attack_block <= 9 damage + 8 block |
| `buffering-wall` | early high block <= 20；反擊 attack <= 14 |
| `comment-flood` | mid multi-hit <= 5x4；attack_block <= 12 damage + 8 block |
| `clip-mirror` | mid anti-cycle attack <= 16 |
| `bitrate-phantom` | delayed burst <= 26 |
| `archive-sentinel` | late block <= 24；attack_block damage <= 22 |

Pass 2 追加目標是降低第二章入口到中段對未成形 AZKi marker deck 的懲罰：`buffering-wall` 的反擊、`comment-flood` 的攻防拖延、`clip-mirror` 的普通攻擊都保留原本考題，但避免在 reward 尚未補足 Laplus 防守橋接前直接壓垮玩家。

## Elite Enemy Contracts

| enemy_id | pressure_tags | pattern | tested decks | counterplay_hint |
|---|---|---|---|---|
| `algorithm-auditor` | `scaling_clock`, `anti_cycle` | 每 3 回合審核玩家節奏；若玩家打牌數過高，提升自身 strength | cheap-chain 需要收束，不可只循環 |
| `notification-storm-elite` | `multi_hit_pressure`, `debuff_pressure` | 多段攻擊 + vulnerable；低血量時連續攻擊 | 防守 density 和 debuff timing 是主考題 |
| `archive-hydra` | `curse_tolerance`, `delayed_burst` | 污染手牌或懲罰 curse；蓄力後大攻擊 | 事件拿 curse 的 deck 要付出真代價 |

## Archetype Interaction

| player archetype | Chapter 2 risk | desired answer |
|---|---|---|
| Subaru `cheap_chain` | 過度連打被 `anti_cycle` 懲罰 | 低費連段要有 payoff，不是只打很多牌 |
| Subaru `tempo_block` | 多段壓力會吃掉零散 block | 需要把 block 轉成穩定回合節奏 |
| Botan `two_cost_burst` | 打進高 block 會浪費爆發 | 需要讀 block puzzle 與 vulnerable window |
| Botan `fortress_counter` | delayed burst 需要提前防守 | 防守反擊應在 warning 前建立 |
| AZKi `marker_loop` | anti-cycle 會限制無腦 marker 循環 | marker payoff 要選擇時機 |
| AZKi `laplus_guard` | multi-hit / overflow 會測召喚物資源 | Laplus HP 是資源，不是免費護盾 |

## Data Prototype Minimum

第一輪 Runtime Prototype 已落地：

1. 2 個 early common：`recommendation-watcher`、`buffering-wall`
2. 3 個 mid common：`comment-flood`、`clip-mirror`、`bitrate-phantom`
3. 1 個 late common：`archive-sentinel`
4. 3 個 elite：`algorithm-auditor`、`notification-storm-elite`、`archive-hydra`

這樣已能證明第二章不是第一章換皮。

## Out Of Scope

- 不新增正式 enemy sprite。
- 不做多敵人站位系統。
- 不做單一角色補償敵人。
- 不因 AZKi 尚未通關而降低第二章整體設計目標。
