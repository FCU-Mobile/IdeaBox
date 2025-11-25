//
//  IdeaRow.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import Dependencies
import Foundation
import SwiftUI
import SwiftData
import SwiftDate

struct IdeaRow: View {
    @Bindable var idea: Idea
    var onEdit: ((Idea) -> Void)?

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

                Text(idea.createdAt, format: .dateTime.month().day().year().hour().minute())
            }

            Spacer()

            Button(action: { onEdit?(idea) }) {
                Image(systemName: "pencil")
                    .font(.headline)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    private func toggleCompletion() {
        idea.isCompleted.toggle()
        idea.updatedAt = Date()
    }
}

#Preview {
    let _ = prepareDependencies {
        $0.date.now = Date().fastMidnight
    }
    @Dependency(\.date.now) var now

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Idea.self, configurations: config)
    
    let idea1 = Idea(title: "Build IdeaBox App", detail: "Create a native iOS app", createdAt: now)
    let idea2 = Idea(title: "Learn SwiftUI", detail: "Master animations", isCompleted: true, createdAt: now)

    container.mainContext.insert(idea1)
    container.mainContext.insert(idea2)
    
    return List {
        IdeaRow(idea: idea1)
        IdeaRow(idea: idea2)
    }
    .modelContainer(container)
}

extension Date {
    var fastMidnight: Date {
        Calendar.current.startOfDay(for: self)
    }
}
