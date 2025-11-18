//
//  CompletedIdeasView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI
import SwiftData

struct CompletedIdeasView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Idea> { $0.isCompleted == true }, sort: \Idea.updatedAt, order: .reverse)
    private var completedIdeas: [Idea]
    @Binding var destination: Destination?

    var body: some View {
        NavigationStack {
            Group {
                if completedIdeas.isEmpty {
                    ContentUnavailableView(
                        "No Completed Ideas",
                        systemImage: "checkmark.circle",
                        description: Text("Ideas you mark as complete will appear here")
                    )
                } else {
                    List {
                        ForEach(completedIdeas) { idea in
                            IdeaRow(idea: idea, onEdit: { destination = .edit($0) })
                        }
                        .onDelete(perform: deleteIdeas)
                    }
                }
            }
            .navigationTitle("Completed")
        }
    }

    private func deleteIdeas(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(completedIdeas[index])
        }
    }
}

#Preview {
    @Previewable @State var destination: Destination?

    CompletedIdeasView(destination: $destination)
        .modelContainer(for: Idea.self, inMemory: true)
}
