# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

IdeaBox is a native iOS app built with SwiftUI for managing ideas. Each idea contains a title, description, and completion status (checkbox).

## Building and Testing

### Build and Run
- **Build**: Open `IdeaBox.xcodeproj` in Xcode and press `Cmd+B`, or use `xcodebuild -project IdeaBox.xcodeproj -scheme IdeaBox build`
- **Run on simulator**: Press `Cmd+R` in Xcode
- **Run on device**: Select a physical device in Xcode and press `Cmd+R` (requires valid development team)

### Testing
- **Run unit tests**: `xcodebuild test -project IdeaBox.xcodeproj -scheme IdeaBox -destination 'platform=iOS Simulator,name=iPhone 16'`
- **Run UI tests**: Use the same command; UI tests are in `IdeaBoxUITests/`
- **Run specific test**: In Xcode, navigate to the test method and click the diamond icon, or press `Cmd+U` for all tests

## Architecture

### Project Structure
```
IdeaBox/
├── IdeaBoxApp.swift              # App entry point using @main
├── ContentView.swift             # Root TabView coordinator
├── Models/
│   └── Idea.swift               # Data model and mock data
├── Views/
│   ├── AllIdeasView.swift       # All ideas tab view
│   ├── SearchView.swift         # Search tab with filtering
│   ├── CompletedIdeasView.swift # Completed ideas tab view
│   ├── IdeaRow.swift            # Individual idea row component
│   └── AddIdeaSheet.swift       # Add idea form sheet
└── Assets.xcassets/             # App icons and assets

IdeaBoxTests/                     # Unit tests
IdeaBoxUITests/                   # UI tests
```

### SwiftUI Standards
This project uses modern SwiftUI APIs:
- `NavigationStack` instead of `NavigationView`
- `@Observable` macro instead of `ObservableObject` + `@Published`
- `foregroundStyle()` instead of `foregroundColor()`
- `onChange(of:)` with two-parameter version

### Development Configuration
- **iOS Deployment Target**: iOS 26
- **Development Team**: 77GUV2264S
- **Bundle ID**: com.buildwithharry.IdeaBox
- **Swift Version**: 6.2
- **Xcode Version**: 26

## Current State
Core MVP implementation complete with:
- Idea model with mock data (7 sample ideas, 2 completed)
- TabView with three tabs: All Ideas, Search, and Completed
- Real-time search through title and description
- Individual idea rows with checkboxes
- Add idea sheet with form validation
- Toggle completion and swipe-to-delete functionality
- ContentUnavailableView for empty states
- Well-organized file structure with separate view files

Next steps: Apply Liquid Glass materials for iOS 26+ visual polish.
