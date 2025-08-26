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
    var isPreview: Bool = true
    let card = Color.white.opacity(0.06)
    let stroke = Color.white.opacity(0.16)
    
    var badgeImage: String
    let totalWorkouts: Int
    let currentStreak: Int
    
    init(workout: Workout, withBackground: Bool, badgeImage: String, totalWorkouts: Int, currentStreak: Int, isPreview: Bool = true) {
        self.workout = workout
        self.withBackground = withBackground
        self.badgeImage = badgeImage
        self.totalWorkouts = totalWorkouts
        self.currentStreak = currentStreak
        self.isPreview = isPreview
    }
    
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
                ContentBackground(badgeImage: badgeImage, totalWorkouts: totalWorkouts, currentStreak: currentStreak, workout: workout)
            } else {
                contentNoBackground
            }
        }
        .fixedSize(horizontal: false, vertical: false)
    }
    
    // MARK: - Com Fundo
//    var contentBackground: some View {
//        VStack(spacing: 24) {
//            // Top Metrics (streak, tempo, insignia)
//            HStack {
//                metric(
//                    icon: "flame.fill",
//                    value: "20",
//                    unit: "",
//                    label: "",
//                    systemImage: true
//                )
//                .frame(maxWidth: .infinity)
//                
//                // Coluna Central
//                VStack(spacing: 4) {
//                    Text("TEMPO")
//                        .font(.caption2)
//                        .fontWeight(.semibold)
//                        .foregroundStyle(.secondary)
//                    Text(
//                        timeFormatter.string(
//                            from: TimeInterval(workout.duration)
//                        ) ?? "00:00:00"
//                    )
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .fontDesign(.rounded)
//                    .monospacedDigit()
//                    .foregroundStyle(.white)
//                }
//                .frame(maxWidth: .infinity)
//                
//                // Coluna Direita
//                metric(
//                    icon: "1stGoal",
//                    value: "100",
//                    unit: "",
//                    label: "",
//                    systemImage: false
//                )
//                .frame(maxWidth: .infinity)
//            }
//            
//            // Placeholder Heatmap
//            ZStack {
//                RoundedRectangle(cornerRadius: 12).fill(card)
//                
//                // Linhas guia do heatmap
//                VStack(spacing: 0) {
//                    Spacer()
//                    Rectangle().fill(stroke).frame(height: 1).opacity(
//                        0.6
//                    )
//                    Spacer()
//                    Rectangle().fill(stroke).frame(height: 1).opacity(
//                        0.6
//                    )
//                    Spacer()
//                }
//                HStack(spacing: 0) {
//                    Spacer()
//                    Rectangle().fill(stroke).frame(width: 1).opacity(
//                        0.6
//                    )
//                    Spacer()
//                }
//            }
//            .frame(height: 360)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
//            )
//            .padding(.horizontal, 12)
//            
//            // Bottom Metrics
//            HStack {
//                metric(
//                    icon: "heart.fill",
//                    value: "\(Int(workout.frequencyHeart))",
//                    unit: "bpm",
//                    label: "BATIMENTO",
//                    systemImage: true
//                    
//                )
//                .frame(maxWidth: .infinity)
//                
//                metric(
//                    icon: "flame.fill",
//                    value: "\(workout.calories)",
//                    unit: "cal",
//                    label: "CALORIAS",
//                    systemImage: true
//                    
//                )
//                .frame(maxWidth: .infinity)
//            }
//            
//            // Nome do App
//            VStack(spacing: 4) {
//                Text("SETE")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundStyle(Color.colorPrimal)
//                Text("FUTEVÔLEI")
//                    .font(.caption)
//                    .fontWeight(.semibold)
//                    .foregroundStyle(.secondary)
//                    .kerning(1.5)
//            }
//            
//        }
//        .background(Color.black)
//        .cornerRadius(24)
//        .padding(.top, 12)
//    }
    
    // MARK: - Sem Fundo (Transparente)
    var contentNoBackground: some View {
        ZStack {
            if isPreview {
                Image("SemFundo")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                                Color.clear
                            }
                
                // MARK: Layout estilo Sem Fundo
                VStack(spacing: 30) {
                    // Altura Máxima
                    VStack(spacing: 8) {
                        Text("Altura máx")
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("40")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundStyle(.white)
                            Text("cm")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    
                    // Calorias
                    VStack(spacing: 8) {
                        Text("Calorias")
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(workout.calories)")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundStyle(.white)
                            Text("cal")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                    
                    // Tempo
                    VStack(spacing: 8) {
                        Text("Tempo")
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text(
                            timeFormatter.string(
                                from: TimeInterval(workout.duration)
                            ) ?? "00:00:00"
                        )
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .fontDesign(.rounded)
                        .monospacedDigit()
                        .foregroundStyle(.white)
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
                            .foregroundStyle(Color.colorPrimal)
                        Text("Futevolei")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .tracking(1.5)
                    }
                }
                .padding(.horizontal, 20)
                .frame(width: 400, height: 600)
                .background(Color.clear)
            }
        }
    }
    
    @ViewBuilder
func metric(icon: String, value: String, unit: String, label: String, systemImage: Bool)
    -> some View
    {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                if systemImage {
                    Image(systemName: icon)
                        .foregroundStyle(Color.colorPrimal)
                }else{
                    Image(icon)
                }
                
                
                if !value.isEmpty {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
            
            if !label.isEmpty {
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
        }
    }

