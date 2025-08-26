import SwiftData
import SwiftUI

struct HomeView: View {
    @ObservedObject var manager: HealthManager
    @ObservedObject var userManager: UserManager
    
    @State private var isGamesPresented = false
    @State var selectedDate: Date = Date()
    @State var opcaoDeTreinoParaMostrarCard: Int = 0
    @State private var showCalendar = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gradiente2.ignoresSafeArea(edges: .all)
                
                VStack(spacing: 0) {
                    
                    // HEADER PRETO PERSONALIZADO
                    HeaderHome(manager: manager)
                    
                    // CONTEÚDO
                    ScrollView {
                        ZStack {
                            LinearGradient(
                                gradient: Gradient(colors: [.gradiente1, .gradiente2, .gradiente2, .gradiente2]),
                                startPoint: .bottomLeading,
                                endPoint: .topTrailing
                            )
                            .ignoresSafeArea()
                            
                            VStack(alignment: .leading, spacing: 20) {
                                ZStack {
                                    VStack {
                                        DatePickerField(
                                            selectedDate: $selectedDate,
                                            showCalendar: $showCalendar,
                                            manager: manager
                                        )
                                        //.padding(.top)
                                        .background(Color.clear)
                                    }
                                    .foregroundStyle(.white)
                                }
                                
                                if manager.workouts.isEmpty {
                                    // Se não houver NENHUM treino na história
                                    CardWithoutWorkout()
                                } else if manager.workoutsByDay[
                                    Calendar.current.startOfDay(
                                        for: selectedDate
                                    )
                                ] != nil
                                            && !manager.workoutsByDay[
                                                Calendar.current.startOfDay(
                                                    for: selectedDate
                                                )
                                            ]!.isEmpty
                                {
                                    // Se houver treinos para a data selecionada
                                    ButtonDiaryGames(
                                        manager: manager,
                                        selectedDate: $selectedDate
                                    )
                                } else {
                                    // Se não houver treinos para a data selecionada, mas a história de treinos existe
                                    CardWithoutDayWorkout()
                                }
                                
                            }
                            .padding()
                        }
                        
                        Divider()
                            .padding(.top, -8)
                        
                        VStack {
                            TotalGames(
                                manager: manager,
                                userManager: userManager,
                                totalWorkouts: manager.totalWorkoutsCount
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            manager.fetchAllWorkouts(until: Date())
            manager.startWeekChangeTimer()
        }
        
        .navigationBarHidden(true)
    }
}
