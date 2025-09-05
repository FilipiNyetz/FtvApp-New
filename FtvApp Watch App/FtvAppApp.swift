//
//  FtvAppApp.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

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
//
//@main
//struct MyWorkouts_Watch_AppApp: App {
//    @StateObject var workoutManager = WorkoutManager()
//    
//    @SceneBuilder var body: some Scene {
//        WindowGroup {
//            NavigationView{
//                StartView()
//                    
//            }
//            .sheet(isPresented: $workoutManager.showingSummaryView){
//                SummaryView()
//            }
//            .environmentObject(workoutManager)
//        }
//    }
//}
