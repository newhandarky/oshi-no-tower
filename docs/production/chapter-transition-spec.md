# Chapter Transition Spec

最近更新：2026-05-14

## Summary

本文件定義 Chapter 1 通關後進入 Chapter 2 的 runtime prototype 流程。2026-05-14 已接上程式流程與 headless tests。

核心決策：第一章 Boss 戰勝利後，玩家先領取 Boss reward，再進入第二章開場事件，選擇一個章節開場交易，之後生成第二章 random map。

## Target Flow

```text
Chapter 1 Boss defeated
-> combat victory animation
-> Boss reward screen
-> player claims one Boss reward path
-> Chapter 2 Start Event
-> player selects one option
-> apply option
-> generate Chapter 2 random map
-> show Chapter 2 map at floor 1
```

## Boss Reward Behavior

第一章 Boss reward 不再直接代表 run clear。

目前 runtime prototype 中，`boss_reward` screen 的終局語意依章節而定：

| current chapter | after reward | note |
|---|---|---|
| Chapter 1 | 前往 `chapter_start_event` | 不直接 `show_run_end(true)` |
| Chapter 2 | 進入 `run_summary` 或 future Chapter 3 hook | 第二章先可視為 demo clear |

第一章 Boss reward 可保留現有選項型態：

- 選一張高價值卡。
- 取得 Boss relic。
- 若保留「跳過 / 繼續」按鈕，文字應改成「前往第二章」，避免看起來像完整結算。

## Resource Carryover

推薦採用以下繼承規則：

| resource | Chapter 2 carryover rule | rationale |
|---|---|---|
| deck | 保留 | deckbuilding roguelite 的核心成長 |
| relic | 保留 | 讓 Chapter 1 路線選擇有長期價值 |
| gold | 保留 | Chapter 2 商店與開場 Gold trade 才有意義 |
| max_hp | 保留 | 角色與事件代價累積需延續 |
| current_hp | 回復到 max_hp | Boss 後進新章節應有公平起點 |
| curse | 保留 | 事件交易的長期負債要成立 |
| upgrade state | 保留 | 篝火 / reward 決策延續 |

## Chapter Start Event Timing

`chapter_start_event` 發生在 HP 回滿之後、Chapter 2 map 生成之前。

原因：

- 玩家先感覺「打完 Boss 進新章」。
- 開場事件選項能清楚影響第二章起跑。
- 若選 Gold + curse，玩家能立刻在 Chapter 2 shop / pathing 中思考代價。

## Chapter Start Event Scope

開場事件應是角色中立系統，不針對 AZKi、Subaru 或 Botan 補償。

允許選項：

- gain relic
- gain gold + add curse
- remove card
- upgrade card
- heal / max HP 類選項若 current HP 已回滿，應避免出現或改成 max HP / relic 交易

不允許選項：

- 給特定角色專屬卡。
- 因某角色通關率較低而提供補償。
- 直接生成大量新素材需求。
- 讓玩家跳過 Chapter 2 直接結算，除非是 debug-only route。

## Runtime Milestones

1. **Foundation Pack**
   - 本文件與 Chapter 2 設計文件完成。

2. **Data Prototype**
   - 已加入 Chapter 2 enemy / event / Boss data。
   - 已可由 Chapter 1 Boss reward 進 Chapter 2 start event。

3. **Runtime Progression**
   - `RunState` 已支援 current chapter。
   - Boss reward 已能依 chapter 導向下一章或結算。
   - Chapter 2 map 已使用第二章 enemy / event / boss pool。
   - Chapter start event 已支援 3 選 1。

4. **Polish / Balance**
   - 第二章正式素材、背景、UI polish、完整平衡與 manual QA 尚未開始。

## QA Policy

- 本文件階段不跑 GUI/manual QA。
- Data Prototype 階段先跑 headless tests。
- Runtime Progression 階段才需要新增 transition-specific smoke tests。
- 手動驗收只需由使用者實玩回報，Codex 不主動代替操作畫面。
