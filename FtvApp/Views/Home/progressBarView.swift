import SwiftUI
import UIKit

struct ProgressBarView: View {
    @ObservedObject var manager: HealthManager
    @EnvironmentObject var userManager: UserManager
    @State private var animatedProgress: Double = 0
    @State private var previousWorkoutsCount: Int = 0
    let goal: Int = 20  

    var body: some View {
        HStack {
            VStack {
                if userManager.bagdeNames.isEmpty {
                    Image("1stGoal")
                } else if manager.totalWorkoutsCount > 500 {
                    Image(userManager.bagdeNames[0])
                        .resizable()
                        .frame(width: 60, height: 50)
                } else {
                    Image(userManager.bagdeNames[0])
                        .resizable()
                        .frame(width: 45, height: 50)
                }

                Text("\(userManager.badgeStart)")
                    .font(.footnote)
                    .foregroundStyle(Color.textGray)
                    .fontWeight(.medium)
                    .animation(nil, value: manager.workouts.count)  
            }

            VStack {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(height: 8)
                            .foregroundColor(Color.backgroundProgressBar)
                            .cornerRadius(8)

                        let progress = min(
                            Double(manager.workouts.count)
                                / Double(userManager.goalBadge),
                            1.0
                        )

                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        interpolatedColor(progress: 0),
                                        interpolatedColor(
                                            progress: animatedProgress
                                        ),
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: progress * geometry.size.width,
                                height: 8
                            )

                    }
                }
                .frame(width: 220, height: 16)
                .padding(.bottom, -4)

                Text("\(manager.totalWorkoutsCount)")
                    .font(.footnote)
                    .foregroundStyle(Color.textGray)
                    .fontWeight(.medium)
                    .animation(nil, value: manager.workouts.count)  
            }

            VStack {
                if userManager.bagdeNames.isEmpty {
                    Image("1stGoal")
                } else if manager.totalWorkoutsCount > 650 {
                    Image(userManager.bagdeNames[1])
                        .resizable()
                        .frame(width: 60, height: 50)
                } else {
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
                gradient: Gradient(colors: [
                    .progressBarBGDark, .progressBarBGDark, .progressBarBGLight,
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)  
                .stroke(Color(.backgroundProgressBar), lineWidth: 0.3)
        )
        .shadow(
            color: Color.black.opacity(0.3),  
            radius: 3,  
            x: 0,
            y: 2
        )
        .onAppear {
            userManager.setBadgeTotalWorkout(
                totalWorkouts: manager.totalWorkoutsCount
            )
            let progress = min(
                Double(manager.totalWorkoutsCount)
                    / Double(userManager.goalBadge),
                1.0
            )
            animatedProgress = progress
        }
        .onChange(of: manager.totalWorkoutsCount) { _, newTotalWorkouts in
            print("--- onChange Disparado! Novo total de treinos: \(newTotalWorkouts) ---")

            if let medalNameToAward = userManager.checkForNewMedal(totalWorkouts: newTotalWorkouts) {
                print("✅ SUCESSO: Nova medalha encontrada para premiar: \(medalNameToAward)")
                userManager.awardMedal(medalNameToAward)

                DispatchQueue.main.async {
                    print("▶️ Tentando exibir a animação na main thread.")
                    if let rootVC = UIApplication.topMostViewController() {
                        print("  ✅ View controller encontrado com sucesso: \(rootVC.classForCoder)")
                        MedalRevealCoordinator.showMedal(
                            medalNameToAward,
                            on: rootVC
                        )
                    } else {
                        print("  ❌ ERRO: UIApplication.topMostViewController() retornou nulo. Salvando medalha como pendente.")
                        userManager.setPendingMedal(medalNameToAward)
                    }
                }
            }else{
                print("❌ NENHUMA MEDALHA NOVA: A função checkForNewMedal retornou nulo.")
            }

            userManager.setBadgeTotalWorkout(totalWorkouts: newTotalWorkouts)
            let progress = min(
                Double(newTotalWorkouts) / Double(userManager.goalBadge),
                1.0
            )
            withAnimation(.easeInOut) { animatedProgress = progress }
        }
    }

    func interpolatedColor(progress: Double) -> Color {
        let clamped = max(0, min(progress, 1))  

        let start = UIColor(hex: "#A2A2A2")  
        let end = UIColor(hex: "#D6FF45")  

        var sR: CGFloat = 0
        var sG: CGFloat = 0
        var sB: CGFloat = 0
        var sA: CGFloat = 0
        var eR: CGFloat = 0
        var eG: CGFloat = 0
        var eB: CGFloat = 0
        var eA: CGFloat = 0

        start.getRed(&sR, green: &sG, blue: &sB, alpha: &sA)
        end.getRed(&eR, green: &eG, blue: &eB, alpha: &eA)

        let r = sR + (eR - sR) * clamped
        let g = sG + (eG - sG) * clamped
        let b = sB + (eB - sB) * clamped

        return Color(red: r, green: g, blue: b)
    }

}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
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

extension UIApplication {
    static func topMostViewController(
        base: UIViewController? =
            UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController,
            let selected = tab.selectedViewController
        {
            return topMostViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}
