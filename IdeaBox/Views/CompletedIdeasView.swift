//
//  CompletedIdeasView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI

struct CompletedIdeasView: View {
    var model: IdeaModel

    var completedIdeas: [Idea] {
        model.ideas.filter { $0.isCompleted }
    }

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
                            IdeaRow(idea: idea) {
                                model.toggleCompletion(for: idea)
                            }
                        }
                        .onDelete(perform: model.deleteIdeas)
                    }
                }
            }
            .navigationTitle("Completed")
        }
    }
}

#Preview {
    @Previewable @State var model = IdeaModel()

    CompletedIdeasView(model: model)
}
