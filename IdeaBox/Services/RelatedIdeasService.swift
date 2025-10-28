//
//  RelatedIdeasService.swift
//  IdeaBox
//
//  Created by Copilot on 10/28/25.
//

import Foundation

/// Service to compute related ideas using embeddings + index + optional reranker.
final class RelatedIdeasService {
    private let engine: SimilarityEngine
    private let index: EmbeddingsIndex
    private let reranker: LLMReranker

    init(engine: SimilarityEngine = BaselineSimilarityEngine(), index: EmbeddingsIndex = LinearEmbeddingsIndex(), reranker: LLMReranker = NoOpLLMReranker()) {
        self.engine = engine
        self.index = index
        self.reranker = reranker
    }

    // Build or update the index for the given ideas.
    func rebuildIndex(ideas: [Idea]) {
        for idea in ideas {
            if let vec = try? engine.embed(title: idea.title, description: idea.description) {
                index.upsert(id: idea.id, vector: vec)
            }
        }
    }

    struct RelatedResult {
        let pinned: [Idea]
        let suggested: [Idea]
    }

    /// Compute related ideas for a given idea, respecting pinned links and blacklist.
    func related(for idea: Idea,
                 allIdeas: [Idea],
                 links: [IdeaLink],
                 blacklist: Set<IdeaBlacklistPair>,
                 maxN: Int = RelatedPreferences.maxN,
                 tau: Float = RelatedPreferences.tau) -> RelatedResult {
        // Pinned first
        let pinnedIDs: Set<UUID> = Set(
            links.filter { $0.pinned }.flatMap { [$0.a, $0.b] }
        ).subtracting([idea.id])

        let pinnedIdeas = allIdeas.filter { pinnedIDs.contains($0.id) }

        // Suggested via embedding index
        guard let queryVec = try? engine.embed(title: idea.title, description: idea.description) else {
            return RelatedResult(pinned: pinnedIdeas, suggested: [])
        }

        // Exclude self and pinned and blacklisted
        let candidates = index.query(vector: queryVec, topK: maxN * 2, threshold: tau, similarity: engine.cosineSimilarity)
            .map { $0.0 }
            .filter { $0 != idea.id && !pinnedIDs.contains($0) && !blacklist.containsPair(idea.id, $0) }

        // Optional rerank (NoOp preserves order)
        let candidateTexts: [String] = allIdeas.reduce(into: [UUID: String]()) { dict, i in
            dict[i.id] = i.title + "\n" + i.description
        }.filter { candidates.contains($0.key) }.map { $0.value }

        let rerankedIndices = (try? reranker.rerank(query: idea.title + "\n" + idea.description, candidates: candidateTexts, topK: maxN)) ?? Array(0..<min(maxN, candidates.count))

        let selectedIDs: [UUID] = rerankedIndices.compactMap { idx in
            guard idx >= 0 && idx < candidates.count else { return nil }
            return candidates[idx]
        }

        let suggestedIdeas: [Idea] = selectedIDs.compactMap { id in allIdeas.first(where: { $0.id == id }) }
        return RelatedResult(pinned: pinnedIdeas, suggested: suggestedIdeas)
    }
}
