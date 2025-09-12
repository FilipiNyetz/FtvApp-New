//
//  ContentBackground.swift
//  FtvApp
//
//  Created by Filipi Romão on 26/08/25.
//

import SwiftUI

struct ContentBackground: View {
    //    let card = Color.white.opacity(1.0)
    //    let stroke = Color.white.opacity(1.0)

    let badgeImage: String
    let totalWorkouts: Int
    let currentStreak: Int
    var isPreview: Bool = true

    var timeFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }

    let workout: Workout

    // Lógica dos níveis de fogo (igual ao HeaderHome)
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
            // Top Metrics (streak, tempo, insignia)
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

                // Coluna Central
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

                // Coluna Direita
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

            // MARK: - Heatmap Display
            ZStack {
                // 1. A imagem da meia quadra como fundo
                Image("mapaTemplateFundo")  // <-- Sua nova imagem de meia quadra
                    .resizable()
                    .frame(width: 380, height: 300)
                    .aspectRatio(contentMode: .fill)

                // 2. O heatmap vem por cima, ocupando o mesmo espaço
                if isPreview {
                    // Para preview, usa a view assíncrona normal
                    GeneratedHeatmapImageView(
                        workout: workout
                    )
                    .frame(width: 340, height: 50)
                    .blur(radius: 4)
                    .padding(.trailing, -20)
                } else {
                    // Para exportação/compartilhamento, renderiza diretamente a imagem
                    if let heatmapImage = HeatmapImageGenerator.shared
                        .ensureImageExists(
                            for: workout,
                            size: CGSize(width: 160, height: 160)
                        )
                    {
                        Image(uiImage: heatmapImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 340, height: 50)
                            .blur(radius: 4)
                            .padding(.trailing, -20)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 340, height: 50)
                            .padding(.trailing, -20)
                    }
                }
            }
            // .frame(height: 250) // A altura do container do mapa de calor
            .cornerRadius(12)
            .clipped()
            .padding(.trailing, 20)  // Adiciona um respiro nas laterais do container

            // Bottom Metrics
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

                if let jump = workout.higherJump, jump != 0 {
                    metric(
                        icon: "arrow.up.and.down",
                        // Agora você usa 'jump', que é um Double garantido (não opcional)
                        value: "\(jump)",
                        unit: "cm",
                        label: "SALTO MAX",
                        systemImage: true,
                        isStreak: false
                    )
                    .frame(maxWidth: .infinity)
                }

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

            // Nome do App
            VStack(spacing: 4) {
                Image("LogoNome7")
            }

        }
        .cornerRadius(24)
        .padding(.top, 12)
    }
}
