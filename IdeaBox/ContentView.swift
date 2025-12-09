//
//  ContentView.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var ScenePhase
    @State private var model = IdeaModel()
    @State private var showingAddIdea = false

    var body: some View {
        TabView {
            Tab("All", systemImage: "list.bullet") {
                AllIdeasView(model: model, showingAddIdea: $showingAddIdea)
            }

            Tab("Completed", systemImage: "checkmark.circle.fill") {
                CompletedIdeasView(model: model)
            }
            
            Tab("Notification", systemImage: "bell") {
                NotificationDemoView()
            }

            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                SearchView(model: model)
            }
        }
        .sheet(isPresented: $showingAddIdea) {
            AddIdeaSheet { newIdea in
                model.addIdea(title: newIdea.title, description: newIdea.description)
            }
        }
        .onChange(of: ScenePhase) { phase in
            if phase == .active {
                UNUserNotificationCenter.current().setBadgeCount(8)
            }
        }
    }
}

#Preview {
    ContentView()
}
