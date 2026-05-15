# 角色圖片重製規格

更新日期：2026-05-10

## 目的

本文件定義 Subaru / Botan 後續重製角色圖片時的最低規格，避免新圖導入後打亂戰鬥 UI、狀態文字、手牌 hover 與敵人位置。

## 檔案路徑

角色素材沿用目前資料路徑：

```text
res://assets/characters/subaru/<action>/sheet-transparent.png
res://assets/characters/botan/<action>/sheet-transparent.png
```

每個 `<action>` 目前至少需要：

- `idle`
- `normal_attack`
- `defense`
- `hurt`
- `tsukkomi`：Subaru 特色動作。
- `shooting_skill`：Botan 特色動作。

## 尺寸與定位

- 基準畫面：`960x540`。
- Godot 顯示尺寸：目前角色以 `178x178` 顯示在戰鬥畫面。
- 建議原始 sheet 單格：至少 `256x256`，透明背景。
- 角色主體應落在單格中央略偏下，腳底或站立底線穩定。
- 頭頂、手部、武器或尾巴可以超出主體，但不可讓整體重心偏到一側。

## 動作要求

- `idle`：可循環，姿勢穩定，不應有大幅位移。
- `normal_attack`：攻擊方向朝右，適合一般攻擊牌。
- `defense`：有防禦、掩護、準備或格擋語意。
- `hurt`：短暫受擊感，角色仍需可辨識。
- 特色動作：
  - Subaru `tsukkomi`：適合吐槽、快速反應、多段攻擊。
  - Botan `shooting_skill`：適合精準射擊、重擊、壓制。

## UI 安全區

重製圖片導入後需確認：

- 不遮住左上玩家 HP / 格擋 / 能量 / 被動文字。
- 不遮住角色下方 `狀態：...` 文字。
- 不和下方手牌未 hover 狀態嚴重重疊。
- 手牌 hover 放大時可以覆蓋角色，這是允許的。
- 角色受擊位移時不可跑出畫面或遮住敵人意圖。

## 驗收方式

導入新角色圖後至少跑：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/runtime_database_tests.gd
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_ui_layout_tests.gd
```

手動驗收：

- Debug `2` 回角色選擇後，選擇要驗收的角色。
- Debug `3` 進普通戰，確認 idle / attack / hurt 可見。
- 出防禦牌確認 defense 動作。
- Hover 手牌確認新圖不影響卡牌閱讀。

## 暫不處理

- 不要求這一版完成正式 Live2D 或骨架動畫。
- 不要求每張卡都有獨立動作。
- 不要求所有敵人同步重製。
