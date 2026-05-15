# 視覺素材新增與接線指南

更新日期：2026-05-13

## 目的

這份文件給後續對話或 agent 使用，說明本專案新增卡圖、狀態 icon、敵人 intent icon、relic icon 與角色動作圖時，要放哪裡、改哪裡、怎麼驗收。

## 基本原則

- 正式遊戲素材一律放在 `res://assets/` 底下。
- `res://generated/` 或 `generated/sprites/` 只當生成來源備份，不應作為正式 runtime 路徑。
- 新圖放進 `assets/` 後，要跑 Godot headless editor reimport。
- 圖片路徑接線集中在 `scripts/data/RuntimeDatabase.gd`，不要在 UI 元件裡硬寫個別卡牌或 relic id。
- 沒有圖片時 UI 必須保留 fallback：
  - 卡圖：顯示 `ART` placeholder。
  - intent icon：顯示文字符號 fallback。
  - status icon：顯示狀態文字 fallback。
  - relic icon：不顯示 icon，但保留 relic 名稱。

## 卡牌主視覺

正式路徑：

```text
res://assets/cards/subaru/<card_id>.png
res://assets/cards/botan/<card_id>.png
res://assets/cards/azki/<card_id>.png
```

目前第一批已接：

```text
res://assets/cards/subaru/subaru-strike.png
res://assets/cards/subaru/subaru-guard.png
res://assets/cards/subaru/subaru-duck-rush.png
res://assets/cards/subaru/subaru-draw-breath.png
res://assets/cards/subaru/subaru-tsukkomi.png
res://assets/cards/botan/botan-shot.png
res://assets/cards/botan/botan-cover.png
res://assets/cards/botan/botan-burst.png
res://assets/cards/botan/botan-reload.png
res://assets/cards/botan/botan-mark.png
```

接線位置：

- `scripts/data/RuntimeDatabase.gd`
- 常數：`CARD_ART_PATHS`

新增卡圖範例：

```gdscript
const CARD_ART_PATHS := {
	"subaru-blue-wave": "res://assets/cards/subaru/subaru-blue-wave.png"
}
```

注意事項：

- key 必須等於卡牌 id。
- `RuntimeDatabase._tag_card_metadata()` 會依 `CARD_ART_PATHS` 自動補 `card["art_path"]`。
- 2026-05-13 起，AZKi 卡圖就算暫時還沒正式列進 `CARD_ART_PATHS`，只要檔案放在 `res://assets/cards/azki/<card_id>.png`，`RuntimeDatabase` 也會自動把 `art_path` 接上。
- 所有卡牌現在都會補 `expected_art_path`；若正式圖檔尚未存在，`art_path` 會維持空字串，UI 仍顯示 `ART` placeholder。
- `CombatCardView` 會在 `art_path` 有效時顯示 `CardArtTexture`。
- 未列入 `CARD_ART_PATHS` 的卡仍會顯示 `ART` placeholder。

建議生成規格：

- 透明 PNG。
- 無文字、無卡牌外框、無費用數字。
- 圖像只畫卡牌事件主視覺，外框、卡名、費用、描述由 `CombatCardView` 負責。
- 橫向或方形都可；目前 UI 使用 `TextureRect.STRETCH_KEEP_ASPECT_COVERED` 放進圖片槽。

## 敵人 Intent Icon

正式路徑：

```text
res://assets/icons/intent/<intent_type>.png
```

目前已接：

```text
res://assets/icons/intent/attack.png
res://assets/icons/intent/block.png
res://assets/icons/intent/attack_block.png
res://assets/icons/intent/buff.png
res://assets/icons/intent/debuff.png
```

接線位置：

- `scripts/data/RuntimeDatabase.gd`
- 常數：`INTENT_ICON_PATHS`

新增 intent icon 範例：

```gdscript
const INTENT_ICON_PATHS := {
	"summon": "res://assets/icons/intent/summon.png"
}
```

注意事項：

- key 必須等於 enemy action 的 `type`。
- `RuntimeDatabase._tag_enemy_metadata()` 會依 action type 自動補 `action["icon_path"]`。
- `ActorStatusView` 會在 `icon_path` 有效時顯示 `IntentIconTexture`。
- 若圖不存在，會回到 `⚔`、`▣`、`⚔▣`、`↑`、`↓` 等文字 fallback。

建議生成規格：

- 128x128 透明 PNG。
- 無文字、無數字、無 UI 外框。
- 在 24x24 或 32x32 下仍要清楚。

## Relic Icon

正式路徑：

```text
res://assets/icons/relic/<relic_id>.png
```

接線位置：

- `scripts/data/RuntimeDatabase.gd`
- 常數：`RELIC_ICON_PATHS`

