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
                VStack(spacing: 40) {
                    // Top Metrics (streak, tempo, insignia)
                    HStack {
                        metric(icon: "flame.fill", value: "20", unit: "", label: "") //foguinho STREAK usuario
                        Spacer()
                        VStack(spacing: 4) {
                            Text("TEMPO")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.secondary)
                            Text(timeFormatter.string(from: TimeInterval(workout.duration)) ?? "00:00:00")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        metric(icon: "medal.fill", value: "100", unit: "", label: "") //insígnia usuario
                    }
                    
                    // Placeholder Heatmap
                    VStack(spacing: 0) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(card)
                            VStack(spacing: 0) {
                                Rectangle().fill(stroke).frame(height: 1)
                                    .opacity(0.6).padding(.top, 48)
                                Spacer()
                                Rectangle().fill(stroke).frame(height: 1)
                                    .opacity(0.6).padding(.bottom, 48)
                            }
                            HStack {
                                Spacer()
                                Rectangle().fill(stroke).frame(width: 1).opacity(0.6)
                                Spacer()
                            }
                        }
                        .frame(height: 360)
                        Rectangle()
                            .fill(stroke)
                            .frame(height: 1)
                            .opacity(0.6)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                    
                    // Bottom Metrics
                    HStack {
                        metric(icon: "arrow.up.arrow.down", value: "40", unit: "cm", label: "ALTURA MÁX")
                        Spacer()
                        metric(icon: "heart.fill", value:  "\(Int(workout.frequencyHeart))", unit: "bpm", label: "BATIMENTO")
                        Spacer()
                        metric(icon: "flame.fill", value: "\(workout.calories)", unit: "", label: "CALORIAS")
                    }
                    
                    // Nome do App
                    VStack(spacing: 8) {
                        Text("SETE")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color.brandGreen)
                        Text("Futevolei")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .tracking(1.5)
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .background(Color.black)
                .cornerRadius(24)
            } else {
                // MARK: Layout estilo Sem Fundo
                VStack(spacing: 40) {
                    // Altura Máxima
                    VStack(spacing: 8) {
                        Text("Altura máx")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("40")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(.primary)
                            Text("cm")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Calorias
                    VStack(spacing: 8) {
                        Text("Calorias")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(Int(workout.frequencyHeart))")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(.primary)
                            Text("cal")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.primary)
                        }
                    }
                    
                    // Tempo
                    VStack(spacing: 8) {
                        Text("Tempo")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                        Text(timeFormatter.string(from: TimeInterval(workout.duration)) ?? "00:00:00")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
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
                                        .foregroundStyle(Color.white.opacity(0.4))
                                    
                                    Text("Heatmap")
                                        .font(.caption2)
                                        .foregroundStyle(Color.white.opacity(0.4))
                                }
                            )
                    }
                    
                    // Nome do App
                    VStack(spacing: 8) {
                        Text("SETE")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(Color.brandGreen)
                        Text("Futevolei")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .tracking(1.5)
                    }
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 20)
            }
        }
    }
    
    @ViewBuilder
    func metric(icon: String, value: String, unit: String, label: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(Color.brandGreen)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)
                    Text(unit)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
        }
    }
}
