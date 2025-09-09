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
                    descricao: card.descricaoKey
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
                          Text("Invista em treinos aeróbicos leves como corridas contínuas, isso aumenta sua resistência e fortalece sua capacidade cardíaca.")),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                             Text("Aprenda a controlar sua respiração entre cada ponto, estabilizando o corpo e ajudando a reduzir batimentos acelerados.")),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              Text("Reduza seu ritmo em jogadas menos decisivas, assim você preserva energia para momentos realmente importantes no jogo."))
                ]
            } else if maxValue < 150 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          Text("Faça corridas contínuas de vinte minutos em intensidade moderada, isso melhora condicionamento e mantém o coração eficiente.")),
                    .init("book.fill",
                          Text("Técnicas"),
                         Text( "Treine sincronizar respiração com seus movimentos de ataque, esse hábito ajuda a manter controle corporal durante o esforço.")),
                    .init("mappin.and.ellipse",
                          Text("Estratégias"),
                          Text("Utilize pausas curtas entre pontos para recuperar fôlego, acelerando sua recuperação e mantendo o desempenho estável."))
                ]
            } else if maxValue < 180 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          Text("Trabalhe treinos curtos de alta intensidade, aumentando sua recuperação cardíaca e melhorando a resistência.")),
                    .init("book.fill",
                          Text("Técnicas"),
                          Text("Estabeleça um ritmo de jogo constante, isso reduz oscilações desnecessárias nos seus batimentos cardíacos.")),
                    .init("mappin.and.ellipse",
                          Text("Estratégias"),
                          Text("Use seu bom condicionamento para impor pressão constante, pois manter essa intensidade desgasta o adversário."))
                ]
            }else {
                return [
                    .init("figure",
                          Text("Físicas"),
                          Text("")),
                    .init("book.fill",
                          Text("Técnicas"),
                          Text("")),
                    .init("mappin.and.ellipse",
                          Text("Estratégias"),
                          Text(""))
                ]
            }
            
        case "calories":
            if maxValue < 300 {
                return [
                    .init("figure",
                          Text("Físicas"),
                         Text( "Movimente-se mais durante os pontos, pois aumentando o gasto calórico ajuda diretamente na melhora do seu condicionamento físico.")),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              Text("Envolva-se em todas as jogadas evitando ficar parado, garantindo participação ativa e mais energia gasta no jogo.")),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              Text("Use movimentação constante para desgastar o adversário, esse estilo aumenta seu gasto calórico e cria vantagem estratégica."))
                ]
            } else if maxValue < 600 {
                return [
                    .init("figure",
                          Text("Físicas"),
                         Text( "Intensifique treinos físicos fora da quadra, pois gastar mais calorias melhora sua preparação e fortalece seu condicionamento.")),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                             Text( "Trabalhe deslocamentos laterais contínuos, pois além de gastar energia isso melhora sua capacidade defensiva contra ataques.")),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              Text("Eleve a intensidade nos pontos mais decisivos, gastando energia adicional e forçando erros importantes do adversário."))
                ]
            } else if maxValue < 800{
                return [
                    .init("figure",
                          Text("Físicas"),
                         Text( "Varie exercícios funcionais com foco em agilidade, aumentando o gasto calórico e melhorando a eficiência dos movimentos.")),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              Text("Participe de ataques e defesas rápidas em sequência, isso exige energia e fortalece sua resistência em quadra.")),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              Text("Mantenha ritmo acelerado contra adversários mais lentos, isso aumenta o gasto energético e cria vantagem competitiva."))
                ]
            } else {
                return [
                    .init("figure",
                          Text("Físicas"),
                          Text("")),
                    .init("book.fill",
                          Text("Técnicas"),
                          Text("")),
                    .init("mappin.and.ellipse",
                          Text("Estratégias"),
                          Text(""))
                ]
            }
            
        case "distance":
            if maxValue < 800 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          Text("Movimente-se mais durante os pontos, pois percorrer maiores distâncias ajuda no condicionamento físico e resistência em geral.")),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              Text("Treine deslocamentos longos em quadra, isso aumenta sua recuperação e melhora a cobertura em bolas difíceis.")),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                             Text( "Ajuste seu posicionamento para compensar percursos curto, ajudando a manter eficiência mesmo com menor distância."))
                ]
            } else if maxValue < 1500 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          Text("Acrescente corridas leves em treinos, isso acostuma seu corpo a percorrer mais distância com menor desgaste físico.")),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              Text("Trabalhe perseguição da bola em pontos longos, esse treino aumenta alcance e melhora o deslocamento durante os jogos.")),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              Text("Movimente-se intencionalmente para abrir espaços em quadra, essa movimentação gera confusão e dificulta leitura do adversário."))
                ]
            } else if maxValue < 2500{
                return [
                    .init("figure",
                          Text("Físicas"),
                          Text("Fortaleça resistência muscular com exercícios de longa duração, ajudando você a suportar bem percursos maiores na quadra.")),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              Text("Aprimore técnica de deslocamento rápido em distâncias maiores, isso permite percorrer espaço sem perder eficiência.")),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              Text("Use sua capacidade de percorrer grandes distâncias para cobrir o parceiro e garantir defesa mais eficaz e completa."))
                ]
            }else {
                return [
                    .init("figure",
                          Text("Físicas"),
                          Text("")),
                    .init("book.fill",
                          Text("Técnicas"),
                          Text("")),
                    .init("mappin.and.ellipse",
                          Text("Estratégias"),
                          Text(""))
                ]
            }
            
            
            //salto Liberar quando saber se vai usar ou nao
        case "height":
            if maxValue < 0.25 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          Text("Agachamento e prancha 2–3×/sem criam base p/ saltar.")),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              Text("Joelhos flexionados, tronco estável e braços coordenados.")),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              Text("Aterre com joelhos levemente flexionados para proteger joelhos."))
                ]
            } else if maxValue < 0.40 {
                return [
                    .init("figure",
                          Text("Físicas"),
                          Text("Pliometria leve: saltos na caixa 3×8 repetições.")),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              Text("Padronize corrida de aproximação antes do salto.")),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              Text("Evite fadiga excessiva para preservar a técnica do salto."))
                ]
            } else {
                return [
                    .init("figure",
                          Text("Físicas"),
                          Text("Inclua contrast training (força + pliometria) 1–2×/sem.")),
                    
                        .init("book.fill",
                              Text("Técnicas"),
                              Text("Video-feedback para corrigir braços e timing.")),
                    
                        .init("mappin.and.ellipse",
                              Text("Estratégias"),
                              Text("Mobilidade tornozelo/quadril para aterrisagens seguras."))
                ]
            }
            
        default:
            return [
                .init("figure",
                      Text("Físicas"),
                      Text("Use os cartões de Máx/Mín para calibrar metas do próximo treino.")),
                
                    .init("book.fill",
                          Text("Técnicas"),
                         Text("Defina 2–3 focos por semana (força, técnica, volume).")),
                
                    .init("mappin.and.ellipse",
                          Text("Estratégias"),
                          Text("Compare evolução mensal e ajuste cargas."))
            ]
        }
    }
    
    struct Card {
        let icone: String
        let tituloKey: Text
        let descricaoKey: Text
        init(_ icone: String, _ titulo: Text, _ descricao: Text) {
            self.icone = icone; self.tituloKey = titulo; self.descricaoKey = descricao
        }
    }
}
