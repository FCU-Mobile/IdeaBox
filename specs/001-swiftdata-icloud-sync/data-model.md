# Phase 1 Data Model: SwiftData 資料模型設計

**日期**: 2025-11-04 | **分支**: `001-swiftdata-icloud-sync`  
**目標**: 定義靈感資料模型與同步中繼資料結構

---

## 核心模型：Idea（靈感）

### 模型定義

```swift
import SwiftData
import Foundation

/// 靈感模型
/// 
/// 此模型使用 @Model 宏啟用 SwiftData 持久化與 CloudKit 同步。
/// 包含基礎靈感資訊與同步相關時間戳與裝置識別碼。
@Model 
final class Idea: Identifiable {
    // MARK: - 基礎屬性
    
    /// 靈感的全域唯一識別符
    @Attribute(.unique) 
    var id: UUID
    
    /// 靈感的標題
    /// - 驗證規則：非空，最多 200 字
    var title: String
    
    /// 靈感的描述或內容
    /// - 驗證規則：最多 5000 字
    var description: String
    
    /// 靈感的完成狀態
    var isCompleted: Bool
    
    // MARK: - 同步相關屬性（CloudKit）
    
    /// 靈感的建立時間（UTC）
    /// - 用途：排序（最新優先）
    var createdAt: Date
    
    /// 靈感的最後更新時間（UTC）
    /// - 用途：Last-Write-Wins 衝突解決的時間戳
    /// - 規則：updatedAt >= createdAt
    var updatedAt: Date
    
    /// 最後修改此靈感的裝置識別符
    /// - 格式：UUID 或裝置名稱
    /// - 用途：衝突解決的 Tie-breaker（時間戳相同時）
    var lastModifiedBy: String
    
    // MARK: - 初始化
    
    /// 初始化靈感
    /// - Parameters:
    ///   - id: 靈感 UUID（預設：新建）
    ///   - title: 靈感標題
    ///   - description: 靈感描述
    ///   - isCompleted: 完成狀態（預設：false）
    ///   - createdAt: 建立時間（預設：現在）
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = createdAt
        self.lastModifiedBy = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }
}

// MARK: - 驗證擴展

extension Idea {
    /// 驗證靈感資料的有效性
    /// - Throws: ValidationError 若驗證失敗
    func validate() throws {
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            throw ValidationError.emptyTitle
        }
        if title.count > 200 {
            throw ValidationError.titleTooLong(max: 200)
        }
        if description.count > 5000 {
            throw ValidationError.descriptionTooLong(max: 5000)
        }
        if updatedAt < createdAt {
            throw ValidationError.invalidTimestamps
        }
    }
    
    enum ValidationError: LocalizedError {
        case emptyTitle
        case titleTooLong(max: Int)
        case descriptionTooLong(max: Int)
        case invalidTimestamps
        
        var errorDescription: String? {
            switch self {
            case .emptyTitle:
                return "靈感標題不能為空"
            case .titleTooLong(let max):
                return "靈感標題超過 \(max) 字限制"
            case .descriptionTooLong(let max):
                return "靈感描述超過 \(max) 字限制"
            case .invalidTimestamps:
                return "更新時間不能早於建立時間"
            }
        }
    }
}

// MARK: - 快照擴展（用於衝突記錄）

extension Idea {
    /// 靈感的快照（用於衝突記錄）
    struct Snapshot: Codable {
        let id: UUID
        let title: String
        let description: String
        let isCompleted: Bool
        let updatedAt: Date
        let lastModifiedBy: String
    }
    
    /// 建立快照
    func toSnapshot() -> Snapshot {
        Snapshot(
            id: id,
            title: title,
            description: description,
            isCompleted: isCompleted,
            updatedAt: updatedAt,
            lastModifiedBy: lastModifiedBy
        )
    }
}
```

### 屬性說明

| 屬性 | 型別 | 必填 | 唯一 | 用途 |
|------|------|------|------|------|
| `id` | UUID | ✅ | ✅ | 全域識別符 |
| `title` | String | ✅ | ❌ | 靈感標題 |
| `description` | String | ✅ | ❌ | 靈感內容 |
| `isCompleted` | Bool | ✅ | ❌ | 完成狀態 |
| `createdAt` | Date | ✅ | ❌ | 建立時間（排序鍵） |
| `updatedAt` | Date | ✅ | ❌ | 最後更新時間（衝突解決） |
| `lastModifiedBy` | String | ✅ | ❌ | 裝置識別符（Tie-breaker） |

