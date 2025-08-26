//
//  CardWithoutDayWorkout.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 26/08/25.
//

import SwiftUI

struct CardWithoutDayWorkout: View {
    var body: some View {

        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    .gradiente1, .progressBarBGDark, .progressBarBGDark, .progressBarBGDark,
                ]),
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .ignoresSafeArea()
            
            // Imagem que flutua atrás do texto
            Image("logo7S")
                .resizable()
                .scaledToFit()
                .opacity(0.1)
                .frame(width: 250, height: 250)
                .offset(x: 130, y: 10)
            
            // Conteúdo de texto e ícone centralizados
            VStack(alignment: .center, spacing: 10) {
                Text("Seu melhor desempenho ainda pode ser hoje!")
                    .font(.title3)
                    .foregroundColor(.colorPrimal)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                Text("Use o seu apple watch na quadra e seus resultados aparecerão aqui")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 25)
                
                HStack {
                    Image(systemName: "sportscourt")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                }
                .foregroundStyle(.colorPrimal)
            }
      
        }
        .frame(maxWidth: .infinity, maxHeight: 220)
        .clipShape(.rect(cornerRadius: 15))
        .clipped()

    }
}

#Preview {
    CardWithoutDayWorkout()
}
