//
//  FtvAppApp.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI
import UIKit

@main
struct FtvAppApp: App {
    @StateObject private var userManager = UserManager() // melhor usar StateObject
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(userManager)
                .preferredColorScheme(.dark)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    showPendingMedalIfNeeded()
                }
        }
    }

    func showPendingMedalIfNeeded() {
        if let medalName = userManager.pendingMedal {
            // Adiciona um pequeno delay para garantir que a UI esteja pronta
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let topVC = UIApplication.topMostViewController() {
                    // ✅ USA O COORDENADOR DIRETAMENTE
                    MedalRevealCoordinator.showMedal(medalName, on: topVC)
                    userManager.clearPendingMedal() // Limpa após disparar a animação
                }
            }
        }
    }
}
