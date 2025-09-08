//
//  suggestions.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
//

import SwiftUI

struct SuggestionsDynamic: View {
    let selectedMetricId: String     // "heartRate" | "calories" | "distance" | "height"
    let maxValue: Double             // valor Máx da métrica no período atual
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sugestões")
                    .font(.title3).bold()
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ForEach(cards, id: \.icone) { card in
                SugestaoCard(
                    icone: card.icone,
                    titulo: card.tituloKey,
                    descricao: Text(card.descricaoKey)
                )
            }
        }
    }
    
    // Subtítulo contextual
    var subtitle: String {
        switch selectedMetricId {
        case "heartRate": return "Ajuste a intensidade pelos seus batimentos"
        case "calories":  return "Otimize gasto calórico e recuperação"
        case "distance":  return "Gerencie volume e técnica no deslocamento"
        case "height":    return "Evolua potência e aterrissagem dos saltos"
        default:          return "Evolua com as dicas certas"
        }
    }
    
    // Regras simples por métrica — 3 cartões SEMPRE
    var cards: [Card] {
        switch selectedMetricId {
        case "heartRate":
            // Faixas exemplo: <=120 baixa, 121–149 moderada, >=150 alta
            if maxValue <= 120 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          "Invista em treinos aeróbicos leves como corridas contínuas, isso aumenta sua resistência e fortalece sua capacidade cardíaca."),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              "Aprenda a controlar sua respiração entre cada ponto, estabilizando o corpo e ajudando a reduzir batimentos acelerados."),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              "Reduza seu ritmo em jogadas menos decisivas, assim você preserva energia para momentos realmente importantes no jogo.")
                ]
            } else if maxValue < 150 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          "Faça corridas contínuas de vinte minutos em intensidade moderada, isso melhora condicionamento e mantém o coração eficiente."),
                    .init("book.fill",
                          Text("Técnicas"),
                          "Treine sincronizar respiração com seus movimentos de ataque, esse hábito ajuda a manter controle corporal durante o esforço."),
                    .init("mappin.and.ellipse",
                          Text("Estratégias"),
                          "Utilize pausas curtas entre pontos para recuperar fôlego, acelerando sua recuperação e mantendo o desempenho estável.")
                ]
            } else if maxValue < 180 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          "Trabalhe treinos curtos de alta intensidade, aumentando sua recuperação cardíaca e melhorando a resistência."),
                    .init("book.fill",
                          Text("Técnicas"),
                          "Estabeleça um ritmo de jogo constante, isso reduz oscilações desnecessárias nos seus batimentos cardíacos."),
                    .init("mappin.and.ellipse",
                          Text("Estratégias"),
                          "Use seu bom condicionamento para impor pressão constante, pois manter essa intensidade desgasta o adversário.")
                ]
            }else {
                return [
                    .init("figure",
                          Text("Físicas"),
                          ""),
                    .init("book.fill",
                          Text("Técnicas"),
                          ""),
                    .init("mappin.and.ellipse",
                          Text("Estratégias"),
                          "")
                ]
            }
            
        case "calories":
            if maxValue < 300 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          "Movimente-se mais durante os pontos, pois aumentando o gasto calórico ajuda diretamente na melhora do seu condicionamento físico."),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              "Envolva-se em todas as jogadas evitando ficar parado, garantindo participação ativa e mais energia gasta no jogo."),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              "Use movimentação constante para desgastar o adversário, esse estilo aumenta seu gasto calórico e cria vantagem estratégica.")
                ]
            } else if maxValue < 600 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          "Intensifique treinos físicos fora da quadra, pois gastar mais calorias melhora sua preparação e fortalece seu condicionamento."),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              "Trabalhe deslocamentos laterais contínuos, pois além de gastar energia isso melhora sua capacidade defensiva contra ataques."),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              "Eleve a intensidade nos pontos mais decisivos, gastando energia adicional e forçando erros importantes do adversário.")
                ]
            } else if maxValue < 800{
                return [
                    .init("figure",
                          Text("Físicas"),
                          "Varie exercícios funcionais com foco em agilidade, aumentando o gasto calórico e melhorando a eficiência dos movimentos."),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              "Participe de ataques e defesas rápidas em sequência, isso exige energia e fortalece sua resistência em quadra."),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              "Mantenha ritmo acelerado contra adversários mais lentos, isso aumenta o gasto energético e cria vantagem competitiva.")
                ]
            } else {
                return [
                    .init("figure",
                          Text("Físicas"),
                          ""),
                    .init("book.fill",
                          Text("Técnicas"),
                          ""),
                    .init("mappin.and.ellipse",
                          Text("Estratégias"),
                          "")
                ]
            }
            
        case "distance":
            if maxValue < 800 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          "Movimente-se mais durante os pontos, pois percorrer maiores distâncias ajuda no condicionamento físico e resistência em geral."),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              "Treine deslocamentos longos em quadra, isso aumenta sua recuperação e melhora a cobertura em bolas difíceis."),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              "Ajuste seu posicionamento para compensar percursos curto, ajudando a manter eficiência mesmo com menor distância.")
                ]
            } else if maxValue < 1500 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          "Acrescente corridas leves em treinos, isso acostuma seu corpo a percorrer mais distância com menor desgaste físico."),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              "Trabalhe perseguição da bola em pontos longos, esse treino aumenta alcance e melhora o deslocamento durante os jogos."),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              "Movimente-se intencionalmente para abrir espaços em quadra, essa movimentação gera confusão e dificulta leitura do adversário.")
                ]
            } else if maxValue < 2500{
                return [
                    .init("figure",
                          Text("Físicas"),
                          "Fortaleça resistência muscular com exercícios de longa duração, ajudando você a suportar bem percursos maiores na quadra."),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              "Aprimore técnica de deslocamento rápido em distâncias maiores, isso permite percorrer espaço sem perder eficiência."),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              "Use sua capacidade de percorrer grandes distâncias para cobrir o parceiro e garantir defesa mais eficaz e completa.")
                ]
            }else {
                return [
                    .init("figure",
                          Text("Físicas"),
                          ""),
                    .init("book.fill",
                          Text("Técnicas"),
                          ""),
                    .init("mappin.and.ellipse",
                          Text("Estratégias"),
                          "")
                ]
            }
            
            
            //salto Liberar quando saber se vai usar ou nao
        case "height":
            if maxValue < 0.25 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          "Agachamento e prancha 2–3×/sem criam base p/ saltar."),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              "Joelhos flexionados, tronco estável e braços coordenados."),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              "Aterre com joelhos levemente flexionados para proteger joelhos.")
                ]
            } else if maxValue < 0.40 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          "Pliometria leve: saltos na caixa 3×8 repetições."),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              "Padronize corrida de aproximação antes do salto."),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              "Evite fadiga excessiva para preservar a técnica do salto.")
                ]
            } else {
                return [
                    .init("figure",
                          Text("Físicas"),
                          "Inclua contrast training (força + pliometria) 1–2×/sem."),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              "Video-feedback para corrigir braços e timing."),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              "Mobilidade tornozelo/quadril para aterrisagens seguras.")
                ]
            }
            
        default:
            return [
                .init("figure",
                      Text("Físicas"),
                      "Use os cartões de Máx/Mín para calibrar metas do próximo treino."),
                
                    .init("book.fill",
                          Text("Técnicas"),
                          "Defina 2–3 focos por semana (força, técnica, volume)."),
                
                    .init("mappin.and.ellipse",
                          Text("Estratégias"),
                          "Compare evolução mensal e ajuste cargas.")
            ]
        }
    }
    
    struct Card {
        let icone: String
        let tituloKey: Text
        let descricaoKey: String
        init(_ icone: String, _ titulo: Text, _ descricao: String) {
            self.icone = icone; self.tituloKey = titulo; self.descricaoKey = descricao
        }
    }
}
