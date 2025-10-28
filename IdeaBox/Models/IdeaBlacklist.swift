//
//  IdeaBlacklist.swift
//  IdeaBox
//
//  Created by Copilot on 10/28/25.
//

import Foundation

struct IdeaBlacklistPair: Identifiable, Codable, Equatable, Hashable {
    var id: String { pairKey(a, b) }
    let a: UUID
    let b: UUID
    let createdAt: Date

    init(a: UUID, b: UUID, createdAt: Date = Date()) {
        let (x, y) = orderedPair(a, b)
        self.a = x
        self.b = y
        self.createdAt = createdAt
    }
}

extension Set where Element == IdeaBlacklistPair {
    func containsPair(_ a: UUID, _ b: UUID) -> Bool {
        let key = pairKey(a, b)
        return self.first(where: { $0.id == key }) != nil
    }
}
