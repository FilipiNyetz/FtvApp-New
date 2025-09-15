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
                            Image("mapacalor") // Fundo da quadra
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                            
                            GeometryReader { proxy in
                                HStack(spacing: 0) {
                                    Spacer() // Empurra para a direita
                                    
                                    GeneratedHeatmapImageView(workout: workoutsDoDia[selectedIndex])
                                        .offset(y: 10) // Mantenha offsets e frames para posicionamento
                                        .frame(width: proxy.size.width * 0.5) // Largura da meia quadra
                                    // A altura será determinada pelo aspectRatio(contentMode: .fill)
                                    // da imagem dentro de GeneratedHeatmapImageView,
                                    // mas você pode forçar uma altura se a imagem gerada tiver a proporção certa.
                                        .frame(height: 180) // Mantenha a altura que você deseja para a região do heatmap
                                        .opacity(1.0)
                                        .blur(radius: 4)
                                    // REMOVA ESTES MODIFICADORES, ELES JÁ FORAM APLICADOS NA GERAÇÃO DA IMAGEM
                                    // .rotationEffect(.degrees(270))
                                    // .scaleEffect(x: -1, y: 1)
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
