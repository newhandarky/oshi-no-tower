# Chapter 2 Design Bible

最近更新：2026-05-14

## Summary

Chapter 2 已進入 runtime prototype，目標是讓專案從第一章 playable demo 的打磨，推進到可測試的第二章章節流程。

本輪已接 runtime prototype，但不新增正式素材、不新增第四角色、不做 GUI/manual QA。AZKi 的卡牌強度與通關率不放進 Chapter 2 開場補償，之後獨立在角色卡牌平衡輪次處理。

## Chapter Identity

- `chapter_id`：`chapter_2_algorithm_depths`
- 暫定名稱：`演算法深層`
- 英文 id：`Algorithm Depths`
- 章節定位：第一章通關後進入的平台深層區域，壓力從「直播事故 / mascot 推塔」升級成「演算法、通知、封存、推薦與留言洪流」。
- 主題語氣：仍是 Hololive 粉絲向、輕量喜劇感，但戰鬥考題更複雜，事件代價更長期。

## Why This Chapter

第一章已經能展示 Subaru / Botan / AZKi 的基本玩法差異。第二章不應只是敵人血量更高，而要讓玩家感覺 deck build 開始被真正檢驗：

- 第一章：學會角色節奏、處理普通戰與 Boss warning。
- 第二章：檢查 deck 是否過度單一、是否有防守 plan、是否能處理 debuff / curse / block puzzle / scaling clock。
- 第一章事件偏資源交換；第二章事件要加入更明確的長期負債。

## Core Design Pillars

1. **章節轉場有儀式感**
   - 第一章 Boss reward 後不直接結算，而是進入第二章開場事件。
   - 開場事件提供 relic、Gold + curse、移除卡、升級卡等選項。

2. **敵人是 deck question**
   - 第二章敵人不只提高數值，而是針對 deck 結構出題。
   - 測試 cheap-chain、2 費爆發、marker loop、保命、debuff handling、curse tolerance、scaling。

3. **事件讓選擇更有重量**
   - 第二章事件應避免單純「拿好處」。
   - 高報酬要搭配 curse、HP、Gold、下一場戰鬥弱化、移除機會成本等代價。

4. **不做角色補償捷徑**
   - 第二章開場事件不針對 AZKi 或任何單一角色補強。
   - 角色平衡應回到卡牌、reward pool、relic hook、敵人 matchup 調整。

5. **先 prototype、後 polish**
   - Foundation Pack 已鎖設計。
   - Runtime Prototype 已新增第二章敵人 / 事件 / Boss 資料。
   - 後續才補第二章正式素材、背景、平衡與手動 QA。

## Player Flow Target

```text
Chapter 1 Boss victory
-> Boss reward
-> Chapter 2 Start Event
-> Apply selected option
-> Generate Chapter 2 random map
-> Chapter 2 floor 1
-> Chapter 2 Boss
-> run summary or future Chapter 3 hook
```

## Chapter 2 Map Direction

- 預設仍使用 16 floor random map。
- Boss floor：16。
- node types：`battle`、`elite`、`event`、`chest`、`shop`、`campfire`、`boss`。
- 地圖視覺可先沿用第一章 map UI；第二章色調與背景素材晚一輪再處理。
- 第二章應提高事件、elite、shop 的決策價值，但不讓路線過度懲罰。

## Content Targets

第一版 Chapter 2 Runtime Prototype 已落地最低內容量：

| content | target count | note |
|---|---:|---|
| common enemy contracts | 6 | 覆蓋 anti-cycle、block puzzle、debuff、multi-hit、delayed burst |
| elite contracts | 3 | 測 scaling、deck speed、curse/debuff tolerance |
| boss contracts | 3 | 隨機 Boss，與第一章保留一致策略 |
| chapter start event options | 8 | runtime 每次抽 3 個選項 |
| chapter 2 events | 8 | 包含高報酬高代價、remove/upgrade 稀缺、curse trade |
| relic / card changes | 0 required | 第二章第一輪不依賴新增角色卡或 relic |

## Out Of Scope

- 不新增第四角色。
- 不在 Chapter 2 開場事件做 AZKi 專屬補強。
- 不一次新增大量正式素材。
- 不做完整音效 / BGM asset。
- 不做 Web build。
- 不新增第二章正式背景 / enemy sprite；runtime 先重用既有 SSRB / meme enemy sprite。

## Acceptance

Chapter 2 Runtime Prototype 完成的判定：

- `chapter-2-design-bible.md`、`chapter-transition-spec.md`、`chapter-start-event-pool.md`、`chapter-2-encounter-design.md`、`chapter-2-boss-contracts.md` 完成且互不矛盾。
- `GAME_DESIGN.md` 與 `game_design_bible.json` 明確標記 Chapter 2 為 `runtime_prototype`，不是 final art / balance ready。
- 文件明確禁止用 Chapter 2 開場事件補償單一角色。
- Headless tests 覆蓋第二章資料、第二章地圖 pool、Boss reward -> chapter start event -> Chapter 2 map。
