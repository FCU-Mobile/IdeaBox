//
//  FeatureFlags.swift
//  IdeaBox
//
//  Created by Copilot on 10/28/25.
//

import Foundation

enum FeatureFlags {
    /// When true, use Core ML embeddings engine instead of baseline.
    static var useCoreMLEmbeddings: Bool {
        #if USE_COREML_EMBEDDINGS
        return true
        #else
        return UserDefaults.standard.bool(forKey: "USE_COREML_EMBEDDINGS")
        #endif
    }

    /// When true, enable local LLM reranker if available.
    static var useLLMReranker: Bool {
        #if USE_LLM_RERANKER
        return true
        #else
        return UserDefaults.standard.bool(forKey: "USE_LLM_RERANKER")
        #endif
    }
}
