# 隨機地圖 v1 前置規格

最近更新：2026-05-09

本文件是 `oshi-no-tower-godot` 從固定長路線走向隨機地圖的實作規格。v1 資料骨架已完成，並已在 MVP-v2 接入主流程；固定路線仍保留為 debug fallback。

## 目標

- 做短版、可 seed 重現的路線圖，不一次追求完整 Slay the Spire 地圖規模。
- 保留目前可玩的 5 普通戰、1 菁英、3 事件、寶箱、商店、篝火、Boss 的內容密度。
- 讓玩家在地圖上有 2-3 條可選路線，但每條都能走到 Boss。
- 固定路線資料仍保留，debug 快捷鍵也保留。

## v1 地圖規則

- 地圖長度：Boss 前 10-12 層，最後固定 Boss。
- 起點後前 2 層至少有 1 場普通戰，避免一開始就商店或篝火。
- 每張地圖至少包含：5 場普通戰候選、1 個菁英候選、2-3 個事件候選、1 個寶箱、1 個商店、1 個篝火。
- 菁英不得出現在第 1 層或 Boss 前最後 1 層。
- 篝火優先放在 Boss 前 1-2 層，或菁英後可到達路線附近。
- 事件節點使用 MVP-v2 資料化事件池，目前至少 6 個事件。

## 目前完成

- 已新增 `scripts/data/RandomMapGenerator.gd`。
- 已新增 `RuntimeDatabase.generate_random_map(seed)` 入口。
- 已新增 `tests/headless/random_map_tests.gd`。
- 同一 seed 可產生相同地圖，不同 seed 會產生不同配置。
- 起點與所有節點都能連到 Boss。
- 地圖候選涵蓋普通戰、事件、菁英、寶箱、商店、篝火與 Boss。
- MVP-v2 已把 random map 接到 Map UI，正常 Subaru / Botan run 預設使用 seed-based random map。
- random map 生成時會決定本局 Boss id，Map UI 會顯示 Boss 預告，Boss 戰使用同一個 id。

## 資料與流程

- map generation helper 輸入 seed 與 RuntimeDatabase，輸出節點陣列與連線。
- RunState 已記錄 active_map、map_seed、current_node_id、visited_node_ids、available_node_ids；固定路線仍沿用 index fallback。
- Map UI 已接入簡化節點排版，不追求複雜曲線，但可點選可到達節點並禁止未連線節點。
- Debug 快捷鍵繼續直接進入指定畫面，不依賴目前地圖位置。

## 測試重點

- 同一 seed 產生相同地圖。
- 不同 seed 大多產生不同節點配置。
- 起點可以走到 Boss。
- 玩家不能點選未連線節點。
- 每張地圖至少有普通戰、事件、菁英、寶箱、商店、篝火與 Boss。
- 固定路線 fallback 與現有 headless 測試不可被破壞。

## 暫不做

- 多 Act。
- 複雜路線交叉檢查。
- 稀有房間、商店權重、事件權重。
- Seed 輸入 UI。
- 存檔與繼續遊戲。
