//
//  SummaryView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

//import SwiftUI
//import HealthKit
//
//// Resumo do treino
//struct SummaryView: View {
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var workoutManager: WorkoutManager
//
//    @State private var durationFormatter: DateComponentsFormatter = {
//        let formatter = DateComponentsFormatter()
//        formatter.allowedUnits = [.hour, .minute, .second]
//        formatter.zeroFormattingBehavior = .pad
//        return formatter
//    }()
//    
//    var body: some View {
//        // carregadno
//        if workoutManager.workout == nil {
//            ProgressView("Saving workout")
//                .navigationBarHidden(true)
//        } else {
//            ScrollView(.vertical) {
//                VStack(alignment: .leading) {
//                    SummaryMetricView(
//                        title: "Total time",
//                        value: durationFormatter.string(from: workoutManager.workout?.duration ?? 0.0) ?? "",
//                        color: .yellow
//                    )
//
//                    SummaryMetricView(
//                        title: "Total Distance",
//                        value: Measurement(
//                            value: workoutManager.workout?.totalDistance?.doubleValue(for: .meter()) ?? 0,
//                            unit: UnitLength.meters
//                        ).formatted(
//                            .measurement(width: .abbreviated, usage: .road)
//                        ),
//                        color: .green
//                    )
//
//                    SummaryMetricView(
//                        title: "Total Energy",
//                        value: Measurement(
//                            value: workoutManager.workout?.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0,
//                            unit: UnitEnergy.kilocalories
//                        ).formatted(
//                            .measurement(
//                                width: .abbreviated,
//                                usage: .workout,
//                                numberFormatStyle: .number.precision(.fractionLength(0))
//                            )
//                        ),
//                        color: .pink
//                    )
//
//                    SummaryMetricView(
//                        title: "Avg. Heart Rate",
//                        value: workoutManager.averageHeartRate.formatted(.number.precision(.fractionLength(0))) + " bpm",
//                        color: .red
//                    )
//
//                    Text("Activity Rings")
//                    ActivityRingsView(
//                        healthStore: workoutManager.healthStore
//                    )
//                    .frame(width: 50, height: 50)
//
//                    Button("Done") {
//                        dismiss()
//                    }
//                }
//                .scenePadding()
//            }
//            .navigationTitle("Summary")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//
//struct SummaryMetricView: View {
//    var title: String
//    var value: String
//    var color: Color
//    
//    var body: some View {
//        Text(title)
//        Text(value)
//            .font(.system(.title2, design: .rounded)
//                .lowercaseSmallCaps()
//            )
//            .foregroundStyle(color)
//        Divider()
//    }
//}
//
//#Preview {
//    SummaryView()
//}
