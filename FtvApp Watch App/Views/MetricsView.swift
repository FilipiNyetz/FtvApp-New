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
                .font(.largeTitle)
                .fontWeight(.medium)
                .fontDesign(.rounded)
                .foregroundStyle(Color.colorPrimal)
                
                HStack(alignment: .firstTextBaseline)  {
                    Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))))

                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .alignmentGuide(.firstTextBaseline) { d in d[.bottom] + 2 }
                }

                HStack(alignment: .firstTextBaseline) {
                    Text(
                        Measurement(
                            value: workoutManager.activeEnergy,
                            unit: UnitEnergy.kilocalories
                        ).value.formatted(.number.precision(.fractionLength(0)))
                    )
                    
                    Text("Calorias")
                        .font(.caption2) // bem pequeno
                        .textCase(.uppercase) // deixa maiúsculo
                        .foregroundColor(.colorSecond) // cor secundária
                        .alignmentGuide(.firstTextBaseline) { d in d[.bottom] + 0.5 }
                }

                HStack(alignment: .firstTextBaseline){
                    Text(
                            workoutManager.distance.formatted(
                                .number.precision(.fractionLength(0))
                            )
                        )
                    
                    Text("Distância")
                        .font(.caption2) // bem pequeno
                        .textCase(.uppercase) // deixa maiúsculo
                        .foregroundColor(.colorSecond) // cor secundária
                        .alignmentGuide(.firstTextBaseline) { d in d[.bottom] + 0.5 }
                    
                }
                
                
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
