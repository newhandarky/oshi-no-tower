# 視覺素材尺寸參考

最近更新：2026-05-12

本文記錄目前正式素材的來源尺寸、sprite sheet layout 與 Godot UI 顯示尺寸。後續新增圖片時，優先依此文件對齊；若實機畫面再微調，需同步更新本文件與 `docs/godot-mvp-status.md`。

## 共通規則

- 遊戲 UI 基準解析度：`960x540`，由 `scripts/Game.gd` 的 `BASE_SIZE` 控制。
- `screen_host` 會依實際視窗等比例縮放；本文的顯示尺寸都指 `960x540` 基準座標下的尺寸。
- 透明素材使用 PNG RGBA。
- 背景圖使用 PNG RGB。
- 角色 / 敵人 sprite sheet 由 `Game._add_sprite_sheet()` 讀取：
  - 新動畫圖預設使用 `3x3` / 9 幀。
  - `768x768`、`1024x1024` 等大型正方形 sheet 會以 `3x3` 讀取。
  - 舊 `256x256` / `512x512` sheet 維持 `2x2` 相容。
  - 非正方形 sheet fallback 為 `2x2`。
  - 顯示時以單格 frame 尺寸等比例縮放到指定 `ui_size`。

## 人物素材

正式路徑：

- `res://assets/characters/subaru/<action>/sheet-transparent.png`
- `res://assets/characters/botan/<action>/sheet-transparent.png`

目前主規格：

| 角色 / 動作 | Sheet 來源尺寸 | Layout | 單格尺寸 | 戰鬥顯示 target |
| --- | ---: | ---: | ---: | ---: |
| Subaru `idle` | `768x768` | `3x3` | `256x256` | `178x178` |
| Subaru `normal_attack` | `768x768` | `3x3` | `256x256` | `178x178` |
| Subaru `tsukkomi` | `768x768` | `3x3` | `256x256` | `178x178` |
| Subaru `defense` | `768x768` | `3x3` | `256x256` | `178x178` |
| Subaru `hurt` | `768x768` | `3x3` | `256x256` | `178x178` |
| Botan `idle` | `768x768` | `3x3` | `256x256` | `178x178` |
| Botan `pistol_attack` | `768x768` | `3x3` | `256x256` | `178x178` |
| Botan `sniper_ultimate` | `768x768` | `3x3` | `256x256` | `178x178` |
| Botan `defense` | `768x768` | `3x3` | `256x256` | `178x178` |
| Botan `hurt` | `768x768` | `3x3` | `256x256` | `178x178` |

舊素材仍存在但目前不是主要規格：

| 角色 / 動作 | Sheet 來源尺寸 | Runtime layout | 備註 |
| --- | ---: | ---: | --- |
| Botan `normal_attack` | `512x512` | `2x2` | 舊 4 幀素材 |
| Botan `shooting_skill` | `768x512` | fallback `2x2` | 舊素材；目前 Botan 傷害牌已改用 `pistol_attack` / `sniper_ultimate` |

角色選擇畫面顯示 target：

- Subaru idle：`190x190`
- Botan idle：`190x190`

建議新人物動作圖：

- 使用 `3x3`。
- Sheet：`768x768`。
- 單格：`256x256`。
- 動作主體需完整落在單格內，腳底 / pivot 盡量穩定。
- 若有對話框或特效，仍需留在單格安全範圍內，不可裁邊。

## 敵人與 Boss 素材

正式路徑：

- `res://assets/enemies/ssrb/<variant>/<action>/sheet-transparent.png`
- `res://assets/enemies/subaruto_duck/<action>/sheet-transparent.png`

目前來源規格：

