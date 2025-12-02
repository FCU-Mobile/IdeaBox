//
//  ContentView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI

struct ContentView: View {
    @State private var ideas = Idea.mockIdeas
    @State private var showingAddIdea = false

    var body: some View {
        TabView {
            Tab("All", systemImage: "list.bullet") {
                AllIdeasView(ideas: $ideas, showingAddIdea: $showingAddIdea)
            }

            Tab("Completed", systemImage: "checkmark.circle.fill") {
                CompletedIdeasView(ideas: $ideas)
            }

            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView(ideas: $ideas)
            }
        }
        .sheet(isPresented: $showingAddIdea) {
            AddIdeaSheet { newIdea in
                ideas.insert(newIdea, at: 0)
            }
        }
    }
}

#Preview {
    ContentView()
}
