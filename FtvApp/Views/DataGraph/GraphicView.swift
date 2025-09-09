////
////  GraphicView.swift
////  FtvApp
////
////  Created by Joao pedro Leonel on 19/08/25.
////
//import SwiftUI
//import Charts
//
//struct GraphicView: View {
//    @ObservedObject var healthManager: HealthManager
//    var period: String
//    var selectedMetric: String
//    
//    @State var selectedWorkout: Workout? = nil
//    
//    var body: some View {
//        
////        VStack {
////            GraphicChart(
////                data: dataForChart(healthManager: healthManager, period: period, selectedMetric: selectedMetric, todosWorkoutsOriginais: healthManager.workouts),
////                selectedMetric: selectedMetric,
////                period: period,
////                selectedWorkout: $selectedWorkout,
////                todosWorkouts: healthManager.workouts
////            )
////            .frame(height: 250)
////            .background(Color.blue)
////        }
////        .onAppear {
////            healthManager.fetchAllWorkouts()
////        }
//    }
//}
