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
                Image(systemName: "checkmark")
                    .font(.system(size: 56))
                    .foregroundColor(.colorPrimal)

                Text("Imagem copiada para a área de transferência")
                    .font(.title3)
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
