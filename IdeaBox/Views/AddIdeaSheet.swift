//
//  AddIdeaSheet.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI
import Dependencies
import Foundation
import SwiftData
import SwiftDate

struct AddIdeaSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var detail = ""

    @Dependency(\.date.now) private var now

    let ideaToEdit: Idea?

    var isEditMode: Bool {
        ideaToEdit != nil
    }

    var navigationTitle: String {
        isEditMode ? "Edit Idea" : "New Idea"
    }

    var icon: Image {
        if DateInRegion(now).compare(.isMorning) {
            Image(systemName: "sun.horizon.fill")
        } else if now.compare(.isAfternoon) {
            Image(systemName: "sun.max.fill")
        } else {
            Image(systemName: "moon.stars.fill")
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                        .font(.headline)

                    TextField("Description", text: $detail, axis: .vertical)
                        .lineLimit(3...6)
                        .font(.body)
                } footer: {
                    HStack {
                        Text("Current time: \(now, format: .dateTime.hour().minute())")
                        icon
                    }
                    .font(.headline)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveIdea()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .onAppear {
            if let idea = ideaToEdit {
                title = idea.title
                detail = idea.detail ?? ""
            }
        }
    }

    private func saveIdea() {
        if let idea = ideaToEdit {
            // Edit existing idea
            idea.title = title
            idea.detail = detail.isEmpty ? nil : detail
            idea.updatedAt = Date()
        } else {
            // Create new idea
            let newIdea = Idea(title: title, detail: detail.isEmpty ? nil : detail)
            modelContext.insert(newIdea)
        }
        dismiss()
    }
}

#Preview {
    let _ = prepareDependencies {
        $0.date.now = Date().fastMidnight + 9.hours
    }
    AddIdeaSheet(ideaToEdit: nil)
        .modelContainer(for: Idea.self, inMemory: true)
}