| 類型 | Sheet 來源尺寸 | Runtime layout | 單格尺寸 |
| --- | ---: | ---: | ---: |
| SSRB Gray / Camouflage / White `idle` | `768x768` | `3x3` | `256x256` |
| SSRB Gray / Camouflage / White `attack` | `768x768` | `3x3` | `256x256` |
| SSRB Gray / Camouflage / White `guard` | `768x768` | `3x3` | `256x256` |
| SSRB Gray / Camouflage / White `hurt` | `768x768` | `3x3` | `256x256` |
| SSRB Gray / Camouflage / White `defeat` | `768x768` | `3x3` | `256x256` |
| Subaruto Duck `idle` | `256x256` | `2x2` | `128x128` |
| Subaruto Duck `attack` | `256x256` | `2x2` | `128x128` |
| Subaruto Duck `hurt` | `256x256` | `2x2` | `128x128` |

戰鬥顯示 target：

| 敵人類型 | Runtime scale | 顯示 target |
| --- | ---: | ---: |
| 普通敵人 | `1.0` | `174x174` |
| 菁英雙敵人 | `0.92` | 約 `160x160`，左右各一隻 |
| Boss / 巨大敵人 | `1.5` | `261x261` |

目前多個 meme enemy / boss 仍共用 SSRB sheet，只靠資料中的 `resource_base_path` / `fallback_resource_base_path` 指向既有素材。SSRB `block` / `guard` 動作會映射到 `guard` sheet。

建議新敵人圖：

- 新敵人動畫預設使用 `3x3` sheet、`768x768`、單格 `256x256`。
- Subaruto Duck 舊素材目前仍可維持 `2x2` sheet、`256x256`、單格 `128x128` 相容。
- Boss 若要更精緻，也建議改為 `3x3` sheet、`768x768`、單格 `256x256`，但需同步測試 `_sprite_sheet_grid()` 與顯示 target。

## 卡牌主視覺

正式路徑：

- `res://assets/cards/subaru/<card_id>.png`
- `res://assets/cards/botan/<card_id>.png`

目前來源規格：

- 全部正式卡圖：`512x512` PNG RGBA。
- 目前 Subaru / Botan 全部 37 張卡都有正式卡圖。
- 卡圖不包含文字、費用、卡牌外框或 UI 背景；只畫主視覺。

卡牌 UI 顯示規則位於 `scripts/ui/CombatCardView.gd`：

- `CardArtTexture` 是 `ImageSlot` 的子節點。
- `ImageSlot.clip_contents = true`。
- `CardArtTexture.ignore_texture_size = true`。
- `CardArtTexture` 顯示寬高為 `ImageSlot` 的 `1.25x`，置中後由 `ImageSlot` 裁切。
- 目前這個大小已確認可用，短期不要再改卡圖顯示比例，除非實機 QA 明確要求。

常見卡牌尺寸與圖片槽：

| 使用場景 | 卡牌尺寸 | ImageSlot 約略尺寸 | CardArtTexture 約略尺寸 | 備註 |
| --- | ---: | ---: | ---: | --- |
| 戰鬥手牌一般狀態 | `108x144` | 約 `84x49` | 約 `105x61` | 會被 ImageSlot 裁切 |
| 戰鬥手牌 hover | 約 `178x238` | 約 `140x71` | 約 `176x89` | hover 使用重排後實際尺寸 |
| 戰鬥 reward card | `180x220` | 約 `148x75` | 約 `185x94` | 不啟用 hover |
| Boss reward card | `180x210` | 約 `148x71` | 約 `185x89` | 不啟用 hover |
| 商店 card 商品 | `196x134` | 約 `172x31` | 約 `215x39` | shop mode，圖片槽較扁 |
| 商店 relic 商品 | `306x118` | 約 `282x27` | 約 `353x34` | relic icon 也走 CardArtTexture |

建議新卡圖：

- 生成來源可用 atlas，但正式切出檔仍為單張 `512x512`。
- 主體應放在畫面中央，避免過細文字與小符號。
- 不要畫卡框、費用、卡名、描述文字。
- 縮小後仍需可辨識，因為實際 UI 中只顯示在卡牌上半部圖片槽。

## Status Icon

正式路徑：

- `res://assets/icons/status/<status_id>.png`

目前來源規格：

