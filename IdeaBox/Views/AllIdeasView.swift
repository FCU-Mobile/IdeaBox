//
//  AllIdeasView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI
import SwiftData

struct AllIdeasView: View {
    @Query var ideas: [Idea]
    @Binding var showingAddIdea: Bool
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                ForEach(ideas) { idea in
                    IdeaRow(idea: idea) {
                        toggleCompletion(for: idea)
                    }
                }
                .onDelete(perform: deleteIdeas)
            }
            .navigationTitle("All Ideas")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddIdea = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private func toggleCompletion(for idea: Idea) {
        idea.isCompleted.toggle()
    }

    private func deleteIdeas(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(ideas[index])
        }
    }
}

#Preview {
    @State var showingAdd = false
    AllIdeasView(showingAddIdea: $showingAdd)
        .modelContainer(for: Idea.self, inMemory: true)
}
