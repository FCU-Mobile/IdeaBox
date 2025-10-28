# Phase 0 Research: Related Ideas Linking

## Decisions and Rationale

### 1) Embedding approach (semantic similarity)
- Decision: Use a small multilingual sentence embedding model converted to Core ML (e.g., MiniLM family) to generate 256–384D vectors for idea title+description. Quantize to 8‑bit for speed/memory. Normalize vectors; use cosine similarity.
- Rationale: On‑device, privacy‑preserving, bilingual (zh/en), higher semantic quality vs TF‑IDF/word averages; still fast for ~1k ideas.
- Alternatives considered:
  - NaturalLanguage.NLEmbedding word vectors + average: Built‑in, simple; but sentence‑level quality is lower and zh coverage uncertain.
  - TF‑IDF/BM25: Lightweight, improves keyword matches but misses semantic similarity.
  - Remote API (LLM/Embeddings): Rejected due to FR‑013 (fully on‑device, offline, privacy).

Implementation note: The actual Core ML model file is out of scope for this plan. The design exposes a `SimilarityEngine` protocol so we can ship a stub first and plug in the Core ML implementation later without changing UI.

### 2) Candidate retrieval and ranking
- Decision: Linear scan over normalized embeddings with cosine similarity; keep top‑K with a tunable threshold τ. K defaults to N+extra (e.g., 2×N) to allow headroom.
- Rationale: For ≤ ~5k ideas, linear scan is simple and fast on device; avoids premature complexity.
- Alternatives:
  - Approximate nearest neighbor (HNSW/Product Quantization): Added complexity and maintenance; defer until scale demands.

### 3) Optional LLM reranking
- Decision: Provide `LLMReranker` protocol; if a local "Foundation Models" LLM API is available, rerank the top 20 from embeddings; otherwise use a No‑Op implementation.
- Rationale: Keeps architecture ready for improved quality without hard dependency; satisfies “use Foundation Models framework” when available while keeping default path fully local and lightweight.
- Alternatives: Standalone reranker model via Core ML; more work, similar tradeoffs.

### 4) Threshold and weights
- Decision: Default τ = 0.65 (range 0.4–0.9). Weight title higher than description (e.g., 0.7/0.3) when composing text for embedding.
- Rationale: Conservative default to reduce false positives; tunable per FR‑015 with documentation.
- Alternatives: Fixed N only (no threshold) rejected per spec; pure threshold (no N) rejected due to list management UX.

### 5) Recompute policy
- Decision: Recompute related list only when an idea is saved. No real‑time/background recomputes.
- Rationale: Matches FR‑014; keeps UI responsive and energy usage low.

### 6) Storage/indexing
- Decision: In‑memory embedding cache derived from current Idea set; optional persisted cache later if needed. Blacklist and pinned links persisted with ideas.
- Rationale: Simple and fast for MVP; avoids migration/DB work.

---

## Open Questions (NEEDS CLARIFICATION)
- "Foundation Models framework" concrete API on iOS: name/availability/capabilities. If unavailable, we proceed without reranking and keep protocol seam.
- Expected upper bound of ideas (e.g., 1k, 5k, 20k). This influences when to consider ANN indexing.

## Risks and Mitigations
- Risk: No high‑quality bilingual embedding model readily available in Core ML format.
  - Mitigation: Start with English‑biased MiniLM; validate zh; prepare fallback: TF‑IDF hybrid for zh terms to boost recall.
- Risk: Performance on older devices.
  - Mitigation: Quantize model; pre‑normalize vectors; cache embeddings; cap candidate pool; do work off main thread.
- Risk: UX overwhelm with noisy results.
  - Mitigation: Threshold τ and "Pinned" separation; clear empty state; manual blacklist respected.
