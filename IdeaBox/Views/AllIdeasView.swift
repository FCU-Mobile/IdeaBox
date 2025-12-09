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
    @State private var showingMagicInput = false

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
                    Button(action: { showingMagicInput = true }) {
                        Image(systemName: "sparkles")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddIdea = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingMagicInput) {
                MagicInputSheet { newIdeas in
                    model.addIdeas(newIdeas)
                }
                .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    @Previewable @State var model = IdeaModel()
    @Previewable @State var showingAdd = false

    AllIdeasView(model: model, showingAddIdea: $showingAdd)
}
