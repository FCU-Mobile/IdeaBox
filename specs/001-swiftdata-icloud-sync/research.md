# Phase 0 Research: SwiftData + CloudKit 遷移指南

**日期**: 2025-11-04 | **分支**: `001-swiftdata-icloud-sync`  
**目標**: 解決技術不確定性，為 Phase 1 設計奠定基礎

---

## R1: SwiftData 最佳實踐

### 決策

使用 Apple SwiftData 框架（iOS 17+，本專案 iOS 26+ 原生支援）替代 @State 記憶體存儲。

### 實作指南

#### 1. 模型標記為 @Model

```swift
import SwiftData

@Model 
final class Idea: Identifiable {
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    
    // CloudKit 同步字段
    var createdAt: Date
    var updatedAt: Date          // Last-Write-Wins 時間戳
    var lastModifiedBy: String   // CloudKit 裝置 ID
    
    init(id: UUID = UUID(), title: String, description: String, 
         isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.lastModifiedBy = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }
}
```

**關鍵點**：
- `@Model` 宏自動生成 Codable 支援與 Identifiable
- `@Attribute(.unique)` 確保 UUID 全域唯一
- `lastModifiedBy` 用於衝突解決時識別修改來源

#### 2. 在 App 中初始化 ModelContainer

```swift
import SwiftUI
import SwiftData

@main
struct IdeaBoxApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            // 啟用 CloudKit 同步的 ModelContainer
            let config = ModelConfiguration(
                url: URL.applicationSupportDirectory.appending(path: "IdeaBox.sqlite"),
                cloudKitDatabase: .private(identifier: "com.buildwithharry.IdeaBox")
            )
            modelContainer = try ModelContainer(
                for: Idea.self,
                configurations: config
            )
        } catch {
            fatalError("無法初始化 ModelContainer：\(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
```

**關鍵點**：
- `cloudKitDatabase: .private(identifier:)` 啟用私有 CloudKit 容器
- `.applicationSupportDirectory` 是 SwiftData 儲存位置慣例
- `modelContainer` 視圖修飾器傳遞至環境

#### 3. 使用 @Query 宏在視圖中查詢

```swift
import SwiftData
import SwiftUI

struct AllIdeasView: View {
    // 自動追蹤 @Query 結果變更，UI 即時更新
    @Query(sort: \.createdAt, order: .reverse) var ideas: [Idea]
    
    @State private var showingAddIdea = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(ideas) { idea in
                    IdeaRow(idea: idea)
                }
                .onDelete(perform: deleteIdeas)
            }
            .navigationTitle("All Ideas")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddIdea = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddIdea) {
            AddIdeaSheet { newIdea in
                // SwiftData 自動持久化
                modelContext.insert(newIdea)
            }
        }
    }
    
    @Environment(\.modelContext) var modelContext
    
    private func deleteIdeas(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(ideas[index])
        }
    }
}
```

**關鍵點**：
- `@Query` 自動搜索並觀察資料庫變更
- `sort: \.createdAt, order: .reverse` 確保新增靈感在頂部
- `modelContext.insert()` 和 `.delete()` 在 SwiftData 中持久化

#### 4. 搜尋與篩選

```swift
struct SearchView: View {
    @Query var ideas: [Idea]
    @State private var searchText = ""
    @State private var showCompleted = true
    
    var filteredIdeas: [Idea] {
        ideas.filter { idea in
            let matchesSearch = searchText.isEmpty || 
                idea.title.contains(searchText) || 
                idea.description.contains(searchText)
            let matchesCompletion = showCompleted || !idea.isCompleted
            return matchesSearch && matchesCompletion
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredIdeas) { idea in
                IdeaRow(idea: idea)
            }
            .searchable(text: $searchText, prompt: "搜尋靈感")
        }
    }
}
```

**關鍵點**：
- SwiftData 查詢在記憶體中，支援複雜篩選邏輯
- `searchable()` 修飾器提供搜尋 UI

### 替代方案評估

| 方案 | 優點 | 缺點 | 結論 |
|------|------|------|------|
| SwiftData + CloudKit | Apple 原生、無需手動 API、自動同步 | iOS 17+ 限制 | ✅ 選定 |
| Core Data + CloudKit | 更廣泛支援 | 複雜 API、手動同步配置 | ❌ 過度工程 |
| Realm + CloudKit | 跨平臺 | 非原生、額外依賴 | ❌ 不必要 |
| Firebase Firestore | 即時同步、跨平臺 | 依賴第三方、付費、隱私風險 | ❌ 違反原則 |

