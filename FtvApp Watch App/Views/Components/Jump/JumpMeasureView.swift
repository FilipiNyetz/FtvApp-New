//
//  JumpMeasureView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 05/09/25.
//

import HealthKit
import SwiftUI

struct JumpMeasureView: View {
    @ObservedObject var jumpDetector: JumpDetector
    
    // Recebemos o binding para o path para podermos adicionar a próxima tela
    @Binding var navigationPath: [JumpNavigationPath]
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Agora cada salto está sendo registrado")
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(Color.colorPrimal)

            Text("\(jumpDetector.lastJumpHeight * 100, specifier: "%.0f") cm")
                .font(.title2)
                .foregroundStyle(.white)
            
            Button(action: {
                jumpDetector.stop()
                let bestJumpInCm = Int(jumpDetector.bestJumpHeight * 100)
                // Adiciona a tela de resultado ao path, passando o dado junto
                navigationPath.append(.result(bestJump: bestJumpInCm))
            }) {
                Text("Concluir Saltos")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .frame(width: 160, height: 50)
                    .background(Color.colorPrimal)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .buttonStyle(.plain)
        }

        .onAppear {
            // Reinicia a detecção de pulo sempre que a tela aparece
            jumpDetector.reset()
            jumpDetector.start()
        }
        
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    .gradiente1, .gradiente2, .gradiente2, .gradiente2,
                ]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            // .opacity(0.85) // A opacidade pode ser ajustada aqui se necessário
            .ignoresSafeArea()
        )
    }
}
