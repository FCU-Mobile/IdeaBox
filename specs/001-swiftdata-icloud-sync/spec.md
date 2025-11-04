# Feature Specification: 將 IdeaBox 遷移至 SwiftData 並啟用 iCloud 同步

**Feature Branch**: `001-swiftdata-icloud-sync`  
**Created**: 2025-11-04  
**Status**: Draft  
**Input**: 使用者需求：「把整個 app 改成 SwiftData，然後需要同步到 iCloud」

## User Scenarios & Testing *(mandatory)*

> 所有敘述、驗收條件與測試說明必須使用正體中文；每個故事需對應至少一個以 Swift Testing 撰寫的自動化測試案例，並標示對應 UI 測試（若有）。

<!--
  IMPORTANT: User stories should be PRIORITIZED as user journeys ordered by importance.
  Each user story/journey must be INDEPENDENTLY TESTABLE - meaning if you implement just ONE of them,
  you should still have a viable MVP (Minimum Viable Product) that delivers value.
  
  Assign priorities (P1, P2, P3, etc.) to each story, where P1 is the most critical.
  Think of each story as a standalone slice of functionality that can be:
  - Developed independently
  - Tested independently
  - Deployed independently
  - Demonstrated to users independently
-->

### User Story 1 - 將靈感資料持久化至 SwiftData (Priority: P1)

使用者在 IdeaBox 中新增、編輯或刪除的靈感必須自動保存至本機 SwiftData 資料庫，即使應用程式重啟後，所有資料仍應完整保留。這是遷移的基礎功能，確保現有使用者體驗不受影響，並為 iCloud 同步做準備。

**Why this priority**: 此為核心遷移功能，所有後續功能皆依賴此基礎。若資料無法正確持久化，將導致使用者資料遺失，直接影響應用穩定性。

**Independent Test**: 
- **Swift Testing**: `IdeaDataPersistenceTests.swift` 應驗證新增靈感時自動保存至 SwiftData、編輯靈感時更新資料庫、刪除靈感時正確移除紀錄、應用重啟後靈感仍存在。
- **UI Testing**: `IdeaBoxUITests.swift` 應驗證使用者新增靈感後返回列表，再次進入應用時該靈感仍存在。

**Acceptance Scenarios**:

1. **Given** 使用者在 All Ideas 頁面，**When** 點擊「+」按鈕並新增一筆「學習 SwiftData」的靈感，**Then** 靈感應立即出現在列表上，且應用重啟後仍存在。
2. **Given** 列表中存在完成的靈感，**When** 使用者勾選該靈感的完成狀態，**Then** 狀態變更應立即反映在 UI 上，應用重啟後完成狀態保持。
3. **Given** 列表中存在靈感，**When** 使用者從左側滑動刪除該靈感，**Then** 靈感應從列表與資料庫中移除，應用重啟後不再出現。
4. **Given** 資料庫中已有 7 筆靈感，**When** 新增第 8 筆靈感，**Then** 所有 8 筆靈感應在應用重啟後完整保留。

---

### User Story 2 - 跨裝置 iCloud 同步 (Priority: P1)

使用者在一台裝置上建立、修改或刪除的靈感應自動同步至 iCloud，其他登入相同 iCloud 帳戶的裝置（iPhone、iPad 等）應在幾秒內自動收到更新。此功能確保使用者的靈感資料在多裝置環境下保持一致。

**Why this priority**: 多裝置同步是 SwiftData 的核心優勢，也是使用者升級至新版本的主要動機。缺少此功能將失去遷移的價值主張。

**Independent Test**: 
- **Swift Testing**: `IdeaCloudSyncTests.swift` 應驗證靈感變更時觸發 iCloud 上傳、從 iCloud 收到遠端變更時合併至本機資料庫、衝突解決邏輯（以最新時間戳為準）。
- **UI Testing**: 需在兩台模擬器或實機上測試，驗證一台裝置上的變更在另一台裝置上自動顯示（`IdeaBoxUITests.swift` 擴充）。

