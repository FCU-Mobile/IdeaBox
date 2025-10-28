//
//  SimilarityEngine.swift
//  IdeaBox
//
//  Created by Copilot on 10/28/25.
//

import Foundation

/// Protocol for computing embeddings and measuring similarity.
protocol SimilarityEngine {
    /// Compose idea text and embed to a normalized vector.
    func embed(title: String, description: String?) throws -> [Float]
    /// Cosine similarity of two normalized vectors.
    func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float
}

/// A deterministic baseline implementation using simple bag-of-words counts.
/// Title is weighted higher than description.
final class BaselineSimilarityEngine: SimilarityEngine {
    private let titleWeight: Float
    private let descWeight: Float
    private let tokenizer: (String) -> [String]

    init(titleWeight: Float = 0.7, descWeight: Float = 0.3, tokenizer: @escaping (String) -> [String] = defaultTokenizer) {
        self.titleWeight = titleWeight
        self.descWeight = descWeight
        self.tokenizer = tokenizer
    }

    func embed(title: String, description: String?) throws -> [Float] {
        var freq: [String: Float] = [:]
        for token in tokenizer(title) { freq[token, default: 0] += titleWeight }
        if let d = description { for token in tokenizer(d) { freq[token, default: 0] += descWeight } }
        // Map to stable order for determinism
        let keys = freq.keys.sorted()
        var vec = keys.map { freq[$0] ?? 0 }
        normalize(&vec)
        return vec
    }

    func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        if a.isEmpty || b.isEmpty { return 0 }
        let count = min(a.count, b.count)
        var dot: Float = 0
        var na: Float = 0
        var nb: Float = 0
        for i in 0..<count {
            let x = a[i]
            let y = b[i]
            dot += x * y
            na += x * x
            nb += y * y
        }
        let denom = (sqrtf(na) * sqrtf(nb))
        return denom == 0 ? 0 : (dot / denom)
    }

    // MARK: - Helpers

    private func normalize(_ vec: inout [Float]) {
        var sumsq: Float = 0
        for x in vec { sumsq += x * x }
        let n = sqrtf(sumsq)
        if n > 0 { for i in 0..<vec.count { vec[i] /= n } }
    }

}

// A free function to avoid actor isolation warnings for default argument usage.
func defaultTokenizer(_ text: String) -> [String] {
    return text
        .lowercased()
        .components(separatedBy: CharacterSet.alphanumerics.inverted)
        .filter { !$0.isEmpty }
}
