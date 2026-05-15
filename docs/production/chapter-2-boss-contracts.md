# Chapter 2 Boss Contracts

最近更新：2026-05-14

## Summary

Chapter 2 Boss pool 延續第一章 random Boss policy，但 Boss 的設計語言要更偏向 deck structure test。地圖只顯示 Boss 名稱與 Boss node；每個 Boss 都要有 combat warning、spike turn、counterplay，避免玩家第一次遇到只能靠背板。

本文件是 contract。2026-05-14 runtime prototype 已新增三個 Boss data；正式 Boss 素材仍未新增，先重用既有 SSRB sprite。

## Boss Pool Target

第一版建議 3 個 Boss contracts：

1. `algorithm-core`
2. `archive-phantom`
3. `notification-storm`

## Boss Contract: Algorithm Core

- `boss_id`：`algorithm-core`
- 名稱：`Algorithm Core`
- 主題：推薦系統核心，會觀察玩家節奏並調整攻擊模式。
- `boss_danger_tag`：`節奏審核`
- combat warning intent：連續大量出牌會讓核心提高壓力，爆發回合要有明確收束。

### Pattern

| turn cycle | behavior |
|---|---|
| Turn 1 | 中傷攻擊，記錄玩家打牌數 |
| Turn 2 | 若上回合玩家打出 4 張以上牌，施加 weak；否則 block |
| Turn 3 | buff 自身或增加下一擊傷害 |
| Turn 4 | spike attack，依玩家前幾回合總出牌數提高傷害 |

### Counterplay

- 玩家可以打連段，但連段要換到實質 payoff。
- 不建議每回合無腦把低費牌全部打完。
- Botan 可用 setup 後爆發；Subaru 要讓 cheap-chain 有收束；AZKi 要避免 marker loop 拖太久。

### Boss Warning

`提示：Boss 警告 - Algorithm Core 正在審核出牌節奏，下回合可能依連打次數提高傷害。`

## Boss Contract: Archive Phantom

- `boss_id`：`archive-phantom`
- 名稱：`Archive Phantom`
- 主題：封存殘影，測玩家是否能處理 curse、retain、exhaust 與長期負債。
- `boss_danger_tag`：`封存污染`
- combat warning intent：牌組越臃腫或 curse 越多，戰鬥越容易被拖慢。

### Pattern

| turn cycle | behavior |
|---|---|
| Turn 1 | 低傷攻擊，若玩家 deck 有 curse，額外施加 vulnerable |
| Turn 2 | 將 temporary status / dead draw 類效果放入 draw pile，或提高自身 block |
| Turn 3 | 對 retained / unplayed hand 做懲罰性小傷害 |
| Turn 4 | spike attack，若玩家手牌有 curse 或 unplayable card，追加傷害 |

### Counterplay

- Chapter start event 的 Gold + curse 交易在此 Boss 會變得有真實代價。
- 移除卡、升級核心卡、保持 deck density 都能降低壓力。
- 不應靠單純高血量硬吃，因為它會讓壞抽更痛。

### Boss Warning

`提示：Boss 警告 - Archive Phantom 正在讀取封存雜訊，手牌中的 curse 或無法打出卡會放大下回合傷害。`

## Boss Contract: Notification Storm

- `boss_id`：`notification-storm`
- 名稱：`Notification Storm`
- 主題：通知暴雨，多段攻擊與 debuff 壓力，測持續防守。
- `boss_danger_tag`：`連續壓力`
- combat warning intent：多段攻擊與易傷會連續壓血，單回合大 block 不一定足夠。

### Pattern

| turn cycle | behavior |
|---|---|
| Turn 1 | 多段小攻擊 |
| Turn 2 | 施加 vulnerable 或 weak |
| Turn 3 | attack_block，建立下回合壓力 |
| Turn 4 | spike multi-hit，若玩家有 vulnerable 則追加段數或傷害 |

### Counterplay

- 持續防守比只靠一次大防更可靠。
- 應在 vulnerable 回合保守，或提前用 burst 打進斬殺線。
- 召喚物 / block / weak management 都會被測試。

### Boss Warning

`提示：Boss 警告 - Notification Storm 即將連續通知轟炸，若身上有易傷，下回合血線會快速下降。`

## Boss Pool Rules

- Chapter 2 map generation 時隨機選 1 個 Boss，並在 map title 顯示 Boss 名稱，不顯示 Boss hint 長文。
- 進 Boss 戰時必須使用同一個 selected Boss id。
- Boss warning 不可只顯示 flavor text，必須給玩家可操作 counterplay。
- Boss 不應要求特定角色才有解法。

## Data Prototype Priority

第一輪 Runtime Prototype 已做：

1. `algorithm-core`
2. `notification-storm`

`archive-phantom` 也已先以既有 curse 壓力接入；temporary status / dead draw 類型可第二輪再深化。
