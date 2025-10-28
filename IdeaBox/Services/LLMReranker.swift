//
//  LLMReranker.swift
//  IdeaBox
//
//  Created by Copilot on 10/28/25.
//

import Foundation

protocol LLMReranker {
    /// Returns indices of candidates in reranked order (descending relevance).
    func rerank(query: String, candidates: [String], topK: Int) throws -> [Int]
}

struct NoOpLLMReranker: LLMReranker {
    func rerank(query: String, candidates: [String], topK: Int) throws -> [Int] {
        // Preserve input order
        let count = min(topK, candidates.count)
        return Array(0..<count)
    }
}
