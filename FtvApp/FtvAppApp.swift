
import SwiftUI
import UIKit

@main
struct FtvAppApp: App {
    @StateObject private var userManager = UserManager() 
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(userManager)
                .preferredColorScheme(.dark)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    showPendingMedalIfNeeded()
                }
        }
    }

    func showPendingMedalIfNeeded() {
        if let medalName = userManager.pendingMedal {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let topVC = UIApplication.topMostViewController() {
                    MedalRevealCoordinator.showMedal(medalName, on: topVC)
                    userManager.clearPendingMedal() 
                }
            }
        }
    }
}
