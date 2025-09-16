
import SwiftUI
import UIKit
import UniformTypeIdentifiers

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
            
            await preGenerateHeatmapImage(for: workout)
            
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
            
            await preGenerateHeatmapImage(for: workout)
            
            let templateView = TemplateBodyView(
                workout: workout,
                withBackground: false,
                badgeImage: badgeImage,
                totalWorkouts: totalWorkouts,
                currentStreak: currentStreak,
                isPreview: false
            )

            let renderer = ImageRenderer(content: templateView)
            renderer.scale = 3.0  
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
    
    
    private func preGenerateHeatmapImage(for workout: Workout) async {
        let renderSize = CGSize(width: 160, height: 160)
        
        let _ = HeatmapImageGenerator.shared.ensureImageExists(for: workout, size: renderSize)
        print("✅ Imagem do heatmap garantida no cache para o template")
    }
}
