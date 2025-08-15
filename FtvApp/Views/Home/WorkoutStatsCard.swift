//
//  WorkoutStatsCard.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import SwiftUI

struct WorkoutStatsCard: View {
    var heartRate: Int
    var calories: Double
    var elapsedTime: TimeInterval
    var steps: Int
    var distance: Double

    private var timeFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }

    var body: some View {
        VStack(spacing: 16) {
            // Linha de cima
            HStack {
                statItem(title: "BATIMENTO", value: "\(heartRate)", unit: "bpm", icon: "heart.fill")
                Divider().frame(height: 40).background(Color.white.opacity(0.4))
                statItem(title: "CALORIA", value: String(format: "%.0f", calories), unit: "cal", icon: "flame.fill")
            }

            // Tempo central
            Text(timeFormatter.string(from: elapsedTime) ?? "00:00:00")
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundColor(.white)

            // Linha de baixo
            HStack {
                statItem(title: "PASSOS", value: "\(steps)", unit: "", icon: "figure.walk")
                Divider().frame(height: 40).background(Color.white.opacity(0.4))
                statItem(title: "DISTÂNCIA", value: String(format: "%.1f", distance), unit: "km", icon: "location.fill")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func statItem(title: String, value: String, unit: String, icon: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.gray)

            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(value)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color.black.edgesIgnoringSafeArea(.all)
        WorkoutStatsCard(
            heartRate: 125,
            calories: 294,
            elapsedTime: 55272, // 15h 21m 12s
            steps: 129,
            distance: 0.3
        )
        .padding()
    }
}
