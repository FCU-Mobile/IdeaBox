//
//  ContentView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI
import SwiftData
import SwiftUINavigation

@CasePathable
enum Destination: Identifiable{
    case addIdea(Idea)
    case editIdea(Idea)
    
    var id: String{
        switch self{
            case .addIdea: "add"
            case .editIdea(let idea): "edit-\(idea.id.uuidString)"
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
//    @State private var showingAddIdea = false
//    @State private var ideaToEdit: Idea?
    @State private var destination: Destination? // 定義成optional，可以有空值

    var body: some View {
        TabView {
            Tab("All", systemImage: "list.bullet") {
                AllIdeasView(destination: $destination)
            }
//
//            Tab("Completed", systemImage: "checkmark.circle.fill") {
//                CompletedIdeasView(ideaToEdit: $ideaToEdit)
//            }
//
//            Tab("Search", systemImage: "magnifyingglass", role: .search) {
//                SearchView(ideaToEdit: $ideaToEdit)
//            }
        }
//        .sheet(isPresented: $showingAddIdea) {
//            AddIdeaSheet(ideaToEdit: nil)
//        }
//        .sheet(item: $destination) { destination in
//            switch destination {
//            case .addIdea:
//                AddIdeaSheet(ideaToEdit: nil)
//            case .editIdea(let idea):
//                AddIdeaSheet(ideaToEdit: idea)
//            }
//        }
        .sheet(item: $destination.addIdea){ _ in
            AddIdeaSheet(ideaToEdit: nil)
            
        }
        .sheet(item: $destination.editIdea){ idea in
            AddIdeaSheet(ideaToEdit: idea)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Idea.self, inMemory: true)
}
