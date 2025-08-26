import SwiftUI

struct ProgressBarView: View {
    @ObservedObject var manager: HealthManager
    @ObservedObject var userManager: UserManager
    let goal: Int = 20 // meta inicial
    
    var body: some View {
        HStack {
            VStack {
                if userManager.bagdeNames.isEmpty{
                    Image("1stGoal")
                }else{
                    Image(userManager.bagdeNames[0])
                        .resizable()
                        .frame(width: 45, height: 50)
                }
                    
                Text("\(manager.workouts.count)")
                    .font(.footnote)
                    .foregroundStyle(Color.textGray)
                    .fontWeight(.medium)
            }
            
            VStack{
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Fundo da barra
                        Rectangle()
                            .frame(height: 8)
                            .foregroundColor(Color.backgroundProgressBar)
                            .cornerRadius(8)
                        
                        // Progresso
                        let progress = min(Double(manager.workouts.count) / Double(userManager.goalBadge), 1.0)
                        
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .frame(
                                width: progress * geometry.size.width,
                                height: 8
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [.white, .colorPrimal]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .animation(.easeInOut, value: manager.workouts.count)
                    }
                }
                .frame(width: 220, height: 16)
                .padding(.bottom, -4)
                Text("\(manager.totalWorkoutsCount)")
                    .font(.footnote)
                    .foregroundStyle(Color.textGray)
                    .fontWeight(.medium)
                
                
            } // largura fixa da barra
            
            VStack {
                if userManager.bagdeNames.isEmpty{
                    Image("1stGoal")
                }else{
                    Image(userManager.bagdeNames[1])
                        .resizable()
                        .frame(width: 45, height: 50)
                }
                Text("\(userManager.goalBadge)")
                    .font(.footnote)
                    .foregroundStyle(Color.textGray)
                    .fontWeight(.medium)
            }
        }
        .frame(width: 361, height: 96)
        .background(LinearGradient(
            gradient: Gradient(colors: [.progressBarBGLight, .progressBarBGDark]),
            startPoint: .top,
            endPoint: .bottom
        ))// tamanho fixo da HStack toda
        .onAppear(){
            userManager.setBadgeTotalWorkout(totalWorkouts: manager.totalWorkoutsCount)
        }
        .onChange(of: manager.totalWorkoutsCount) {
            userManager.setBadgeTotalWorkout(totalWorkouts: manager.totalWorkoutsCount)
        }
    }
        
}
