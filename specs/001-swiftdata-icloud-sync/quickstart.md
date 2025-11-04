# Phase 1 Quickstart: SwiftData + CloudKit 遷移快速指南

**日期**: 2025-11-04 | **分支**: `001-swiftdata-icloud-sync`  
**目標**: 5 分鐘快速了解遷移方案與核心步驟

---

## 30 秒概覽

**目前狀態**: @State 記憶體存儲  
**目標狀態**: SwiftData 本機 + CloudKit 同步  
**方法**: Apple 原生框架，零第三方依賴  
**工期**: ~3-4 週（含測試）

---

## 核心變更

### 1. 模型層：@Model 標記

**之前**:
```swift
struct Idea: Identifiable {
    let id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
}
```

**之後**:
```swift
import SwiftData

@Model
final class Idea {
    @Attribute(.unique) var id: UUID
    var title: String
    var description: String
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    var lastModifiedBy: String
}
```

### 2. 應用層：ModelContainer 初始化

**新增至 IdeaBoxApp.swift**:
```swift
import SwiftData

@main
struct IdeaBoxApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(
                url: URL.applicationSupportDirectory.appending(path: "IdeaBox.sqlite"),
                cloudKitDatabase: .private(identifier: "com.buildwithharry.IdeaBox")
            )
            modelContainer = try ModelContainer(for: Idea.self, configurations: config)
        } catch {
            fatalError("ModelContainer 初始化失敗: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)  // 關鍵！傳遞至環境
        }
    }
}
```

### 3. 視圖層：@Query 取代 @Binding

**之前**:
```swift
struct AllIdeasView: View {
    @Binding var ideas: [Idea]
    
    var body: some View {
        List(ideas) { idea in
            IdeaRow(idea: idea)
        }
    }
}
```

**之後**:
```swift
import SwiftData

struct AllIdeasView: View {
    @Query(sort: \.createdAt, order: .reverse) var ideas: [Idea]
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        List(ideas) { idea in
            IdeaRow(idea: idea)
        }
        .onDelete(perform: deleteIdeas)
    }
    
    private func deleteIdeas(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(ideas[index])
        }
    }
}
```

---

## 部署檢查清單

### 階段 1：基礎設置

- [ ] 將 `Idea.swift` 轉換為 @Model
- [ ] 新增 CloudKit 時間戳欄位（createdAt, updatedAt, lastModifiedBy）
- [ ] 在 `IdeaBoxApp` 初始化 ModelContainer
- [ ] 在 `ContentView` 新增 `.modelContainer()` 修飾器

**預期時間**: 30 分鐘

### 階段 2：視圖遷移

- [ ] 將 `AllIdeasView` 遷移至 @Query
- [ ] 將 `SearchView` 遷移至 @Query
- [ ] 將 `CompletedIdeasView` 遷移至 @Query
- [ ] 更新 `AddIdeaSheet` 使用 modelContext.insert()

**預期時間**: 1 小時

### 階段 3：服務層

- [ ] 建立 `Services/CloudKitService.swift`（CloudKit 狀態偵測）
- [ ] 建立 `Services/SyncCoordinator.swift`（同步監控）
- [ ] 建立 `Services/ConflictResolver.swift`（衝突解決）

**預期時間**: 1.5 小時

### 階段 4：測試

- [ ] 編寫 SwiftData 持久化測試
- [ ] 編寫 CloudKit 同步測試
- [ ] 編寫衝突解決測試
- [ ] 執行 UI 測試（多裝置同步）
- [ ] 達到 85% 覆蓋率

**預期時間**: 2 小時

### 階段 5：驗收

- [ ] 本機 CRUD 操作正常
- [ ] 應用重啟後資料保留
- [ ] iCloud 登入時自動啟用同步
- [ ] 多裝置同步在 5 秒內完成
- [ ] 離線操作隊列正常

**預期時間**: 1 小時

---

## 常見陷阱與解決

### 陷阱 1: ModelContainer 未傳遞至環境

**症狀**: @Query 返回空集合  
**原因**: 忘記 `.modelContainer()` 修飾器  
**解決**:
```swift
WindowGroup {
    ContentView()
        .modelContainer(modelContainer)  // ← 必須
}
```

### 陷阱 2: 時間戳遺漏

**症狀**: 衝突解決失敗  
**原因**: Idea 模型缺少 updatedAt 或 lastModifiedBy  
**解決**: 確保模型包含所有時間戳欄位

### 陷阱 3: 離線時崩潰

**症狀**: 飛行模式下操作拋出異常  
**原因**: 未處理 CloudKit 不可用情況  
**解決**: 在 CloudKitService 中偵測 accountStatus()

### 陷阱 4: @Model 類別必須是 final

**症狀**: 編譯錯誤：@Model must be applied to a final class  
**原因**: @Model 不支援繼承  
**解決**: 使用 `final class` 而非 `class`

### 陷阱 5: 查詢謂詞語法

