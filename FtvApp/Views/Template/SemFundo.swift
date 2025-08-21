//
//  SemFundo.swift
//  FtvApp
//
//  Created by Cauê Carneiro on 21/08/25.
//

import SwiftUI
import UIKit

struct SemFundoView: View {
    @State private var showCopiedAlert = false
    
    let workout: Workout
    
    private let neon = Color.brandGreen
    private let textPrimary = Color.white
    private let textSecondary = Color.white.opacity(0.7)
    
    var timeFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    var body: some View {
        let base = posterBody
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
        
        VStack(spacing: 12) {
            base
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    copyImageToClipboard(of: base)
                } label: {
                    Label("Copiar", systemImage: "doc.on.clipboard")
                }
            }
        }
        .alert("Imagem Copiada!", isPresented: $showCopiedAlert) {
            Button("OK") { }
        } message: {
            Text("A imagem foi copiada para a área de transferência.\nAgora você pode colar no story do Instagram!")
        }
    }
    
    private var posterBody: some View {
        VStack(spacing: 40) {
            // Altura máxima
            VStack(spacing: 8) {
                Text("Altura máx")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(textPrimary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("40") //puxar do relogio
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(textPrimary)
                    Text("cm")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(textSecondary)
                }
            }
            
            // Velocidade máxima
            VStack(spacing: 8) {
                Text("Velocidade máx")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(textPrimary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("20") //puxar do relogio
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(textPrimary)
                    Text("km/h")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(textSecondary)
                }
            }
            
            // Tempo
            VStack(spacing: 8) {
                Text("Tempo")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(textPrimary)
                
                Text(timeFormatter.string(from: TimeInterval(workout.duration)) ?? "00:00:00")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(textPrimary)
            }
            
            // Espaço reservado para heatmap (implementação futura)
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
            
            // Nome do app e esporte
            VStack(spacing: 8) {
                Text("SETE")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(neon)
                
                Text("Futevolei")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(textSecondary)
                    .tracking(1.5)
            }
        }
    }
    
    private func copyImageToClipboard(of view: some View) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        renderer.isOpaque = false  // IMPORTANTE: Sem fundo opaco para transparência
        
        if let uiImage = renderer.uiImage {
            // Copia a imagem para a área de transferência
            UIPasteboard.general.image = uiImage
            
            // Mostra o alerta de confirmação
            showCopiedAlert = true
            
            // Feedback háptico para indicar sucesso
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
}
