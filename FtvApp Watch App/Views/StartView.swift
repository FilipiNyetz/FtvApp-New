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
    
    var workoutTypes: [HKWorkoutActivityType] = [.soccer]
    
    var body: some View {
        NavigationStack{
            List(workoutTypes) { workoutType in
                Button {
                    //workoutManager.selectedWorkout = workoutType
                } label: {
                    Text(workoutType.name)
                        .padding(.vertical, 15)
                }
            }
            .listStyle(.carousel)
            .navigationTitle("Workouts")
            /*
            if workoutManager.selectedWorkout == nil {
                List(workoutTypes) { workoutType in
                    Button {
                        workoutManager.selectedWorkout = workoutType
                    } label: {
                        Text(workoutType.name)
                            .padding(.vertical, 15)
                    }
                }
                .listStyle(.carousel)
                .navigationTitle("Workouts")
                .onAppear {
                    workoutManager.requestAuthorization()
                }
            } else {
                SessionPagingView()
            }*/
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
