import SwiftUI

struct ButtonDiaryGames: View {
    @ObservedObject var manager: HealthManager
    @ObservedObject var userManager: UserManager
    @Binding var selectedDate: Date
    @State private var opcaoDeTreinoParaMostrarCard: Int = 0
    let totalWorkouts: Int
    
    var body: some View {
        Group {
            if let workoutsDoDia = manager.workoutsByDay[Calendar.current.startOfDay(for: selectedDate)] {
                VStack {
                    WorkoutMenu(workouts: workoutsDoDia, selectedIndex: $opcaoDeTreinoParaMostrarCard)
                    
                    WorkoutCardView(
                        workouts: workoutsDoDia,
                        selectedIndex: opcaoDeTreinoParaMostrarCard,
                        userManager: userManager,
                        totalWorkouts: totalWorkouts
                    )
                }
            } else {
                Text("Nenhum treino nesse dia")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .onChange(of: selectedDate) { _ in
            opcaoDeTreinoParaMostrarCard = 0
        }
    }
}

// MARK: - Menu de Treinos
struct WorkoutMenu: View {
    let workouts: [Workout]
    @Binding var selectedIndex: Int
    
    var body: some View {
        Menu {
            ForEach(Array(workouts.enumerated()), id: \.element.id) { index, _ in
                Button("Treino \(index + 1)") {
                    selectedIndex = index
                }
            }
        } label: {
            HStack {
                Text("Jogos do dia")
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

// MARK: - Card do treino selecionado
struct WorkoutCardView: View {
    let workouts: [Workout]
    let selectedIndex: Int
    @ObservedObject var userManager: UserManager
    let totalWorkouts: Int
    
    var body: some View {
        if selectedIndex < workouts.count {
            WorkoutStatsCard(userManager: userManager,workout: workouts[selectedIndex], totalWorkouts: totalWorkouts)
        }
    }
}
