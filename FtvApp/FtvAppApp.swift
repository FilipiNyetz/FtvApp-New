//
//  FtvAppApp.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI
import SwiftData

@main
struct FtvAppApp: App {
    
    @AppStorage("countWorkouts") var countWorkouts: Int = 0
    
    @StateObject var manager = HealthManager()
    @StateObject var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            HomeView(manager: manager, dataManager: dataManager)
                .modelContainer(for:[
                    WorkoutModel.self
                ])
        }
    }
}
