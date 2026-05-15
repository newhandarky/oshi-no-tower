# Card Depth v1 Plan

最近更新：2026-05-15

本輪目標是建立可驗證的卡牌深度第一版，不一次擴成完整 roguelike 卡池。重點是讓每位角色至少有一條能被 fixture 測起來的主流派，並新增少量底層 effect 支撐更明確的 setup / payoff / defense / scaling 決策。

## Scope

- 不做完整 Power 系統、毒、姿態、orb 或大型 deck builder UI。
- 不新增正式卡圖；v1 prototype cards 使用 `ART` placeholder，但保留 `expected_art_path`。
- 自然流程勝率不是本輪唯一指標；先用固定 fixture 驗證流派成立，再用多 seed probe 調整 reward 密度與敵人壓力。

## Runtime Effects

- `next_attack_bonus`：本回合下一張攻擊牌第一段追加傷害，適合 setup 後爆發或低費連段收束。
- `draw_from_discard`：從棄牌堆取回指定 `kind` 的牌，支援防守後回收攻擊、marker loop 回收 support。
- `exhaust_count_at_least`：作為 `conditional.condition`，讓已 Exhaust 張數成為 payoff 條件。
- `temporary_card`：建立本場戰鬥臨時牌；打出後進 Exhaust，不進 run deck。
- `upgrade_signal`：卡牌 metadata，用來標示升級偏向穩定、爆發、抽牌、scaling 或 setup。

## Archetype Lines

### Subaru: `cheap_chain + tempo_block`

主線是低費連打、下一張攻擊強化、打第 N 張牌觸發，最後靠多段攻擊與力量收束。

新增 v1 prototype cards：

- `subaru-combo-boost`：0 費 setup / bridge，提供 `next_attack_bonus` 與抽牌。
- `subaru-encore-recall`：棄牌堆攻擊回收，補 bridge / defense。
- `subaru-afterimage-table`：Exhaust payoff，多段傷害並在達成條件後給格擋。

### Botan: `two_cost_burst + fortress_counter`

主線是先防守 / setup，再用 2 費攻擊與下一槍加成打出爆發。

新增 v1 prototype cards：

- `botan-kill-zone`：防守與下一張攻擊加成，讓爆發有準備回合。
- `botan-cover-reload`：高格擋並從棄牌堆回收攻擊牌。
- `botan-flashbang-round`：低費控制，提供虛弱防守轉向與 Exhaust 條件材料。

### AZKi: `marker_loop + laplus_guard`

主線是標記、抽牌、Laplus 疊血，再把防守資源轉成 payoff。

新增 v1 prototype cards：

- `azki-phantom-route`：建立臨時 `Phantom Marker`，同時回復 Laplus HP。
- `azki-necro-recall`：從棄牌堆回收 support，讓 marker / guard loop 更穩。
- `azki-laplus-release`：Exhaust 條件達成後，把 Laplus HP 轉成傷害。

## Fixture Tests

`tests/headless/archetype_fixture_tests.gd` 不作為玩家入口，只用於 headless guardrail。

- Subaru early：cheap-chain fixture 對 `ssrb-debuff-check`。
- Subaru late：late formed fixture 對 `algorithm-core` boss warning 類壓力。
- Botan early：fortress-burst fixture 對 `buffering-wall` block puzzle。
- Botan late：late formed fixture 對 `ssrb-giant-white` high attack boss。
- AZKi early：marker-laplus fixture 對 `comment-flood` multi-hit。
- AZKi late：late formed fixture 對 `notification-storm-elite` elite pressure。

測試要求固定 deck 在 guardrail 內勝利，並保留最低 HP 線；不要求無傷。

## Reward Draft v1.5

`CardRewardDraft` 現在會同時看：

- archetype signal：deck / relic 已走向的 build tag。
- role gap：deck 是否缺 `defense`、`payoff`、`scaling`、`bridge`。
- character-specific guardrails：例如 AZKi 第二章入口仍要 frontload Laplus guard，Botan 已有 rare payoff 後轉防守橋接。

這讓 reward 不只追同 tag，也會修正 deck 結構缺口。

## Next Expansion

- 將 fixture 成立後的卡牌密度反映到自然 reward 多 seed 勝率。
- 視 fixture 與 auto-run 結果微調 `upgrade_signal` 權重，而不是直接大量加牌。
- 若後續要做更完整的 Slay the Spire 式深度，再新增 Power / stance / poison 這類大型系統。
