//
//  CardWithoutWorkout.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 26/08/25.
//

import SwiftUI

struct CardWithoutWorkout: View {
    var body: some View {

        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    .gradiente1, .progressBarBGDark, .progressBarBGDark,
                    .progressBarBGDark,
                ]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )

            // Imagem que flutua atrás do texto
            Image("logo7S")
                .resizable()
                .scaledToFit()
                .opacity(0.1)
                .frame(width: 250, height: 250)
                .offset(x: 130, y: 10)

            // Conteúdo de texto e ícone centralizados
            VStack(alignment: .center, spacing: 10) {

                Text("Você ainda não tem treinos registrados")
                    .font(.headline)
                    .foregroundColor(.colorPrimal)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                Text(
                    "Use o SETE na partida e visualize seus resultados logo depois do jogo!"
                )
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Image(systemName: "applewatch")
                    Image(systemName: "arrow.up.and.down")
                    Image(systemName: "heart.fill")
                    Image(systemName: "flame.fill")
                    Image(systemName: "location.fill")
                }
                .frame(width: 30, height: 30)
                .foregroundStyle(.colorPrimal)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: 220)
        .clipShape(.rect(cornerRadius: 15))
        .clipped()

    }
}

#Preview {
    CardWithoutDayWorkout()
}
