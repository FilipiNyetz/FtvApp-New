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
    @StateObject private var healthManager = HealthManager()
    @StateObject private var userManager = UserManager()

    var body: some View {
        ZStack {
            SplashScreeniOS()
                .opacity(isLoading ? splashOpacity : 0)

            if !isLoading {
                HomeView(manager: healthManager, userManager: userManager)
                    .opacity(startViewOpacity)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(0.7))

            withAnimation(.easeInOut(duration: 0.6)) {
                splashOpacity = 0.0
                startViewOpacity = 1.0
            }

            try? await Task.sleep(for: .seconds(0.6))
            isLoading = false
        }
    }
}
