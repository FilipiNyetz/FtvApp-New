//
//  StartView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI
import HealthKit

struct StartView: View {
    
    @ObservedObject var manager: WorkoutManager
    @State private var isWorkoutActive = false
    
    var workoutTypes: [HKWorkoutActivityType] = [.soccer]
    
    var body: some View {
            NavigationStack {
                if isWorkoutActive {
                    SessionPagingView(manager: manager)
                } else {
                    List(workoutTypes) { workoutType in
                        Button {
                            manager.startWorkout(workoutType: workoutType)
                            isWorkoutActive = true
                        } label: {
                            Text(workoutType.name)
                                .font(.title3)
                        }
                    }
                    .listStyle(.carousel)
                    .navigationTitle("Workouts")
                    .onAppear {
                        manager.requestAuthorization()
                    }
                }
            }
        }
}



extension HKWorkoutActivityType: @retroactive Identifiable {
    public var id: UInt { rawValue }
    
    var name: String {
        switch self {
        case .soccer:
            return "Futevolei"
        default:
            return ""
        }
    }
}
