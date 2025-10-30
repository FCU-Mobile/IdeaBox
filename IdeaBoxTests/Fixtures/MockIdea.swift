//
//  MockIdea.swift
//  IdeaBoxTests
//
//  Created by Harry Ng on 10/30/25.
//

import Foundation
@testable import IdeaBox

extension Idea {
    static let mockIdeas: [Idea] = [
        Idea(
            title: "Build IdeaBox App",
            detail: "Create a native iOS app for managing ideas with Liquid Glass materials"
        ),
        Idea(
            title: "Learn SwiftUI Animations",
            detail: "Master smooth transitions and interactive animations in SwiftUI"
        ),
        Idea(
            title: "Write Technical Blog",
            detail: "Share insights about iOS development and best practices"
        ),
        Idea(
            title: "Redesign Portfolio",
            detail: "Update personal website with latest projects and modern design"
        ),
        Idea(
            title: "Contribute to Open Source",
            detail: "Find interesting Swift packages to contribute to"
        ),
        Idea(
            title: "Study Design Patterns",
            detail: "Deep dive into MVVM, Coordinator, and other architectural patterns"
        ),
        Idea(
            title: "Attend WWDC Session",
            detail: "Watch sessions about iOS 26 features and Liquid Glass materials"
        )
    ]
}
