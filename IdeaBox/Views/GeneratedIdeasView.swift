//
//  GeneratedIdeasView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/4/25.
//

import SwiftUI

struct GeneratedIdeasView: View {
    @Environment(\.dismiss) private var dismiss
    @State var ideas: [Idea]
    @State private var selectedIds: Set<UUID> = []
    
    var onConfirm: ([Idea]) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(ideas, id: \.id) { idea in
                    HStack {
                        Image(systemName: selectedIds.contains(idea.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedIds.contains(idea.id) ? .blue : .gray)
                            .onTapGesture {
                                toggleSelection(for: idea)
                            }
                        
                        VStack(alignment: .leading) {
                            Text(idea.title)
                                .font(.headline)
                            Text(idea.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    ideas.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Generated Ideas")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add Selected (\(selectedIds.count))") {
                        let selected = ideas.filter { selectedIds.contains($0.id) }
                        onConfirm(selected)
                    }
                    .disabled(selectedIds.isEmpty)
                }
            }
        }
        .onAppear {
            // Select all by default
            selectedIds = Set(ideas.map(\.id))
        }
    }
    
    private func toggleSelection(for idea: Idea) {
        if selectedIds.contains(idea.id) {
            selectedIds.remove(idea.id)
        } else {
            selectedIds.insert(idea.id)
        }
    }
}

#Preview {
    GeneratedIdeasView(
        ideas: Idea.mockIdeas
    ) { _ in
    }
}
