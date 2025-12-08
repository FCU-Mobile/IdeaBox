//
//  IdeaViewModelTests.swift
//  IdeaBoxTests
//
//  Created by Harry Ng on 10/2/25.
//

import Foundation
import Testing
@testable import IdeaBox

@MainActor
struct IdeaModelTests {
    @Test func testAddIdea() async throws {
        let model = IdeaModel()
        let initialCount = model.ideas.count

        model.addIdea(title: "New Idea", description: "Description")

        #expect(model.ideas.count == initialCount + 1)
        #expect(model.ideas.first?.title == "New Idea")
        #expect(model.ideas.first?.description == "Description")
    }

    @Test func testToggleCompletion() async throws {
        let model = IdeaModel()
        let idea = model.ideas[0]
        let initialStatus = idea.isCompleted

        model.toggleCompletion(for: idea)

        #expect(model.ideas[0].isCompleted != initialStatus)
    }

    @Test func testDeleteIdeas() async throws {
        let model = IdeaModel()
        let initialCount = model.ideas.count

        model.deleteIdeas(at: IndexSet([0, 1]))

        #expect(model.ideas.count == initialCount - 2)
    }
}