**Acceptance Scenarios**:

1. **Given** 使用者在 iPhone 上登入 iCloud，**When** 新增「參加 iOS 開發工作坊」靈感，**Then** 該靈感應在 5 秒內同步至登入相同 iCloud 帳戶的 iPad 上。
2. **Given** iPad 上存在「完成 Liquid Glass 教學」靈感且未完成，**When** 使用者在 iPhone 上勾選該靈感為完成，**Then** iPad 上該靈感的狀態應在 5 秒內更新為完成。
3. **Given** 使用者在兩台裝置上同時修改同一靈感的描述，**When** 衝突發生，**Then** 系統應自動根據時間戳保留最新版本，對使用者無可見衝突提示，衝突事件記錄供開發調試。
4. **Given** 使用者在飛行模式下刪除靈感，**When** 恢復網路連線，**Then** 刪除應在 10 秒內同步至 iCloud，其他裝置應自動刪除該靈感。

---

### User Story 3 - 無縫啟用 iCloud 同步 (Priority: P2)

現有使用者在本機 SwiftData 中的靈感應在更新後自動與 iCloud 同步。應用應無縫啟用 CloudKit 後端，不丟失任何現有資料，現有本機靈感應逐步同步至使用者的 iCloud 帳戶。

**Why this priority**: 此為使用者體驗關鍵，確保現有 SwiftData 投資不被浪費。若遷移失敗或資料丟失，現有使用者將失去所有靈感，導致負面口碑。

**Independent Test**: 
- **Swift Testing**: `IdeaDataPreservationTests.swift` 應驗證新版本啟動時保留所有本機靈感、CloudKit 同步初始化不丟失資料、本機靈感成功上傳至 iCloud。
- **UI Testing**: `IdeaBoxUITests.swift` 應驗證更新後首次啟動時 All Ideas 頁面顯示所有原有靈感，且靈感在其他已登入 iCloud 的裝置上可見。

**Acceptance Scenarios**:

1. **Given** 使用者在舊版應用中有 7 筆本機 SwiftData 靈感，**When** 更新至新版本啟動應用，**Then** All Ideas 頁面應顯示所有 7 筆靈感，無遺漏。
2. **Given** 舊版中靈感的完成狀態已設定，**When** 新版本啟動，**Then** 每筆靈感的完成狀態應與舊版一致，無重置。
3. **Given** 舊版本地存儲中有靈感，**When** 新版本啟動且 iCloud 已登入，**Then** 本機靈感應在 30 秒內開始同步至 iCloud（可在另一台裝置上看到）。

---

### User Story 4 - 在已有 iCloud 同步帳戶的裝置上啟用 CloudKit 容器 (Priority: P2)

若使用者已在系統偏好設定中啟用 iCloud 並登入帳戶，應用啟動時應自動偵測並初始化 CloudKit 容器。若使用者尚未登入 iCloud，應應用應優雅降級，暫時以本機模式運作，待使用者登入後自動啟用同步。

**Why this priority**: 確保 iCloud 同步對使用者而言是自動的、無需手動設定的體驗。若需要使用者手動設定，將大幅降低功能採用率。

**Independent Test**: 
- **Swift Testing**: `CloudKitSetupTests.swift` 應驗證應用啟動時偵測 iCloud 狀態、CloudKit 容器初始化成功、無 iCloud 帳戶時本機模式運作、使用者登入後自動啟用同步。
- **UI Testing**: 驗證在無 iCloud 帳戶與有 iCloud 帳戶的環境下應用皆可正常運作。

**Acceptance Scenarios**:

1. **Given** 使用者裝置已登入 iCloud，**When** 應用首次啟動，**Then** CloudKit 容器應成功初始化，應用無錯誤提示。
2. **Given** 使用者裝置未登入 iCloud，**When** 應用啟動，**Then** 應用應在本機模式下運作，使用者可正常新增、編輯、刪除靈感。
3. **Given** 使用者首次未登入 iCloud，後來在系統偏好設定中登入，**When** 應用下次啟動，**Then** CloudKit 應自動初始化，同步功能應啟用。

