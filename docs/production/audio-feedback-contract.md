# Audio Feedback Contract

最近更新：2026-05-14

## Source

- GAME_DESIGN：`GAME_DESIGN.md`
- game_design_bible：`game_design_bible.json`
- owner skill：`game-audio-feedback-pipeline`
- acceptance depth：manifest-only，本輪不要求正式音效 / BGM asset。

## Music Contexts

| music_context_id | intent | transition style | asset status |
|---|---|---|---|
| `music_context_ui` | character select / menu calm loop | crossfade | deferred |
| `music_context_map` | route planning and resource pressure | crossfade | deferred |
| `music_context_combat` | normal / elite combat | stinger then loop | deferred |
| `music_context_boss` | Boss warning and Boss combat pressure | duck current BGM, warning stinger | deferred |
| `music_context_reward` | reward / chest / boss reward | short stinger then quiet loop | deferred |
| `music_context_shop` | shop browsing | crossfade | deferred |
| `music_context_campfire` | rest / upgrade relief | crossfade | deferred |
| `music_context_event` | event choice tension | crossfade | deferred |
| `music_context_failure` | defeat result | stinger then stop/loop | deferred |

## SFX Cue Manifest

| event_id | sfx_cue | priority | cooldown_ms | polyphony | playback_mode | volume |
|---|---|---:|---:|---:|---|---:|
| `ui_select_character` | `ui_confirm_soft` | 20 | 80 | 1 | one_shot | 0.8 |
| `map_node_enter` | `map_node_confirm` | 30 | 100 | 1 | one_shot | 0.8 |
| `combat_start` | `combat_enter_stinger` | 70 | 500 | 1 | one_shot | 0.9 |
| `card_played` | `card_play_generic` | 40 | 40 | 3 | one_shot | 0.7 |
| `status_marker_applied` | `marker_apply_ping` | 55 | 120 | 2 | one_shot | 0.85 |
| `marker_payoff_damage` | `marker_payoff_hit` | 60 | 120 | 2 | one_shot | 0.9 |
| `azki_laplus_dash` | `laplus_dash_whoosh` | 65 | 200 | 1 | one_shot | 0.9 |
| `azki_laplus_crash` | `laplus_crash_impact` | 75 | 250 | 1 | one_shot | 0.95 |
| `boss_warning` | `boss_warning_pulse` | 90 | 800 | 1 | one_shot | 0.95 |
| `battle_victory` | `battle_victory_stinger` | 80 | 800 | 1 | one_shot | 0.9 |
| `battle_defeat` | `battle_defeat_drop` | 85 | 800 | 1 | one_shot | 0.9 |
| `chapter_transition` | `chapter_transition_stinger` | 70 | 600 | 1 | one_shot | 0.9 |
| `chapter_start_event_selected` | `event_choice_confirm` | 35 | 100 | 1 | one_shot | 0.8 |
| `reward_claimed` | `reward_claim` | 35 | 80 | 2 | one_shot | 0.8 |
| `shop_purchase` | `shop_purchase_chime` | 35 | 80 | 2 | one_shot | 0.8 |
| `campfire_rest` | `campfire_rest_warm` | 45 | 300 | 1 | one_shot | 0.8 |
| `event_choice_selected` | `event_choice_confirm` | 35 | 100 | 1 | one_shot | 0.8 |

## Mixing Rules

- `boss_warning_pulse` priority 高於 `card_play_generic`，必要時 duck generic combat cue。
- `laplus_crash_impact` 不與 `marker_payoff_hit` 同時無限制疊加；若同 frame 觸發，保留 crash cue。
- UI cues 保持短、低音量，不掩蓋 Boss warning 或 combat impact。
- Audio asset 尚未存在時，runtime 可保持 silent，但 contract 不可刪除。

## Acceptance

- 每個 player-facing `event_id` 已有 `sfx_cue` 或明確 deferred manifest cue。
- 正式音檔導入時，需補 asset path、loop point、crossfade 秒數與 runtime audio audit。
