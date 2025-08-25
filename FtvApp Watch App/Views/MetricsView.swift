//
//  MetricsView.swift
//  MyWorkouts Watch App
//
//  Created by Gustavo Souto Pereira on 11/08/25.
//

import SwiftUI
import HealthKit

struct MetricsView: View {
    @ObservedObject var workoutManager: WorkoutManager
    @StateObject private var jumpDetector = JumpDetector()

    var body: some View {
        TimelineView(MetricsTimeLineSchedule(from: workoutManager.startDate ?? Date())) { context in
            VStack(alignment: .leading) {
                ElapsedTimeView(
                    elapsedTime: workoutManager.elapsedTime,
                    showSubseconds: context.cadence == .live
                )
                .foregroundStyle(.yellow)

                Text(
                    Measurement(
                        value: workoutManager.activeEnergy,
                        unit: UnitEnergy.kilocalories
                    ).formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .workout,
                            numberFormatStyle: .number.precision(.fractionLength(0))
                        )
                    )
                )

                Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))) + " bpm")

                Text(
                    Measurement(
                        value: workoutManager.distance,
                        unit: UnitLength.meters
                    ).formatted(
                        .measurement(
                            width: .abbreviated,
                            usage: .road
                        )
                    )
                )
                
                // Saltos
//                Text("Ú: \(String(format: "%.0f", jumpDetector.lastJumpHeight * 100)) cm")
//                
//                Text("MKA: \(String(format: "%.0f", jumpDetector.bestJumpHeight * 100)) cm")
            }
            .font(
                .system(.title, design: .rounded)
                    .monospacedDigit()
                    .lowercaseSmallCaps()
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .ignoresSafeArea(edges: .bottom)
            .scenePadding()
        }
//        .onAppear {
//            jumpDetector.start()
//        }
//        .onDisappear {
//            jumpDetector.stop()
//        }
    }
}

private struct MetricsTimeLineSchedule: TimelineSchedule {
    var startDate: Date

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
