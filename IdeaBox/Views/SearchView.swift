//
//  SearchView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/2/25.
//

import SwiftUI

struct SearchView: View {
    @Binding var ideas: [Idea]
    @State private var searchText = ""

    var filteredIdeas: [Idea] {
        if searchText.isEmpty {
            return []
        }
        return ideas.filter { idea in
            idea.title.localizedCaseInsensitiveContains(searchText) ||
            idea.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    ContentUnavailableView(
                        "Search Ideas",
                        systemImage: "magnifyingglass",
                        description: Text("Enter keywords to search through your ideas")
                    )
                } else if filteredIdeas.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List {
                        ForEach(filteredIdeas) { idea in
                            IdeaRow(idea: idea) {
                                toggleCompletion(for: idea)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search ideas...")
        }
    }

    private func toggleCompletion(for idea: Idea) {
        if let index = ideas.firstIndex(where: { $0.id == idea.id }) {
            ideas[index].isCompleted.toggle()
        }
    }
}

#Preview {
    @Previewable @State var ideas = Idea.mockIdeas

    SearchView(ideas: $ideas)
}
