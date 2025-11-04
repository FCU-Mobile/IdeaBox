# Implementation Plan: 將 IdeaBox 遷移至 SwiftData 並啟用 iCloud 同步

**Branch**: `001-swiftdata-icloud-sync` | **Date**: 2025-11-04 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-swiftdata-icloud-sync/spec.md`

## Summary

遷移 IdeaBox 應用從 @State 記憶體存儲至 SwiftData 持久化框架，並啟用原生 CloudKit 同步支援。此遷移確保：
1. **本機持久化** (P1)：所有靈感自動保存至 SwiftData，應用重啟後完整保留
2. **跨裝置同步** (P1)：靈感在登入相同 iCloud 帳戶的多台裝置間自動同步（≤5 秒延遲）
3. **無縫過渡** (P2)：現有本機靈感無損啟用 iCloud 同步，無需使用者干預
4. **自動 CloudKit 初始化** (P2)：偵測 iCloud 狀態並自動初始化同步，無手動設定
5. **現有功能保留** (P2)：搜尋、篩選、完成狀態等功能基於 SwiftData 查詢

**技術方案**：利用 SwiftData 的原生 CloudKit 支援 + @Query 宏進行 UI 綁定，避免手動 CloudKit 配置的複雜性。

## Technical Context

**Language/Version**: Swift 6.2、iOS 26+
**Primary Dependencies**: 
- SwiftData（Apple 原生數據持久化框架）
- CloudKit（Apple iCloud 同步服務）
- SwiftUI（現有 UI 框架，無變更）
- Swift Testing（單元測試，遵循憲章）

**Storage**: 
- 本機：SwiftData（SQLite 後端）
- 遠端：CloudKit（iCloud 私有資料庫）
- 配置：ModelContainer 啟用 CloudKit 同步（`.cloudKitContainer(identifier: "com.buildwithharry.IdeaBox")` 模式）

**Testing**: 
- 單元測試：Swift Testing + mock CloudKit（MockModelContainer）
- UI 測試：Xcode UITesting（模擬多裝置同步場景）
- 目標涵蓋率：≥ 85%（關鍵流程 100%）

**Target Platform**: iOS 26+（iPhone 與 iPad，直橫向）

**Project Type**: iOS 單一應用（IdeaBox.xcodeproj）

**Performance Goals**:
- 搜尋：≤ 500ms（500 筆靈感時）
- 同步延遲：平均 ≤ 5 秒，最大 10 秒
- UI 反應：列表操作 60fps，無卡頓
- 啟動時間：< 2 秒（冷啟動，含 CloudKit 初始化）

**Constraints**:
- 離線支援：飛行模式下操作應本機快取，網路恢復後 30 秒內同步
- 衝突解決：自動採用 Last Write Wins（時間戳），無使用者提示
- CloudKit 免費額度：≤ 1000 筆靈感/使用者，每筆 ≤ 10KB
- 向後相容：現有本機 SwiftData 無損遷移至 CloudKit 後端

**Scale/Scope**:
- MVP：5 個使用者故事（P1 × 2，P2 × 3）
- 預期代碼量：500-700 行新增（服務層、模型擴展、測試）
- 檔案拆分：模型層、服務層、測試層各 3-5 個檔案
- 預期超過 200 行：AppDelegate CloudKit 初始化（拆分為 CloudKitService）

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### 原則一：簡潔體驗優先

- [x] 主要流程步驟數已列出
  - **新增靈感流程**：3 步驟（點擊 +、輸入、儲存）
  - **編輯靈感流程**：3 步驟（點擊靈感、修改、自動儲存）
  - **勾選完成流程**：1 步驟（點擊勾選框，即時同步）
  - 所有流程 ✅ 符合三步驟內完成原則

- [x] SwiftUI 原生元件 + iOS HIG 合規
  - 使用 `@Observable`、`NavigationStack`、`@Query`（SwiftData）
  - 支援動態字體、深色模式（現有支援，無變更）
  - VoiceOver：靈感列表項有 accessibilityIdentifier，搜尋欄有 accessibilityLabel
  
- [x] 可用性巡檢清單已準備
  - 空狀態：無靈感時顯示"沒有靈感"提示
  - 邊界資料：100+ 筆靈感時效能驗證
  - 錯誤訊息：iCloud 不可用時顯示"本機模式"提示（中文）

**結論**：✅ 原則一 PASS

### 原則二：全面測試驅動

- [x] Swift Testing 單元測試計畫已制定
  - `IdeaDataPersistenceTests.swift`：SwiftData 基礎操作（新增、編輯、刪除）
  - `IdeaCloudSyncTests.swift`：CloudKit 同步邏輯（上傳、下載、衝突）
  - `IdeaDataPreservationTests.swift`：無縫遷移（現有資料保留）
  - `CloudKitSetupTests.swift`：iCloud 偵測與初始化
  - `IdeaQueryTests.swift`：搜尋與篩選查詢

- [x] UI 測試計畫已制定
  - `IdeaBoxUITests.swift` 擴充：多裝置同步場景（需兩台模擬器或實機）
  - 快照測試：靈感列表、搜尋結果、完成狀態

- [x] 覆蓋率目標與測試計畫
  - 目標：≥ 85% 行覆蓋率
  - 關鍵互動（新增、勾選、刪除、同步）：100% 覆蓋
  - PR 前執行 `xcodebuild test`，附上覆蓋率報告

**結論**：✅ 原則二 PASS

### 原則三：模組化目錄紀律

- [x] 資料夾結構計畫（詳見 Project Structure）
  ```text
  IdeaBox/
  ├── Models/
  │   ├── Idea.swift          # @Model 標記，支援 CloudKit
  │   └── SyncMetadata.swift  # 同步中繼資料
  ├── Services/               # 新建
  │   ├── CloudKitService.swift       # CloudKit 初始化與狀態管理
  │   ├── SyncCoordinator.swift       # 同步協調邏輯
  │   └── ConflictResolver.swift      # 衝突解決
  ├── Views/                  # 現有，無需異動
  │   ├── AllIdeasView.swift  → 遷移至 @Query
  │   ├── SearchView.swift    → 遷移至 @Query
  │   └── ...
  ├── Shared/
  │   └── IdeaModels.swift    # 共用模型定義
  └── IdeaBoxApp.swift        # 新增 ModelContainer 初始化
  ```

- [x] 模組職責清晰
  - Models：資料模型 (@Model)
  - Services：CloudKit、同步、衝突解決
  - Views：UI 呈現（無邏輯變更）

**結論**：✅ 原則三 PASS

### 原則四：檔案輕量與責任分離

- [x] 超過 200 行檔案識別與拆分策略
  
  | 檔案 | 預期行數 | 拆分方案 |
  |------|--------|--------|
  | `Idea.swift` | 150 | 保持（核心模型）|
  | `IdeaBoxApp.swift` | 180 | 新增模型容器初始化；CloudKit 邏輯拆分至 `CloudKitService.swift` |
  | `ContentView.swift` | 100 | 無需異動 |
  | `AllIdeasView.swift` | 120 | 遷移至 @Query；查詢邏輯改用 SwiftData（無代碼增加） |
  | `CloudKitService.swift` | 150-180 | 拆分為 `CloudKitManager.swift`（初始化）+ `SyncCoordinator.swift`（邏輯） |

- [x] 檔案註解與責任明確
  - 每個檔案頂部中文註解說明用途
  - 模型層：資料格式與驗證規則
  - 服務層：同步與衝突解決邏輯

**結論**：✅ 原則四 PASS（含拆分計畫）

### 原則五：正體中文敘述與註解

- [x] UI 文案全中文
  - 現有文案保留（無修改）
  - 新增提示："本機模式（iCloud 不可用）"、"同步中..."、"衝突已自動解決"（開發日誌）

- [x] 測試敘述全中文
  - Swift Testing 測試案例名稱：`test靈感新增後應在資料庫中存在()`
  - 断言訊息中文：`XCTAssert(idea.isCompleted, "靈感完成狀態應已更新")`

- [x] 註解與文件中文
  - 服務層複雜邏輯附中文註解
  - 同步算法與衝突解決有詳細中文說明

**結論**：✅ 原則五 PASS

---

## Constitution Check Summary

✅ **所有 5 項原則已確認 PASS，無違規。** 

可進入 Phase 0 研究與設計階段。

## Project Structure

### Documentation (this feature)

```text
specs/001-swiftdata-icloud-sync/
├── plan.md                      # 本檔案 (/speckit.plan 產出)
├── research.md                  # Phase 0 研究產出（SwiftData/CloudKit 最佳實踐）
├── data-model.md                # Phase 1 資料模型設計
├── quickstart.md                # Phase 1 快速開始指南
├── contracts/                   # Phase 1 API 契約 (N/A - iOS 應用)
└── checklists/requirements.md   # 規格品質檢查清單
```

### Source Code Structure（iOS 應用單一專案）

**選擇方案**：Option 1 (Single iOS Project) - IdeaBox 既有 Xcode 工程

```text
IdeaBox/                         # 應用主目錄
│
├── IdeaBox/                     # 應用源代碼
│   │
│   ├── Models/                  # 資料模型層
│   │   ├── Idea.swift          # @Model 靈感模型（新增 CloudKit 支援）
│   │   └── SyncMetadata.swift   # [新建] 同步中繼資料模型
│   │
│   ├── Services/                # [新建] 服務層
│   │   ├── CloudKitService.swift        # CloudKit 初始化與狀態管理（150 行）
│   │   ├── SyncCoordinator.swift        # 同步邏輯協調（180 行）
│   │   └── ConflictResolver.swift       # 衝突解決策略（100 行）
│   │
│   ├── Views/                   # UI 視圖層（現有，遷移至 @Query）
│   │   ├── ContentView.swift            # [修改] 新增 ModelContainer 環境修飾
│   │   ├── AllIdeasView.swift           # [修改] @Query 取代 @Binding
│   │   ├── SearchView.swift             # [修改] @Query 取代 @Binding
│   │   ├── CompletedIdeasView.swift     # [修改] @Query 取代 @Binding
│   │   ├── IdeaRow.swift                # [無變更]
│   │   ├── AddIdeaSheet.swift           # [無變更]
│   │   └── [其他視圖]
│   │
│   ├── Shared/                  # 共用資源
│   │   └── Localization/        # 本地化資源（正體中文）
│   │
│   ├── IdeaBoxApp.swift         # [修改] App 進入點 + ModelContainer 初始化
│   └── Assets.xcassets/         # 視覺資源（無變更）
│
├── IdeaBoxTests/                # 單元測試（新增/擴充）
│   ├── IdeaDataPersistenceTests.swift    # [新建] SwiftData 基礎操作測試
│   ├── IdeaCloudSyncTests.swift          # [新建] CloudKit 同步邏輯測試
│   ├── IdeaDataPreservationTests.swift   # [新建] 資料保留測試
│   ├── CloudKitSetupTests.swift          # [新建] CloudKit 初始化測試
│   ├── IdeaQueryTests.swift              # [新建] SwiftData 查詢測試
│   └── [現有單元測試]
│
├── IdeaBoxUITests/              # UI 測試（擴充）
│   ├── IdeaBoxUITests.swift             # [修改] 新增多裝置同步場景
│   └── IdeaBoxUITestsLaunchTests.swift  # [無變更]
│
├── IdeaBox.xcodeproj/           # Xcode 工程配置
│   └── [schemes、簽署身份、Capabilities for CloudKit]
│
└── README.md、CHANGELOG.md 等文檔
```

**結構決策說明**：
- **單一 iOS 應用專案**：IdeaBox 既有工程結構，無需分割為多個 target
- **模型層增強**：`Idea.swift` 新增 `@Model`、`@Attribute`、CloudKit 屬性（`createdAt`, `updatedAt`, `lastModifiedBy`）
- **服務層新建**：`Services/` 目錄承載 CloudKit、同步、衝突解決邏輯（原則三：模組化）
- **視圖層遷移**：保留現有 UI 結構，僅更新資料綁定從 `@Binding` 至 `@Query`
- **測試層擴充**：新增 5 個測試檔案，覆蓋 SwiftData/CloudKit 全流程

**檔案行數預期**：
| 檔案 | 現有行數 | 新增行數 | 目標行數 | 拆分策略 |
|------|---------|--------|--------|--------|
| `Idea.swift` | 50 | 20 | 70 | 保持（<200） |
| `IdeaBoxApp.swift` | 30 | 50 | 80 | 保持；CloudKit 邏輯拆分至 `CloudKitService.swift` |
| `AllIdeasView.swift` | 80 | 0 | 80 | @Query 取代 @Binding，代碼淨減 |
| `ContentView.swift` | 45 | 5 | 50 | 新增環境修飾（modelContainer）|
| `CloudKitService.swift` | - | 150 | 150 | [新建] 單獨服務 |
| `SyncCoordinator.swift` | - | 180 | 180 | [新建] 拆分超過 200 行的邏輯 |

---

---

## Phase 0: Research & Unknowns

**目標**：解決所有技術不確定性，確保 Phase 1 設計清晰無誤。

### 已解決的澄清項（Spec 確認）

1. ✅ **iCloud 容器存取範圍** → Option A：單一使用者容器
   - CloudKit 配置使用應用 Bundle ID 私有容器
   - 資料隔離：每個 iCloud 帳戶完全獨立

2. ✅ **舊版資料來源** → Custom：舊版已使用 SwiftData
   - 新版需無縫啟用 CloudKit 同步
   - 現有本機 SwiftData 資料保留

3. ✅ **衝突解決策略** → Option A：自動解決（Last Write Wins）
   - 時間戳決定版本優先級
   - 對使用者完全透明，記錄供開發診斷

### 研究任務

| # | 任務 | 狀態 | 預期產出 |
|---|------|------|--------|
| R1 | SwiftData 最佳實踐（持久化、@Query、@Model） | 📋 待研究 | 實作指南、程式片段 |
| R2 | CloudKit 同步配置（ModelContainer、SyncEngine） | 📋 待研究 | 配置步驟、錯誤處理 |
| R3 | 多裝置同步測試策略（模擬器、實機） | 📋 待研究 | 測試計畫、工具鏈 |
| R4 | 衝突解決演算法（LastWriteWins、時間戳比較） | 📋 待研究 | 虛擬代碼、測試案例 |
| R5 | 離線隊列與重試機制 | 📋 待研究 | 隊列設計、失敗恢復 |
| R6 | iOS 無障礙 (VoiceOver) 與 SwiftData 集成 | 📋 待研究 | 測試清單 |

**Phase 0 產出**：`research.md` 將包含每項任務的決策、理由與替代方案。

---

## Phase 1: Design & Data Model

**前置條件**：Phase 0 研究完成

### Data Model (`data-model.md` 產出)

#### Idea 模型（擴展）

```swift
@Model 
final class Idea {
    // 基礎屬性
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    
    // 同步相關屬性（CloudKit）
    var createdAt: Date
    var updatedAt: Date          // Last-Write-Wins 時間戳
    var lastModifiedBy: String   // CloudKit 裝置 ID
    
