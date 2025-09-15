//
//  GeneratedHeatmapImageView.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 11/09/25.
//

import SwiftUI

struct GeneratedHeatmapImageView: View {
    let workout: Workout
    
    // Mantemos um tamanho de renderização fixo e de alta resolução.
    // Ajuste esses valores para o tamanho ideal da imagem original que será gerada.
    // Por exemplo, se a sua "meia quadra" tem uma proporção específica (ex: 1:2),
    // o renderSize deve refletir isso (ex: width: 400, height: 800)
    let renderSize: CGSize
    
    @State private var heatmapImage: UIImage? = nil
    
    init(workout: Workout, renderSize: CGSize = CGSize(width: 160, height: 160)) {
        self.workout = workout
        self.renderSize = renderSize
    }
    
    var body: some View {
        Group {
            if let image = heatmapImage {
                Image(uiImage: image)
                    .resizable()
                    // Agora a imagem já vem rotacionada e espelhada.
                    // Apenas preenche o espaço disponível.
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .overlay(ProgressView())
            }
        }
        .onAppear(perform: generateImage)
        .onChange(of: workout.id) {_, _ in
            generateImage()
        }
    }
    
    private func generateImage() {
        Task { @MainActor in
            self.heatmapImage = HeatmapImageGenerator.shared.image(for: workout, size: renderSize)
        }
    }
    
    // Método público para força a geração da imagem (usado pelos templates)
    func forceImageGeneration() {
        self.heatmapImage = HeatmapImageGenerator.shared.image(for: workout, size: renderSize)
    }
}
