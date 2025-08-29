//
//  suggestions.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
//

import SwiftUI

struct suggestions: View {
    var body: some View {
        // ---------- Sugestões ----------
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sugestões")
                    .font(.title3)
                    .bold()
                Text("Evolua nos jogos com as dicas certas")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            SugestaoCard(
                icone: "figure.strengthtraining.traditional",
                titulo: Text("Física"),
                descricao: Text("Faça agachamento, salto na caixa e prancha isométrica. Isso fortalece pernas e core — essenciais para pular mais alto com estabilidade.")
            )

            SugestaoCard(
                icone: "book.fill",
                titulo: Text("Técnica"),
                descricao: Text("Treine saltos com passada controlada e aterrissagem suave. Tente corrigir postura e alinhar braços, tronco e pernas no movimento.")
            )

            SugestaoCard(
                icone: "mappin.and.ellipse",
                titulo: Text("Estratégia"),
                descricao: Text("Jogue mais partidas focando em prever a jogada adversária.")
            )
        }
    }
}

#Preview {
    suggestions()
        .preferredColorScheme(.dark)
}
