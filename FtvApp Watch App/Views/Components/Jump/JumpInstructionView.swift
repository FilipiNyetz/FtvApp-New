//
//  JumpInstructionView.swift
//  FtvApp Watch App
//
//  Jump measurement flow has been removed.
//

import SwiftUI

struct JumpInstructionView: View {
    var body: some View {
        // Placeholder view kept for compatibility after removing jump feature
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.gradiente1, .gradiente2, .gradiente2]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "figure.run")
                    .font(.system(size: 36))
                    .foregroundStyle(.white.opacity(0.9))

                Text("Medição de salto removida")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Esta tela não é mais utilizada.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}
