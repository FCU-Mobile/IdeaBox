//
//  AllIdeasView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI

struct AllIdeasView: View {
    var model: IdeaModel
    @Binding var showingAddIdea: Bool

    var body: some View {
        NavigationStack {
            List {
                ForEach(model.ideas) { idea in
                    IdeaRow(idea: idea) {
                        model.toggleCompletion(for: idea)
                    }
                }
                .onDelete(perform: model.deleteIdeas)
            }
            .navigationTitle("All Ideas")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddIdea = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var model = IdeaModel()
    @Previewable @State var showingAdd = false

    AllIdeasView(model: model, showingAddIdea: $showingAdd)
}
