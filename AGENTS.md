# AGENTS.md

## 專案溝通規則

- 本專案的文件、開發紀錄、TODO、狀態摘要，預設使用繁體中文。
- Agent 回覆使用者時，預設使用繁體中文。
- 技術名詞、檔案路徑、Godot API、程式碼符號、錯誤訊息可保留英文原文。
- 若使用者明確要求其他語言，才切換語言。

## 專案狀態入口

- 每次接續開發前，先閱讀 `docs/godot-mvp-status.md`。
- 完成一輪功能或重要決策後，更新 `docs/godot-mvp-status.md`，避免新對話遺失上下文。

## 測試與操作限制

- 除非使用者明確要求，不主動代替使用者執行 GUI / manual QA。
- 除非使用者明確要求，不使用 Browser、Computer Use、Godot editor GUI 或 Demo QA 畫面來操作測試流程。
- 需要驗證時，優先使用 headless / non-GUI 測試；若測試範圍很大，先說明必要性與範圍，再執行。
- 使用者提供的實機體感與通關經驗，可整理成 `player-confirmed evidence` 寫入文件，不要求使用者自行撰寫 QA 報告。

## 目前方向

- 以 Godot 版 MVP 為主。
- 保留 Subaru 與 Botan 皆可遊玩。
- 保留隨機 Boss 設計。
- 優先改善戰鬥 UI、角色差異、Boss 提示與可延續的開發紀錄。
