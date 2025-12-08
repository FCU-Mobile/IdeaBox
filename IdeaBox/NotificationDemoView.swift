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
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                self.permissionGranted = granted
            } catch {
                print("Error requesting permission: \(error.localizedDescription)")
            }
        }
    }
    
    // Step 2: Create content and trigger
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Hello!"
        content.body = "This is a local notification."
        content.sound = .default
        content.badge = 1
        
        // Step 3: Create and add request
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
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
