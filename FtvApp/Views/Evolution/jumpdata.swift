//
//  jumpdata.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
//

import SwiftUI

struct jumpdata: View {
    var workouts: [Workout]
    var selectedMetric: String

    var body: some View {
        let (minWorkout, maxWorkout) = minMaxForMetric(workouts: workouts, metric: selectedMetric)

        HStack(spacing: 12) {
            // Card Máx
            if let max = maxWorkout {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("MÁX")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(dateString(max.dateWorkout))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(valueForMetric(max, selectedMetric)))")
                            .fontWeight(.semibold)
                            .font(.title)
                        Text(unitForMetric(selectedMetric))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(height: 76)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
            }

            // Card Mín
            if let min = minWorkout {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("MÍN")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(dateString(min.dateWorkout))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(valueForMetric(min, selectedMetric)))")
                            .fontWeight(.semibold)
                            .font(.title)
                        Text(unitForMetric(selectedMetric))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(height: 76)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
            }
        }
    }

    // Helpers
    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }

    private func unitForMetric(_ metric: String) -> String {
        switch metric {
        case "Batimento": return "bpm"
        case "Caloria": return "kcal"
        case "Distância": return "m"
        default: return ""
        }
    }
}


//#Preview {
//    jumpdata()
//        .preferredColorScheme(.dark)
//}
