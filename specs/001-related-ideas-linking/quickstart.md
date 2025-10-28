# Quickstart: Related Ideas Linking

## Goals
- On-device semantic similarity for zh/en ideas.
- Top‑N with threshold, recompute on save, pinned manual links.
- Modern SwiftUI using system components only.
- Swift Testing for unit tests; UI acceptance test for P1.

## How to use (dev)
1) Work on branch `001-related-ideas-linking`.
2) Implement `Services/SimilarityEngine.swift` and `Services/EmbeddingsIndex.swift` with a simple baseline first.
3) Add UI: `RelatedIdeasSection.swift` and `IdeaFocusView.swift` using List/NavigationStack/DisclosureGroup.
4) Wire recompute on save in the view model.
5) Add Swift Testing unit tests in `IdeaBoxTests/SimilarityTests.swift`.
6) Add a UI test for P1 flow (new idea → related list → focus → back).

## Feature flags
- `USE_COREML_EMBEDDINGS` (default false): swap baseline with Core ML implementation when available.
- `USE_LLM_RERANKER` (default false): enable reranking if a local "Foundation Models" LLM API is present; otherwise no-op.

## Tuning
- User preference keys: `related.maxN` (5–20, default 10), `related.thresholdTau` (0.4–0.9, default 0.65).

## Notes
- Keep all heavy work off the main thread; use Task and TaskGroup.
- Respect blacklist and pinned sections; pinned does not count toward N.
- All computation and state remain on-device to satisfy privacy/offline.

## Agent context update
- Ran `.specify/scripts/bash/update-agent-context.sh copilot`.
- Created/updated `.github/copilot-instructions.md` with language (Swift 6.2) and storage notes (UserDefaults prefs, optional embedding cache).
