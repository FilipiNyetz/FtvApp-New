import SwiftUI

struct ButtonDiaryGames: View {
    @ObservedObject var manager: HealthManager
    @ObservedObject var userManager: UserManager
    @Binding var selectedDate: Date
    //@State private var opcaoDeTreinoParaMostrarCard: Int = 0
    let totalWorkouts: Int
    @Binding var selectedIndex: Int

    var body: some View {
        Group {
            if let workoutsDoDia = manager.workoutsByDay[
                Calendar.current.startOfDay(for: selectedDate)
            ], !workoutsDoDia.isEmpty {  // Adicionado !workoutsDoDia.isEmpty para segurança
                VStack {
                    WorkoutMenu(
                        workouts: workoutsDoDia,
                        selectedIndex: $selectedIndex
                    )

                    // Garante que o índice selecionado é válido
                    if selectedIndex < workoutsDoDia.count {

                        ZStack {
                            Image("mapacalor")
                                .resizable()
                                .aspectRatio(contentMode: .fill)

                            GeometryReader { proxy in
                                HStack(spacing: 0) {

                                    Spacer()

                                    HeatmapResultView(
                                        Workout: workoutsDoDia[selectedIndex]
                                    )
                                    .offset(y: 10)
                                    .frame(width: proxy.size.width / 2)
                                    .frame(height: 180)
                                }
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(12)
                        .clipped()  // 5. ESSENCIAL: Corta qualquer coisa (como o blur) que vaze para fora do frame

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
        //        .onChange(of: selectedDate) { _ in
        //            opcaoDeTreinoParaMostrarCard = 0
        //        }
    }
}

// MARK: - Menu de Treinos
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

// MARK: - Card do treino selecionado
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
