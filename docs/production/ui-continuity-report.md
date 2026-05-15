# UI Continuity Report

最近更新：2026-05-14

## Source

- GAME_DESIGN：`GAME_DESIGN.md`
- game_design_bible：`game_design_bible.json`
- owner skill：`game-art-ui-continuity`

## Display Contract

- Runtime text 不烘焙到素材；卡牌效果、Boss warning、status fallback、tooltip 都由 runtime label 顯示。
- Button states 至少保留 normal / focus / pressed / disabled；地圖節點需表現 reachable / locked。
- `declared_visual_anchor` 原則：random map 只顯示 Boss 名稱與節點狀態；Boss warning 在 combat header safe area；status summary 在角色下方；AZKi / Laplus FX 不進入手牌 hover 大卡區。
- Combat hand motion 需服務資訊理解：hover transition 可放大閱讀卡牌內容；end turn 時未用手牌往右側棄掉；draw 時新牌從左側進入並排在手牌最右側。
- 目前不新增 decorative UI asset，不啟動 `game-asset-pipeline`。

## Required Screens

| screen_id | purpose | safe text requirement | status |
|---|---|---|---|
| `character_select` | 三角色選擇與被動提示 | 三個角色提示不可互擠 | ready |
| `random_map` | 16 floor vertical route | 不顯示 Boss hint 長文；Boss node 只顯示 `BOSS`，標題區保留 Boss 名稱 | focus |
| `combat` | 戰鬥核心畫面 | Boss warning、status、intent、relic tooltip、hand hover 不重疊 | focus |
| `reward` | 3 選 1卡牌獎勵 | 卡名與描述保留固定安全文字區 | ready |
| `chest_reward` | 單 relic 結果 | 不跳回一般 reward context | ready |
| `shop` | card / relic / remove-card | 價格、特價、disabled 狀態清楚 | ready |
| `campfire` | rest / upgrade | 升級卡列表可讀 | ready |
| `event` | 事件選擇 | option 文字不可超出按鈕 | manual QA |
| `boss_reward` | 終局獎勵 | 不假裝是完整多 Act transition | ready |

## Combat Motion Contract

| interaction | runtime behavior | timing | QA rule |
|---|---|---:|---|
| card hover in | 卡牌置頂並放大，卡面依放大尺寸重排 | `0.5s` | 不可瞬間跳動或閃爍 |
| card hover out | 回到原本扇形位置、尺寸與 rotation | `0.3s` | 不可殘留最高 z-index |
| end turn discard | 尚未使用手牌往畫面右側滑出、淡出 | `0.34s + stagger` | 動畫結束後才處理 enemy turn |
| draw card | 新抽到的牌從畫面左側滑入 | `0.36s + stagger` | 新牌固定出現在手牌最右側 |

## Event Feedback Mapping

| event_id | UI feedback | FX rule | SFX cue status |
|---|---|---|---|
| `ui_select_character` | button pressed + start run | none | manifest only |
| `map_node_enter` | reachable node pressed | none | manifest only |
| `card_played` | card leaves hand / action animation | actor-owned | manifest only |
| `status_marker_applied` | status label shows `標記` fallback if no icon | `map_marker_projectile` must avoid text | manifest only |
| `boss_warning` | two-line warning label with smart wrap | no FX over label | manifest only |
| `reward_claimed` | selected reward exits to next screen | none | manifest only |
| `shop_purchase` | item removed / disabled by gold | none | manifest only |

## Acceptance Notes

- `marker` 沒有正式 icon 時必須顯示繁中 fallback：`標記 value/duration`。
- Boss warning 允許文字醒目，但不可遮住角色、敵人、relic summary 或手牌。
- AZKi / Laplus / FX 的 z-order 應讓 FX 高於 Laplus、角色語意清楚，但不能蓋住 runtime text。
- 卡牌 hover / draw / discard motion 目前已由 headless layout tests 保護基本 wiring；實際滑順度仍屬 manual visual QA 範圍。
- 手動 QA 需確認 960x540 基準比例下沒有文字或 UI overlap。