目前 V4.2 已為 18 個 relic 全部接上 icon。新增 relic 時要同步補：

```gdscript
const RELIC_ICON_PATHS := {
	"new-relic-id": "res://assets/icons/relic/new-relic-id.png"
}
```

注意事項：

- key 必須等於 relic id。
- `RuntimeDatabase._tag_relic_metadata()` 會依 `RELIC_ICON_PATHS` 自動補 `relic["icon_path"]`。
- 戰鬥 header relic summary 會顯示目前持有 relic 的小 icon + 名稱。
- 商店 relic 商品會在卡牌圖片槽顯示 relic icon。
- 若圖不存在，功能不應壞掉，只是不顯示 icon。

建議生成規格：

- 128x128 透明 PNG。
- 無文字、無數字、無 UI 外框。
- 在 18x18、32x32、48x48 下仍要清楚。

## Status Icon

正式路徑：

```text
res://assets/icons/status/<status_id>.png
```

目前正式接入 gameplay 的只有：

```text
res://assets/icons/status/strength.png
res://assets/icons/status/weak.png
res://assets/icons/status/vulnerable.png
res://assets/icons/status/regen.png
```

接線位置：

- `scripts/data/RuntimeDatabase.gd`
- 常數：`STATUS_ICON_PATHS`
- `scripts/ui/ActorStatusView.gd` 也保留同一批 fallback path。

注意事項：

- 不要只因為有圖就新增 gameplay 狀態。
- `burn`、`poison`、`stun`、`draw` 目前只是生成備份，尚未接入 CombatEngine。
- 若要新增正式狀態，除了 icon，還要同步設計 CombatEngine 規則、duration / stack、卡牌或敵人效果、UI 文字與測試。

## 角色動作圖

正式路徑：

```text
res://assets/characters/subaru/<action>/sheet-transparent.png
res://assets/characters/botan/<action>/sheet-transparent.png
```

現有 action：

```text
idle
normal_attack
defense
hurt
tsukkomi
shooting_skill
```

注意事項：

- 新角色動作圖預設做成 3x3 / 9 幀，透明背景。
- 標準 sheet 建議 768x768，每格 256x256。
- 大型正方形 sheet 也會預設以 3x3 / 9 幀讀取。
- 既有 256x256 / 512x512 舊 sheet 會維持 2x2 / 4 幀相容。
- 角色腳底 / pivot 要穩定，避免播放時上下跳動。
- 新動作要先確認卡牌 `animation` 是否會使用該 action。

卡牌使用角色動作的位置：

- `scripts/data/RuntimeDatabase.gd`
- 卡牌欄位：`animation`

範例：

```gdscript
{ "id": "subaru-tsukkomi", "animation": "tsukkomi" }
```

## 生成與後處理流程

使用 `$generate2dsprite` 時：

1. raw 圖必須由 image generation 產生。
2. raw 圖使用 solid `#FF00FF` 背景。
3. 用 `generate2dsprite.py process` 做 magenta cleanup、切格、透明輸出、QC。
4. 檢查 `pipeline-meta.json`：

```json
"edge_touch_frames": []
```

5. 把正式 PNG 複製到 `assets/`。
6. 保留 generated 來源資料夾作備份。

## Godot Reimport

新增或覆蓋 `assets/` 圖片後跑：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --editor --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --quit
```

這會產生或更新 `.import` 與 `.godot/imported/*.ctex`。

## 必跑驗收

資料與素材路徑：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/runtime_database_tests.gd
```

UI 顯示：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_ui_layout_tests.gd
```

戰鬥規則防回歸：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --script res://tests/headless/combat_engine_tests.gd
```

專案載入：

```bash
/Users/zhangzhipeng/Downloads/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhangzhipeng/MyProject/oshi-no-tower-godot --quit
```

## 手動 QA 快捷鍵

- `2`：Subaru 開局，確認卡牌與角色動作。
- `3`：Botan 開局，確認卡牌與角色動作。
- `4`：普通戰，確認 intent icon、status icon、手牌 hover。
- `7`：菁英戰，確認勝利後 relic 獎勵與 header relic icon。
- `9`：商店，確認 relic 商品 icon。
- `-`：取得下一個未持有 relic。

## 常見錯誤

- 圖放在 `generated/sprites/` 但沒有複製到 `assets/`：Godot runtime 不應依賴 generated 路徑。
- 忘記跑 Godot reimport：`ResourceLoader.exists()` 可能找不到新圖。
- 只新增 PNG，忘記補 `RuntimeDatabase.gd` 對照表：UI 仍會顯示 placeholder。
- status icon 已生成，但 CombatEngine 沒有狀態規則：不要接成正式狀態。
- 卡圖含文字或卡框：會和 `CombatCardView` 的卡名、費用、描述重疊。
