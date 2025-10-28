# Implementation Plan: Related Ideas Linking

**Branch**: `001-related-ideas-linking` | **Date**: 2025-10-28 | **Spec**: `specs/001-related-ideas-linking/spec.md`
**Input**: Feature specification from `specs/001-related-ideas-linking/spec.md`

## Summary

Implement on-device related-ideas linking using semantic similarity over Idea title/description. Compute embeddings locally, maintain bidirectional links, and present results in modern SwiftUI using system components. Recompute on save; show Top‑N above a threshold; manual removals blacklist a pair; manual links are pinned and don’t count toward N. Prefer fully offline and private approaches. Optionally re-rank with a local LLM via the “Foundation Models” framework if available; otherwise, rely on embeddings-only ranking.

## Technical Context

**Language/Version**: Swift 6.2  
**Primary Dependencies**: SwiftUI, Observation (@Observable), Swift Concurrency, NaturalLanguage (NLEmbedding) and/or Core ML for sentence embeddings; optional: “Foundation Models” LLM API (NEEDS CLARIFICATION)  
**Storage**: In-memory store for MVP; persisted user preferences (N and threshold τ) via `UserDefaults`. Future-proofs for embedding cache (file/CoreData) if needed.  
**Testing**: Swift Testing for unit tests; existing XCTest UI tests continue for primary flows. P1 acceptance covered by UI test or Swift Testing UI harness where supported.  
**Target Platform**: iOS 26+ (modern SwiftUI APIs)  
**Project Type**: Mobile (single iOS app)  
**Performance Goals**: Related list initial render ≤ 1s (p95) for up to ~1k ideas; maintain 60 fps UI  
**Constraints**: 100% on-device; offline-capable; no network calls for similarity/LLM  
**Scale/Scope**: MVP assumes up to ~1k ideas; linear scan is acceptable; design allows swapping in an index if needed

Unknowns (to resolve in research):
- What exact “Foundation Models framework” API is available for Swift/iOS? If unavailable, we’ll proceed with embeddings-only and keep a protocol abstraction for a reranker. (NEEDS CLARIFICATION)

## Constitution Check

Pre‑design evaluation: PASS (no violations anticipated)

- 代碼品質：Small, single‑purpose types (engines/protocols); public APIs documented; no new warnings; rationale recorded for any new folder (Services/). 
- 現代 API：SwiftUI + NavigationStack; Observation; async/await for background similarity work. 
- 測試：Swift Testing for unit coverage of similarity computation and ranking; UI tests for P1 flow; at least one executable acceptance test for User Story 1. 
- 結構簡單：Reuse Models/ and Views/; add minimal `Services/` for engines to avoid bloating views. 
- UX 與無障礙：Dynamic Type, a11y labels for “Related” section; clear empty states; ensure smooth scrolling.

Post‑design re‑evaluation appears in the end of this document.

## Project Structure

### Documentation (this feature)

```text
specs/001-related-ideas-linking/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (internal protocol contracts)
└── tasks.md             # Phase 2 (created by /speckit.tasks)
```

### Source Code (repository root)

```text
IdeaBox/
├── Models/
│   ├── Idea.swift
│   ├── IdeaLink.swift                 # NEW: link model (auto/manual, pinned, score)
│   └── IdeaBlacklist.swift            # NEW: pair blacklist
├── Services/                          # NEW: minimal services to keep Views light
│   ├── SimilarityEngine.swift         # Protocol + default implementation (embeddings)
│   ├── EmbeddingsIndex.swift          # In-memory index with linear scan
│   └── LLMReranker.swift              # Protocol; optional no-op impl
└── Views/
    ├── RelatedIdeasSection.swift      # NEW: system List/DisclosureGroup section
    └── IdeaFocusView.swift            # NEW: focus view with pinned + suggested groups

IdeaBoxTests/
└── SimilarityTests.swift              # Swift Testing: unit tests for similarity/ranking
```

**Structure Decision**: Keep existing simple structure. Add a small `Services/` folder to isolate computation and preserve view simplicity per Constitution.

## Complexity Tracking

N/A — No Constitution violations expected.

## Phase 0: Outline & Research

See `research.md` for decisions on embeddings (Core ML vs NaturalLanguage), LLM reranking feasibility, storage, and thresholds.

## Phase 1: Design & Contracts

- Data Model: see `data-model.md` (Idea, IdeaLink, LinkType, Blacklist, Embedding).
- Contracts: see `contracts/` for Swift protocol definitions enabling engine swap.
- Quickstart: see `quickstart.md` for running, toggling feature, and tests.

## Constitution Check (post‑design)

Re‑evaluation: PASS

- Rationale: The design adds minimal surface area (Services/) and uses modern APIs. All logic is testable with Swift Testing; UI flows remain covered by existing XCTest. No deprecated APIs; a11y and empty states addressed.
