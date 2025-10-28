# Contracts: Internal Protocols (Swift)

The feature is fully on-device and does not introduce a network API. Instead of OpenAPI/GraphQL, we define Swift protocols to keep the engines swappable and testable.

```swift
import Foundation

/// Embedding computation + similarity. Backed by Core ML or a simple baseline.
public protocol SimilarityEngine {
    /// Compose idea text with weights (e.g., title 0.7, description 0.3) and embed it.
    func embed(title: String, description: String?) throws -> [Float]
    /// Cosine similarity of two normalized vectors.
    func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float
}

/// Simple in-memory index with linear scan over normalized embeddings.
public protocol EmbeddingsIndex {
    func upsert(id: UUID, vector: [Float])
    func remove(id: UUID)
    /// Returns ordered (id, score) filtered by threshold, limited to topK.
    func query(vector: [Float], topK: Int, threshold: Float) -> [(UUID, Float)]
}

/// Optional reranker using a local LLM. If unavailable, use a no-op implementation.
public protocol LLMReranker {
    /// Stable input format: pairs of (query idea text, candidate idea text).
    /// Returns reranked results by descending score.
    func rerank(query: String, candidates: [String], topK: Int) throws -> [Int]
}
```

Testing notes:
- Provide a deterministic baseline `SimilarityEngine` that tokenizes and computes a simple bag-of-words cosine to enable unit tests without a model.
- Gate Core ML implementation behind a feature flag for E2E testing.