    // 初始化
    init(id: UUID = UUID(), title: String, description: String, 
         isCompleted: Bool = false) { ... }
}
```

**驗證規則**：
- `title`：非空，≤ 200 字
- `description`：≤ 5000 字
- `id`：全域唯一
- `updatedAt` ≥ `createdAt`

**狀態轉換**：
```
建立 → 未完成 ↔ 已完成 → 刪除
       (同步、編輯) 
```

#### SyncMetadata 模型（新建）

```swift
@Model
final class SyncMetadata {
    var lastSyncDate: Date
    var conflictLog: [ConflictRecord]
    var isSyncEnabled: Bool      // CloudKit 是否已啟用
    var lastCloudKitError: String?
}

struct ConflictRecord: Codable {
    let ideaId: UUID
    let conflictTime: Date
    let localVersion: IdeaSnapshot
    let remoteVersion: IdeaSnapshot
    let resolution: String       // "Local", "Remote", "Merged"
}
```

### API 契約（N/A）

iOS 應用無外部 API；SwiftData/CloudKit 為本地/同步層。

### 快速開始指南（`quickstart.md` 產出）

1. 將 `Idea.swift` 標記為 `@Model`
2. 在 `IdeaBoxApp.swift` 初始化 ModelContainer（啟用 CloudKit）
3. 在視圖中用 `@Query` 取代 `@Binding`
4. 部署 `CloudKitService`、`SyncCoordinator`、`ConflictResolver`
5. 執行測試套件

### 代理上下文更新

執行命令：
```bash
.specify/scripts/bash/update-agent-context.sh copilot
```

更新內容：
- 新增 SwiftData 和 CloudKit 技術棧標記
- 記錄單一使用者容器決策
- 標記測試覆蓋需求（85%+）

---

## 後續步驟

**進行 `/speckit.tasks` 工作流**以：
1. 產生詳細工作分解結構（WBS）
2. 估算每項工作的工期
3. 識別依賴與關鍵路徑
4. 排定衝刺計畫與里程碑

---
