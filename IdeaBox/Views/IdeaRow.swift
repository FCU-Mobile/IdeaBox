//
//  IdeaRow.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI
import SwiftData

struct IdeaRow: View {
    @Bindable var idea: Idea

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: { toggleCompletion() }) {
                Image(systemName: idea.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(idea.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(idea.title)
                    .font(.headline)
                    .foregroundStyle(idea.isCompleted ? .secondary : .primary)
                    .strikethrough(idea.isCompleted)

                if let detail = idea.detail, !detail.isEmpty {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func toggleCompletion() {
        idea.isCompleted.toggle()
        idea.updatedAt = Date()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Idea.self, configurations: config)
    
    let idea1 = Idea(title: "Build IdeaBox App", detail: "Create a native iOS app")
    let idea2 = Idea(title: "Learn SwiftUI", detail: "Master animations", isCompleted: true)
    
    container.mainContext.insert(idea1)
    container.mainContext.insert(idea2)
    
    return List {
        IdeaRow(idea: idea1)
        IdeaRow(idea: idea2)
    }
    .modelContainer(container)
}
