
import SwiftUI

struct GeneratedHeatmapImageView: View {
    let workout: Workout
    
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
    
    func forceImageGeneration() {
        self.heatmapImage = HeatmapImageGenerator.shared.image(for: workout, size: renderSize)
    }
}
