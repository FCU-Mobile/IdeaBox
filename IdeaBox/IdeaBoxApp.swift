//
//  IdeaBoxApp.swift
//  IdeaBox
//
//  Created by Harry Ng on 10/1/25.
//

import SwiftUI

@main
struct IdeaBoxApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                UNUserNotificationCenter.current().setBadgeCount(0) { error in
                    if let error = error {
                        print("Failed to clear badge: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
