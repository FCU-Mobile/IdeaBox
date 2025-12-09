import SwiftUI
import UserNotifications

struct NotificationDemoView: View {
    @State private var permissionGranted = false

    
    var body: some View {
        VStack {
            Text("Local Notifications Demo")
                .font(.title)
            
            Button("Schedule Notification") {
                scheduleNotification()
            }
            .disabled(!permissionGranted)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Text("Tap button, then wait 5 seconds outside the app.")
                .font(.caption)
                .padding(.top)
        }
        .onAppear {
            requestPermission()
        }
    }
    
    // Step 1: Request permission on appear
    private func requestPermission() {
        Task {
            do {
                // TODO: 請求權限
                let granted = try await
                UNUserNotificationCenter
                    .current()
                    .requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                print("Error requesting permission: \(error.localizedDescription)")
            }
        }
    }
    
    // Step 2: Create content and trigger
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        // TODO: 設定提醒內容
        content.title = "Hello, World!"
        content.body = "This is a test notification."
        content.sound = .default
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats : false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        // Step 3: Create and add request
        // TODO: 建立並加入通知請求

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully!")
            }
        }
    }
}

#Preview {
    NotificationDemoView()
}
