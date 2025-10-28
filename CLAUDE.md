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

## SpecKit Workflow & Rules (必讀)

This repo uses SpecKit to drive features. Follow these to stay compliant with the project Constitution (`.specify/memory/constitution.md`).

### Constitution gates (summary)

- Code quality: no new warnings (treat warnings as errors), small focused PRs, Swift API naming, public symbols documented, no TODO/FIXME on main, code review required.
- Modern APIs: SwiftUI + NavigationStack, Swift Observation (@Observable), Swift Concurrency (async/await); avoid deprecated APIs.
- Testing: unit tests for core logic; UI tests for primary flows; P1 user stories include at least one executable acceptance test in XCTest; deterministic tests; aim ≥70% coverage for critical modules.
- Simplicity: keep structure simple (Models/, Views/); avoid mega‑files; composition over inheritance; minimal global state.
- UX & a11y: Dynamic Type, accessibility labels/traits/actions, clear empty states, smooth 60 fps, use system components and SF Symbols.

### Feature lifecycle

- Create/Update Spec: `/speckit.specify "<feature description>"`
  - Creates a numbered branch and `specs/<###-short-name>/spec.md`.
- Clarify before planning: `/speckit.clarify`
  - Ask up to 5 targeted questions; record answers under `## Clarifications`; update FRs immediately.
- Plan: `/speckit.plan` produces `plan.md`, aligned with Constitution gates.
- Tasks: `/speckit.tasks` generates `tasks.md` grouped by user story.
- Checklists: use when helpful to validate edge cases and gates.

Branching: SpecKit uses numeric prefixes (e.g., `001-related-ideas-linking`). For ad‑hoc work, use `<issue-or-topic>-short-desc`.

### Authoring rules

- Use `.specify/templates/`; fully replace placeholders (no `[ALL_CAPS]` tokens left).
- Write specs/plans/tasks in Traditional Chinese unless a feature explicitly targets another locale.
- P1 stories must include executable acceptance scenarios mapping to XCTest (unit or UI).
- Keep specs focused on WHAT/WHY; defer detailed HOW to planning and code.

### PR checklist

- Constitution Check evidence in the plan (link or summary).
- Tests added/updated and passing; UI changes include screenshots or short videos.
- No new build warnings; static analysis clean if enabled.
- Accessibility covered for new UI (labels/traits, Dynamic Type, empty states).
- Any added complexity is justified (doc note or inline comments).

### Governance

- Changes to the Constitution require updating `.specify/memory/constitution.md` with a Sync Impact Report and a semantic version bump.
- If a spec conflicts with the Constitution, update the spec to comply and annotate the deviation rationale.

### Quick links

- Constitution: `.specify/memory/constitution.md`
- Templates: `.specify/templates/`
- Scripts: `.specify/scripts/bash/`
- Specs: `specs/`
