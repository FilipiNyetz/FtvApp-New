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
//                    VStack(spacing: 8) {
//                        Text("Altura máx")
//                            .font(.callout)
//                            .fontWeight(.bold)
//                            .foregroundStyle(.white)
//                        HStack(alignment: .firstTextBaseline, spacing: 4) {
//                            Text("40")
//                                .font(.largeTitle)
//                                .fontWeight(.heavy)
//                                .foregroundStyle(.white)
//                            Text("cm")
//                                .font(.title2)
//                                .fontWeight(.medium)
//                                .foregroundStyle(.white.opacity(0.6))
//                        }
//                    }
                    
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
                        Text("TEMPO")
                            .font(.caption2)
                            .fontWeight(.regular)
                            .foregroundStyle(Color.textGray)
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
                    
//                 //    Heatmap Pequeno
//                    VStack(spacing: 20) {
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
//                            .frame(width: 120, height: 160)
//                            .overlay(
//                                // Placeholder para heatmap futuro
//                                VStack(spacing: 8) {
//                                    Image(systemName: "chart.xyaxis.line")
//                                        .font(.title2)
//                                        .foregroundStyle(
//                                            Color.white.opacity(0.4)
//                                        )
//                                    
//                                    Text("Heatmap")
//                                        .font(.caption2)
//                                        .foregroundStyle(
//                                            Color.white.opacity(0.4)
//                                        )
//                                }
//                            )
//                    }
                    
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
func metric(icon: String, value: String, unit: String, label: String, systemImage: Bool, isStreak: Bool)
    -> some View
    {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                if systemImage {
                    Image(systemName: icon)
                        .foregroundStyle(Color.colorSecond)
                        .font(.system(size: 16, weight: .medium))
                }else if !systemImage && isStreak{
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                }
                else{
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                }
                
                
                if !value.isEmpty && systemImage {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                } else if !value.isEmpty && !systemImage{
                    Text(value)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.textGray)
                }
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.footnote)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.textGray)
                        .padding(.top, 4)
                }
            }
            
            if !label.isEmpty {
                Text(label)
                    .font(.caption2)
                    .fontWeight(.regular)
                    .foregroundStyle(Color.textGray)
            }
        }
    }



