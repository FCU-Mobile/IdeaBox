# Tasks: Related Ideas Linking

Feature Branch: 001-related-ideas-linking
Feature Dir: /Users/harryworld/Developer/harryworld/IdeaBox/specs/001-related-ideas-linking

## Dependencies (story order)
1) US1 (P1): 新增後顯示相關點子 — MVP scope
2) US2 (P2): 既有點子的相關清單與延伸探索
3) US3 (P3): 手動維護關聯（Pinned/Blacklist）

Parallelization guidance: Within each phase, tasks marked [P] can proceed in parallel (different files, no unmet deps).

---

## Phase 1 — Setup

- [ ] T001 Create model file IdeaLink.swift at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Models/IdeaLink.swift
- [ ] T002 Create model file IdeaBlacklist.swift at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Models/IdeaBlacklist.swift
- [ ] T003 Create services folder (if missing) at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Services/
- [ ] T004 [P] Create SimilarityEngine.swift stub at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Services/SimilarityEngine.swift
- [ ] T005 [P] Create EmbeddingsIndex.swift stub at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Services/EmbeddingsIndex.swift
- [ ] T006 [P] Create LLMReranker.swift (no-op impl + protocol) at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Services/LLMReranker.swift
- [ ] T007 [P] Create RelatedPreferences.swift (N, τ storage) at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Services/RelatedPreferences.swift
- [ ] T008 Add feature flags (USE_COREML_EMBEDDINGS, USE_LLM_RERANKER) at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/
- [ ] T009 Update agent context for Copilot via script (optional) — document result in /Users/harryworld/Developer/harryworld/IdeaBox/specs/001-related-ideas-linking/quickstart.md

## Phase 2 — Foundational

- [ ] T010 Implement baseline SimilarityEngine (deterministic BOW cosine) in /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Services/SimilarityEngine.swift
- [ ] T011 Implement EmbeddingsIndex linear scan with normalized vectors in /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Services/EmbeddingsIndex.swift
- [ ] T012 [P] Implement RelatedIdeasService (merge engine+index, threshold τ, Top‑N, blacklist, pinned separation) at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Services/RelatedIdeasService.swift
- [ ] T013 [P] Implement NoOp LLMReranker and a pluggable seam in RelatedIdeasService at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Services/LLMReranker.swift
- [ ] T014 Add Swift Testing unit tests for engine and ranking at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBoxTests/SimilarityTests.swift

## Phase 3 — US1 (P1): 新增後顯示相關點子

Goal: After saving a new idea, show related list (Top‑N ≥ τ). Tap to focus, view extended links, and return.
Independent Test: UI flows from add → related list → focus → back.

- [ ] T015 [US1] Wire recompute-on-save in AddIdea flow at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Views/AddIdeaSheet.swift
- [ ] T016 [P] [US1] Create RelatedIdeasSection.swift using List/DisclosureGroup at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Views/RelatedIdeasSection.swift
- [ ] T017 [P] [US1] Create IdeaFocusView.swift with Pinned + Suggested sections at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Views/IdeaFocusView.swift
- [ ] T018 [US1] Integrate navigation from post-save to related list/focus view at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/ContentView.swift
- [ ] T019 [US1] Empty state for no results (ContentUnavailableView) at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Views/RelatedIdeasSection.swift
- [ ] T020 [US1] Accessibility: labels/traits/actions for related items and sections at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Views/RelatedIdeasSection.swift
- [ ] T021 [US1] Add UI acceptance test: add → related list → focus → back at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBoxUITests/RelatedFlowUITests.swift

## Phase 4 — US2 (P2): 既有點子的相關清單與延伸探索

Goal: From any existing idea, view related list and navigate to focus; continue exploration.
Independent Test: Open existing idea → related list → other idea focus.

- [ ] T022 [US2] Add entry point to related list from existing ideas (button/menu) at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Views/IdeaRow.swift
- [ ] T023 [P] [US2] Route to IdeaFocusView with correct model binding at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Views/AllIdeasView.swift
- [ ] T024 [US2] Preserve navigation state on back at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/ContentView.swift

## Phase 5 — US3 (P3): 手動維護關聯（Pinned/Blacklist）

Goal: Manually add/remove links; keep symmetry; pinned links prioritized and excluded from Top‑N.
Independent Test: Add A↔B link → appears in both lists; remove A↔B → both lists drop and pair blacklisted.

- [ ] T025 [US3] Manual add link control in IdeaFocusView (A ↔ B) at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Views/IdeaFocusView.swift
- [ ] T026 [P] [US3] Implement persistence for manual links (pinned=true) at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Models/IdeaLink.swift
- [ ] T027 [P] [US3] Implement remove link → update both sides and add blacklist at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Models/IdeaBlacklist.swift
- [ ] T028 [US3] Add "Restore suggestions" entry to remove pair from blacklist at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Views/IdeaFocusView.swift

## Final Phase — Polish & Cross-Cutting

- [ ] T029 Document thresholds and preferences in quickstart.md at /Users/harryworld/Developer/harryworld/IdeaBox/specs/001-related-ideas-linking/quickstart.md
- [ ] T030 Performance: ensure work off main thread; verify p95 ≤ 1s at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Services/RelatedIdeasService.swift
- [ ] T031 A11y verification for screen reader flows at /Users/harryworld/Developer/harryworld/IdeaBox/IdeaBox/Views/IdeaFocusView.swift
- [ ] T032 Add screenshots/video to PR for new UI at /Users/harryworld/Developer/harryworld/IdeaBox/

---

## Parallel execution examples
- Setup: T004/T005/T006/T007 can run in parallel after T003 creates Services/
- Foundational: T012 and T013 can run in parallel after T010/T011
- US1: T016 and T017 can run in parallel after T015 (wiring save trigger)
- US3: T026 and T027 can run in parallel

## Implementation strategy
- MVP first: Deliver US1 end-to-end using the baseline engine and linear index.
- Incremental: Add US2 entry points; then US3 manual management.
- Optional: Swap in Core ML embeddings and (if available) local Foundation Models reranker behind flags.

## Format validation
- All tasks follow the checklist format: `- [ ] T### [P]? [US?] Description with file path`

## Summary report
- Output: /Users/harryworld/Developer/harryworld/IdeaBox/specs/001-related-ideas-linking/tasks.md
- Total tasks: 32
- Per user story: US1 = 7 (T015–T021), US2 = 3 (T022–T024), US3 = 4 (T025–T028)
- Parallel opportunities: Setup (4), Foundational (2), US1 (2), US3 (2)
- MVP scope: Phase 1–2 + US1
