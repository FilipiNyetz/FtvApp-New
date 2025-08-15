//
//  EvolutionView.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//


import SwiftUI
import Charts

struct EvolutionView: View {

    // ---- Dados do gráfico (mock) ----
    struct Dado: Identifiable {
        let id = UUID()
        let dia: Int
        let valor: Double
    }

    let dados: [Dado] = [
        .init(dia: 1,  valor: 28),
        .init(dia: 4,  valor: 28),
        .init(dia: 10, valor: 26),
        .init(dia: 12, valor: 40),
        .init(dia: 19, valor: 12),
        .init(dia: 21, valor: 28),
        .init(dia: 24, valor: 14),
        .init(dia: 26, valor: 16),
        .init(dia: 30, valor: 12)
    ]

    // ---- Estado da métrica selecionada + lista de métricas ----
    @State private var selectedMetric: String = "Altura"

    private let metrics: [(name: String, icon: String)] = [
        ("Altura",          "arrow.up.and.down"),
        ("Velocidade máx",  "speedometer"),
        ("Batimento",       "heart"),
        ("Caloria",         "flame"),
        ("Passos",          "figure.walk"),
        ("Distância",       "location")
    ]

    // Ícone da métrica atual
    private var currentMetricIcon: String {
        metrics.first(where: { $0.name == selectedMetric })?.icon ?? "arrow.up.and.down"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    // ---------- Cabeçalho + seletor de métrica ----------
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Evolução")
                                .font(.title2).bold()
                            Text("Este mês")
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        // MENU CURTO: pílula com ícone, texto e chevron
                        Menu {
                            ForEach(metrics, id: \.name) { metric in
                                Button {
                                    selectedMetric = metric.name
                                } label: {
                                    Label(metric.name, systemImage: metric.icon)
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: currentMetricIcon)
                                    .font(.body)
                                Text(selectedMetric == "Velocidade máx" ? "Vel. máx" : selectedMetric)
                                    .font(.body)
                                    .lineLimit(1)
                                Spacer(minLength: 0)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .opacity(0.85)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: 160, alignment: .leading) // <<< largura controlada
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white.opacity(0.10))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                            )
                        }
                        .menuStyle(.button)
                        .menuIndicator(.hidden) // usamos nosso chevron
                    }

                    // ---------- Tabs de tempo ----------
                    HStack {
                        ForEach(["D", "S", "M", "6M", "A"], id: \.self) { periodo in
                            Text(periodo)
                                .font(.subheadline)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(periodo == "M" ? Color.white.opacity(0.2) : Color.clear)
                                .cornerRadius(8)
                        }
                        Spacer()
                    }

                    // ---------- Gráfico ----------
                    Chart {
                        ForEach(dados) { dado in
                            BarMark(
                                x: .value("Dia", dado.dia),
                                y: .value(selectedMetric, dado.valor) // título usa a métrica atual
                            )
                            .foregroundStyle(Color.white)
                        }
                    }
                    .frame(height: 200)

                    // ---------- Cards Máx / Mín ----------
                    HStack(spacing: 12) {
                        // Card Máx
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("MÁX")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("12/07/25")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("40")
                                    .font(.title3).bold()
                                Text("cm")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(height: 60)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)

                        // Card Mín
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("MÍN")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("08/02/25")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text("12")
                                    .font(.title3).bold()
                                Text("cm")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(height: 60)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                    }

                    // ---------- Sugestões ----------
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sugestões")
                                .font(.headline)
                            Text("Evolua nos jogos com as dicas certas")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }

                        SugestaoCard(
                            icone: "figure.strengthtraining.traditional",
                            titulo: "Fortalecer membros inferiores",
                            descricao: "Faça agachamento, salto na caixa e prancha isométrica. Isso fortalece pernas e core — essenciais para pular mais alto com estabilidade."
                        )

                        SugestaoCard(
                            icone: "book.fill",
                            titulo: "Técnica",
                            descricao: "Treine saltos com passada controlada e aterrissagem suave. Tente corrigir postura e alinhar braços, tronco e pernas no movimento."
                        )

                        SugestaoCard(
                            icone: "figure.run",
                            titulo: "Estratégia",
                            descricao: "Jogue mais partidas focando em prever a jogada adversária."
                        )
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(.gray.opacity(0.1))
            .foregroundColor(.white)
        }
    }
}

struct SugestaoCard: View {
    let icone: String
    let titulo: String
    let descricao: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(titulo, systemImage: icone)
                .font(.subheadline).bold()
            Text(descricao)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.gray.opacity(0.2))
        .cornerRadius(10)
    }
}

struct EvolutionView_Previews: PreviewProvider {
    static var previews: some View {
        EvolutionView()
            .preferredColorScheme(.dark)
    }
}

#Preview {
    EvolutionView()
}
