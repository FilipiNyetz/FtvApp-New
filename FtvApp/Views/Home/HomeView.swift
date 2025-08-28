import SwiftData
import SwiftUI

struct HomeView: View {
    @ObservedObject var manager: HealthManager
    @ObservedObject var userManager: UserManager
    @State private var isGamesPresented = false
    @State var selectedDate: Date = Date()
    @State var opcaoDeTreinoParaMostrarCard: Int = 0
    @State private var showCalendar = false
    
    // Conveniências
    private var dayStart: Date { Calendar.current.startOfDay(for: selectedDate) }
    private var workoutsToday: [Workout] { manager.workoutsByDay[dayStart] ?? [] }
    private var hasWorkoutsToday: Bool { !workoutsToday.isEmpty }
    
    // Pegamos o workout escolhido pelo usuário (via índice)
    private var selectedWorkoutForShare: Workout? {
        guard hasWorkoutsToday else { return nil }
        let idx = min(max(opcaoDeTreinoParaMostrarCard, 0), workoutsToday.count - 1)
        return workoutsToday[idx]
    }

    
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
                                
                                // Linha da data com share alinhado ao topo-direito
                                HStack {
                                    DatePickerField(
                                        selectedDate: $selectedDate,
                                        showCalendar: $showCalendar,
                                        manager: manager
                                    )
                                    .background(Color.clear)
                                    
                                }
                                .overlay(alignment: .topTrailing) {
                                    if let workout = selectedWorkoutForShare {
                                        NavigationLink {
                                            TemplateMainView(
                                                workout: workout,
                                                totalWorkouts: manager.totalWorkoutsCount,
                                                currentStreak: manager.currentStreak,
                                                badgeImage: userManager.bagdeNames.first ?? ""
                                            )
                                        } label: {
                                            Image(systemName: "square.and.arrow.up")
                                                .resizable()
                                                .frame(width: 20, height: 25)
                                                .fontWeight(.medium)
                                                .foregroundStyle(
                                                    LinearGradient(colors: [.white, .colorSecond, .colorPrimal],
                                                                   startPoint: .top, endPoint: .bottom)
                                                )
                                        }
                                        .padding(.trailing, 10)
                                    }
                                }
                                .foregroundStyle(.white)
                                
                                // Cards conforme estado
                                Group {
                                    if manager.workouts.isEmpty {
                                        // Nenhum treino no histórico
                                        CardWithoutWorkout()
                                    } else if hasWorkoutsToday {
                                        // Há treinos na data selecionada
                                        ButtonDiaryGames(
                                            manager: manager,
                                            userManager: userManager,
                                            selectedDate: $selectedDate,
                                            totalWorkouts: manager.totalWorkoutsCount,
                                            selectedIndex: $opcaoDeTreinoParaMostrarCard
                                        )
                                    } else {
                                        // Há histórico, mas não nessa data
                                        CardWithoutDayWorkout()
                                    }
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
                    .scrollIndicators(.hidden)
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
