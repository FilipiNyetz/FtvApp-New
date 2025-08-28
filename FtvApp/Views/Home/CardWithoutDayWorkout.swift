//
//  CardWithoutDayWorkout.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 26/08/25.
//

import SwiftUI

struct CardWithoutDayWorkout: View {
    var body: some View {

        ZStack(alignment: .center) {  // garante que todo o conteúdo fique centralizado
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .gradiente1, .progressBarBGDark, .progressBarBGDark,
                        ]),
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: 6,
                    x: 0,
                    y: 2
                )

            // Imagem de fundo
            Image("logo7S")
                .resizable()
                .scaledToFit()
                .opacity(0.1)
                .frame(width: 250, height: 250)
                .offset(x: 130, y: 10)

            // Conteúdo do card
            VStack(spacing: 10) {
                Text("Seu melhor desempenho ainda pode ser hoje!")
                    .font(.title3)
                    .foregroundColor(.colorPrimal)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)

                Text(
                    "Use o seu apple watch na quadra e seus resultados aparecerão aqui"
                )
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

                HStack {
                    Image(systemName: "sportscourt")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                }
                .foregroundStyle(.colorPrimal)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: 220)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.backgroundProgressBar, lineWidth: 0.3)
        )
    }
}

#Preview {
    CardWithoutDayWorkout()
}
