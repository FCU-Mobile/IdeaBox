//
//  SearchView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/2/25.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allIdeas: [Idea]
    @State private var searchText = ""

    var filteredIdeas: [Idea] {
        if searchText.isEmpty {
            return []
        }
        return allIdeas.filter { idea in
            idea.title.localizedCaseInsensitiveContains(searchText) ||
            (idea.detail ?? "").localizedCaseInsensitiveContains(searchText)
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
                            IdeaRow(idea: idea)
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Search ideas...")
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(for: Idea.self, inMemory: true)
}
