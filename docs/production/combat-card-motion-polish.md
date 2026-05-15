# Combat Card Motion Polish

最近更新：2026-05-14

## Summary

本輪只處理戰鬥手牌的操作手感，不新增 gameplay 規則、不新增卡牌、不做 GUI/manual QA。

目標是把原本瞬間切換的卡牌 hover 改成可讀、滑順、比較像網頁圖片 hover transition 的動態，並讓手牌操作有明確方向語意：打出的牌先微上浮再往右上滑出，沒用完的手牌往右下側棄掉，新抽到的牌從左方進入手牌列，且新牌固定排在手牌最右側。

## Implemented Behavior

- 戰鬥手牌 hover：
  - hover in 用 `0.3s` 完成，分成兩段：前 `0.1s` 先沿原本角度抬起，後段放大到前景閱讀狀態。
  - hover out 用 `0.3s` 縮小回原本扇形位置。
  - hover 全程保留卡牌原本扇形角度，不再自動轉正。
  - hover 期間其他手牌不透明化、不改位置；改為暫停其他手牌的滑鼠判定，避免相鄰卡牌互相搶 hover。
  - hover 期間卡牌維持最高 z-index，避免被其他手牌蓋住。
  - hover 卡會用放大後尺寸重新排卡面文字，不只是單純 scale，降低描述區閃爍與字體糊掉的機率。
- 回合結束：
  - 玩家按「結束回合」後，當前尚未使用的手牌會先往畫面右側滑出、淡出並略微旋轉。
  - 動畫完成後才進入 CombatEngine 的回合結束處理，讓畫面語意與 discard timing 一致。
- 打出手牌：
  - 玩家成功打出一張手牌後，該張牌會先短暫往上浮，再往畫面右上側滑出、旋轉並淡出。
  - 動畫完成後才進入既有角色攻擊 / 受擊 / 抽牌刷新流程。
  - 這條動線刻意和回合結束未用手牌的右下棄牌方向分開，避免玩家把「已打出」與「被棄掉」誤讀成同一件事。
- 抽牌：
  - 每次因新玩家回合或卡牌效果抽到的牌，都會從畫面左側滑入。
  - CombatEngine 抽牌仍以 append 到 `combat.hand` 的方式處理，因此新抽到的卡牌自然位於手牌最右側。
  - 若有 `retain` 卡留在手上，新抽卡只會從 retained card 後方開始做滑入動畫。

## Runtime Touchpoints

- `scripts/ui/CombatHandView.gd`
  - 新增 hover tween duration 與 draw/discard tween helpers。
  - `animate_cards_to_discard()` 負責手牌往右側棄牌的視覺動畫。
  - `animate_played_card_to_right()` 負責單張打出卡的上浮、右上滑出與淡出。
  - `animate_draw_from_left()` 負責指定範圍的新手牌從左側進場。
- `scripts/Game.gd`
  - 記錄目前 combat hand buttons。
  - 在 `end_turn()` 前先播放棄牌動畫。
  - 在 `play_card()` 成功結算後先播放單張打出卡動畫，再進入 combat refresh / attack feedback。
  - 在新回合抽牌後與卡牌效果抽牌後，標記新抽卡起始 index，下一次重建手牌 UI 時播放抽牌動畫。
- `tests/headless/combat_ui_layout_tests.gd`
  - 覆蓋 hover 先上浮、保留原角度、hover after tween 的尺寸與 z-index、其他手牌維持不透明、暫停 / 恢復其他手牌滑鼠判定、縮回位置與角度還原。
  - 覆蓋棄牌往右滑出與抽牌從左滑入的 helper wiring。
  - 覆蓋打出手牌的上浮 metadata、右上滑出終點、動畫時間區間與淡出。

## Motion Contract

- `hover` 只負責閱讀焦點：可以放大、上浮並鎖住其他手牌 hit-test，但不可改變 combat state。
- `play` / `discard` / `draw` 會接管手牌狀態；開始前必須清掉整組手牌的 hover hit-test lock，避免 hover 中斷後留下不可選手牌。
- `play` 和 `discard` 都可以 kill 既有 hover tween，因為它們代表玩家已離開閱讀狀態，進入結算狀態。
- `draw` 重建或接回手牌時，進場卡必須回到 `Color.WHITE` 並恢復原本 `mouse_filter`。
- 後續若新增 card shake、cost pulse、invalid play feedback，應先判斷它是閱讀狀態還是結算狀態；結算狀態應優先清理 hover hit-test lock。

## Verification

已完成 headless / 非 GUI 驗證：

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

執行期間仍可見既有 macOS CA certificate warning 與部分測試結束時的 `ObjectDB instances leaked` warning；本專案先前已將這類 warning 列為 non-blocking，只要測試 exit code 為 0。

## Next Planning

1. 若繼續手牌 motion，可做更細的節奏微調：打出卡滑出時間、抽牌延遲與攻擊動畫銜接。
2. 若轉回內容線，下一步較適合收斂第二章 common / elite / Boss 數值與 AZKi reward pool，不需要 GUI/manual QA。
3. Technical QA 要從 `needs_revision` 推進，仍需要人類玩家完成 Subaru / Botan / AZKi 三角色完整 run 紀錄；automated proxy 與本輪 UI 動畫測試不取代 manual acceptance。
