//
//  IdeaViewModel.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/2/25.
//

import Foundation
import SwiftUI

@Observable
class IdeaModel {
    var ideas: [Idea] = Idea.mockIdeas
    
    // MARK: - Intents
    
    func addIdea(title: String, description: String) {
//        let newIdea = Idea(title: title, description: description)
//        ideas.insert(newIdea, at: 0)
    }
    
    func deleteIdeas(at offsets: IndexSet) {
//        ideas.remove(atOffsets: offsets)
    }
    
    func toggleCompletion(for idea: Idea) {
//        if let index = ideas.firstIndex(where: { $0.id == idea.id }) {
//            ideas[index].isCompleted.toggle()
//        }
    }
}