---

### User Story 5 - 保留搜尋、篩選與完成狀態視圖功能 (Priority: P2)

現有的搜尋、已完成靈感篩選、所有靈感列表等功能應在遷移後繼續正常運作，使用者體驗無變化。所有資料操作應基於 SwiftData 查詢。

**Why this priority**: 確保遷移對使用者而言是透明的，不破壞現有工作流。

**Independent Test**: 
- **Swift Testing**: `IdeaQueryTests.swift` 應驗證搜尋功能基於 SwiftData 查詢正確篩選、完成狀態篩選正確、排序邏輯保持（最新優先）。
- **UI Testing**: `IdeaBoxUITests.swift` 應驗證搜尋頁面能正確搜尋遷移後的資料、Completed 頁面正確顯示已完成靈感。

**Acceptance Scenarios**:

1. **Given** All Ideas 列表中有 10 筆靈感（3 筆已完成），**When** 使用者點擊 Search 標籤並搜尋「SwiftData」，**Then** 應顯示標題或描述包含「SwiftData」的靈感。
2. **Given** 已完成 3 筆靈感，**When** 使用者點擊 Completed 標籤，**Then** 應僅顯示 3 筆已完成的靈感。
3. **Given** 新增靈感後，**When** 返回 All Ideas 列表，**Then** 新增的靈感應在列表頂部，且搜尋與篩選應立即涵蓋新靈感。

---

### Edge Cases

- **自動衝突解決**: 若使用者在兩台裝置上同時編輯同一靈感的描述，系統應根據最新時間戳自動保留版本，衝突對使用者透明（無 UI 提示），衝突記錄由系統記載供開發調試。
- **網路斷線**: 使用者在飛行模式下的所有操作應本機快取，網路恢復後應自動同步至 iCloud。
- **CloudKit 額度限制**: 若使用者超過 CloudKit 免費額度，應用應優雅降級為本機模式，並在設定中提示使用者。
- **資料完整性驗證**: 應用啟動時應驗證本機與遠端資料一致性，若檢測到異常應記錄警告日誌。
- **刪除資料恢復**: 若使用者在一台裝置上刪除靈感，其他裝置應在 5 秒內同步刪除；若 30 秒內無確認，應提示使用者此操作不可復原。

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: 系統必須使用 Apple SwiftData 框架替代現有的 @State 記憶體存儲，所有靈感資料應持久化至本機 SwiftData 資料庫。
- **FR-002**: 系統必須在應用啟動時自動初始化 SwiftData 模型容器，支援 iCloud 同步的 CloudKit 後端。
- **FR-003**: 系統必須配置 CloudKit 容器（使用應用 Bundle ID 衍生的容器名稱），以支援單一使用者的靈感同步；每個 iCloud 帳戶的資料隔離完全獨立，無跨帳戶共享功能。
- **FR-004**: 系統必須在本機資料變更時自動上傳至 iCloud，並在接收遠端變更時自動合併至本機資料庫。
- **FR-005**: 系統必須支援多裝置同步，使用者在一台裝置上的操作應在 10 秒內同步至其他登入相同 iCloud 帳戶的裝置。
- **FR-006**: 系統必須提供自動衝突解決機制，當同一靈感在多台裝置上同時修改時，應自動根據時間戳選擇最新版本（Last Write Wins），對使用者完全透明，衝突事件記錄至日誌供開發診斷。
- **FR-007**: 系統必須保留現有 SwiftData 中的所有靈感，新版本啟動時應無縫啟用 iCloud 同步功能，而不重新初始化或丟失任何本機資料。
- **FR-008**: 系統必須在無 iCloud 帳戶的情況下以本機模式運作，所有功能應仍可使用（僅無跨裝置同步）。
- **FR-009**: 系統必須保留所有現有功能（搜尋、篩選、完成狀態切換、新增、編輯、刪除），查詢應基於 SwiftData 而非記憶體陣列。
- **FR-010**: 系統必須支援使用者在系統偏好設定中登入 iCloud 後，應用重啟時自動啟用 CloudKit 同步。
- **FR-011**: 系統必須在模型變更時提供遷移邏輯，確保舊版本資料格式相容或自動升級。
- **FR-012**: 系統必須記錄同步活動日誌（iCloud 上傳、下載、衝突），供開發調試與使用者支援參考。

