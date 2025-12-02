//
//  CompletedIdeasView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI

struct CompletedIdeasView: View {
    @Binding var ideas: [Idea]

    var completedIdeas: [Idea] {
        ideas.filter { $0.isCompleted }
    }

    var body: some View {
        NavigationStack {
            Group {
                if completedIdeas.isEmpty {
                    ContentUnavailableView(
                        "No Completed Ideas",
                        systemImage: "checkmark.circle",
                        description: Text("Ideas you mark as complete will appear here")
                    )
                } else {
                    List {
                        ForEach(completedIdeas) { idea in
                            IdeaRow(idea: idea) {
                                toggleCompletion(for: idea)
                            }
                        }
                        .onDelete(perform: deleteIdeas)
                    }
                }
            }
            .navigationTitle("Completed")
        }
    }

    private func toggleCompletion(for idea: Idea) {
        if let index = ideas.firstIndex(where: { $0.id == idea.id }) {
            ideas[index].isCompleted.toggle()
        }
    }

    private func deleteIdeas(at offsets: IndexSet) {
        let idsToDelete = offsets.map { completedIdeas[$0].id }
        ideas.removeAll { idea in idsToDelete.contains(idea.id) }
    }
}

#Preview {
    @Previewable @State var ideas = Idea.mockIdeas

    CompletedIdeasView(ideas: $ideas)
}
