//
//  MetricsView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI
import HealthKit

struct MetricsView: View {
    var body: some View {
        /*TimelineView(MetricsTimeLineSchedule(from: workoutManager.builder?.startDate ?? Date())) { context in*/
        Section() {
            VStack(alignment: .leading){
                ElapsedTimeView()
                    .foregroundStyle(Color.corRosa)
                
                Text(
                    Measurement( //workoutManager.activeEnergy
                        value: 100, unit: UnitEnergy.kilocalories
                               ).formatted(
                                .measurement(
                                    width: .abbreviated,
                                    usage: .workout,
                                    numberFormatStyle: .number.precision(.fractionLength(0))
                                    
                                )
                               )
                )
                
                // Display the heart rate.
                /* Text(
                 workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))) + " bpm"
                 )*/
                Text("150 bpm") //coração
                
                // Display the distance covered.
                /* Text(
                 Measurement(
                 value: workoutManager.distance,
                 unit: UnitLength.meters
                 ).formatted(
                 .measurement(
                 width: .abbreviated,
                 usage: .road
                 )
                 )
                 )*/
                Text("1000 m")
            }
        }
        .font(.system(.title, design: .rounded)
            .monospacedDigit()
            .lowercaseSmallCaps()
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .ignoresSafeArea(edges: .bottom)
        .scenePadding()
    }
}

#Preview {
    MetricsView()
}
/*
// A custom TimelineSchedule to control the view's update frequency.
private struct MetricsTimeLineSchedule: TimelineSchedule {
    var startDate: Date

    // The fix is in this initializer's signature.
    // The external parameter name 'from' is followed by the internal parameter name 'startDate'.
    init(from startDate: Date) {
        self.startDate = startDate
    }

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> PeriodicTimelineSchedule.Entries {
        PeriodicTimelineSchedule(
            from: self.startDate,
            by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0)
        ).entries(from: startDate, mode: mode)
    }
}
*/
