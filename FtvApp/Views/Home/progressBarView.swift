import SwiftUI

struct ProgressBarView: View {
    @ObservedObject var manager: HealthManager
    @ObservedObject var userManager: UserManager
    @State private var animatedProgress: Double = 0
    let goal: Int = 20 // meta inicial
    
    var body: some View {
        HStack {
            VStack {
                if userManager.bagdeNames.isEmpty{
                    Image("1stGoal")
                        .resizable()
                        .frame(width: 45, height: 50)
                        .animation(nil, value: manager.workouts.count) // bloqueia animação
                }else{
                    Image(userManager.bagdeNames[0])
                        .resizable()
                        .frame(width: 45, height: 50)
                        .animation(nil, value: manager.workouts.count) // bloqueia animação
                }
                    
                Text("\(userManager.badgeStartValue())")
                    .font(.footnote)
                    .foregroundStyle(Color.textGray)
                    .fontWeight(.medium)
                    .animation(nil, value: manager.workouts.count) // bloqueia animação
            }
            
            VStack {
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
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        interpolatedColor(progress: 0),
                                        interpolatedColor(progress: animatedProgress)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: progress * geometry.size.width, height: 8)
                        
                    }
                }
                .frame(width: 220, height: 16)
                .padding(.bottom, -4)
                
                Text("\(manager.totalWorkoutsCount)")
                    .font(.footnote)
                    .foregroundStyle(Color.textGray)
                    .fontWeight(.medium)
                    .animation(nil, value: manager.workouts.count) // bloqueia animação
            }

            
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
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.progressBarBGDark,.progressBarBGDark, .progressBarBGLight]),
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8) // mesmo radius do Figma
                .stroke(Color(.backgroundProgressBar), lineWidth: 0.3)
        )
        .shadow(
            color: Color.black.opacity(0.3), // ajusta a opacidade
            radius: 3, // blur
            x: 0,
            y: 2
        )
        .onAppear {
            userManager.setBadgeTotalWorkout(totalWorkouts: manager.totalWorkoutsCount)
            // Inicializa animação da barra
            let progress = min(Double(manager.workouts.count) / Double(userManager.goalBadge), 1.0)
            animatedProgress = progress
        }
        .onChange(of: manager.workouts.count) { _, newValue in
            userManager.setBadgeTotalWorkout(totalWorkouts: newValue)
            let progress = min(Double(newValue) / Double(userManager.goalBadge), 1.0)
            withAnimation(.easeInOut) {
                animatedProgress = progress
            }
        }
    }
    
    /// Interpola entre duas cores (#A2A2A2 -> #D6FF45) conforme o progresso
    func interpolatedColor(progress: Double) -> Color {
        let clamped = max(0, min(progress, 1)) // garante que esteja entre 0 e 1
        
        let start = UIColor(hex: "#A2A2A2") // cinza
        let end = UIColor(hex: "#D6FF45")   // verde limão
        
        var sR: CGFloat = 0, sG: CGFloat = 0, sB: CGFloat = 0, sA: CGFloat = 0
        var eR: CGFloat = 0, eG: CGFloat = 0, eB: CGFloat = 0, eA: CGFloat = 0
        
        start.getRed(&sR, green: &sG, blue: &sB, alpha: &sA)
        end.getRed(&eR, green: &eG, blue: &eB, alpha: &eA)
        
        let r = sR + (eR - sR) * clamped
        let g = sG + (eG - sG) * clamped
        let b = sB + (eB - sB) * clamped
        
        return Color(red: r, green: g, blue: b)
    }

}

// Extensão para converter hex em UIColor
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