---

## R2: CloudKit 同步配置

### 決策

使用 SwiftData 原生 CloudKit 支援，完全避免手動 CloudKit API。ModelContainer 自動管理同步。

### 實作指南

#### 1. ModelContainer 配置

```swift
// 步驟 1：在 Xcode 專案設定中啟用 iCloud Capability
// Xcode → Project → Signing & Capabilities → + Capability → iCloud
// 選擇「CloudKit」並輸入 Container ID: "com.buildwithharry.IdeaBox"

// 步驟 2：程式碼中配置 ModelContainer
let config = ModelConfiguration(
    url: URL.applicationSupportDirectory.appending(path: "IdeaBox.sqlite"),
    cloudKitDatabase: .private(identifier: "com.buildwithharry.IdeaBox")
)

let modelContainer = try ModelContainer(
    for: Idea.self,
    configurations: config
)
```

**CloudKit 對應**:
- `.private(identifier:)` → 使用者私人資料庫（只有該用戶可存取）
- `.public(identifier:)` → 公開資料庫（所有用戶可讀，需明確權限寫入）
- `.shared(identifier:)` → 共享資料庫（家庭/團隊共享）

本功能採用 `.private`（單一使用者容器）。

#### 2. 自動同步機制

SwiftData + CloudKit 自動處理：
- ✅ 本機變更自動上傳
- ✅ 遠端變更自動下載
- ✅ 衝突自動解決（可自訂）
- ✅ 離線隊列管理

```swift
// 無需顯式同步呼叫；所有 modelContext 操作自動同步
modelContext.insert(newIdea)  // 即時同步至 CloudKit
idea.isCompleted.toggle()      // 即時同步
modelContext.delete(idea)      // 即時同步
```

#### 3. 錯誤處理與監控

```swift
struct CloudKitService: ObservableObject {
    @Published var isSyncEnabled = false
    @Published var lastError: Error? = nil
    
    func checkCloudKitStatus() async {
        do {
            // 驗證使用者 iCloud 帳戶
            let accountStatus = try await CKContainer.default().accountStatus()
            
            DispatchQueue.main.async {
                self.isSyncEnabled = (accountStatus == .available)
            }
            
            if accountStatus != .available {
                // 記錄日誌：iCloud 不可用，應用以本機模式運作
                os_log("iCloud 帳戶不可用，進入本機模式", log: .default, type: .warning)
            }
        } catch {
            DispatchQueue.main.async {
                self.lastError = error
                self.isSyncEnabled = false
            }
            os_log("檢查 CloudKit 狀態失敗：%@", log: .default, type: .error, error.localizedDescription)
        }
    }
}
```

**監控點**:
- `CKContainer.default().accountStatus()` → 檢查 iCloud 可用性
- `ModelContext` 錯誤 → 同步失敗
- 離線狀態 → 隊列延遲

### 替代方案評估

| 方案 | 複雜度 | 自動化程度 | 結論 |
|------|--------|---------|------|
| SwiftData 原生 | 低 | 100% 自動 | ✅ 選定 |
| 手動 CloudKit API | 高 | 需手動實作 | ❌ 過度工程 |
| 第三方同步庫 | 中 | 部分自動 | ❌ 不必要依賴 |

---

## R3: 多裝置同步測試策略

### 決策

使用 Xcode 多模擬器 + Swift Testing，驗證同步邏輯與衝突解決。

### 實作指南

#### 1. Swift Testing 測試框架

