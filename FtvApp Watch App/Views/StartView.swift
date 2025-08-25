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
    @State private var isWorkoutActive = false
    @State private var savedWorkout: HKWorkout?
    
    var workoutTypes: [HKWorkoutActivityType] = [.soccer]
    
    var body: some View {
        NavigationStack {
            if isWorkoutActive {
                SessionPagingView(manager: manager)
                    .onAppear {
                        // Callback para mostrar summary
                        manager.onWorkoutEnded = { workout in
                            self.savedWorkout = workout
                        }
                    }
                    .sheet(item: $savedWorkout, onDismiss: {
                        isWorkoutActive = false
                    }) { workout in
                        SummaryView(workout: workout)
                            .environmentObject(manager)
                    }
            } else {
                List(workoutTypes) { workoutType in
                    Button {
                        manager.startWorkout(workoutType: workoutType)
                        isWorkoutActive = true
                    } label: {
                        HStack {
                            Image(systemName: "figure.run.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.green)
                            Text(workoutType.name)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.carousel)
                .navigationTitle("Escolha o treino")

                .onAppear {
                    manager.requestAuthorization()
                }
            }
        }
    }
}

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
