//
//  SugestaoCard.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
//

import SwiftUI

struct SugestaoCard: View {
    let icone: String
    let titulo: Text
    let descricao: Text
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Linha do título + ícone
            HStack {
                Image(systemName: icone)
                    .foregroundColor(.colorSecond)
                
                titulo
                    .foregroundColor(.white)
                    .font(.callout)
                    .fontWeight(.medium)
            }
            
            // Texto da descrição
            descricao
                .font(.subheadline)
                .foregroundColor(.white)
                .foregroundColor(.secondary)
                .fontWeight(.regular)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.progressBarBGDark, Color.progressBarBGDark, Color.progressBarBGDark,Color.progressBarBGLight]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.backgroundProgressBar,lineWidth: 0.3)
                )
        )
//        .background(.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct EvolutionView_Previews: PreviewProvider {
    static var previews: some View {
        EvolutionView()
            .preferredColorScheme(.dark)
    }
}
