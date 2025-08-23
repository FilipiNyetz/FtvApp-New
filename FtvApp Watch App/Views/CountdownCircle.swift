//
//  CountdownCircle.swift
//  FtvApp Watch App
//
//  Created by Joao pedro Leonel on 23/08/25.
//

import SwiftUI

struct CountdownCircle: View {
    let number: Int
    let progress: CGFloat

    var body: some View {
        ZStack {
            // Círculo de fundo mais sutil, como na imagem
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 15)

            // Círculo de progresso com gradiente e espessura ajustados
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.colorPrimal, Color.colorSecond]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 18, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // Começa do topo

            // Texto com tamanho e cor ajustados
            Text("\(number)")
                .font(.system(size: 90, weight: .bold))
                .foregroundColor(.colorPrimal)
        }
        .frame(width: 150, height: 150) // Frame ligeiramente maior para melhor visualização
    }
}
