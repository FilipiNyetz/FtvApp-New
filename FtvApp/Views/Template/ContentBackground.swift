//
//  ContentBackground.swift
//  FtvApp
//
//  Created by Filipi Romão on 26/08/25.
//

import SwiftUI

struct ContentBackground: View {
    let card = Color.white.opacity(0.06)
    let stroke = Color.white.opacity(0.16)

    let badgeImage: String
    let totalWorkouts: Int
    let currentStreak: Int

    var timeFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }

    let workout: Workout

    var nivelFogo: Int {
        switch currentStreak {
        case 0...1: return 1
        case 2...3: return 2
        case 4...7: return 3
        case 8...15: return 4
        default: return 5
        }
    }

    var imageFogoNum: String {
        "Fogo\(nivelFogo)"
    }

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                metric(
                    icon: imageFogoNum,
                    value: "\(currentStreak)",
                    unit: "",
                    label: "",
                    systemImage: false,
                    isStreak: true
                )
                .frame(maxWidth: .infinity)

                VStack(spacing: 4) {
                    Text("TEMPO")
                        .font(.caption2)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.textGray)
                    Text(
                        timeFormatter.string(
                            from: TimeInterval(workout.duration)
                        ) ?? "00:00.00"
                    )
                    .font(.title2)
                    .fontWeight(.medium)
                    .fontDesign(.rounded)
                    .monospacedDigit()
                    .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)

                metric(
                    icon: badgeImage,
                    value: "\(totalWorkouts)",
                    unit: "",
                    label: "",
                    systemImage: false,
                    isStreak: false
                )
                .frame(maxWidth: .infinity)
            }

            Image("logo7S")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
                .opacity(0.8)
                .padding(50)

            HStack {
                metric(
                    icon: "heart.fill",
                    value: "\(Int(workout.frequencyHeart))",
                    unit: "bpm",
                    label: "BATIMENTO",
                    systemImage: true,
                    isStreak: false

                )
                .frame(maxWidth: .infinity)

                metric(
                    icon: "flame.fill",
                    value: "\(workout.calories)",
                    unit: "cal",
                    label: "CALORIA",
                    systemImage: true,
                    isStreak: false

                )
                .frame(maxWidth: .infinity)
            }

            VStack(spacing: 4) {
                Image("LogoNome7")
            }

        }
        .cornerRadius(24)
        .padding(.top, 12)
    }
}
