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
    
    @State private var selectedSelection = "M"
//        let Selections = ["D", "S", "M", "6M", "A"]

    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // ---------- Cabeçalho + seletor de métrica ----------
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Evolução")
                                .font(.title)
                                .bold()
                            // aqui colocar o que ele selecionar (D,S,M,6M,A)
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
                                    .foregroundColor(.colorSecond)
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
                    // ZStack {
                    
                   
                    
                }
                .padding()
                
                VStack {
                    HStack {
                        Picker("Período", selection: $selectedSelection) {
                            ForEach(["D", "S", "M", "6M", "A"], id: \.self) { periodo in
                                Text(periodo).tag(periodo) // mostra o valor e associa ao Picker
                            }
                        }
                        .pickerStyle(.segmented) // deixa no estilo do SegmentedControl
                        .padding(.bottom, 8)
                        Spacer()
                    }
                    
                    // colocar em outra pagina depois !!!
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
                    // Dados de Salto(max/min)
                    jumpdata()
                }
                
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gradiente2,Color.gradiente2, Color.gradiente1]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                        
                    )
                )
                // }
                //Divider()
                // Sugestões para o usuario
                suggestions()
                    .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(.gray.opacity(0.1))
            .foregroundColor(.white)
        }
    }
}



#Preview {
    EvolutionView()
        .preferredColorScheme(.dark)
}
