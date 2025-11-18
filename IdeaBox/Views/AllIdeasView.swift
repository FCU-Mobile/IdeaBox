//
//  AllIdeasView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI
import SwiftData

struct AllIdeasView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Idea.createdAt, order: .reverse) private var ideas: [Idea]
    @Binding var destination: Destination?

    var body: some View {
        NavigationStack {
            List {
                ForEach(ideas) { idea in
                    IdeaRow(idea: idea, onEdit: { destination = .edit($0) })
                }
                .onDelete(perform: deleteIdeas)
            }
            .navigationTitle("All Ideas")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { destination = .addNew(Idea(title: "")) }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private func deleteIdeas(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(ideas[index])
        }
    }
}

#Preview {
    @Previewable @State var destination: Destination?

    AllIdeasView(destination: $destination)
        .modelContainer(for: Idea.self, inMemory: true)
}
