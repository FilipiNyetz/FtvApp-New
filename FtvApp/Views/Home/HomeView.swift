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
    
    @State var todosOsEsportes: [Sport] = [.beachTennis, .footvolley, .volleyball]

    @State private var selectedSport: Sport = .footvolley

    private var dayStart: Date {
        Calendar.current.startOfDay(for: selectedDate)
    }
    private var workoutsToday: [Workout] {
        manager.workoutsByDay[dayStart] ?? []
    }
    private var hasWorkoutsToday: Bool { !workoutsToday.isEmpty }

    private var selectedWorkoutForShare: Workout? {
        guard hasWorkoutsToday else { return nil }
        let idx = min(
            max(opcaoDeTreinoParaMostrarCard, 0),
            workoutsToday.count - 1
        )
        return workoutsToday[idx]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.gradiente2.ignoresSafeArea(edges: .all)

                VStack(spacing: 0) {
                    HeaderHome(
                        manager: manager,
                        wcSessionDelegate: wcSessionDelegate
                    )

                    ScrollViewReader { proxy in
                        ScrollView {
                            ZStack {
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .gradiente1, .gradiente2, .gradiente2,
                                        .gradiente2,
                                    ]),
                                    startPoint: .bottomLeading,
                                    endPoint: .topTrailing
                                )
                                .ignoresSafeArea()

                                VStack(alignment: .leading, spacing: 20) {

                                    HStack {
                                        DatePickerField(
                                            selectedDate: $selectedDate,
                                            showCalendar: $showCalendar,
                                            manager: manager
                                        )
                                        .background(Color.clear)

                                    }
                                    .foregroundStyle(.white)

                                    Group {
                                        if manager.workouts.isEmpty {
                                            CardWithoutWorkout()
                                                .id("card-top")
                                        } else if hasWorkoutsToday {

                                            ButtonDiaryGames(
                                                manager: manager,
                                                userManager: userManager,
                                                selectedDate: $selectedDate,
                                                totalWorkouts: manager
                                                    .totalWorkoutsCount,
                                                selectedIndex:
                                                    $opcaoDeTreinoParaMostrarCard
                                            )
                                            .id("card-top")
                                        } else {
                                            CardWithoutDayWorkout()
                                                .id("card-top")
                                        }
                                    }
                                }
                                .padding()
                            }
                            .onChange(of: selectedDate) {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(todosOsEsportes, id: \.id) { sport in
                            Button {
                                selectedSport = sport
                                manager.fetchAllWorkouts(until: Date(), sport: sport)
                                manager.filterWorkouts(period: "day", sport: sport, referenceDate: selectedDate)
                            } label: {
                                Label(sport.displayName, systemImage: sport.iconName)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedSport.displayName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Image(systemName: selectedSport.iconName)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }
            }
            // se quiser título minimalista sem esconder a barra:
            .navigationTitle("")  // título vazio
            .navigationBarTitleDisplayMode(.inline)  // sem “Large Title”
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            //            manager.fetchAllWorkouts(until: Date())
            //            manager.startWeekChangeTimer()

            manager.fetchAllWorkouts(until: Date(), sport: selectedSport)
            manager.filterWorkouts(
                period: "day",
                sport: selectedSport,
                referenceDate: selectedDate
            )
            manager.startWeekChangeTimer()
        }
        // .navigationBarHidden(true)
    }
}
private var toolbarTrailingPlacement: ToolbarItemPlacement {
    if #available(iOS 17.0, *) {
        return .topBarTrailing
    } else {
        return .navigationBarTrailing
    }
}
