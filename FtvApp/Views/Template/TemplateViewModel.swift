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
    @Published var isGeneratingImage = false

    func exportTemplate(
        workout: Workout,
        withBackground: Bool,
        badgeImage: String,
        totalWorkouts: Int,
        currentStreak: Int
    ) {
        Task {
            isGeneratingImage = true
            
            // 1. Primeiro, garante que a imagem do heatmap está no cache
            await preGenerateHeatmapImage(for: workout)
            
            // 2. Agora renderiza o template diretamente
            let templateView = TemplateBodyView(
                workout: workout,
                withBackground: withBackground,
                badgeImage: badgeImage,
                totalWorkouts: totalWorkouts,
                currentStreak: currentStreak,
                isPreview: false
            )
            .frame(width: 360, height: 700)

            let renderer = ImageRenderer(content: templateView)
            renderer.scale = 3.0
            renderer.isOpaque = withBackground

            if let uiImage = renderer.uiImage {
                self.renderedImage = uiImage
                self.showShare = true
                print("✅ Template exportado com heatmap incluído")
            } else {
                print("❌ Falha ao gerar template para compartilhamento")
            }
            
            isGeneratingImage = false
        }
    }

    func copyTemplateToClipboard(
        workout: Workout,
        badgeImage: String,
        totalWorkouts: Int,
        currentStreak: Int
    ) {
        Task {
            isGeneratingImage = true
            
            // 1. Primeiro, garante que a imagem do heatmap está no cache
            await preGenerateHeatmapImage(for: workout)
            
            // 2. Agora renderiza o template diretamente
            let templateView = TemplateBodyView(
                workout: workout,
                withBackground: false,
                badgeImage: badgeImage,
                totalWorkouts: totalWorkouts,
                currentStreak: currentStreak,
                isPreview: false
            )

            let renderer = ImageRenderer(content: templateView)
            renderer.scale = 3.0  // Maior resolução para cópia
            renderer.isOpaque = false

            if let uiImage = renderer.uiImage {
                UIPasteboard.general.image = uiImage
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                print("✅ Template copiado para clipboard comx heatmap incluído")
            } else {
                print("❌ Falha ao gerar template para clipboard")
            }
            
            isGeneratingImage = false
        }
    }
    
    // MARK: - Helper Methods
    
    private func preGenerateHeatmapImage(for workout: Workout) async {
        // Força a geração da imagem do heatmap no cache
        let renderSize = CGSize(width: 160, height: 160)
        
        // Garante que a imagem está no cache antes de continuar
        let _ = HeatmapImageGenerator.shared.ensureImageExists(for: workout, size: renderSize)
        print("✅ Imagem do heatmap garantida no cache para o template")
    }
}
