//
//  RelatedIdeasSection.swift
//  IdeaBox
//
//  Created by Copilot on 10/28/25.
//

import SwiftUI

struct RelatedIdeasSection: View {
    let pinned: [Idea]
    let suggested: [Idea]
    let onSelect: (Idea) -> Void

    var body: some View {
        if pinned.isEmpty && suggested.isEmpty {
            ContentUnavailableView(
                "No Related Ideas",
                systemImage: "link.slash",
                description: Text("Try expanding the title or description to improve matches.")
            )
        } else {
            List {
                if !pinned.isEmpty {
                    Section("Pinned") {
                        ForEach(pinned) { idea in
                            RelatedRow(idea: idea) { onSelect(idea) }
                        }
                    }
                }
                if !suggested.isEmpty {
                    Section("Suggested") {
                        ForEach(suggested) { idea in
                            RelatedRow(idea: idea) { onSelect(idea) }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

private struct RelatedRow: View {
    let idea: Idea
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 4) {
                Text(idea.title)
                    .font(.headline)
                    .accessibilityLabel(Text("Related idea: \(idea.title)"))
                if !idea.description.isEmpty {
                    Text(idea.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .accessibilityHint(Text("Double tap to open idea"))
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    RelatedIdeasSection(pinned: [], suggested: Idea.mockIdeas) { _ in }
}
