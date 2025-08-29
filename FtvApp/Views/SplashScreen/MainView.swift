//
//  MainView.swift
//  FtvApp
//
//  Created by Cauê Carneiro on 26/08/25.
//

import SwiftUI

struct MainView: View {
    @State private var isLoading = true
    @State private var splashOpacity: Double = 1.0
    @State private var startViewOpacity: Double = 0.0
    
    // Instâncias dos managers
    @StateObject private var healthManager = HealthManager()
    @StateObject private var userManager = UserManager()
    @StateObject var wcSessionDelegate = PhoneWCSessionDelegate()

    var body: some View {
        ZStack {
            SplashScreeniOS()
                .opacity(isLoading ? splashOpacity : 0)

            if !isLoading {
                HomeView(manager: healthManager, userManager: userManager, wcSessionDelegate: wcSessionDelegate)
                    .opacity(startViewOpacity)
            }
        }
        .task {
            // Wait for the splash screen duration
            try? await Task.sleep(for: .seconds(2))

            // Animate splash screen fade out and start view fade in
            withAnimation(.easeInOut(duration: 1.0)) {
                splashOpacity = 0.0
                startViewOpacity = 1.0
            }

            // Wait for the animation to complete before changing the state
            try? await Task.sleep(for: .seconds(1.0))
            isLoading = false
        }
        .onAppear {
            wcSessionDelegate.startSession()
        }
    }
}
