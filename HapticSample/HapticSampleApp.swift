import SwiftUI
import WatchConnectivity
import UserNotifications

class CountingAppModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var count = 0
    private var session: WCSession

    override init() {
        self.session = WCSession.default
        super.init()
        session.delegate = self
        session.activate()
    }

    func incrementCounter() {
        count += 1
        sendNotificationToWatch()
    }

    private func sendNotificationToWatch() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["count": count], replyHandler: nil, errorHandler: nil)
        } else {
            // Fallback to notification if unreachable
            let content = UNMutableNotificationContent()
            content.title = "Counter Update"
            content.body = "New Count: \(count)"
            content.sound = .default
            let request = UNNotificationRequest(identifier: "CounterUpdate", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        }
    }

    // WCSessionDelegate required methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}

struct ContentView: View {
    @StateObject private var model = CountingAppModel()

    var body: some View {
        VStack {
            Text("Count: \(model.count)")
                .font(.largeTitle)
            Button("Increment Counter") {
                model.incrementCounter()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        }
    }
}

@main
struct CountingApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
