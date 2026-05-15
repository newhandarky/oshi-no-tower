# Chapter Start Event Pool

最近更新：2026-05-14

## Summary

第二章開場事件模仿 Slay the Spire 的章節間祝福 / 交易感，但語意改成 `Holo Support Desk`：玩家通過第一章 Boss 後，支援台提供一組進入第二章前的資源整理選項。

此事件是角色中立，不提供 AZKi 專屬補強。AZKi 平衡之後在卡牌與 reward pool 調整處理。

## Event Contract

- `event_id`：`chapter-2-support-desk`
- `screen_id`：`chapter_start_event`
- 顯示名稱：`Holo Support Desk`
- 說明語氣：通過第一章後的臨時補給台，玩家在進入演算法深層前整理牌組與資源。
- 選項數量：每次顯示 3 個。
- 選項來源：從 option pool 依權重抽取，但必須至少包含 1 個低風險選項。

## Option Pool

| option_id | label | effect | risk tier | notes |
|---|---|---|---|---|
| `support-claim-relic` | 領取支援 relic | 取得 1 個 relic | low | 穩定選項，若 relic pool 已空則改給 Gold |
| `support-gold-dead-air` | 接受演算法補助 | 獲得 Gold 120，加入 `curse-dead-air` | high | 高經濟起跑，污染抽牌與能量 |
| `support-gold-bad-connection` | 接受不穩定贊助 | 獲得 Gold 140，加入 `curse-bad-connection` | high | 金額更高，但留手扣 HP |
| `support-gold-comment-fire` | 開放留言加速 | 獲得 Gold 110，加入 `curse-comment-fire` | high | 易傷風險，適合有移除計畫的 deck |
| `support-remove-card` | 整理牌組 | 移除 1 張牌 | low | 不收 Gold；對所有角色公平 |
| `support-upgrade-card` | 強化核心牌 | 升級 1 張牌 | low | 比 remove 穩定，但不解決牌組污染 |
| `support-relic-for-curse` | 簽下深層合約 | 取得 1 個 relic，加入隨機 curse | high | 強報酬，應低權重 |
| `support-gold-for-hp-cap` | 購買安全通行 | 失去 Gold 60，增加 Max HP 6 | medium | 若 Gold 不足則不出現 |

## Selection Rules

Runtime prototype 規則：

1. 每次顯示 3 個選項。
2. 至少 1 個 low risk。
3. 至少 1 個 resource-heavy option，例如 Gold + curse 或 relic。
4. 不顯示角色專屬選項。
5. 不顯示玩家無法支付的選項，例如 Gold 不足時不顯示 `support-gold-for-hp-cap`。
6. 若玩家 deck 已有 2 張以上 curse，Gold + curse 選項權重降低，但不完全移除。

## Runtime Mapping Notes

既有事件 outcome 已支援：

- `gain_gold`
- `add_card`
- `remove_card`
- `grant_relic`

Runtime prototype 已補：

- `chapter_start_event` screen 的 3 選 1 layout。
- `gain_gold`、`add_card`、`add_random_curse`、`remove_card`、`upgrade_card`、`grant_relic`、`increase_max_hp` outcome。
- chapter start option draft helper，至少含 1 個 low risk，並會排除 Gold 不足選項。

後續 polish：

- 移除卡 / 升級卡目前 runtime prototype 使用第一張可處理卡；正式版可改為指定選牌。
- Gold + curse 權重與數值仍需第二章實玩後調整。

## Balance Notes

- Gold + curse 的金額要足以讓玩家真的心動，否則永遠選 remove / relic。
- Free remove 的價值很高，不應每次都必出；若必出，其他選項要更強。
- Relic + curse 應低權重，避免每局最佳解太固定。
- 不用此事件修正單一角色通關率；角色強弱要回到角色卡與 reward/relic synergy。
