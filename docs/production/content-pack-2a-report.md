# Content Pack 2A Report

最近更新：2026-05-14

## Summary

Content Pack 2A 已落地 `Card Depth System`：本輪深化 Subaru / Botan / AZKi 三角色，不新增章節、不新增第四角色、不做 GUI/manual QA、不新增正式素材。新卡使用 `prototype_placeholder`，UI 會維持 `ART` placeholder，並預留 `expected_art_path`。

## Runtime Changes

- `CombatEngine.gd` 新增 `cards_played_this_turn`、`retain`、`exhaust_on_play`、`summon_heal`、`conditional` effect wrapper。
- Relic trigger v2 支援 `trigger` / `condition` / `effects` / `limit`，目前可做每回合或每場戰鬥的條件觸發。
- `RuntimeDatabase.gd` 新增 card / relic / enemy depth metadata，並支援 `upgrade_effects` / `upgrade_description` 的 Upgrade v2。
- 新增 `CardRewardDraft.gd`，reward 會依 deck / relic signal 產生 build-relevant、survival/bridge、wildcard 三類選項；shop card 依 build relevance 排序。

## Content Added

新增 12 張 prototype 卡：

- Subaru：`subaru-opening-quack`、`subaru-crowd-cover`、`subaru-table-slam-loop`、`subaru-unstoppable-cheer`。
- Botan：`botan-range-finder`、`botan-overwatch`、`botan-piercing-round`、`botan-perfect-line`。
- AZKi：`azki-route-marker`、`azki-laplus-guard-order`、`azki-singing-coordinate`、`azki-necrobinder-finale`。

新增 4 個 encounter question：

- `ssrb-guard-tutor`：`anti_burst_into_block`。
- `ssrb-striker-intent`：`attack_intent_test`。
- `ssrb-debuff-check`：`debuff_resilience`。
- `ssrb-scaling-clock`：`scaling_clock` elite。

## Design Impact

- Subaru 現在有更明確的第 2 / 第 3 張牌 payoff，低費連段不只省費，也能轉防守、抽牌與 scaling。
- Botan 的 2 費卡更依賴易傷 setup、攻擊意圖與格擋門檻，爆發回合更像狙擊窗口。
- AZKi 的 marker loop、Laplus guard 與 route explore 被拉開，Laplus HP 變成可被卡牌管理的資源。
- Reward / shop 會更常順著目前 deck signal 推牌，但仍保留防守橋接與 wildcard，避免三張全 payoff。

## Verification Scope

本輪只做 headless / 非 GUI 驗證。Manual full run gate 仍是獨立 blocker，不因 Content Pack 2A 自動通過。

已通過：

- `combat_engine_tests.gd`
- `runtime_database_tests.gd`
- `reward_draft_tests.gd`
- `enemy_design_tests.gd`
- `combat_ui_layout_tests.gd`
- `random_map_tests.gd`
- `shop_campfire_selection_tests.gd`
- `playable_demo_smoke_tests.gd`
- `playable_demo_auto_run_tests.gd`
- `demo_qa_mode_tests.gd`
- Godot `--quit`
- `game_design_bible.json` JSON parse

執行期間仍可見既有 macOS `get_system_ca_certificates` warning 與部分 Godot `ObjectDB instances leaked` warning，依既有政策列為 non-blocking。
