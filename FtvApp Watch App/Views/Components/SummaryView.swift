//
//  SummaryView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import HealthKit
import SwiftUI
import WatchConnectivity

struct SummaryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var manager: WorkoutManager
    @ObservedObject var wcSessionDelegate: WatchWCSessionDelegate
    @ObservedObject var positionManager: managerPosition

    let workout: HKWorkout

    @State private var durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 10) {
                SummaryMetricView(
                    title: "Total time",
                    value: durationFormatter.string(from: workout.duration)
                        ?? "",
                    color: .yellow
                )

                SummaryMetricView(
                    title: "Total Distance",
                    value: Measurement(
                        value: workout.totalDistance?.doubleValue(for: .meter())
                            ?? 0,
                        unit: UnitLength.meters
                    ).formatted(
                        .measurement(width: .abbreviated, usage: .road)
                    ),
                    color: .green
                )

                SummaryMetricView(
                    title: "Total Energy",
                    value: Measurement(
                        value: workout.totalEnergyBurned?.doubleValue(
                            for: .kilocalorie()
                        ) ?? 0,
                        unit: UnitEnergy.kilocalories
                    ).formatted(
                        .measurement(width: .abbreviated, usage: .workout)
                    ),
                    color: .pink
                )

                SummaryMetricView(
                    title: "Avg. Heart Rate",
                    value: manager.averageHeartRate.formatted(
                        .number.precision(.fractionLength(0))
                    ) + " bpm",
                    color: .red
                )
                
                if let bestJump = manager.preWorkoutJumpHeight {
                    SummaryMetricView(
                        title: "Best Jump",
                        value: "\(bestJump) cm",
                        color: .orange // Uma cor para destacar
                    )
                }

                Button("Done") {
                    dismiss()
                }
                .padding(.top)
            }
            .scenePadding()
        }
        .navigationTitle("Summary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                let bestJumpValue: Int? = manager.preWorkoutJumpHeight
                
                let workoutPath = await positionManager.stopMotionUpdates()
                
                print("Vai enviar o melhor pulo (\(bestJumpValue ?? -1)) para o iphone")
                print("Quantidade de pontos: \(workoutPath.count)")
                
                wcSessionDelegate.sendMessage(message: [
                    "pulo": bestJumpValue as Any,
                    "workoutId": workout.uuid.uuidString,
                    "workoutPath": workoutPath
                ])
            }
        }

    }
}

struct SummaryMetricView: View {
    var title: String
    var value: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
            Text(value)
                .font(.system(.title2, design: .rounded).lowercaseSmallCaps())
                .foregroundStyle(color)
            Divider()
        }
    }
}
