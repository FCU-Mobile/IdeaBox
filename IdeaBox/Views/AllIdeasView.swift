//
//  AllIdeasView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI

struct AllIdeasView: View {
    @Binding var ideas: [Idea]
    @Binding var showingAddIdea: Bool
    @State private var showFocus = false
    @State private var selectedIdea: Idea? = nil
    private let relatedService = RelatedIdeasService()

    var body: some View {
        NavigationStack {
            List {
                ForEach(ideas) { idea in
                    IdeaRow(idea: idea) { toggleCompletion(for: idea) }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                selectedIdea = idea
                                relatedService.rebuildIndex(ideas: ideas)
                                showFocus = true
                            } label: {
                                Label("Related", systemImage: "link")
                            }
                            .tint(.blue)
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
            .sheet(isPresented: $showFocus, onDismiss: { selectedIdea = nil }) {
                if let idea = selectedIdea {
                    IdeaFocusView(idea: idea, allIdeas: ideas, service: relatedService)
                }
            }
        }
    }

    private func toggleCompletion(for idea: Idea) {
        if let index = ideas.firstIndex(where: { $0.id == idea.id }) {
            ideas[index].isCompleted.toggle()
        }
    }

    private func deleteIdeas(at offsets: IndexSet) {
        ideas.remove(atOffsets: offsets)
    }
}

#Preview {
    @Previewable @State var ideas = Idea.mockIdeas
    @Previewable @State var showingAdd = false

    AllIdeasView(ideas: $ideas, showingAddIdea: $showingAdd)
}
