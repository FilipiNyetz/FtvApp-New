//
//  CountdownScreen.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 25/08/25.
//

// CountdownScreen.swift

import SwiftUI
import WatchKit

struct CountdownScreen: View {
    @State private var countdownNumber: Int = 0 // Inicia com 0 para o estado "Preparar"
    @State private var progress: Double = 0.0 // Começa com 0.0 para animar o preenchimento
    @State private var textScale: Double = 1.0 // Para animação de escala do texto
    @State private var textOpacity: Double = 1.0 // Para animação de opacidade do texto
    @State private var circleScale: Double = 1.0 // Para animação de escala do círculo
    var onCountdownFinished: () -> Void

    var body: some View {
        ZStack {
            // Anel de fundo com animação de escala
            Circle()
                .stroke(Color.colorPrimal.opacity(0.3), lineWidth: 10)
                .frame(width: 140, height: 140)
                .scaleEffect(circleScale)
                .animation(.easeInOut(duration: 0.6), value: circleScale)

            // Anel que se preenche ou diminui com animação fluida
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(Color.colorPrimal, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 140, height: 140)
                .scaleEffect(circleScale)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: progress)
                .animation(.easeInOut(duration: 0.6), value: circleScale)
            
            // Texto da contagem com animações fluidas
            Text(countdownText)
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .scaleEffect(textScale)
                .opacity(textOpacity)
                .animation(.easeInOut(duration: 0.4), value: textScale)
                .animation(.easeInOut(duration: 0.4), value: textOpacity)
                .id(countdownNumber)
        }
        .task {
            // FASE 1: PREPARAR - Anima o preenchimento rápido do círculo
            withAnimation(.easeInOut(duration: 0.6)) {
                progress = 1.0
                circleScale = 1.02 // Crescimento mais sutil do círculo
            }
            try? await Task.sleep(for: .seconds(1.0))

            // FASE 2: CONTAGEM REGRESSIVA com animações fluidas e travadinhas
            for i in (1...3).reversed() {
                // Animação de saída do número anterior
                withAnimation(.easeInOut(duration: 0.2)) {
                    textScale = 0.5
                    textOpacity = 0.0
                }
                try? await Task.sleep(for: .seconds(0.2))
                
                // Muda o número e anima entrada com travadinha no círculo
                countdownNumber = i
                withAnimation(.easeInOut(duration: 0.3)) {
                    textScale = 1.2 // Efeito bounce
                    textOpacity = 1.0
                    // ✨ TRAVADINHA: Círculo cresce sutilmente
                    circleScale = 1.08
                }
                try? await Task.sleep(for: .seconds(0.15))
                
                // ✨ TRAVADINHA: Círculo volta ao normal criando o efeito
                withAnimation(.easeInOut(duration: 0.15)) {
                    circleScale = 1.0
                }
                
                // Volta o texto ao tamanho normal
                withAnimation(.easeInOut(duration: 0.2)) {
                    textScale = 1.0
                }
                try? await Task.sleep(for: .seconds(0.1))
                
                // Animação do círculo diminuindo suavemente
                withAnimation(.easeInOut(duration: 0.6)) {
                    progress = Double(i - 1) / 3.0 // O progresso diminui para a esquerda
                }
                try? await Task.sleep(for: .seconds(0.3))
            }
            
            // Transição final com efeito de recolhimento
            withAnimation(.easeInOut(duration: 0.3)) {
                textScale = 0.1 // Recolhe o texto
                textOpacity = 0.0
                circleScale = 0.9 // Diminui o círculo sutilmente
            }
            countdownNumber = -1
            try? await Task.sleep(for: .seconds(0.5))
            
            // Feedback háptico quando o treino inicia
            WKInterfaceDevice.current().play(.start)
            
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
