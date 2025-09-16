
import Combine
import SwiftUI

struct HeatmapResultView: View {
    
    let Workout: Workout
    
    @State private var latestPoints: [CGPoint] = []  
    @State private var subscription: AnyCancellable? = nil  
    
    private let debugSquare = CGRect(x: -6, y: -6, width: 12, height: 12)
    
    var body: some View {
        HeatmapView(
            points: Workout.pointsPath.map { CGPoint(x: $0[0], y: $0[1]) },
            originPoint: Workout.pointsPath.first.map { CGPoint(x: $0[0], y: $0[1]) }
        )
        .rotationEffect(.degrees(270))
        .scaleEffect(x: -1, y: 1)
        .allowsHitTesting(false)
        .onAppear {
            latestPoints = Workout.pointsPath.map {
                CGPoint(x: $0[0], y: $0[1])
            }
            
        }
        .onDisappear {
            subscription?.cancel()
            subscription = nil
        }
    }
}
