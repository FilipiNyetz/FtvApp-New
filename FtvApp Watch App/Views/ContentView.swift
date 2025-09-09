//
//  ContentView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 05/09/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        if hasCompletedOnboarding {
            MainView()
        } else {
            FirstView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
    }
}
