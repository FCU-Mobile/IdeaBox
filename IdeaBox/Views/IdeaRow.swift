//
//  IdeaRow.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI

struct IdeaRow: View {
    let idea: Idea
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
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

                if !idea.details.isEmpty {
                    Text(idea.details)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

//#Preview {
//    List {
//        IdeaRow(idea: Idea.mockIdeas[0]) { }
//        IdeaRow(idea: Idea.mockIdeas[2]) { }
//    }
//}
