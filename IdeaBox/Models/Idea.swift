//
//  Idea.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import Foundation
import SwiftData

@Model
class Idea {
    var title: String
    var details: String
    var isCompleted: Bool
    var sortOrder: Int

    init(title: String, details: String, isCompleted: Bool = false, sortOrder: Int) {
        self.title = title
        self.details = details
        self.isCompleted = isCompleted
        self.sortOrder = sortOrder
    }
}
