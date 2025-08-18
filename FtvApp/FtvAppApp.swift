//
//  FtvAppApp.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI

@main
struct FtvAppApp: App {
    
    @StateObject var manager = HealthManager()
    
    var body: some Scene {
        WindowGroup {
            HomeView(manager: manager, selectedDate: Date())
                .preferredColorScheme(.dark)
        }
    }
}
