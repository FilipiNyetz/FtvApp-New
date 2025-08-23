import SwiftData
import SwiftUI

struct HomeView: View {
    @ObservedObject var manager: HealthManager
    
    @State private var isGamesPresented = false
    @State var selectedDate: Date = Date()
    @State var opcaoDeTreinoParaMostrarCard: Int = 0
    
    var body: some View {
        NavigationStack {
           
            ZStack{
                
                Color.gradiente2.ignoresSafeArea(edges: .all)
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
                        .padding(.horizontal)
                       // .padding(.top, 50)
                        
                        // “Foguinho” logo abaixo do título
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.brandGreen)
                            Text("20")  // valor dinâmico se quiser
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    .background(Color.black)
                    
                    // CONTEÚDO
                    ScrollView {
                       ZStack {
                           LinearGradient(
                            gradient: Gradient(colors: [.gradiente1, .gradiente2, .gradiente2,  .gradiente2]),
                                   startPoint: .bottomLeading,
                                   endPoint: .topTrailing
                               )
                               .ignoresSafeArea()
                           VStack(alignment: .leading, spacing: 20) {
                               ZStack{
                                   VStack{
                                       DatePickerField(
                                           selectedDate: $selectedDate,
                                           manager: manager
                                       )
                                       //.padding(.top)
                                       .background(Color.clear)
                                   }
                                   .foregroundStyle(.white)
                               }
                               
                               
                               if manager.workoutsByDay[
                                   Calendar.current.startOfDay(for: selectedDate)
                               ] != nil{
                                   ButtonDiaryGames(manager: manager, selectedDate: $selectedDate)
                               }
                               
                           }.padding()
                       }
                        
                        
                        Divider()
                            .padding(.top, -8)
                        
                        VStack{
                            TotalGames(manager: manager, totalWorkouts: manager.workouts.count)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            manager.fetchMonthWorkouts(for: selectedDate)
        }
        .navigationBarHidden(true)
    }
    
}

