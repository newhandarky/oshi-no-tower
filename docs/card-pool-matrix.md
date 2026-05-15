# Card Pool Matrix v0

最近更新：2026-05-08

本文件整理 Subaru / Botan 的卡牌內容矩陣。這是下一輪擴充卡牌資料前的設計依據；目前先規劃，不直接新增 Power、Status、Curse 或複雜新效果。

## 目前效果限制

第一輪卡牌擴充只使用既有 CombatEngine 支援的效果：

- `damage`
- `block`
- `draw`
- `energy`

暫不新增：

- Power 牌。
- Status / Curse。
- debuff / buff。
- exhaust / discard synergy。
- 多敵人 target。
- 隨機效果。

## 卡牌類型對應

目前程式中的 `kind` 暫時維持：

| kind | 規劃語意 | UI 色系 |
| --- | --- | --- |
| `attack` | 傷害牌 | 紅色系 |
| `defense` | 格擋牌 | 藍色系 |
| `support` | 抽牌、能量、節奏輔助 | 綠色系 |
| `mixed` | 傷害 + 防禦，或防禦 + 能量等混合效果 | 紫色系 |

未來若導入 StS 風格 type，可再分 attack / skill / power；但目前不急著改 schema。

## Subaru 卡池方向

核心定位：低費、多段、節奏型。

### 現有卡牌

| id | 名稱 | 定位 | 評估 |
| --- | --- | --- | --- |
| `subaru-strike` | 節奏拳 | Basic attack | 低費基本輸出，可保留作基準線。 |
| `subaru-guard` | 團隊防守 | Basic defense | 低費基本格擋，可保留。 |
| `subaru-duck-rush` | 鴨式連打 | 多段 attack | 很符合 Subaru，多段 identity 應保留。 |
| `subaru-draw-breath` | 調整呼吸 | support | 0 費抽牌 + 能量，節奏感強，需注意不要太強。 |
| `subaru-tsukkomi` | 吐槽爆擊 | 2 費多段爆發 | 可作為中高價值攻擊牌。 |
| `subaru-second-wind` | 重新站穩 | mixed | 防禦 + 能量，適合作為節奏恢復牌。 |

### 第一輪缺口

Subaru 需要補：

- 1-2 張低費補刀牌。
- 1 張多段但低單hit傷害牌。
- 1 張抽牌 / 能量節奏牌，但不能比 `調整呼吸` 更無腦。
- 1 張中等格擋牌，避免只靠基本防守。
- 1 張混合牌，強化「打很多張」的體感。

### 建議新增候選

| 暫定 id | 暫定名稱 | kind | cost | 效果方向 | 設計意圖 |
| --- | --- | --- | --- | --- | --- |
| `subaru-quick-retort` | 快速吐槽 | attack | 0 | 小量 damage | 補刀與維持出牌節奏。 |
| `subaru-rhythm-guard` | 節奏防守 | defense | 1 | 中量 block | 讓 Subaru 有比 basic 稍好的防禦選擇。 |
| `subaru-cheer-loop` | 應援循環 | support | 1 | draw + 小量 energy 或 draw 2 | 強化節奏，但需避免 0 費無限感。 |
| `subaru-duck-step` | 鴨步閃身 | mixed | 1 | block + 小 damage | 低費混合牌，讓回合更靈活。 |
| `subaru-team-rush` | 團隊連衝 | attack | 2 | 多段 damage | 作為中費多段 payoff。 |

## Botan 卡池方向

核心定位：高單發、防禦穩、射擊感。

### 現有卡牌

| id | 名稱 | 定位 | 評估 |
| --- | --- | --- | --- |
| `botan-shot` | 精準射擊 | Basic attack | 單發傷害較高，符合角色。 |
| `botan-cover` | 掩體防守 | Basic defense | 格擋較高，符合穩定防線。 |
| `botan-burst` | 連續點放 | 2 費 attack | 目前偏多段，仍可視為射擊連發。 |
| `botan-reload` | 快速換彈 | support | 0 費抽牌，符合換彈，但可考慮未來加能量或選牌。 |
| `botan-mark` | 狙擊準備 | mixed | 防禦 + 高單發 | 很符合 Botan，可作為核心 mixed。 |

### 第一輪缺口

Botan 需要補：

- 1 張高單發 2 費攻擊牌。
- 1 張穩定大格擋牌。
- 1 張準備 / 換彈感的 support。
- 1 張防守轉輸出的 mixed。
- 1 張低費但不搶 Subaru identity 的小攻擊。

### 建議新增候選

| 暫定 id | 暫定名稱 | kind | cost | 效果方向 | 設計意圖 |
| --- | --- | --- | --- | --- | --- |
| `botan-heavy-shot` | 重裝一擊 | attack | 2 | 高單發 damage | 強化高單發 identity。 |
| `botan-steady-aim` | 穩定瞄準 | support | 1 | draw 或 energy | 表現準備感，讓 Botan 不只是數字大。 |
| `botan-fortified-cover` | 強化掩體 | defense | 2 | 大量 block | 建立穩定防線。 |
| `botan-counter-line` | 反擊火線 | mixed | 2 | block + damage | 防守後反擊。 |
| `botan-tap-shot` | 輕點射擊 | attack | 1 | 中量 damage | 保留低費行動，但效率不壓過 Subaru 多段節奏。 |

## 獎勵池規劃

下一輪實作時，建議把 reward / shop 從硬編碼清單逐步整理成角色分流：

- Subaru reward pool 只放 Subaru 牌。
- Botan reward pool 只放 Botan 牌。
- 之後才加入 colorless pool。
- 商店可先沿用角色牌池，未來再加入通用工具牌。

第一輪不做 rarity 抽樣，只做「角色池正確 + 數量足夠」。

## 平衡方向

### Subaru

- 平均 cost 較低。
- 單張傷害不要太高，靠多段與多張行動取勝。
- 抽牌與能量牌要小心，不要讓 0 費牌過強。
- 防禦值比 Botan 低，但更靈活。

### Botan

- 單張傷害與格擋較高。
- 2 費牌可以更強，但需要讓玩家做取捨。
- 抽牌與能量不宜太多，避免變成 Subaru 的節奏型玩法。
- mixed 牌可以體現「穩住後開火」。

## 本輪實作狀態

已完成：

- Subaru 新增：`subaru-quick-retort`、`subaru-rhythm-guard`、`subaru-cheer-loop`、`subaru-duck-step`、`subaru-team-rush`。
- Botan 新增：`botan-heavy-shot`、`botan-steady-aim`、`botan-fortified-cover`、`botan-counter-line`、`botan-tap-shot`。
- Reward pool 已角色分流，Subaru 9 張、Botan 8 張。
- Shop pool 已角色分流，Subaru 6 張、Botan 6 張。
- RuntimeDatabase 測試已檢查 reward/shop pool 最低數量、不可重複、不可混入其他角色卡。

## 下一輪實作目標

下一輪程式實作建議：

1. 用 `2` / `3` 分別快速測 Subaru / Botan 手感。
2. 檢查新增卡是否造成卡牌文字過擠或戰鬥節奏過強。
3. 若手感通過，下一輪進入戰鬥後卡牌獎勵流程。
4. 若手感不通過，先調整新增卡牌數值與描述。
