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
    
    
    var body: some Scene {
        WindowGroup {
            HomeView(manager: manager)
                .preferredColorScheme(.dark)
               
        }
    }
}
