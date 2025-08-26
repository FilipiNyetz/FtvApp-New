import SwiftUI

struct WorkoutStatsCard: View {
    
    @ObservedObject var userManager: UserManager
    
    
    let workout: Workout
    let totalWorkouts: Int
    
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
                    value: "\(workout.calories)",
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
                statItem(
                    title: "DISTÂNCIA",
                    value: String(format: "%.1f", workout.distance),
                    unit: "km",
                    icon: "location.fill"
                )
            }
            
            if userManager.bagdeNames.isEmpty{
                NavigationLink(destination: TemplateMainView(workout: workout, badgeImage: "1stGoal")) {
                    Text("Gerar Template")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.colorPrimal)
                        .cornerRadius(12)
                }
            }else{
                NavigationLink(destination: TemplateMainView(workout: workout, badgeImage: userManager.bagdeNames[0])) {
                    Text("Gerar Template")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.colorPrimal)
                        .cornerRadius(12)
                }
            }
            
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .onAppear {
            userManager.setBadgeTotalWorkout(totalWorkouts: totalWorkouts)
        }
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