**症狀**: @Query 無法編譯  
**原因**: #Predicate 宏語法錯誤  
**解決**:
```swift
// ✅ 正確
@Query(filter: #Predicate<Idea> { $0.isCompleted == true })

// ❌ 錯誤
@Query(filter: #Predicate { $0.isCompleted == true })  // 缺少型別
```

---

## 效能優化建議

### 1. 查詢優化

```swift
// ✅ 好：篩選後再排序
@Query(
    filter: #Predicate<Idea> { !$0.isCompleted },
    sort: \.createdAt,
    order: .reverse
) 
var activeIdeas: [Idea]

// ⚠️ 較差：查詢所有，然後在 Swift 中篩選
@Query(sort: \.createdAt, order: .reverse)
var allIdeas: [Idea]
var activeIdeas: [Idea] { allIdeas.filter { !$0.isCompleted } }
```

### 2. 批量操作

```swift
// 批量插入（例如遷移資料）
let ideas = [/* 大量靈感 */]
for idea in ideas {
    modelContext.insert(idea)
}
try? modelContext.save()  // 單一提交
```

### 3. 分頁（未來）

```swift
// SwiftData 目前無原生分頁，可用 limit:
@Query(sort: \.createdAt, order: .reverse)
var allIdeas: [Idea]

var pagedIdeas: [Idea] {
    Array(allIdeas.prefix(50))  // 前 50 筆
}
```

---

## CloudKit 設置清單

### Xcode 設定

1. **開啟 iCloud Capability**:
   - 專案 → Signing & Capabilities
   - "+ Capability" → iCloud
   - 勾選 CloudKit
   - Container ID: `com.buildwithharry.IdeaBox`

2. **檢查簽署身份**:
   - Team ID 設定正確（77GUV2264S）
   - Provisioning Profile 包含 iCloud entitlement

3. **測試 CloudKit 連線**:
   ```bash
   # 在 Xcode 控制台檢查
   xcrun cloudkit describe-schema \
     --container-id com.buildwithharry.IdeaBox
   ```

### 模擬器測試

```bash
# 模擬器預設無 iCloud 帳戶，需手動啟用
# 設定 → iCloud → 登入

# 或使用環境變數模擬
SIMCTL_CHILD_NSDebugCloudKitContainerAvailable=1 \
  xcrun simctl launch booted com.buildwithharry.IdeaBox
```

---

## 測試快速入門

### 單元測試

```bash
# 執行所有 SwiftData 測試
xcodebuild test \
  -project IdeaBox.xcodeproj \
  -scheme IdeaBox \
  -testPlan "IdeaDataPersistenceTests"
```

### UI 測試（多裝置）

```bash
# 啟動兩台模擬器
xcrun simctl launch booted com.buildwithharry.IdeaBox &
xcrun simctl launch booted com.buildwithharry.IdeaBox &

# 執行同步測試
xcodebuild test -scheme IdeaBoxUITests
```

### 覆蓋率報告

```bash
xcodebuild test \
  -project IdeaBox.xcodeproj \
  -scheme IdeaBox \
  -enableCodeCoverage YES \
  -resultBundlePath /tmp/CodeCoverage.xcresult

# 產生 HTML 報告
xcov --project IdeaBox.xcodeproj \
  --scheme IdeaBox \
  --source-files "IdeaBox" \
  --html_report /tmp/coverage
```

---

## 無障礙檢查

### VoiceOver 測試

1. **啟用**:
   - 設定 → 無障礙 → VoiceOver → 開啟
   - 或 Control Center 快捷方式

2. **測試點**:
   - 靈感列表項有清晰描述
   - 新增/編輯按鈕有 accessibilityLabel
   - 完成勾選框有反饋公告

3. **驗證**:
   ```swift
   // 確保每個互動元素有標籤
   Button(action: { /* ... */ }) {
       Image(systemName: "plus")
           .accessibilityLabel("新增靈感")
   }
   ```

---

## 回滾計畫

若遷移失敗，回滾步驟：

1. **暫存本機資料**:
   ```bash
   cp ~/Library/Application\ Support/IdeaBox.sqlite /backup/
   ```

2. **回到舊分支**:
   ```bash
   git checkout SpecKit  # 或上一版本
   ```

3. **恢復資料庫**:
   ```bash
   cp /backup/IdeaBox.sqlite ~/Library/Application\ Support/
   ```

---

## 下一步

✅ 完成本快速指南後：

1. 進行詳細計畫與工作分解
2. 根據 `research.md` 與 `data-model.md` 開始實作
3. 執行 `/speckit.tasks` 產生工作清單
4. 按優先級實作 P1 使用者故事

**預期完成時間**: 3-4 週（全職開發）

---

## 參考資源

- [SwiftData 文件](https://developer.apple.com/documentation/swiftdata)
- [CloudKit 開發者指南](https://developer.apple.com/icloud/cloudkit/)
- [WWDC 2024 SwiftData 演講](https://developer.apple.com/videos/)

---

**快速指南完成。進入 Phase 1 實作！**
