# Implementation Plan: 雲端同步與排序體驗

**Branch**: `001-sync-ideas-cloud` | **Date**: 2025-10-29 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-sync-ideas-cloud/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

導入 SwiftData with iCloud 以跨裝置同步想法資料，使用系統內建變更追蹤避免自行維護同步設定；擴充排序功能支援建立日期、更新日期、字母以及可控的拖拉自訂順序，並於切換到自訂排序前以彈窗提醒；建立每日本地提醒流程以提升回訪率，提醒設定改採 `AppStorage`（或 UserDefaults）記錄並以 UserNotifications 排程；必要時引入 Point-Free Navigation 與 Dependencies 套件協助管理複雜的導覽與注入邏輯，同時維持模組化目錄與檔案輕量原則。

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Swift 5.10（隨 Xcode 16，SwiftUI 5 支援）  
**Primary Dependencies**: SwiftUI、SwiftData with iCloud（CloudKit）、UserNotifications、AppStorage/UserDefaults、可能採用 Point-Free Navigation 與 Dependencies；第三方套件需經安全審查  
**Storage**: SwiftData 永續層（自動管理 CloudKit 同步與衝突解決）；提醒設定使用 AppStorage/UserDefaults；本地快取（SQLite）自動管理  
**Testing**: Swift Testing（單元 & 功能）、Xcode UITesting（拖拉與提醒流程）  
**Target Platform**: iOS 26+（iPhone、iPad，直向／橫向）
**Project Type**: 行動應用（SwiftUI 單一 App 專案）  
**Performance Goals**: 清單互動保持 60fps；iCloud 同步 95% 案例於 5 秒內完成；每日提醒觸發延遲 < 1 分鐘  
**Constraints**: 離線後須避免資料衝突；拖拉觸發必須顯示彈窗確認；通知需遵循使用者授權設定；任務遵守檔案 200 行限制  
**Scale/Scope**: 單一使用者多裝置同步，預期清單 1,000 筆想法內仍需流暢；提醒每日一次

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] 驗證主要使用流程是否可於三步驟內完成：新增／同步流程為「開啟 App → 建立或編輯想法 → 自動同步」，排序調整為「選擇排序 →（若為自訂則）彈窗確認 → 拖拉完成」。
- [x] 提供 Swift Testing 與 UI 測試計畫：Sync、Sorting、Reminder 三大模組皆規劃專屬 Swift Testing 檔與 UITest 套件；目標覆蓋率 ≥85%。
- [x] 描述資料夾與檔案結構：將新增 `IdeaBox/Services/Sync`（依賴 SwiftData Container）、`IdeaBox/Services/Reminders`、`IdeaBox/Features/IdeaSorting` 等子資料夾，遵循模組化規範。
- [x] 標示潛在 200 行以上檔案：`IdeaSyncService.swift` 與 `IdeaListView.swift` 可能超限，計畫拆分為協議 + 實作或子視圖。
- [x] 確認正體中文文案：提醒彈窗、同步錯誤提示、測試描述全部以正體中文撰寫並更新本地化資源。

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

ios/ or android/
```text
IdeaBox/
├── Models/
│   └── Idea.swift                # SwiftData 模型與屬性
├── Services/
│   ├── Sync/
│   │   ├── IdeaSyncService.swift
│   │   ├── CloudSyncCoordinator.swift
│   │   └── SyncStatusPresenter.swift
│   └── Reminders/
│       ├── ReminderScheduler.swift
│       └── ReminderAuthorizationService.swift
├── Features/
│   └── IdeaSorting/
│       ├── IdeaSortingView.swift
│       ├── IdeaSortingViewModel.swift
│       └── DragDropHandler.swift
├── Views/
│   ├── IdeaList/
│   │   ├── IdeaListView.swift
│   │   └── IdeaRowView.swift
│   └── Components/
│       └── SortPicker.swift
└── Shared/
  └── Localization/
    └── zh-Hant.strings

IdeaBoxTests/
├── Sync/
│   └── SyncCloudTests.swift
├── Sorting/
│   └── IdeaSortingTests.swift
└── Reminders/
  └── DailyReminderTests.swift

IdeaBoxUITests/
├── SyncCloudUITests.swift
├── IdeaSortingUITests.swift
└── DailyReminderUITests.swift
```

**Structure Decision**: 保持單一 SwiftUI App 結構，但將同步、排序、提醒模組化至 `Services/` 與 `Features/` 子資料夾，確保責任分離並遵守檔案行數限制；測試依模組分類，方便達到覆蓋率目標。

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
