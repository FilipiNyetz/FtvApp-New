//
//  JumpInstructionView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 08/09/25.
//

import SwiftUI

struct JumpInstructionView: View {
    @Binding var navigationPath: [JumpNavigationPath]

    var body: some View {
        Group{
            VStack(spacing: 12) {
                Text("Como medir seu salto")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: true, vertical: false)
                
                Text("Mãos na cintura e prepare-se para pular quantas vezes quiser")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)

                Button(action: {
                    navigationPath.append(.measure)
                }) {
                    Text("Iniciar medição")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        .frame(width: 160, height: 50)
                        .background(Color.colorPrimal)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.gradiente1, .gradiente2, .gradiente2]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .ignoresSafeArea()
        )
    }
}
