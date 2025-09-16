
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

        let viewToRender = HeatmapView(
            points: workout.pointsPath.map { CGPoint(x: $0[0], y: $0[1]) },
            originPoint: workout.pointsPath.first.map { CGPoint(x: $0[0], y: $0[1]) }
        )
        .frame(width: size.width, height: size.height) 
        .rotationEffect(.degrees(270)) 
        .scaleEffect(x: -1, y: 1)      
        .drawingGroup()                
        
        let renderer = ImageRenderer(content: viewToRender)
        renderer.scale = 2.0 

        guard let uiImage = renderer.uiImage else {
            print("❌ Falha ao renderizar a HeatmapView para UIImage.")
            return nil
        }
        
        cache.setObject(uiImage, forKey: cacheKey)
        print("✅ Imagem do heatmap renderizada e armazenada no cache.")
        return uiImage
    }
    
    func ensureImageExists(for workout: Workout, size: CGSize) -> UIImage? {
        let cacheKey = workout.id.uuidString as NSString
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        print("🔄 Forçando geração síncrona da imagem do heatmap...")
        return image(for: workout, size: size)
    }
}
