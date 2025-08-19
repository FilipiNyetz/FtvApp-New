//
//  SugestaoCard.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
//

import SwiftUI

struct SugestaoCard: View {
    let icone: String
    let titulo: String
    let descricao: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack{
                Text(titulo)
                    .foregroundColor(.white)
                
                Image(icone)
                    .foregroundColor(.colorSecond)
                
                Text(descricao)
                    .font(.footnote)
                    .foregroundColor(.white)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.gray.opacity(0.2))
            .cornerRadius(10)
        }

    }
}

struct EvolutionView_Previews: PreviewProvider {
    static var previews: some View {
        EvolutionView()
            .preferredColorScheme(.dark)
    }
}
