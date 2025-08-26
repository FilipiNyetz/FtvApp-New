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
    @StateObject var manager = HealthManager()
    @StateObject var userManager = UserManager()
    
    
    var body: some Scene {
        WindowGroup {
            HomeView(manager: manager, userManager: userManager)
                .preferredColorScheme(.dark)
               
        }
    }
}