### 驗證規則

1. **title**: 
   - 非空（去除空白後）
   - 最多 200 字
   - 不包含空值字符

2. **description**:
   - 允許空值（可留白）
   - 最多 5000 字

3. **timestamps**:
   - `updatedAt >= createdAt`（必須）
   - 使用 UTC 時間
   - 精度：秒級（CloudKit 同步足夠）

4. **lastModifiedBy**:
   - 非空
   - 格式：`UIDevice.current.identifierForVendor` 或自訂裝置名稱

### 狀態轉換圖

```
┌─────────────────────────────────┐
│     建立狀態 (created)          │
│  isCompleted = false            │
│  updatedAt = createdAt          │
└──────────────┬──────────────────┘
               │
      (編輯 / 切換完成)
               ↓
┌─────────────────────────────────┐
│    活躍狀態 (active/completed)   │
│  updatedAt > createdAt          │
│  可多次編輯、切換完成狀態        │
└──────────────┬──────────────────┘
               │
            (刪除)
               ↓
┌─────────────────────────────────┐
│     已刪除狀態 (deleted)         │
│  從資料庫移除                   │
│  同步至 CloudKit（刪除標記）    │
└─────────────────────────────────┘
```

---

## 同步中繼資料模型

### 模型定義

```swift
/// 同步中繼資料
/// 
/// 追蹤應用與 CloudKit 的同步狀態與衝突歷史。
@Model
final class SyncMetadata {
    /// 最後成功同步的時間戳
    var lastSyncDate: Date?
    
    /// CloudKit 是否已啟用
    var isSyncEnabled: Bool = false
    
    /// 衝突記錄日誌
    @Relationship(deleteRule: .cascade) 
    var conflictLog: [ConflictRecord] = []
    
    /// 最後遇到的同步錯誤（用於診斷）
    var lastSyncError: String?
    
    /// 初始化
    init() {
        self.lastSyncDate = nil
        self.isSyncEnabled = false
        self.conflictLog = []
        self.lastSyncError = nil
    }
    
    /// 記錄衝突事件
    func logConflict(_ record: ConflictRecord) {
        conflictLog.append(record)
        // 保持日誌大小合理（最多保留 100 條）
        if conflictLog.count > 100 {
            conflictLog.removeFirst(conflictLog.count - 100)
        }
    }
    
    /// 更新同步時間戳
    func recordSync() {
        lastSyncDate = Date()
        lastSyncError = nil
    }
    
    /// 記錄同步錯誤
    func recordError(_ error: Error) {
        lastSyncError = error.localizedDescription
    }
}

/// 衝突記錄
/// 
/// 記錄多裝置衝突的詳細資訊，供開發診斷與日誌追蹤。
@Model
final class ConflictRecord {
    /// 發生衝突的靈感 UUID
    var ideaId: UUID
    
    /// 衝突發生的時間
    var conflictTime: Date
    
    /// 本機版本的快照
    var localSnapshot: Data  // Codable 序列化
    
    /// 遠端版本的快照
    var remoteSnapshot: Data  // Codable 序列化
    
    /// 衝突解決方式
    /// 
    /// 可能值：
    /// - "Local": 保留本機版本（本機時間戳較新）
    /// - "Remote": 採用遠端版本（遠端時間戳較新）
    /// - "TieBreaker": 使用裝置 ID tie-breaker
    var resolution: String
    
    /// 初始化
    init(
        ideaId: UUID,
        conflictTime: Date = Date(),
        localSnapshot: Idea.Snapshot,
        remoteSnapshot: Idea.Snapshot,
        resolution: String
    ) {
        self.ideaId = ideaId
        self.conflictTime = conflictTime
        self.localSnapshot = try! JSONEncoder().encode(localSnapshot)
        self.remoteSnapshot = try! JSONEncoder().encode(remoteSnapshot)
        self.resolution = resolution
    }
    
    /// 取得本機快照（反序列化）
    func getLocalSnapshot() throws -> Idea.Snapshot {
        try JSONDecoder().decode(Idea.Snapshot.self, from: localSnapshot)
    }
    
    /// 取得遠端快照（反序列化）
    func getRemoteSnapshot() throws -> Idea.Snapshot {
        try JSONDecoder().decode(Idea.Snapshot.self, from: remoteSnapshot)
    }
}
```

### 屬性說明

