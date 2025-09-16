
import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        if hasCompletedOnboarding {
            MainView()
        } else {
            FirstView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
    }
}
