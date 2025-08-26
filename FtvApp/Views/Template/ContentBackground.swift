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
    
    let badgeImage:String
    
    var timeFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    let workout: Workout
   
    
    var body: some View {
        VStack(spacing: 24) {
            // Top Metrics (streak, tempo, insignia)
            HStack {
                metric(
                    icon: "flame.fill",
                    value: "20",
                    unit: "",
                    label: "",
                    systemImage: true
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
                    icon: badgeImage,
                    value: "100",
                    unit: "",
                    label: "",
                    systemImage: false
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
            .frame(height: 360)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 12)
            
            // Bottom Metrics
            HStack {
                metric(
                    icon: "heart.fill",
                    value: "\(Int(workout.frequencyHeart))",
                    unit: "bpm",
                    label: "BATIMENTO",
                    systemImage: true
                    
                )
                .frame(maxWidth: .infinity)
                
                metric(
                    icon: "flame.fill",
                    value: "\(workout.calories)",
                    unit: "cal",
                    label: "CALORIAS",
                    systemImage: true
                    
                )
                .frame(maxWidth: .infinity)
            }
            
            // Nome do App
            VStack(spacing: 4) {
                Text("SETE")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.colorPrimal)
                Text("FUTEVÔLEI")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .kerning(1.5)
            }
            
        }
        .background(Color.black)
        .cornerRadius(24)
        .padding(.top, 12)
    }
}

