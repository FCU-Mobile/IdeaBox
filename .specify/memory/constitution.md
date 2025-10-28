<!--
Sync Impact Report
Version change: N/A → 1.0.0
Modified principles: 新增 — 原則一：簡潔體驗優先; 新增 — 原則二：全面測試驅動; 新增 — 原則三：模組化目錄紀律; 新增 — 原則四：檔案輕量與責任分離; 新增 — 原則五：正體中文敘述與註解
Added sections: Core Principles; 工程標準; 開發流程; Governance
Removed sections: None
Templates requiring updates: ✅ .specify/templates/plan-template.md; ✅ .specify/templates/spec-template.md; ✅ .specify/templates/tasks-template.md
Follow-up TODOs: 無
-->

# IdeaBox Constitution

## Core Principles

### 原則一：簡潔體驗優先
- 任何主要使用流程必須在三個互動步驟內完成，新增流程需於規格書中列出步驟數並說明簡化方案。
- 介面必須採用 SwiftUI 原生元件並遵循 iOS 人機介面準則，確保動態字體、深色模式與 VoiceOver 完整運作。
- 在提交前須執行可用性巡檢：檢查空狀態、邊界資料與錯誤訊息皆以正體中文提供。
**Rationale**: IdeaBox 的核心價值為快速捕捉靈感，流程過程越短越能維持使用者專注與滿意度。

### 原則二：全面測試驅動
- 所有新功能必須使用 Swift Testing 撰寫對應的單元測試，並搭配 UI 測試案例於實作前確認失敗紅燈。
- `IdeaBoxTests` 需維持整體行覆蓋率 ≥ 85%，關鍵互動（新增、勾選、刪除）必須以 Swift Testing 為主，並輔以 UI 測試與快照驗證。
- 每次合併前須在最新 Xcode 版本執行 `xcodebuild test`，確認 Swift Testing 與 UI 測試皆通過，並附上測試結果摘要。
**Rationale**: 穩定的測試基礎確保功能迭代不會回歸，並允許快速驗證使用體驗。

### 原則三：模組化目錄紀律
- 功能程式碼必須依領域落在 `IdeaBox/Models`, `IdeaBox/Views`, `IdeaBox/Services`（新增時建立）或 `IdeaBox/Features/<FeatureName>` 等目錄，禁止在根目錄新增零散檔案。
- 每個新功能需在規劃文件中定義資料夾與檔案名稱，避免多個責任集中於單一模組。
- 共用元件或樣式統一放置於 `IdeaBox/Shared`（若不存在則先在計畫中說明並建立），並附對應 README 指示使用方式。
**Rationale**: 清晰結構讓團隊可快速定位責任區塊，減少交叉依賴與維護成本。

### 原則四：檔案輕量與責任分離
- 任一 Swift 檔案超過 200 行或包含多於一個主要型別時，必須拆分成多個檔案或子視圖，並在 PR 描述內說明拆分策略。
- 每個檔案需包含以正體中文撰寫的高階註解，說明該檔案負責的使用者情境或資料流。
- 當需要例外時，需在實作計畫與 PR 內提出時程與 refactor 責任人，並於下一個衝刺修正。
**Rationale**: 輕量檔案提升可讀性與可維護性，使審查與測試更有效率。

### 原則五：正體中文敘述與註解
- 所有使用者可見文字、測試敘述、註解與文件必須使用正體中文，必要時提供英文對照並置於同行括號內。
- 新增或修改 UI 時需更新本地化資源（`.strings` 或 `LocalizedStringKey`）並在 PR 中標註內容變更。
- 若引用外語專有名詞，需於註解內提供中文解釋及來源連結。
**Rationale**: 以正體中文呈現可確保團隊與使用者共享語境，降低溝通成本並滿足在地化要求。

## 工程標準
- 平台：iOS 26+，需同時支援 iPhone 與 iPad 直向／橫向模式。
- 語言與框架：Swift 5.10 以上、SwiftUI、`@Observable` 狀態模型、`NavigationStack` 導航、Liquid Glass 材質效果。
- 測試：使用 Swift Testing 進行單元與流程驗證，UI 層採用 Xcode UITesting（XCUITest）；關鍵流程需提供自動化測試步驟與期望結果敘述。
- 效能：清單操作與動畫維持 60fps，新增或切換狀態需即時回饋，任何操作延遲超過 200 毫秒需在計畫中提出優化方案。
- 無障礙：VoiceOver、動態字體、顏色對比與操作提示須經實測並在測試報告中記錄。

## 開發流程
1. 以 `/speckit.specify` 產出的規格為基礎，確保使用者故事、測試案例與 UI 文案皆為正體中文。
2. 在 `/speckit.plan` 計畫中明確列出資料夾與檔案拆分策略，並提前標示可能超過檔案行數限制之區塊。
3. 實作前撰寫或更新單元／UI 測試，遵循紅燈→綠燈→重構節奏，確保測試涵蓋所有驗證點。
4. Code review 必須檢查：流程步驟數、測試完整性、模組化結構、檔案行數與中文文案；未達標準不得合併。
5. 釋出前執行完整測試並更新 `CHANGELOG` 或同等發佈文件，摘要使用者可見變更與測試結果。

## Governance
- 本憲章為專案最高準則；任何衝突文件須更新以符合本憲章。
- 憲章修訂需由兩位以上維運者審核，同步更新版本號、修訂日期與套用範圍；重大變更須記錄於版本控制提交訊息。
- 版本控管遵循語意化：加入原則或重大調整→MINOR；限制更動或移除原則→MAJOR；文字澄清→PATCH。
- 每次發佈前由指定維運者進行合規巡檢，確認測試報告、結構與本地化符合原則，並於會議記錄存證。
- 未遵循原則之例外需於兩週內提出補救計畫與完成期限，逾期視為違規並不得進入下一開發循環。

**Version**: 1.0.0 | **Ratified**: 2025-10-29 | **Last Amended**: 2025-10-29
