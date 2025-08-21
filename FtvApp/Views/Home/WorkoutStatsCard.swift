import SwiftUI

struct WorkoutStatsCard: View {
    let workout: Workout
    
    var timeFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Linha de cima
            HStack {
                statItem(
                    title: "BATIMENTO",
                    value: "\(Int(workout.frequencyHeart))",
                    unit: "bpm",
                    icon: "heart.fill"
                )
                Divider().frame(height: 40).background(Color.white.opacity(0.4))
                statItem(
                    title: "CALORIA",
                    value: String(format: "%.0f", workout.calories),
                    unit: "cal",
                    icon: "flame.fill"
                )
            }
            
            Text(timeFormatter.string(from: TimeInterval(workout.duration)) ?? "00:00:00")
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            // Linha de baixo
            HStack {
                
                Divider().frame(height: 40).background(Color.white.opacity(0.4))
                statItem(
                    title: "DISTÂNCIA",
                    value: String(format: "%.1f", workout.distance),
                    unit: "km",
                    icon: "location.fill"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func statItem(
        title: String,
        value: String,
        unit: String,
        icon: String
    ) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(value)
                    .font(
                        .system(size: 22, weight: .semibold, design: .rounded)
                    )
                    .foregroundColor(.white)
                if !unit.isEmpty {
                    Text(unit)
                        .font(
                            .system(size: 12, weight: .medium, design: .rounded)
                        )
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}
