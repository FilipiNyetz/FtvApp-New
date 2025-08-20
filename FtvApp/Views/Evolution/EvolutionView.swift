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
                        MenuView()
                    }
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
                    // Gráfico
                    graphic()
                    
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
}



#Preview {
    EvolutionView()
        .preferredColorScheme(.dark)
}