```swift
import SwiftTesting
import SwiftData

@Test("新增靈感應持久化至 SwiftData")
func testIdeaPersistence() async {
    // 準備：建立測試 ModelContainer
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: Idea.self, configurations: config)
    let context = ModelContext(container)
    
    // 執行：新增靈感
    let newIdea = Idea(title: "學習 SwiftData", description: "掌握持久化框架")
    context.insert(newIdea)
    try context.save()
    
    // 驗證：查詢靈感
    let descriptor = FetchDescriptor<Idea>()
    let ideas = try context.fetch(descriptor)
    #expect(ideas.count == 1)
    #expect(ideas.first?.title == "學習 SwiftData")
}

@Test("衝突解決：Last Write Wins")
func testConflictResolution() async {
    // 準備：建立兩台虛擬裝置的模擬器
    let device1 = MockDeviceContext(id: "device-1")
    let device2 = MockDeviceContext(id: "device-2")
    
    // 執行：兩台裝置同時修改同一靈感
    let ideaId = UUID()
    let ideaTitle = "靈感"
    
    device1.update(ideaId: ideaId, newTitle: "修改版本 A", timestamp: Date(timeIntervalSince1970: 100))
    device2.update(ideaId: ideaId, newTitle: "修改版本 B", timestamp: Date(timeIntervalSince1970: 200))
    
    // 驗證：最後寫入（timestamp 200）勝出
    let resolved = device1.resolvConflict(device1.getIdea(ideaId), device2.getIdea(ideaId))
    #expect(resolved.title == "修改版本 B")
    #expect(resolved.updatedAt.timeIntervalSince1970 == 200)
}
```

**關鍵點**：
- `ModelConfiguration(isStoredInMemoryOnly: true)` 建立測試資料庫
- `#expect()` 是 SwiftTesting 的斷言（取代 XCTAssert）
- MockDeviceContext 模擬多裝置場景

#### 2. 多模擬器同步測試

```bash
# 啟動兩台 iPhone 模擬器
xcrun simctl create "iPhone-Device1" com.apple.CoreSimulator.SimDeviceType.iPhone16 com.apple.CoreSimulator.SimRuntime.iOS-26-0
xcrun simctl create "iPhone-Device2" com.apple.CoreSimulator.SimDeviceType.iPhone16 com.apple.CoreSimulator.SimRuntime.iOS-26-0

# 在兩台模擬器上建置並執行應用
xcodebuild -scheme IdeaBox -destination "id=<device1-udid>" -configuration Debug build
xcodebuild -scheme IdeaBox -destination "id=<device2-udid>" -configuration Debug build

# 執行 UI 測試（多裝置場景）
xcodebuild test -scheme IdeaBoxUITests -destination "id=<device1-udid>,id=<device2-udid>"
```

**測試場景**:
- Device 1 新增靈感 → Device 2 在 5 秒內看到
- Device 1 編輯 → Device 2 自動更新
- Device 1 刪除 → Device 2 自動刪除
- 衝突：兩裝置同時編輯 → Last-Write-Wins 解決

#### 3. 離線測試

```swift
@Test("飛行模式下操作應離線隊列，網路恢復後同步")
func testOfflineOperation() async {
    // 準備：啟用飛行模式
    let deviceContext = MockDeviceContext(isOffline: true)
    let container = try ModelContainer(for: Idea.self)
    
    // 執行：飛行模式下新增靈感
    let idea = Idea(title: "離線靈感", description: "將在網路恢復後同步")
    deviceContext.modelContext.insert(idea)
    try deviceContext.modelContext.save()
    
    // 驗證：靈感在本機存在
    let ideas = try deviceContext.fetch()
    #expect(ideas.count == 1)
    
    // 模擬網路恢復
    deviceContext.isOffline = false
    await deviceContext.triggerSync()
    
    // 驗證：靈感已上傳至 CloudKit
    #expect(deviceContext.syncQueue.isEmpty)  // 隊列已清空
}
```

### 替代方案評估

| 方案 | 複雜度 | 真實性 | 結論 |
|------|--------|-------|------|
| Swift Testing + Mock | 中 | 高 | ✅ 選定 |
| UITesting + 真實裝置 | 高 | 最高 | ⚠️ 補充（整合測試） |
| 簡單單元測試 | 低 | 低 | ❌ 不足 |

---

## R4: 衝突解決演算法

### 決策

實作 **Last Write Wins (LWW)** 策略：根據 `updatedAt` 時間戳選擇最新版本，對使用者完全透明。

### 演算法虛擬代碼

```
函數 resolveConflict(localVersion, remoteVersion):
    // 比較時間戳
    if remoteVersion.updatedAt > localVersion.updatedAt:
        return remoteVersion        // 遠端版本較新，使用遠端
    else if localVersion.updatedAt > remoteVersion.updatedAt:
        return localVersion         // 本機版本較新，保持本機
    else:
        // 時間戳相同（極罕見），使用裝置 ID 作為 tie-breaker
        if localVersion.lastModifiedBy > remoteVersion.lastModifiedBy:
            return localVersion
        else:
            return remoteVersion

    // 記錄衝突事件
    logConflict({
        ideaId: localVersion.id,
        conflictTime: now(),
        localVersion: localVersion.toSnapshot(),
        remoteVersion: remoteVersion.toSnapshot(),
        resolution: chosenVersion == localVersion ? "Local" : "Remote"
    })
```

