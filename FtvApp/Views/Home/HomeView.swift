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
           
            ZStack{
                
                Color.gradiente2.ignoresSafeArea(edges: .all)
                VStack(spacing: 0) {
                    
                    // HEADER PRETO PERSONALIZADO
                    HeaderHome(manager:manager)
                    
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
                                           showCalendar: $showCalendar,
                                           manager: manager
                                       )
                                       //.padding(.top)
                                       .background(Color.clear)
                                   }
                                   .foregroundStyle(.white)
                               }
                               
                               if manager.workouts.isEmpty {
                                   CardWithoutWorkout()
                               }else{
                                   if manager.workoutsByDay[
                                       Calendar.current.startOfDay(for: selectedDate)
                                   ] != nil{
                                       ButtonDiaryGames(manager: manager, selectedDate: $selectedDate)
                                   }
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
            manager.fetchAllWorkouts(until: Date())
            userManager.countWorkouts = manager.workouts.count
            manager.startWeekChangeTimer()
        }
        
        
        .navigationBarHidden(true)
    }
    
}
