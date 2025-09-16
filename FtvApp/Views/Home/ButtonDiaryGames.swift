import SwiftUI

struct ButtonDiaryGames: View {
    @ObservedObject var manager: HealthManager
    @ObservedObject var userManager: UserManager
    @Binding var selectedDate: Date
    let totalWorkouts: Int
    @Binding var selectedIndex: Int
    
    var body: some View {
        Group {
            if let workoutsDoDia = manager.workoutsByDay[
                Calendar.current.startOfDay(for: selectedDate)
            ], !workoutsDoDia.isEmpty {  
                VStack {
                    WorkoutMenu(
                        workouts: workoutsDoDia,
                        selectedIndex: $selectedIndex
                    )
                    
                    if selectedIndex < workoutsDoDia.count {
                        ZStack {
                            Image("mapacalor") 
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            
                            GeometryReader { proxy in
                                HStack(spacing: 0) {
                                    Spacer() 
                                    
                                    GeneratedHeatmapImageView(workout: workoutsDoDia[selectedIndex])
                                        .offset(y: 10) 
                                        .frame(width: proxy.size.width * 0.5) 
                                        .frame(height: 180) 
                                        .opacity(1.0)
                                        .blur(radius: 4)
                                }
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                        .clipped()
                        
                        WorkoutCardView(
                            workouts: workoutsDoDia,
                            selectedIndex: selectedIndex,
                            userManager: userManager,
                            healthManager: manager,
                            totalWorkouts: totalWorkouts
                        )
                    }
                }
            } else {
                Text("Nenhum treino nesse dia")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .onChange(of: selectedDate) {
            selectedIndex = 0
        }
    }
}

struct WorkoutMenu: View {
    let workouts: [Workout]
    @Binding var selectedIndex: Int
    
    var body: some View {
        Menu {
            ForEach(Array(workouts.enumerated()), id: \.element.id) {
                index,
                _ in
                Button("Treino \(index + 1)") {
                    selectedIndex = index
                }
            }
        } label: {
            HStack {
                Text("Jogos do dia")
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
        }
        .frame(width: 361, height: 40)
        .background(Color.darkGrayBackground)
        .foregroundStyle(.white)
        .cornerRadius(8)
        .padding(.bottom, 8)
    }
}

struct WorkoutCardView: View {
    let workouts: [Workout]
    let selectedIndex: Int
    @ObservedObject var userManager: UserManager
    @ObservedObject var healthManager: HealthManager
    let totalWorkouts: Int
    
    var body: some View {
        if selectedIndex < workouts.count {
            WorkoutStatsCard(
                userManager: userManager,
                healthManager: healthManager,
                workout: workouts[selectedIndex],
                totalWorkouts: totalWorkouts
            )
        }
    }
}
