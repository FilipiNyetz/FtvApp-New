//
//  MainView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 25/08/25.
//

import SwiftUI

struct MainView: View {
    @State private var isLoading = true

    var body: some View {
        if isLoading {
            SplashScreen()
                .task {
                    try? await Task.sleep(for: .seconds(2)) // Atraso de 2 segundos
                    isLoading = false
                }
        } else {
            StartView()
        }
    }
}
