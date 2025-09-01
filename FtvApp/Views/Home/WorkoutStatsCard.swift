import SwiftUI

struct WorkoutStatsCard: View {
    
    @ObservedObject var userManager: UserManager
    @ObservedObject var healthManager: HealthManager
    
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
                    title: Text("BATIMENTO"),
                    value: "\(Int(workout.frequencyHeart))",
                    unit: "bpm",
                    icon: "heart.fill"
                )
                Divider().frame(height: 40).background(Color.white.opacity(0.4))
                statItem(
                    title: Text("CALORIA"),
                    value: "\(workout.calories)",
                    unit: "cal",
                    icon: "flame.fill"
                )
                Divider().frame(height: 40).background(Color.white.opacity(0.4))
                statItem(
                    title: Text("ALTURA"),
                    value: "\(Double(workout.higherJump!))",
                    unit: "cm",
                    icon: "flame.fill"
                )
            }
            

            VStack{
                Text("TEMPO")
                    .font(.caption)
                    .fontWeight(.regular)
                    .fontDesign(.rounded)
                    .foregroundColor(.gray)
                
                Text(timeFormatter.string(from: TimeInterval(workout.duration)) ?? "00:00:00")
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Linha de baixo
            HStack {
                statItem(
                    title: Text("DISTÂNCIA"),
                    value: String(format: "%.1f", workout.distance),
                    unit: "km",
                    icon: "location.fill"
                )
            }
            
            if userManager.bagdeNames.isEmpty{
                NavigationLink(destination: TemplateMainView(workout: workout, totalWorkouts: totalWorkouts, currentStreak: healthManager.currentStreak, badgeImage: "1stGoal")) {
                    Text("Compartilhar treino")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.colorPrimal).opacity(0.9)
                        .cornerRadius(12)
                }
            }else{
                NavigationLink(destination: TemplateMainView(workout: workout, totalWorkouts: totalWorkouts, currentStreak: healthManager.currentStreak, badgeImage: userManager.bagdeNames[0])) {
                    Text("Compartilhar treino")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.colorPrimal).opacity(0.9)
                        .cornerRadius(12)
                }
            }
            
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.backgroundProgressBar, lineWidth: 0.3)
                .fill(Color(.secondarySystemBackground))
                .opacity(0.5)
                
        )
        .onAppear {
            userManager.setBadgeTotalWorkout(totalWorkouts: totalWorkouts)
        }
    }
    
    private func statItem(
        title: Text,
        value: String,
        unit: String,
        icon: String
    ) -> some View {
        VStack(spacing: 2) {
            title
                .font(.caption)
                .fontWeight(.regular)
                .fontDesign(.rounded)
                .foregroundColor(.gray)
            
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(Color("ColorSecond"))
                Text(value)
                    .font(
                        .system(size: 22, weight: .semibold, design: .rounded)
                    )
                    .foregroundColor(.white)
            }
            
            if !unit.isEmpty {
                Text(unit)
                    .font(
                        .system(size: 12, weight: .medium, design: .rounded)
                    )
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
}
