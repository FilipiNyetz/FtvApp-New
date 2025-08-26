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
    
    func exportTemplate(workout: Workout, withBackground: Bool) {
        let templateView = TemplateBodyView(workout: workout, withBackground: withBackground, badgeImage: "1stGoal", isPreview: false)
        
        let renderer = ImageRenderer(content: templateView)
        renderer.scale = UIScreen.main.scale
        renderer.isOpaque = withBackground
        
        if let uiImage = renderer.uiImage {
            self.renderedImage = uiImage
            self.showShare = true
        }
    }
    
    func copyTemplateToClipboard(workout: Workout) {
        Task {
            let templateView = TemplateBodyView(
                workout: workout,
                withBackground: false,
                badgeImage: "1stGoal",
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
