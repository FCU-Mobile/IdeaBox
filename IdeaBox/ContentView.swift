//
//  ContentView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI
import SwiftData
import SwiftUINavigation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var destination: Destination?

    var body: some View {
        TabView {
            Tab("All", systemImage: "list.bullet") {
                AllIdeasView(destination: $destination)
            }

            Tab("Completed", systemImage: "checkmark.circle.fill") {
                CompletedIdeasView(destination: $destination)
            }

            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView(destination: $destination)
            }
        }
        .sheet(item: $destination.addNew) { _ in
            AddIdeaSheet(ideaToEdit: nil)
        }
        .sheet(item: $destination.edit) { idea in
            AddIdeaSheet(ideaToEdit: idea)
        }
    }
}

@CasePathable
enum Destination: Identifiable {
    case addNew(Idea)
    case edit(Idea)

    var id: String {
        switch self {
        case .addNew:
            return "addNew"
        case .edit(let idea):
            return "edit-\(idea.id)"
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Idea.self, inMemory: true)
}