| 屬性 | 型別 | 用途 |
|------|------|------|
| `lastSyncDate` | Date? | 同步時間線 |
| `isSyncEnabled` | Bool | CloudKit 可用性 |
| `conflictLog` | [ConflictRecord] | 衝突歷史 |
| `lastSyncError` | String? | 錯誤診斷 |

---

## 關係與約束

### 關係圖

```
┌──────────────────┐
│  IdeaBoxApp      │
│  (ModelContainer)│
└────────┬─────────┘
         │ contains
         ↓
    ┌─────────────────┐
    │ Idea            │ (多筆)
    ├─────────────────┤
    │ id (UUID)       │
    │ title           │
    │ description     │
    │ isCompleted     │
    │ createdAt       │
    │ updatedAt       │
    │ lastModifiedBy  │
    └─────────────────┘

┌────────────────────┐
│ SyncMetadata       │ (單一全域)
├────────────────────┤
│ lastSyncDate       │
│ isSyncEnabled      │
│ conflictLog[]      │ ─┐
│ lastSyncError      │  │
└────────────────────┘  │
         ↑              │
         └──────┬───────┘
                │ contains
                ↓
         ┌──────────────────┐
         │ ConflictRecord   │ (多筆)
         ├──────────────────┤
         │ ideaId (ref)     │
         │ conflictTime     │
         │ localSnapshot    │
         │ remoteSnapshot   │
         │ resolution       │
         └──────────────────┘
```

### 唯一性約束

- `Idea.id` → 全域唯一（@Attribute(.unique)）
- `SyncMetadata` → 應用層確保單一實例（單一 ModelContainer）
- `ConflictRecord` → 無唯一性約束（允許重複記錄相同衝突）

### 級聯刪除規則

```swift
// SyncMetadata 刪除時，自動刪除所有 ConflictRecord
@Relationship(deleteRule: .cascade) 
var conflictLog: [ConflictRecord] = []
```

---

## 資料庫配置

### ModelContainer 初始化

```swift
let config = ModelConfiguration(
    url: URL.applicationSupportDirectory.appending(path: "IdeaBox.sqlite"),
    cloudKitDatabase: .private(identifier: "com.buildwithharry.IdeaBox")
)

let modelContainer = try ModelContainer(
    for: Idea.self, SyncMetadata.self,
    configurations: config
)
```

### 儲存位置

- **本機**: `~/Library/Application Support/IdeaBox.sqlite`
- **遠端**: CloudKit 私有資料庫（com.buildwithharry.IdeaBox）

### 資料庫版本管理

| 版本 | 變更 | 遷移策略 |
|------|------|--------|
| v1.0 | 初始版本（Idea + SyncMetadata） | 無遷移（新應用） |

---

## 查詢模式

### 常見查詢

```swift
// 1. 所有靈感（按建立時間反序）
@Query(sort: \.createdAt, order: .reverse) 
var allIdeas: [Idea]

// 2. 已完成靈感
@Query(
    filter: #Predicate<Idea> { $0.isCompleted == true },
    sort: \.createdAt,
    order: .reverse
) 
var completedIdeas: [Idea]

// 3. 搜尋靈感（標題或描述包含關鍵字）
@Query(
    filter: #Predicate<Idea> { idea in
        idea.title.contains(searchText) || 
        idea.description.contains(searchText)
    },
    sort: \.createdAt,
    order: .reverse
) 
var searchResults: [Idea]

// 4. 最近 24 小時的靈感
let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
@Query(
    filter: #Predicate<Idea> { $0.createdAt > oneDayAgo },
    sort: \.createdAt,
    order: .reverse
) 
var recentIdeas: [Idea]
```

---

## 效能考量

### 索引建議

- `createdAt` → 排序查詢頻繁
- `isCompleted` → 篩選查詢頻繁
- `title`, `description` → 搜尋查詢頻繁

**實作**：SwiftData 自動為 @Model 屬性建立基本索引。

### 預期規模

- 典型使用者：100-500 筆靈感
- 超級使用者：1000+ 筆靈感
- 單筆大小：平均 500 字 = ~1KB
- 資料庫大小：100 筆 = 100KB，1000 筆 = 1MB

**結論**：本地 SQLite 充分；CloudKit 免費額度足夠。

---

## 總結

✅ 資料模型設計完成，可進入 Phase 1 實作。

| 模型 | 用途 | 複雜度 |
|------|------|--------|
| Idea | 靈感持久化 | 低 |
| SyncMetadata | 同步追蹤 | 低 |
| ConflictRecord | 衝突診斷 | 低 |
