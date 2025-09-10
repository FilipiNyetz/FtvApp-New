import SwiftData
import SwiftUI

struct HomeView: View {
    @ObservedObject var manager: HealthManager
    @EnvironmentObject var userManager: UserManager
    @ObservedObject var wcSessionDelegate: PhoneWCSessionDelegate
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
                    HeaderHome(manager: manager, wcSessionDelegate: wcSessionDelegate)
                
                    // CONTEÚDO
                    ScrollViewReader { proxy in
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
                                    .foregroundStyle(.white)
                                    
                                    // Cards conforme estado
                                    Group {
                                        if manager.workouts.isEmpty {
                                            // Nenhum treino no histórico
                                            CardWithoutWorkout()
                                                .id("card-top")
                                        } else if hasWorkoutsToday {
                                            // Há treinos na data selecionada
                                            
                                            
                                            ButtonDiaryGames(
                                                manager: manager,
                                                userManager: userManager,
                                                selectedDate: $selectedDate,
                                                totalWorkouts: manager.totalWorkoutsCount,
                                                selectedIndex: $opcaoDeTreinoParaMostrarCard
                                            )
                                            .id("card-top")
                                        } else {
                                            // Há histórico, mas não nessa data
                                            CardWithoutDayWorkout()
                                                .id("card-top")
                                        }
                                    }
                                }
                                .padding()
                            }
                            .onChange(of: selectedDate) {
                                // Quando muda a data, rolar para o card
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo("card-top", anchor: .top)
                                }
                            }
                            
                            Divider()
                                .padding(.top, -8)
                            
                            VStack {
                                TotalGames(
                                    manager: manager,
                                    totalWorkouts: manager.totalWorkoutsCount
                                )
                            }
                        }
                        .padding(.horizontal)
                        .scrollIndicators(.hidden)
                    }
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
