//
//  EmbeddingsIndex.swift
//  IdeaBox
//
//  Created by Copilot on 10/28/25.
//

import Foundation

protocol EmbeddingsIndex {
    func upsert(id: UUID, vector: [Float])
    func remove(id: UUID)
    func query(vector: [Float], topK: Int, threshold: Float, similarity: (_ a: [Float], _ b: [Float]) -> Float) -> [(UUID, Float)]
}

final class LinearEmbeddingsIndex: EmbeddingsIndex {
    private var store: [UUID: [Float]] = [:]

    func upsert(id: UUID, vector: [Float]) {
        store[id] = vector
    }

    func remove(id: UUID) {
        store.removeValue(forKey: id)
    }

    func query(vector: [Float], topK: Int, threshold: Float, similarity: (_ a: [Float], _ b: [Float]) -> Float) -> [(UUID, Float)] {
        var scores: [(UUID, Float)] = []
        scores.reserveCapacity(store.count)
        for (id, vec) in store {
            let s = similarity(vector, vec)
            if s >= threshold { scores.append((id, s)) }
        }
        scores.sort { $0.1 > $1.1 }
        if scores.count > topK { return Array(scores.prefix(topK)) }
        return scores
    }
}
