//
//  SimilarityTests.swift
//  IdeaBoxTests
//
//  Created by Copilot on 10/28/25.
//

import Foundation
import Testing
@testable import IdeaBox

struct SimilarityTests {

    @Test func baselineEmbeddingProducesDeterministicVector() throws {
        let engine = BaselineSimilarityEngine()
        let v1 = try engine.embed(title: "Hello World", description: "Hello SwiftUI")
        let v2 = try engine.embed(title: "Hello World", description: "Hello SwiftUI")
        #expect(v1 == v2)
    }

    @Test func cosineSimilarityWithinRange() throws {
        let engine = BaselineSimilarityEngine()
        let a = try engine.embed(title: "SwiftUI List", description: "NavigationStack")
        let b = try engine.embed(title: "SwiftUI List", description: "NavigationStack")
        let c = try engine.embed(title: "Different Topic", description: "Totally unrelated")
        let ab = engine.cosineSimilarity(a, b)
        let ac = engine.cosineSimilarity(a, c)
        #expect(ab > 0.9)
        #expect(ac < 0.9)
    }

    @Test func linearIndexFiltersByThresholdAndTopK() throws {
        let engine = BaselineSimilarityEngine()
        let index = LinearEmbeddingsIndex()
        let ideas: [Idea] = [
            Idea(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, title: "SwiftUI Animations", description: "Smooth transitions"),
            Idea(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, title: "Core ML Embeddings", description: "On-device"),
            Idea(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!, title: "Gardening Tips", description: "Plant care"),
        ]
        for i in ideas {
            let v = try engine.embed(title: i.title, description: i.description)
            index.upsert(id: i.id, vector: v)
        }
        let query = try engine.embed(title: "SwiftUI List", description: "Navigation")
        let results = index.query(vector: query, topK: 2, threshold: 0.1, similarity: engine.cosineSimilarity)
        #expect(results.count <= 2)
    }

    @Test func relatedServiceRespectsPinnedAndBlacklist() throws {
        let engine = BaselineSimilarityEngine()
        let index = LinearEmbeddingsIndex()
        let svc = RelatedIdeasService(engine: engine, index: index, reranker: NoOpLLMReranker())

        let a = Idea(id: UUID(uuidString: "00000000-0000-0000-0000-0000000000AA")!, title: "SwiftUI", description: "List Navigation")
        let b = Idea(id: UUID(uuidString: "00000000-0000-0000-0000-0000000000BB")!, title: "UIKit", description: "TableView")
        let c = Idea(id: UUID(uuidString: "00000000-0000-0000-0000-0000000000CC")!, title: "Gardening", description: "Plants care")
        let ideas = [a, b, c]
        svc.rebuildIndex(ideas: ideas)

        // Pinned link A<->B
        let pinned = [IdeaLink(a: a.id, b: b.id, type: .manual, pinned: true)]
        let blacklist = Set<IdeaBlacklistPair>()

        let res1 = svc.related(for: a, allIdeas: ideas, links: pinned, blacklist: blacklist, maxN: 5, tau: 0.0)
        #expect(res1.pinned.contains(where: { $0.id == b.id }))

        // Blacklist A<->C should exclude C from suggestions even if similar
        let bl = Set([IdeaBlacklistPair(a: a.id, b: c.id)])
        let res2 = svc.related(for: a, allIdeas: ideas, links: pinned, blacklist: bl, maxN: 5, tau: 0.0)
        #expect(!res2.suggested.contains(where: { $0.id == c.id }))
    }
}
