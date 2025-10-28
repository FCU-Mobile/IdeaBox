//
//  IdeaLink.swift
//  IdeaBox
//
//  Created by Copilot on 10/28/25.
//

import Foundation

enum LinkType: String, Codable {
    case auto
    case manual
}

struct IdeaLink: Identifiable, Codable, Equatable {
    var id: String { pairKey(a, b) }

    let a: UUID
    let b: UUID
    var type: LinkType
    var pinned: Bool
    var score: Double?
    let createdAt: Date
    var updatedAt: Date

    init(a: UUID, b: UUID, type: LinkType, pinned: Bool = false, score: Double? = nil, createdAt: Date = Date(), updatedAt: Date = Date()) {
        let (x, y) = orderedPair(a, b)
        self.a = x
        self.b = y
        self.type = type
        self.pinned = pinned
        self.score = score
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Helpers

func orderedPair(_ a: UUID, _ b: UUID) -> (UUID, UUID) {
    return a.uuidString < b.uuidString ? (a, b) : (b, a)
}

func pairKey(_ a: UUID, _ b: UUID) -> String {
    let (x, y) = orderedPair(a, b)
    return "\(x.uuidString)::\(y.uuidString)"
}
