# 第一版 MVP 需求整理（Godot 調整版）

本文件由 Web 版 `docs/first-design.md` 搬入並調整。原始文件以瀏覽器 Web MVP 為目標；目前專案已改以 Godot 版為主。

## 目前結論

- 現行開發環境是 Godot：

  ```text
  /Users/zhangzhipeng/MyProject/oshi-no-tower-godot
  ```

- Web 版與 Unity 版只作為歷史參考。
- Unity 版不再作為後續開發方向。
- 文件、開發紀錄與 Agent 回覆預設使用繁體中文。

## 專案目標

製作一個 Hololive fan game / 非商業原型的短流程卡牌 roguelite MVP。玩法參考 Slay the Spire，但範圍維持小而完整，目標是驗證一輪可玩的 deckbuilding 戰鬥 loop。

優先順序：

1. 可玩。
2. 可驗收。
3. 範圍小。
4. 視覺清楚。
5. 達成 MVP 後停止擴張。

## IP / 二創限制

- 本專案是非官方 fan game / 非商業原型。
- 不使用官方 Logo、官方立繪、官方 UI、官方語音、官方音樂或拆包素材。
- 素材應使用原創 fan-game 詮釋或已確認可用的生成素材。
- 不包裝成官方 Hololive 遊戲。

## 目前角色

- Subaru：
  - Godot 版可遊玩。
  - 定位是低費、多段、節奏型。
- Botan：
  - Godot 版可遊玩。
  - 定位是高單發、防禦穩、射擊感。

## 固定路線

Godot MVP 使用固定路線，不做分支與隨機地圖。

```text
開始
-> 小怪 1
-> 寶箱
-> 小怪 2
-> 商店
-> 小怪 3
-> 篝火
-> Boss
-> 結算
```

## 戰鬥需求

戰鬥採回合制卡牌系統，必須包含：

- HP
- Energy
- Block
- 抽牌堆
- 手牌
- 棄牌堆
- 敵人意圖
- 敵人回合
- 勝利 / 失敗流程

玩家必須能：

- 抽牌。
- 出牌。
- 消耗能量。
- 獲得格擋。
- 對敵人造成傷害。
- 結束回合。

## 內容範圍

目前 Godot 版保留：

- 兩位可遊玩角色。
- 三場普通敵人戰。
- 一場 Boss 戰。
- 寶箱卡牌獎勵。
- 商店購買卡牌。
- 篝火回血。
- Boss 隨機選擇邏輯。
- Debug / 驗收快捷鍵。

目前不做：

- 分支地圖。
- 隨機地圖生成。
- Relic 系統。
- 事件系統。
- 存檔 / 讀檔。
- Meta progression。
- 語音。
- 劇情章節。
- 抽卡系統。
- 多人模式。
- 大型卡池。

## 素材需求與現況

Godot 版目前已接入：

- Subaru / Botan 角色 sprite sheet。
- SSRB Gray / Camouflage / White 敵人 sprite sheet。
- Subaruto Duck Boss sprite sheet。
- Combat 背景圖。
- Map 背景圖。
- SSRB explosion FX 素材。

素材原始參考與生成紀錄由使用者另行備份，不在本次文件搬移範圍。

## 驗收標準

- Godot 專案可啟動。
- Subaru 與 Botan 都能開始路線。
- 玩家可以沿固定路線走到 Boss。
- 怪物、寶箱、商店、篝火、Boss 節點都能互動。
- 戰鬥中能抽牌、出牌、消耗能量、獲得格擋、顯示敵人意圖、執行敵人回合、判定勝負。
- 打贏 Boss 後顯示通關成功。
- 玩家 HP 歸零時顯示挑戰失敗。
- Boss 戰有 BOSS 標示、Boss 名稱與暗色 overlay。

## Debug 快捷鍵

- `F1`：顯示或隱藏 debug 快捷鍵說明。
- `F2`：直接開始 Subaru 路線。
- `F3`：直接開始 Botan 路線。
- `F4`：直接進入普通戰測試。
- `F5`：切換指定 Boss。
- `F6`：直接進入指定 Boss 戰。
