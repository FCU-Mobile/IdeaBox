//
//  Idea.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import Foundation
import SwiftData

@Model
final class Idea {
    @Attribute(.unique) var id: UUID
    var title: String
    var detail: String?
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    var customOrderIndex: Double?
    var lastSyncedAt: Date?
    var lastSyncError: String?
    
    init(
        id: UUID = UUID(),
        title: String,
        detail: String? = nil,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        customOrderIndex: Double? = nil,
        lastSyncedAt: Date? = nil,
        lastSyncError: String? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.customOrderIndex = customOrderIndex
        self.lastSyncedAt = lastSyncedAt
        self.lastSyncError = lastSyncError
    }
}
