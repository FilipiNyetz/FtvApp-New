//
//  TemplateViewModel.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 22/08/25.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

// MARK: - ViewModel
@MainActor
class TemplateViewModel: ObservableObject {
    @Published var showShare = false
    @Published var renderedImage: UIImage?
    @Published var isPreview = true

    func exportTemplate(
        workout: Workout,
        withBackground: Bool,
        badgeImage: String,
        totalWorkouts: Int,
        currentStreak: Int
    ) {

        let templateView = TemplateBodyView(
            workout: workout,
            withBackground: withBackground,
            badgeImage: badgeImage,
            totalWorkouts: totalWorkouts,
            currentStreak: currentStreak,
            isPreview: false
        )
        .frame(width: 360, height: 700)  // define o tamanho da imagem desejado

        let renderer = ImageRenderer(content: templateView)
        renderer.scale = 3.0  // você pode ajustar para 2 ou 3 para maior resolução
        renderer.isOpaque = withBackground

        if let uiImage = renderer.uiImage {
            self.renderedImage = uiImage
            self.showShare = true
        }
    }

    func copyTemplateToClipboard(
        workout: Workout,
        badgeImage: String,
        totalWorkouts: Int,
        currentStreak: Int
    ) {
        Task {
            let templateView = TemplateBodyView(
                workout: workout,
                withBackground: false,
                badgeImage: badgeImage,
                totalWorkouts: totalWorkouts,
                currentStreak: currentStreak,
                isPreview: false
            )

            let renderer = ImageRenderer(content: templateView)
            renderer.scale = UIScreen.main.scale
            renderer.isOpaque = false

            if let uiImage = renderer.uiImage {
                UIPasteboard.general.image = uiImage
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }
}
