//
//  ComFundo.swift
//  FtvApp
//
//  Created by Cauê Carneiro on 20/08/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct TemplateBodyView: View {
    let workout: Workout
    let withBackground: Bool

    private let card = Color.white.opacity(0.06)
    private let stroke = Color.white.opacity(0.16)

    var timeFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }

    var body: some View {
        Group {
            if withBackground {
                // MARK: Layout estilo Com Fundo
                VStack(spacing: 24) {  // Ajuste no espaçamento geral
                    // Top Metrics (streak, tempo, insignia)
                    HStack {
                        // Coluna Esquerda
                        metric(
                            icon: "flame.fill",
                            value: "20",
                            unit: "",
                            label: ""
                        )
                        .frame(maxWidth: .infinity)

                        // Coluna Central
                        VStack(spacing: 4) {
                            Text("TEMPO")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            Text(
                                timeFormatter.string(
                                    from: TimeInterval(workout.duration)
                                ) ?? "00:00:00"
                            )
                            .font(.title2)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                            .monospacedDigit()
                            .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)

                        // Coluna Direita
                        metric(
                            icon: "medal.fill",
                            value: "100",
                            unit: "",
                            label: ""
                        )
                        .frame(maxWidth: .infinity)
                    }

                    // Placeholder Heatmap
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(card)

                        // Linhas guia do heatmap
                        VStack(spacing: 0) {
                            Spacer()
                            Rectangle().fill(stroke).frame(height: 1).opacity(
                                0.6
                            )
                            Spacer()
                            Rectangle().fill(stroke).frame(height: 1).opacity(
                                0.6
                            )
                            Spacer()
                        }
                        HStack(spacing: 0) {
                            Spacer()
                            Rectangle().fill(stroke).frame(width: 1).opacity(
                                0.6
                            )
                            Spacer()
                        }
                    }
                    .frame(height: 360)  // Altura fixa para o heatmap
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    .padding(.horizontal, 12)

                    // Bottom Metrics
                    HStack {
                        metric(
                            icon: "arrow.up.arrow.down",
                            value: "40",
                            unit: "cm",
                            label: "ALTURA MÁX"
                        )
                        .frame(maxWidth: .infinity)
                        
                        metric(
                            icon: "heart.fill",
                            value: "\(Int(workout.frequencyHeart))",
                            unit: "bpm",
                            label: "BATIMENTO"
                        )
                        .frame(maxWidth: .infinity)

                        metric(
                            icon: "flame.fill",
                            value: "\(workout.calories)",
                            unit: "cal",
                            label: "CALORIAS"
                        )
                        .frame(maxWidth: .infinity)
                    }

                    // Nome do App
                    VStack(spacing: 4) {  // Espaçamento menor
                        Text("SETE")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.brandGreen)
                        Text("FUTEVÔLEI")  // Em maiúsculo como no protótipo
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .kerning(1.5)  // Kerning é melhor que tracking para espaçamento de letras
                    }

                }
                .background(Color.black)
                .cornerRadius(24)
                .padding(.top, 12)

            } else {
                ZStack {
                    Image("SemFundo")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()

                    // MARK: Layout estilo Sem Fundo
                    VStack(spacing: 30) {
                        // Altura Máxima
                        VStack(spacing: 8) {
                            Text("Altura máx")
                                .font(.callout)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("40")
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(.primary)
                                Text("cm")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.top, -60)

                        // Calorias
                        VStack(spacing: 8) {
                            Text("Calorias")
                                .font(.callout)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(Int(workout.frequencyHeart))")
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                                    .foregroundStyle(.primary)
                                Text("cal")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                            }
                        }

                        // Tempo
                        VStack(spacing: 8) {
                            Text("Tempo")
                                .font(.callout)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            Text(
                                timeFormatter.string(
                                    from: TimeInterval(workout.duration)
                                ) ?? "00:00:00"
                            )
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .fontDesign(.rounded)
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                        }

                        // Heatmap Pequeno
                        VStack(spacing: 20) {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                .frame(width: 120, height: 160)
                                .overlay(
                                    // Placeholder para heatmap futuro
                                    VStack(spacing: 8) {
                                        Image(systemName: "chart.xyaxis.line")
                                            .font(.title2)
                                            .foregroundStyle(
                                                Color.white.opacity(0.4)
                                            )

                                        Text("Heatmap")
                                            .font(.caption2)
                                            .foregroundStyle(
                                                Color.white.opacity(0.4)
                                            )
                                    }
                                )
                        }

                        // Nome do App
                        VStack(spacing: 8) {
                            Text("SETE")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundStyle(Color.brandGreen)
                            Text("Futevolei")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                                .tracking(1.5)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .center
                )
            }
        }
    }

    @ViewBuilder
    func metric(icon: String, value: String, unit: String, label: String)
        -> some View
    {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundStyle(Color.brandGreen)

                // Só mostra o valor se ele não estiver vazio
                if !value.isEmpty {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }

                // Só mostra a unidade se ela não estiver vazia
                if !unit.isEmpty {
                    Text(unit)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)  // Ajuste fino para alinhar com o valor
                }
            }

            // Só mostra o label se ele não estiver vazio
            if !label.isEmpty {
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
