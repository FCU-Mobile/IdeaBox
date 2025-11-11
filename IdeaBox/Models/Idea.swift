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
    var sortOrder: Double?
    
    init(
        id: UUID = UUID(),
        title: String,
        detail: String? = nil,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        sortOrder: Double? = nil,
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sortOrder = sortOrder
    }
}
