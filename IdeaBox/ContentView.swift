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

    // Related service state
    private let relatedService = RelatedIdeasService()
    @State private var showFocus = false
    @State private var focusIdea: Idea? = nil

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
                // Rebuild index on save and show focus view
                relatedService.rebuildIndex(ideas: ideas)
                focusIdea = newIdea
                showFocus = true
            }
        }
        .sheet(isPresented: $showFocus, onDismiss: { focusIdea = nil }) {
            if let idea = focusIdea {
                IdeaFocusView(idea: idea, allIdeas: ideas, service: relatedService)
            }
        }
        .task {
            // Build initial index
            relatedService.rebuildIndex(ideas: ideas)
        }
    }
}

#Preview {
    ContentView()
}
