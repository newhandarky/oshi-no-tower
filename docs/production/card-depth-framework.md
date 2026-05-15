# Card Depth Framework

最近更新：2026-05-14

本文件定義 Godot MVP 後續設計卡牌、relic、敵人與 reward draft 的最低資料契約。目標不是增加牌數，而是讓每張牌的價值會依 deck、relic、敵人意圖、路線與升級而改變。

## Card Schema

每張卡必須有：

- `archetype_tags`：build 方向，例如 `cheap_chain`、`tempo_block`、`two_cost_burst`、`marker_loop`、`laplus_guard`。
- `role_tags`：功能角色，限定使用 `setup`、`payoff`、`bridge`、`defense`、`scaling`、`utility`、`risk` 等可讀標籤。
- `rarity`：`starter`、`common`、`uncommon`、`rare`、`curse`。
- `floor_band`：`early`、`mid`、`late`、`boss`。
- `upgrade_plan`：說明升級是在提高穩定度、爆發、抽牌、scaling 或降低風險。
- 新卡必須有 `upgrade_effects` 與 `upgrade_description`；舊卡沒有時才走通用升級 fallback。

## Placeholder Policy

- 新 prototype 卡可設定 `art_status = "prototype_placeholder"` 並讓 `art_path = ""`，UI 顯示 `ART` placeholder。
- 所有 prototype 卡仍必須有 `expected_art_path`，後續正式卡圖只要放到指定路徑即可自動接線。
- Subaru / Botan 既有正式卡仍要求正式卡圖；本輪新增 prototype 卡例外。

## Reward Draft v2

Reward 不再只是全池 shuffle 取前三張。每次 3 選 1 要盡量包含：

- 一張符合目前 deck / relic signal 的 build-relevant 卡。
- 一張 `defense` 或 `bridge`，避免 deck 只有 payoff 沒 setup 或生存。
- 一張 wildcard，保留轉向或高價值驚喜。

Rarity 依樓層調整：early 避免過早塞 rare；mid 開始允許 uncommon；late / elite / boss 可以提高 rare 露出。

## Combat Depth Blocks

Runtime 現支援以下通用積木：

- `conditional`：可依 `enemy_intent`、`target_status`、`cards_played_this_turn_min`、`summon_alive`、`player_block_at_least` 觸發 nested effects。
- `retain`：回合結束保留在手上，並標記 `_retained_from_previous_turn`。
- `exhaust_on_play`：打出後進 exhaust pile。
- `summon_heal`：回復 Laplus summon HP，並 clamp 到 max HP。
- `cards_played_this_turn`：支援 Subaru 低費連段與第 N 張牌 payoff。

## Enemy Question Design

敵人不是只放數值，必須像考題：

- `anti_burst_into_block`：教玩家不要把爆發丟進高 block。
- `attack_intent_test`：測防守與 `enemy_intent` conditional card。
- `debuff_resilience`：測 deck 是否能處理 weak / vulnerable 的低品質回合。
- `scaling_clock`：測 deck 是否有足夠 scaling 或爆發窗口。

每個 enemy 必須有 `pressure_tags`、`tests_archetypes`、`counterplay_hint`，讓 QA 和後續設計能知道它在考什麼。
