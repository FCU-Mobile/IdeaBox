# Phase 0 Research — 雲端同步與排序體驗

## SwiftData with iCloud 雲端同步
- **Decision**: 以 SwiftData（CloudKit 同步模式）作為主要持久層，啟用 `@Model` 搭配 `ModelContainer(for:configurations:)` 指向自定義 CloudKit container。
- **Rationale**: 原生 SwiftData 與 SwiftUI 整合良好，可提供本地快取與離線支援，並簡化多裝置同步設定。
- **Alternatives considered**: 自行管理 CloudKit CKRecord；使用 Core Data + NSPersistentCloudKitContainer。前者開發成本高，後者會增加 legacy 轉換負擔。

- **Decision**: 採「時間戳優先」結合 SwiftData 內建變更佇列的合併方案：最近更新者覆蓋欄位，並在 App 端以錯誤提示提醒使用者。
- **Rationale**: 多裝置同時編輯機率低，時間戳可快速決定勝出；依賴 SwiftData 自動維護衝突狀態可減少自建同步資料表的成本。
- **Alternatives considered**: 建立版本樹並要求使用者手動合併（增加負擔）；完全最後寫入覆蓋且不記錄歷史（風險高）。

## 排序與拖拉行為
- **Decision**: 使用 SwiftUI `List` 的 `.onMove` 與 `.moveDisabled` 搭配 `DragDropHandler`，自行維護「自訂排序」欄位；切換到自訂排序時先顯示 `Alert` 提醒。
- **Rationale**: 保持與原生行為一致，減少第三方依賴；Alert 可提醒自訂排序覆蓋既有排序狀態。
- **Alternatives considered**: 使用第三方拖拉套件（不必要且增加學習成本）；允許拖拉不彈窗（違反需求）。

## Point-Free 套件評估
- **Decision**: 導入 `swift-dependencies` 用於測試切換同步與提醒服務；`swiftui-navigation` 若現有 NavigationStack 足夠則暫緩，僅在需要複雜導覽時選用。
- **Rationale**: Dependencies 有助於注入模擬器與測試替身；Navigation 套件目前需求較低可延後。
- **Alternatives considered**: 使用自製 Service Locator（較難測試）；全面導入 Composable Architecture（超出當前範疇）。

## 每日提醒
- **Decision**: 使用 UserNotifications `UNUserNotificationCenter`，支援授權流程與重複排程；提醒設定（啟用、時間、訊息）存放於 `AppStorage`／UserDefaults，App 啟動時同步檢查排程狀態。
- **Rationale**: 原生 API 已滿足每日提醒需求；透過 `AppStorage` 管理簡易偏好即可避免額外 SwiftData schema，同時便於測試與同步 UI。
- **Alternatives considered**: 背景推播或第三方提醒服務（成本高且需伺服器支援）。

## 第三方程式碼庫準則
- **Decision**: 所有第三方庫需通過 License（MIT/Apache2 等）檢視、版本鎖定、Xcode 下載管理；評估是否需透過 SPM 管理。
- **Rationale**: 確保供應鏈安全並符合專案治理。
- **Alternatives considered**: 直接加入原始碼（更新負擔大）。
