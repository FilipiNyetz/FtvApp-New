//
//  StartTraining.swift
//  FtvApp Watch App
//
//  Created by Joao pedro Leonel on 23/08/25.
//

import SwiftUI
import HealthKit // Importar HealthKit para usar HKWorkoutActivityType

struct StartTraining: View {
    @ObservedObject var workoutManager: WorkoutManager
    var workoutType: HKWorkoutActivityType
    @State private var navigateToMetrics = false

    var body: some View {
        ZStack {
            NavigationLink(
                destination: MetricsView(workoutManager: workoutManager),
                isActive: $navigateToMetrics
            ) {
                EmptyView()
            }
            .hidden()

            // Countdown circular iniciado imediatamente
            CountdownCircle(onComplete: {
                workoutManager.startWorkout(workoutType: workoutType)
                navigateToMetrics = true
            })
        }
        .navigationBarHidden(true)
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
