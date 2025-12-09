//
//  IdeaGenerator.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import Foundation
import FoundationModels
import Playgrounds

@Generable(description: "An idea with a title and description.")
struct GeneratedIdea: Codable {
    let title: String
    let description: String
}

@Generable
struct ResultIdeas {
    let language: String
    @Guide(.maximumCount(5))
    let ideas: [GeneratedIdea]
}

class IdeaGenerator {
    static let shared = IdeaGenerator()

    static let prefixPrompt = """
    把以下的文字，拆分成幾個具體且清晰的點子。每個點子都應包含一個簡短的標題和描述。
    use locale: zh-Hant-TW
    """

    func generateIdeas(from text: String) async throws -> [GeneratedIdea] {
        let session = LanguageModelSession()

        let prompt = """
            \(Self.prefixPrompt)
        
        \(text)
        """
        
        let result = try await session.respond(
            to: prompt,
            generating: ResultIdeas.self
        )
        
        return result.content.ideas
    }
}

#Playground {
    SystemLanguageModel.default.supportedLanguages

    let session = LanguageModelSession()
    let prompt = """
    \(IdeaGenerator.prefixPrompt)
    
    學習 SwiftUI
    """

    let result = try await session.respond(
        to: prompt,
        generating: ResultIdeas.self
    )
    let ideas = result.content.ideas
}
