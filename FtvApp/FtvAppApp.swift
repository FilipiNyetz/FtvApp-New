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
    
    init() {
        // Configuração mínima da navigation bar
        UINavigationBar.appearance().tintColor = UIColor(named: "ColorPrimal") ?? UIColor.systemGreen
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
//                .onAppear {
//                    wcSessionDelegate.startSession()
//                }
               
        }
        
    }
}
