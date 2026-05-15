# Reference Prototype：Web / Phaser MVP（Godot 調整版）

本文件由 Web 版 `docs/reference-prototype.md` 搬入並調整。Web / Phaser 版本現在只作為歷史驗證參考，不再是主開發環境。

## Web 原型驗證結論

Web / Phaser 原型已驗證：

- 短流程卡牌 roguelite 可以成立。
- 固定單一路線適合第一版驗證。
- 回合制卡牌戰鬥的最小系統足以支撐一輪短 run。
- 戰鬥核心與畫面表現分離是正確方向。
- 資料驅動的角色、卡牌、敵人、地圖節點方便移植。

## 已被 Godot 承接的決策

Godot 版已承接：

- 固定單一路線。
- 三場普通戰加一場 Boss 戰。
- 寶箱、商店、篝火都有功能。
- Combat engine 與 UI 流程分離到不同腳本層次。
- 卡牌、敵人、地圖節點集中在 `RuntimeDatabase.gd`。
- MVP 優先，不加入分支地圖、隨機事件、relic、存檔、meta progression 或大型卡池。

## Godot 版已超過 Web 原型的部分

Godot 版目前已新增或替換：

- Subaru 與 Botan 都可遊玩。
- 普通敵人改為 SSRB Gray / Camouflage / White。
- Boss 使用 Subaruto Duck 與巨大 SSRB 變體。
- Combat / Map 背景圖。
- Boss 戰 BOSS 標示與暗色 overlay。
- Debug / 驗收快捷鍵。
- 繁中 README、AGENTS、狀態文件。

## 不再照搬的 Web 內容

以下 Web 內容不再作為 Godot 必須實作：

- Phaser scene 結構。
- Vite / TypeScript 專案結構。
- Web 版 UI 排版。
- Web 版 placeholder 敵人與 Boss 命名。
- Web 版 Botan 作為敵人 stand-in 的設定。
- Web 版 Weak 機制，除非未來重新需要 debuff 系統。

## Web 測試的參考價值

Web 版 `tests/combatEngine.test.ts` 仍有參考價值。Godot 目前已有 `tests/headless/combat_engine_tests.gd`，但仍可參考 Web 測試繼續擴充案例。

可參考轉換的測試案例：

- 初始化戰鬥會抽 5 張。
- 攻擊牌消耗能量並造成傷害。
- 防禦牌增加 Block。
- 結束回合會處理敵人意圖。
- 勝利與失敗判定。
- 抽牌堆空時處理棄牌堆。

## 現行驗證指令

Godot 專案載入檢查：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --quit
```

手動驗收以 Godot 執行主場景為準：

```text
res://scenes/main.tscn
```
