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
                    // HEADER
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
                                // DATE PICKER
                                DatePickerField(
                                    selectedDate: $selectedDate,
                                    showCalendar: $showCalendar,
                                    manager: manager
                                )
                                .foregroundStyle(.white)
                                
                                if let workoutsDoDia = manager.workoutsByDay[
                                    Calendar.current.startOfDay(for: selectedDate)
                                ], !workoutsDoDia.isEmpty {
                                    ButtonDiaryGames(manager: manager, selectedDate: $selectedDate)
                                } else {
                                    CardWithoutWorkout()
                                }
                            }
                            .padding()
                        }
                        
                        Divider()
                            .padding(.top, -8)
                        
                        // 🔹 Sempre mostra o total de treinos
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
