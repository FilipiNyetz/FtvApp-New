//
//  StartTraining.swift
//  FtvApp Watch App
//
//  Created by Joao pedro Leonel on 23/08/25.
//

import SwiftUI
import HealthKit // Importar HealthKit para usar HKWorkoutActivityType

struct StartTraining: View {
    @State  var timeRemaining = 3
    @State  var timerRunning = false
    @State  var progress: CGFloat = 1.0
    @ObservedObject var workoutManager : WorkoutManager
    
    // Propriedade para receber o tipo de treino da StartView.
    var workoutType: HKWorkoutActivityType
    
    // Estado para controlar a navegação para a MetricsView.
    @State private var navigateToMetrics = false

    var body: some View {
        // A NavigationView foi removida daqui, pois a StartView já está em uma NavigationStack.
        ZStack {
            // Navegação invisível que é acionada pelo estado.
            NavigationLink(
                destination: MetricsView(workoutManager: workoutManager),
                isActive: $navigateToMetrics
            ) {
                EmptyView()
            }
            .hidden()

            VStack {
                if timerRunning {
                    CountdownCircle(number: timeRemaining, progress: progress)
                } else {
                    Text("O Watch está calibrado e pronto para começar")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding()

                    Button("Iniciar") {
                        startTimer()
                    }
                    .foregroundColor(Color.limeGreen)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
        }
        .navigationBarHidden(true) // Esconde a barra de navegação padrão.
    }

    func startTimer() {
        timerRunning = true
        timeRemaining = 3
        progress = 1.0

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
                withAnimation(.linear(duration: 1.0)) {
                    self.progress = CGFloat(self.timeRemaining) / 3.0
                }
            }

            if self.timeRemaining == 0 {
                timer.invalidate()
                workoutManager.startWorkout(workoutType: workoutType)
                self.navigateToMetrics = true
            }
        }
    }

}


extension Color {
    static let limeGreen = Color(red: 0.8, green: 1.0, blue: 0.2)
    static let darkerGreen = Color(red: 0.5, green: 0.8, blue: 0.1)
}


// A Preview precisa ser atualizada para passar um tipo de treino.
struct StartTraining_Previews: PreviewProvider {
    static var previews: some View {
        StartTraining(workoutManager: WorkoutManager(), workoutType: .soccer)
    }
}
