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
    @State private var sheetPresentation: SheetPresentation?

    var body: some View {
        TabView {
            Tab("All", systemImage: "list.bullet") {
                AllIdeasView(sheetPresentation: $sheetPresentation)
            }

            Tab("Completed", systemImage: "checkmark.circle.fill") {
                CompletedIdeasView(sheetPresentation: $sheetPresentation)
            }

            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView(sheetPresentation: $sheetPresentation)
            }
        }
        .sheet(item: $sheetPresentation) { presentation in
            switch presentation {
            case .addNew:
                AddIdeaSheet(ideaToEdit: nil)
            case .edit(let idea):
                AddIdeaSheet(ideaToEdit: idea)
            }
        }
    }
}

enum SheetPresentation: Identifiable {
    case addNew
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
