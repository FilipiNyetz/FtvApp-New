import SwiftData
import SwiftUI

struct HomeView: View {
    @ObservedObject var manager: HealthManager
    
    @State private var isGamesPresented = false
    @State var selectedDate: Date = Date()
    @State var opcaoDeTreinoParaMostrarCard: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // HEADER PRETO PERSONALIZADO
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Seus jogos")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        NavigationLink(destination: EvolutionView()) {
                            Circle()
                                .fill(Color.brandGreen)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "chart.bar")
                                        .font(.subheadline)
                                        .foregroundStyle(.black)
                                )
                        }
                        .padding(.top, 16)
                    }
                   // .padding(.top, 50)
                    
                    // “Foguinho” logo abaixo do título
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.brandGreen)
                        Text("20")  // valor dinâmico se quiser
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .background(Color.black)
                
                // CONTEÚDO
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        DatePickerField(
                            selectedDate: $selectedDate,
                            manager: manager
                        )
                        .background(Color.ligthGrayBackground)
                        .foregroundStyle(.white)
                        
                        
                        if let workoutsDoDia = manager.workoutsByDay[
                            Calendar.current.startOfDay(for: selectedDate)
                        ]{
                            ButtonDiaryGames(manager: manager, selectedDate: $selectedDate)
                        }
                        
                    }
                    
                    Divider()
                    
                    TotalGames(totalWorkouts: manager.workouts.count)
                }
                .padding(.horizontal)
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            manager.fetchMonthWorkouts(for: selectedDate)
        }
        .navigationBarHidden(true)
        .onAppear {
            manager.fetchMonthWorkouts(for: selectedDate)
        }
    }
    
}

