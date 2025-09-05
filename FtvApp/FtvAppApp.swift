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
                .preferredColorScheme(.dark)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    showPendingMedalIfNeeded()
                }
        }
    }

    func showPendingMedalIfNeeded() {
        if let medalName = userManager.pendingMedal {
            userManager.clearPendingMedal()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let topVC = UIApplication.topMostViewController() {
                    let medalView = MedalRevealView(medalImage: UIImage(named: medalName))
                    medalView.translatesAutoresizingMaskIntoConstraints = false
                    topVC.view.addSubview(medalView)

                    NSLayoutConstraint.activate([
                        medalView.centerXAnchor.constraint(equalTo: topVC.view.centerXAnchor),
                        medalView.centerYAnchor.constraint(equalTo: topVC.view.centerYAnchor),
                        medalView.widthAnchor.constraint(equalToConstant: 220),
                        medalView.heightAnchor.constraint(equalToConstant: 220)
                    ])

                    medalView.reveal()
                }
            }
        }
    }
}
