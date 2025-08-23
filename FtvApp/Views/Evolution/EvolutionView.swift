//
//  EvolutionView.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//
import SwiftUI
import Charts


struct EvolutionView: View {
    
    @State private var selectedSelection = "M"
    @State private var selectedMetric: String = "Batimento"
    @StateObject var healthManager = HealthManager()
    
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Cabeçalho + seletor de métrica
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Evolução")
                                .font(.title)
                                .bold()
                            // aqui colocar o que ele selecionar (D,S,M,6M,A)
                            Text(selectedselection())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // pílula com ícone, texto e chevron
                        MenuView(selectedMetric: $selectedMetric)
                    }
                }
                .padding()
                
                VStack {
                    HStack {
                        Picker("Período", selection: $selectedSelection) {
                            ForEach(["D","S", "M", "6M", "A"], id: \.self) { periodo in
                                Text(periodo).tag(periodo) // mostra o valor e associa ao Picker
                            }
                        }
                        .pickerStyle(.segmented) // deixa no estilo do SegmentedControl
                        .padding(.bottom, 8)
                        Spacer()
                    }
                    // Gráfico
                    GraphicView(healthManager: healthManager, period: Period(selection: selectedSelection), selectedMetric: selectedMetric)
                            .id(selectedSelection)
                    //graphic()
                    
                    //Dados selecionados
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
                Divider()
                // Sugestões para o usuario
                suggestions()
                    .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(.gray.opacity(0.1))
            .foregroundColor(.white)
            .onAppear {
                healthManager.fetchDataWorkout(endDate: Date(), period: Period(selection: selectedSelection))
            }
            .onChange(of: selectedSelection) { oldSelection, newSelection in
                healthManager.fetchDataWorkout(endDate: Date(), period: Period(selection: newSelection))
            }
        }
    }
    func selectedselection() -> String {
        switch selectedSelection {
        case "D":
            return "Diário"
        case "S":
            return "Semanal"
        case "M":
            return "Mensal"
        case "6M":
            return "Semestral"
        case "A":
            return "Anual"
        default:
            return "mensal"
        }
    }
    
    func Period(selection: String) -> String {
        switch selection {
        case "D":
            return "day"
        case "S":
            return "week"
        case "M":
            return "month"
        case "6M":
            return "sixmonth"
        case "A":
            return "year"
        default:
            return "month"
        }
        
    }
}



#Preview {
    EvolutionView()
        .preferredColorScheme(.dark)
}
