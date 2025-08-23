//
//  CopiedAlertView.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 22/08/25.
//

import SwiftUI

struct CopiedAlertView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.brandGreen)

                Text("Imagem Copiada para a Área de Transferência")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
            }
            .padding(EdgeInsets(top: 60, leading: 40, bottom: 60, trailing: 40))
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 10)
        }
        .padding(.horizontal, 50)
        .transition(.opacity.animation(.easeInOut))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    isPresented = false
                }
            }
        }
    }
}
