# Data Model: Related Ideas Linking

## Entities

### Idea
- id: UUID (implicit/derived)
- title: String (non-empty)
- description: String (nullable/empty allowed)
- isCompleted: Bool
- createdAt: Date
- updatedAt: Date
- links: [IdeaLink] (derived view or persisted, see below)

Validation:
- title trimmed non-empty; description optional.

### IdeaLink
- a: IdeaID (UUID)
- b: IdeaID (UUID)
- type: LinkType (auto | manual)
- pinned: Bool (true only for manual)
- score: Double (0..1, optional for manual)
- createdAt: Date
- updatedAt: Date

Invariants:
- Symmetry: if (a,b) exists, (b,a) is implied; present once, render as needed.
- Uniqueness: (min(a,b), max(a,b)) unique.
- Pinned manual links display first and do not count toward Top‑N.

### LinkType
- auto
- manual

### BlacklistPair
- a: IdeaID (UUID)
- b: IdeaID (UUID)
- reason: String? (optional note)
- createdAt: Date

Invariants:
- Symmetry: if (a,b) blacklisted, (b,a) is blacklisted.
- Uniqueness: (min(a,b), max(a,b)) unique.

### Embedding (derived/cache)
- ideaID: UUID
- vector: [Float] (normalized)
- modelVersion: String (e.g., "MiniLM-ml-q8")
- languageHint: String? (e.g., "zh", "en", or "auto")
- updatedAt: Date

Notes:
- For MVP, embeddings may be computed on the fly and cached in memory; persistence is optional.

## Relationships
- Idea has many IdeaLink (both directions considered a single undirected link).
- Idea participates in zero or more BlacklistPair entries with other ideas.

## Derived Views
- RelatedIdeasViewModel computes two sections:
  - Pinned (manual, pinned=true)
  - Suggested (auto, score ≥ τ, top‑N)

## State Transitions
- On save Idea:
  1) Update embedding for the idea.
  2) Recompute similarity against other embeddings.
  3) Exclude blacklisted pairs.
  4) Merge with pinned manual links (separate section, not counted in N).
  5) Update UI model.

- On manual add link A‑B:
  - Create IdeaLink {type=manual, pinned=true} and ensure symmetry.

- On manual remove link A‑B:
  - Remove any existing link and add BlacklistPair(A,B).

- On restore suggestion A‑B:
  - Remove BlacklistPair(A,B). Auto suggestions may reappear if score ≥ τ.
