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
    
    var body: some Scene {
        WindowGroup {
            StartView(manager: manager)
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
