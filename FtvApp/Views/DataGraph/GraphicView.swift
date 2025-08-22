//
//  GraphicView.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
//
import SwiftUI
import Charts

struct GraphicView: View {
    @ObservedObject var healthManager: HealthManager
    var period: String
    var selectedMetric: String
    
    @State var selectedWorkout: Workout? = nil
    
    var body: some View {
        VStack {
            GraphicChart(
                data: dataForChart(healthManager: healthManager, period: period, selectedMetric: selectedMetric),
                selectedMetric: selectedMetric,
                period: period,
                selectedWorkout: $selectedWorkout
            )
            .frame(height: 250)
        }
    }
}