### Swift 實作

```swift
class ConflictResolver {
    // 靜態方法解決衝突
    static func resolve(local: Idea, remote: Idea) -> Idea {
        // 比較時間戳
        if remote.updatedAt > local.updatedAt {
            os_log("衝突解決：選擇遠端版本（時間戳 %@）", 
                   log: .default, type: .info, 
                   remote.updatedAt.description)
            logConflict(ideaId: local.id, resolution: "Remote", 
                       local: local, remote: remote)
            return remote
        } else if local.updatedAt > remote.updatedAt {
            os_log("衝突解決：保持本機版本（時間戳 %@）", 
                   log: .default, type: .info, 
                   local.updatedAt.description)
            logConflict(ideaId: local.id, resolution: "Local", 
                       local: local, remote: remote)
            return local
        } else {
            // Tie-breaker：比較裝置 ID（字典序）
            let winner = local.lastModifiedBy > remote.lastModifiedBy ? local : remote
            os_log("衝突解決（相同時間戳）：選擇 %@ 版本", 
                   log: .default, type: .info, 
                   local.lastModifiedBy > remote.lastModifiedBy ? "本機" : "遠端")
            logConflict(ideaId: local.id, resolution: "TieBreaker", 
                       local: local, remote: remote)
            return winner
        }
    }
    
    private static func logConflict(ideaId: UUID, resolution: String, 
                                   local: Idea, remote: Idea) {
        // 記錄至日誌供開發診斷
        let record = ConflictRecord(
            ideaId: ideaId,
            conflictTime: Date(),
            localVersion: local.toSnapshot(),
            remoteVersion: remote.toSnapshot(),
            resolution: resolution
        )
        // 保存至 SyncMetadata
        SyncService.shared.logConflict(record)
    }
}
```

### 邊界情況

| 情況 | 處理 | 結果 |
|------|------|------|
| 時間戳完全相同 | tie-breaker（裝置 ID） | 確定性解決 |
| 時間戳相差 < 1ms | LWW 仍適用 | 微小時差優先 |
| 本地時鐘不同步 | 使用伺服器時間戳（CloudKit）| 伺服器真實來源 |
| 三向衝突（多裝置） | LWW 逐次應用 | 最終一致性 |

### 替代方案評估

| 策略 | 優點 | 缺點 | 結論 |
|------|------|------|------|
| Last Write Wins | 簡單、確定性、無使用者介入 | 可能遺漏舊編輯 | ✅ 選定 |
| Operational Transform | 合併所有編輯 | 複雜、不適合文本 | ❌ 過度工程 |
| 使用者手動選擇 | 保留完整資訊 | UI 複雜、降低採用率 | ❌ 違反簡潔原則 |

---

## R5: 離線隊列與重試機制

### 決策

利用 SwiftData + CloudKit 自動離線隊列管理；在應用層實作重試邏輯。

### 實作指南

```swift
class SyncCoordinator: ObservableObject {
    @Published var offlineQueueCount = 0
    @Published var isRetrying = false
    
    func monitorSyncStatus() async {
        // CloudKit 容器通知同步狀態
        let updates = CKContainer.default().subscribeToNotifications(...)
        
        for await update in updates {
            switch update.type {
            case .recordZoneUpdated:
                os_log("收到遠端更新，開始同步...", log: .default, type: .info)
                await triggerSync()
                
            case .recordZoneDeleted:
                os_log("遠端區域已刪除，清除本機副本", log: .default, type: .warning)
                
            default:
                break
            }
        }
    }
    
    func triggerSync() async {
        do {
            // SwiftData 自動上傳所有本機變更
            try await CKContainer.default().reachableCloudDatabase().
                fetch(withQuery: CKQuery(...))
            
            os_log("同步成功", log: .default, type: .info)
            self.offlineQueueCount = 0
            
        } catch let error as CKError {
            // 根據錯誤類型決定重試策略
            switch error.code {
            case .networkFailure, .serviceUnavailable:
                os_log("網路不可用，進入離線模式", log: .default, type: .warning)
                await retryWithExponentialBackoff()
                
            case .permissionFailure:
                os_log("權限不足，需要使用者授權", log: .default, type: .error)
                // 提示使用者檢查 iCloud 設定
                
            default:
                os_log("同步失敗：%@", log: .default, type: .error, error.localizedDescription)
            }
        }
    }
    
    private func retryWithExponentialBackoff(attempt: Int = 1) async {
        guard attempt <= 5 else {
            os_log("重試超過 5 次，放棄", log: .default, type: .error)
            return
        }
        
        // 指數退避：1s、2s、4s、8s、16s
        let delaySeconds = pow(2.0, Double(attempt - 1))
        try? await Task.sleep(for: .seconds(delaySeconds))
        
        os_log("重試 #%d (延遲 %.0f 秒)", log: .default, type: .info, attempt, delaySeconds)
        await triggerSync()
    }
}
```

