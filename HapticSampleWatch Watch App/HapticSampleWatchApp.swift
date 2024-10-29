import SwiftUI
import WatchConnectivity
import UserNotifications

class CountingWatchModel: NSObject, ObservableObject, WCSessionDelegate {
    @Published var count = 0
    private var session: WCSession
    
    override init() {
        self.session = WCSession.default
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let count = message["count"] as? Int {
            DispatchQueue.main.async {
                self.count = count
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }
    
    // WCSessionDelegate required methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
}

struct ContentView: View {
    @StateObject private var model = CountingWatchModel()
    
    var body: some View {
        VStack {
            Text("Count: \(model.count)")
                .font(.largeTitle)
        }
    }
}

@main
struct CountingWatchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