### Key Entities

- **Idea** (靈感): 
  - 屬性：`id` (UUID)、`title` (String)、`description` (String)、`isCompleted` (Bool)
  - 新增：`createdAt` (Date)、`updatedAt` (Date)、`lastModifiedBy` (String, CloudKit 裝置 ID)
  - SwiftData 特性：需標記 `@Model` 與 `@Attribute` 以支援持久化與 CloudKit 同步
- **SyncMetadata** (同步中繼資料): 
  - 用於追蹤本機與遠端資料版本、上次同步時間、衝突記錄
  - 屬性：`lastSyncDate` (Date)、`conflictLog` ([ConflictRecord])
- **ConflictRecord** (衝突記錄): 
  - 記錄衝突的靈感 ID、衝突時間、本機版本、遠端版本、解決策略

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: 使用者新增、編輯或刪除靈感後，應用重啟時所有操作應完整保留（100% 資料持久化成功率）。
- **SC-002**: 在同一 iCloud 帳戶下，一台裝置上的靈感變更應在另一台裝置上於 10 秒內自動顯示（平均同步延遲 ≤ 5 秒）。
- **SC-003**: 應用首次啟動新版本時，應自動遷移舊資料，使用者無需手動操作（遷移成功率 100%，使用者干預步驟 = 0）。
- **SC-004**: 應用應在無 iCloud 帳戶的環境下正常運作，所有功能可用，僅無跨裝置同步（降級功能可用性 100%）。
- **SC-005**: 在多裝置同時編輯衝突場景中，系統應自動解決衝突（衝突解決率 100%），使用者無需手動選擇版本。
- **SC-006**: 現有功能（搜尋、篩選、完成狀態）應在遷移後保持性能，搜尋時間應 ≤ 500ms（500 筆靈感時）。
- **SC-007**: 應用應正確記錄同步與衝突日誌，支援開發者與技術支援診斷問題（日誌可讀性 = 優，涵蓋所有關鍵事件）。
- **SC-008**: 飛行模式下執行的操作應在網路恢復後 30 秒內同步至 iCloud（離線操作隊列成功率 100%）。
- **SC-009**: 使用者手動登入 iCloud 後，應用應在下次啟動時自動啟用 CloudKit 同步（自動啟用成功率 100%）。
- **SC-010**: 單位測試涵蓋率應 ≥ 85%，所有 SwiftData 與 CloudKit 操作應有對應的 Swift Testing 測試案例。

---

## Assumptions

- 使用者已在系統偏好設定中啟用 iCloud（若未啟用，應用在本機模式下運作，不影響功能）。
- CloudKit 免費額度足以支援一般使用者（≤ 1000 筆靈感，假設每筆靈感 ≤ 10KB）。
- 應用使用 CloudKit 預設公開容器進行同步（假設不需要私有容器或複雜權限控制）。
- 衝突解決採用「最後寫入獲勝」策略（Last Write Wins），以時間戳決定版本優先級。
- 應用遷移後最低 iOS 版本為 iOS 26+（與專案目前版本一致），支援所有 SwiftData 特性。
- 使用者資料不需加密（CloudKit 自動加密傳輸與存儲）。

## Clarifications

### Session 2025-11-04

- Q1: iCloud 容器存取範圍 → A: 單一使用者容器（每個使用者的靈感只同步至其自己的 iCloud 帳戶，未來可擴展）
- Q2: 舊版資料來源 → Custom: 舊版應用已使用 SwiftData，新版需啟用 iCloud 同步但保留本機存儲
- Q3: 衝突解決策略 → A: 自動解決（根據時間戳採用最後寫入獲勝，使用者無感知，衝突記錄供開發診斷）
