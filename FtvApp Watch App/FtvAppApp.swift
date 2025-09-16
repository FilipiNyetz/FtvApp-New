
import SwiftUI

@main
struct FtvApp_Watch_AppApp: App {
    
    @StateObject var manager = WorkoutManager()
    
    @AppStorage("totalGames") var totalGames: Int = 0
    @AppStorage("currentStreak") var totalWins: Int = 0
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
