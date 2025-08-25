//
//  CountdownScreen.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 25/08/25.
//

// CountdownScreen.swift

import SwiftUI

struct CountdownScreen: View {
    @State private var countdownNumber: Int = 0 // Inicia com 0 para o estado "Preparar"
    @State private var progress: Double = 0.0 // Começa com 0.0 para animar o preenchimento
    var onCountdownFinished: () -> Void

    var body: some View {
        ZStack {
            // Anel de fundo
            Circle()
                .stroke(Color.colorPrimal.opacity(0.3), lineWidth: 13)
                .frame(width: 150, height: 150)

            // Anel que se preenche ou diminui
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(Color.colorPrimal, style: StrokeStyle(lineWidth: 13, lineCap: .round))
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
            
            // Texto da contagem
            Text(countdownText)
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .id(countdownNumber)
                .transition(.scale)
        }
        .task {
            // FASE 1: PREPARAR - Anima o preenchimento rápido do círculo
            withAnimation(.linear(duration: 0.5)) {
                progress = 1.0
            }
            try? await Task.sleep(for: .seconds(1.0))

            // FASE 2: CONTAGEM REGRESSIVA
            for i in (1...3).reversed() {
                countdownNumber = i
                withAnimation(.linear(duration: 1.0)) {
                    progress = Double(i - 1) / 3.0 // O progresso diminui para a esquerda
                }
                try? await Task.sleep(for: .seconds(1.0))
            }
            
            // Transição para o texto final
            withAnimation {
                countdownNumber = -1
            }
            try? await Task.sleep(for: .seconds(0.5))
            
            // Finaliza a contagem
            onCountdownFinished()
        }
    }
    
    // Propriedade computada para o texto da contagem
    var countdownText: String {
        if countdownNumber == 0 {
            return "Preparar"
        } else if countdownNumber > 0{ // O estado inicial é 0, o resto é > 0
            return String(countdownNumber)
        }else{
            return ""
        }
    }
    
    // Propriedade computada para o tamanho da fonte
    private var fontSize: CGFloat {
        return countdownNumber > 0 ? 80 : 30
    }
}