- `strength`、`weak`、`vulnerable`、`regen`：`128x128` PNG RGBA。

UI 顯示規則位於 `scripts/ui/ActorStatusView.gd`：

- 狀態 icon slot：`20x20`。
- `StatusIconTexture.ignore_texture_size = true`。
- 實際顯示寬高：slot 的 `0.9x`，也就是約 `18x18`。
- 多狀態水平間距：每組 `128px`。
- icon 後文字起點：icon slot 起點 + `26px`。
- status icon 目前使用 Godot 原生 `tooltip_text`，hover 時會顯示狀態說明。

建議新增 status icon：

- 正式檔維持 `128x128`。
- 不要文字、不要外框、不要 UI 背景。
- 主體置中，深色描邊，縮到 18px 時仍可辨識。

## Intent Icon

正式路徑：

- `res://assets/icons/intent/<type>.png`

目前來源規格：

- `attack`、`block`、`attack_block`、`buff`、`debuff`：`128x128` PNG RGBA。

UI 顯示規則位於 `scripts/ui/ActorStatusView.gd`：

- intent icon slot：`24x24`。
- `IntentIconTexture.ignore_texture_size = true`。
- 實際顯示寬高：slot 的 `0.9x`，也就是約 `21.6x21.6`。
- intent 文字起點：`x = 724`，避免與 icon 重疊。
- 若 icon path 遺失，會回到文字 fallback，例如 `⚔ 攻擊 7`。
- intent icon 目前使用 Godot 原生 `tooltip_text`，hover 時會顯示意圖說明。

建議新增 intent icon：

- 正式檔維持 `128x128`。
- 不要文字，圖形需在 22px 左右仍清楚。

## Relic Icon

正式路徑：

- `res://assets/icons/relic/<relic_id>.png`

目前來源規格：

- 18 個 relic icon 皆為 `128x128` PNG RGBA。

目前顯示位置：

| 使用場景 | 顯示方式 |
| --- | --- |
| 戰鬥 header relic icon row | 位於玩家名稱上方，只顯示 icon、不顯示文字；slot `20x20`，實際顯示約 `18x18`，最多顯示 8 個 |
| Map / 非戰鬥 relic summary | 仍使用小 icon + relic 名稱文字 |
| 商店 relic 商品 | 走 `CombatCardView` 的 `CardArtTexture`，放在 shop card 的 `ImageSlot` 中 |

戰鬥 relic icon 目前使用 Godot 原生 `tooltip_text`，hover 時會顯示 relic 名稱與說明。

建議新增 relic icon：

- 正式檔維持 `128x128`。
- 不要文字、不要外框、不要 UI 背景。
- 主體需能在戰鬥 header 的 `18x18` icon 中辨識。

## 背景

正式路徑：

- `res://assets/backgrounds/combat/background.png`
- `res://assets/backgrounds/map/background.png`

目前來源規格：

- Combat background：`1672x941` PNG RGB。
- Map background：`1672x941` PNG RGB。

UI 顯示規則：

- 以 `TextureRect.STRETCH_KEEP_ASPECT_COVERED` 覆蓋整個 `960x540` screen host。
- 背景會被等比例裁切填滿畫面。

建議新增背景：

- 維持接近 16:9。
- 最低建議 `1672x941` 或更高。
- 主要視覺避免放在極邊緣，因為 `KEEP_ASPECT_COVERED` 可能裁切。

## 後續新增素材檢查清單

新增圖片後請確認：

1. 正式檔放在 `assets/`，生成來源保留在 `generated/sprites/`。
2. Godot headless editor reimport 已跑過。
3. `RuntimeDatabase` 對應 `art_path` / `icon_path` 已補。
4. `ResourceLoader.exists()` 測試通過。
5. Combat UI layout 測試通過，確認圖片沒有外溢、重疊或裁到關鍵主體。
6. 若改動人物 / 敵人 sheet layout，需同步確認 `_sprite_sheet_grid()` 推斷是否正確。
