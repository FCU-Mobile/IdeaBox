//
//  SearchView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/2/25.
//

import SwiftUI

struct SearchView: View {
    var model: IdeaModel
    @State private var searchText = ""

    var filteredIdeas: [Idea] {
        if searchText.isEmpty {
            return []
        }
        return model.ideas.filter { idea in
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
                                model.toggleCompletion(for: idea)
                            }
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
    @Previewable @State var model = IdeaModel()

    SearchView(model: model)
}
