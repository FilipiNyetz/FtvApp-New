//
//  StartView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI
import HealthKit

struct StartView: View {
    
    @StateObject var manager = WorkoutManager()
    
    // O tipo de treino que será exibido na lista.
    var workoutTypes: [HKWorkoutActivityType] = [.soccer]
    
    var body: some View {
        NavigationStack {
            List(workoutTypes) { workoutType in
                // NavigationLink para levar à tela de contagem regressiva (StartTraining).
                NavigationLink(destination: StartTraining(workoutManager: manager, workoutType: workoutType)) {
                    Text(workoutType.name)
                        .font(.title3)
                }
            }
            .listStyle(.carousel)
            .navigationTitle("Workouts")
            .onAppear {
                // Solicita autorização ao HealthKit quando a view aparece.
                manager.requestAuthorization()
            }
        }
    }
}

// ✅ Extensão que faltava para HKWorkout
extension HKWorkout: @retroactive Identifiable {
    public var id: UUID { self.uuid }
}

extension HKWorkoutActivityType: @retroactive Identifiable {
    public var id: UInt { rawValue }
    
    var name: String {
        switch self {
        case .soccer: return "Futevôlei"
        default: return "Treino"
        }
    }
}
