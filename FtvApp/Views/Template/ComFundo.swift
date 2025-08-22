//
//  ComFundo.swift
//  FtvApp
//
//  Created by Cauê Carneiro on 20/08/25.
//


import SwiftUI
import UniformTypeIdentifiers

// MARK: - Poster / Template
struct SessionPosterView: View {
    @State private var showShare = false
    @State private var renderedImage: UIImage?
    
    var onShare: () -> Void = {}
    
    let workout: Workout
    
    private let neon = Color.brandGreen
    private let card = Color.white.opacity(0.06)
    private let stroke = Color.white.opacity(0.16)
    private let textSecondary = Color.white.opacity(0.7)
    
    var timeFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    @ViewBuilder
    func metric(icon: String, value: String, unit: String, label: String) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(neon)
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value).font(.system(size: 22, weight: .bold)).foregroundStyle(.white)
                    Text(unit).font(.system(size: 12, weight: .semibold)).foregroundStyle(textSecondary)
                }
            }
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(textSecondary)
        }
    }
    
    var posterBody: some View {
        VStack(spacing: 16) {
            // Top bar
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(neon)
                    Text("\(workout.calories)")
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .semibold))
                }
                Spacer()
                VStack(spacing: 4) {
                    Text("TEMPO")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(textSecondary)
                    Text(timeFormatter.string(from: TimeInterval(workout.duration)) ?? "00:00:00")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white)
                }
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "shield.checkerboard")
                        .foregroundStyle(neon)
                    Text("20")
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            
            // Card com heatmap
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
            
            // Métricas
            HStack {
                metric(icon: "arrow.up.arrow.down", value: "40", unit: "cm", label: "ALTURA MÁX") //puxar do relogio dps
                Spacer()
                metric(icon: "heart.fill", value: "\(workout.frequencyHeart)", unit: "bpm", label: "BATIMENTO")
                Spacer()
                metric(icon: "wind", value: "20", unit: "km/h", label: "VELOCIDADE MÁX") // puxar do relogio dps
            }
            .padding(.top, 4)
            
                         // Nome do App e Esporte
             VStack(spacing: 4) {
                 Text("SETE")
                     .font(.system(size: 24, weight: .bold))
                     .foregroundStyle(neon)
                 Text("Futevolei")
                     .font(.system(size: 12, weight: .semibold))
                     .foregroundStyle(textSecondary)
                     .tracking(1.2)
             }
            .padding(.top, 8)
        }
    }
    
    
    func exportImage(of view: some View) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        renderer.isOpaque = true  // sempre com fundo
        if let uiImage = renderer.uiImage {
            self.renderedImage = uiImage
            self.showShare = true
        }
    }
    
    var body: some View {
        let base = posterBody
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .background(Color.black) // fixado com fundo
        
        VStack(spacing: 12) {
            base
                .cornerRadius(24)
        }
        .toolbar{
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onShare) {
                    ZStack {
                        Circle().fill(neon)
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.black)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
                }
                .accessibilityLabel("Compartilhar")
            }
        }
        
    }
    
}

// MARK: - Extensions
extension TimeInterval {
    var mmssSS: String {
        let hours = Int(self) / 3600
        let minutes = (Int(self) % 3600) / 60
        let seconds = Int(self) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