### 離線隊列狀態機

```
[已連接] 
  ↓
新增/編輯/刪除靈感
  ↓
本機變更已保存 → [已連接] → 即時同步至 CloudKit
                        ↓
                    [已斷開] → 離線隊列快取
                        ↓
                    網路恢復 → 重試機制 (Exp. Backoff)
                        ↓
                    同步成功 → [已連接]
```

### 替代方案評估

| 方案 | 覆蓋面 | 複雜度 | 結論 |
|------|--------|--------|------|
| CloudKit 自動隊列 + 應用層重試 | 完整 | 中 | ✅ 選定 |
| 完全手動隊列 | 完整 | 高 | ❌ 不必要 |
| 簡單重試 | 部分 | 低 | ⚠️ 不足 |

---

## R6: iOS 無障礙 (VoiceOver) 集成

### 決策

在靈感列表與搜尋中新增無障礙標籤，確保 VoiceOver 使用者可完整使用應用。

### 實作指南

```swift
struct IdeaRow: View {
    let idea: Idea
    
    var body: some View {
        HStack {
            // 勾選框
            Image(systemName: idea.isCompleted ? "checkmark.circle.fill" : "circle")
                .accessibilityLabel(idea.isCompleted ? "已完成" : "未完成")
                .accessibilityHint("點擊以切換完成狀態")
            
            VStack(alignment: .leading, spacing: 4) {
                Text(idea.title)
                    .font(.headline)
                    .strikethrough(idea.isCompleted)
                
                Text(idea.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(idea.title)
        .accessibilityHint(idea.description)
        .accessibilityAddTraits(idea.isCompleted ? .startsMediaSession : [])
    }
}

struct AllIdeasView: View {
    @Query(sort: \.createdAt, order: .reverse) var ideas: [Idea]
    @State private var showingAddIdea = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(ideas) { idea in
                    IdeaRow(idea: idea)
                }
                .onDelete(perform: deleteIdeas)
            }
            .navigationTitle("所有靈感")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddIdea = true }) {
                        Image(systemName: "plus")
                            .accessibilityLabel("新增靈感")
                    }
                }
            }
        }
    }
    
    @Environment(\.modelContext) var modelContext
    
    private func deleteIdeas(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(ideas[index])
        }
        // VoiceOver 公告
        UIAccessibility.post(notification: .announcement, 
                            argument: "靈感已刪除")
    }
}
```

### 無障礙檢查清單

- [ ] 所有圖示有 `accessibilityLabel`
- [ ] 互動元素有 `accessibilityHint`
- [ ] 清單項目用 `.combine` 聚合標籤
- [ ] 狀態變更發送公告（如刪除、同步）
- [ ] 顏色對比滿足 WCAG AA 標準
- [ ] 動態字體支援

### 測試

```bash
# 啟用 VoiceOver 測試
設定 → 無障礙 → VoiceOver → 開啟
# 或使用 Xcode Simulator Settings 模擬
```

---

## 總結

| 研究項目 | 決策 | 實作複雜度 | 測試難度 |
|---------|------|----------|--------|
| R1: SwiftData 最佳實踐 | @Model + @Query | 低 | 低 |
| R2: CloudKit 配置 | ModelContainer 原生支援 | 低 | 中 |
| R3: 多裝置測試 | Swift Testing + Mock | 中 | 中 |
| R4: 衝突解決 | Last-Write-Wins | 低 | 低 |
| R5: 離線隊列 | CloudKit 自動 + Retry | 中 | 高 |
| R6: 無障礙 | VoiceOver 標籤 | 低 | 低 |

**Phase 0 完成。可進入 Phase 1 設計與建模。**
