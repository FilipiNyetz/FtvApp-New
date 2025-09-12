//
//  HeatmapImageGenerator.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 11/09/25.
//

import SwiftUI
import UIKit

@MainActor
final class HeatmapImageGenerator {
    static let shared = HeatmapImageGenerator()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}

    func image(for workout: Workout, size: CGSize) -> UIImage? {
        let cacheKey = workout.id.uuidString as NSString

        if let cachedImage = cache.object(forKey: cacheKey) {
            print("✅ Imagem do heatmap encontrada no cache para o treino: \(workout.id.uuidString)")
            return cachedImage
        }

        print("⚠️ Imagem do heatmap não encontrada no cache. Renderizando uma nova...")

        // AQUI ESTÁ A MUDANÇA: Aplique a rotação e o scaleEffect na view ANTES de renderizar.
        let viewToRender = HeatmapView(
            points: workout.pointsPath.map { CGPoint(x: $0[0], y: $0[1]) },
            originPoint: workout.pointsPath.first.map { CGPoint(x: $0[0], y: $0[1]) }
        )
        // A proporção da quadra é 8x8. Se a quadra é quadrada, podemos usar um frame quadrado
        // para renderizar e depois rotacionar e escalar.
        // O renderSize é o tamanho "virtual" em que a imagem será criada.
        .frame(width: size.width, height: size.height) // Use o size passado como parâmetro
        .rotationEffect(.degrees(270)) // Aplica a rotação para virar a quadra
        .scaleEffect(x: -1, y: 1)      // Inverte no eixo X para espelhar
        .drawingGroup()                // Garante que o blur e os efeitos sejam aplicados bem
        
        let renderer = ImageRenderer(content: viewToRender)
        renderer.scale = 2.0 // Renderiza com o dobro da resolução para telas Retina.

        guard let uiImage = renderer.uiImage else {
            print("❌ Falha ao renderizar a HeatmapView para UIImage.")
            return nil
        }
        
        cache.setObject(uiImage, forKey: cacheKey)
        print("✅ Imagem do heatmap renderizada e armazenada no cache.")
        return uiImage
    }
}
