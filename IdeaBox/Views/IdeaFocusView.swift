//
//  IdeaFocusView.swift
//  IdeaBox
//
//  Created by Copilot on 10/28/25.
//

import SwiftUI

struct IdeaFocusView: View {
    let idea: Idea
    let allIdeas: [Idea]
    let service: RelatedIdeasService
    // For MVP, pass empty collections. Future: persist and plumb through bindings.
    var links: [IdeaLink] = []
    var blacklist: Set<IdeaBlacklistPair> = []

    @State private var pinned: [Idea] = []
    @State private var suggested: [Idea] = []

    var body: some View {
        NavigationStack {
            RelatedIdeasSection(pinned: pinned, suggested: suggested) { selected in
                // For MVP: simply pop a detail with the selected idea's related list
                navigate(to: selected)
            }
            .navigationTitle(idea.title)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await recompute()
            }
        }
    }

    private func navigate(to selected: Idea) {
        // In a more complete flow, push another IdeaFocusView; for MVP, no-op.
        // This placeholder ensures the onSelect works and can be expanded later.
    }

    private func recompute() async {
        // Build index (idempotent) and compute related for the current idea
        service.rebuildIndex(ideas: allIdeas)
        let res = service.related(for: idea, allIdeas: allIdeas, links: links, blacklist: blacklist)
        self.pinned = res.pinned
        self.suggested = res.suggested
    }
}

#Preview {
    IdeaFocusView(idea: Idea.mockIdeas[0], allIdeas: Idea.mockIdeas, service: RelatedIdeasService())
}
