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
    
    var data: SessionData
    
    private let neon = Color.brandGreen
    private let textPrimary = Color.white
    private let textSecondary = Color.white.opacity(0.7)
    
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
                    Text("\(data.maxHeightCM)")
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
                    Text("\(data.maxSpeedKMH)")
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
                
                Text(data.elapsed.mmssSS)
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
                
                Text(data.sport.uppercased())
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

// Preview
struct SemFundoView_Previews: PreviewProvider {
    static var previews: some View {
        let data = SessionData(
            points: 1250,
            score: 89,
            elapsed: 921, // 15:21 em segundos
            maxHeightCM: 40,
            avgBPM: 145,
            maxSpeedKMH: 15,
            sport: "FUTVÔLEI"
        )
        NavigationStack {
            SemFundoView(data: data)
                .background(Color.gray.opacity(0.1)) // Para ver o contraste no preview
                .padding()
        }
    }
}
