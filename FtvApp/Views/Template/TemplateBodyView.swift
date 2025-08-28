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
                        Text("Caloria")
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
                                .foregroundStyle(.white)
                                .padding(.leading, 3)
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
                            ) ?? "00:00.00"
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
                       Image("LogoNome7")
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
               if systemImage || isStreak {
                   // 🔹 Mantém o layout atual (ícone + texto lado a lado)
                   HStack(spacing: 4) {
                       if systemImage {
                           Image(systemName: icon)
                               .foregroundStyle(Color.colorSecond)
                               .font(.system(size: 16, weight: .medium))
                       } else {
                           Image(icon)
                               .resizable()
                               .scaledToFit()
                               .frame(width: 24, height: 24)
                       }
                       
                       if !value.isEmpty {
                           Text(value)
                               .font(systemImage ? .title2 : .headline)
                               .fontWeight(systemImage ? .bold : .semibold)
                               .foregroundStyle(systemImage ? .white : Color.textGray)
                       }
                       
                       if !unit.isEmpty {
                           Text(unit)
                               .font(.footnote)
                               .fontWeight(.regular)
                               .foregroundStyle(Color.textGray)
                               .padding(.top, 4)
                       }
                   }
               } else {
                   // 🔹 Caso do badge → Ícone em cima, número embaixo
                   VStack(spacing: 4) {
                       Image(icon)
                           .resizable()
                           .scaledToFit()
                           .frame(width: 40, height: 40)
                       
                       if !value.isEmpty {
                           Text(value)
                               .font(.headline)
                               .fontWeight(.semibold)
                               .foregroundStyle(.white)
                       }
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



