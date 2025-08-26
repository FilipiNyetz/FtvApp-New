//
//  EvolutionView.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//
import SwiftUI
import Charts

struct EvolutionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedSelection = "M"
    @State private var selectedMetric: String = "Batimento"
    @StateObject var healthManager = HealthManager()
    @State private var selectedWorkout: Workout?

    var body: some View {

        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Cabeçalho + seletor de métrica
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Evolução")
                                .font(.title)
                                .bold()
                            Text(selectedselection())
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                        MenuView(selectedMetric: $selectedMetric)
                    }
                }
                .padding()

                // Dados do gráfico (filtrados/agregados p/ período + métrica)
                let periodKey = Period(selection: selectedSelection)
                let chartData = dataForChart(
                    healthManager: healthManager,
                    period: periodKey,
                    selectedMetric: selectedMetric
                )

                VStack {
                    HStack {
                        Picker("Período", selection: $selectedSelection) {
                            ForEach(["D","S","M","6M","A"], id: \.self) { periodo in
                                Text(periodo).tag(periodo)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom, 8)
                        Spacer()
                    }

                    // Gráfico
                    GraphicChart(
                        data: chartData,
                        selectedMetric: selectedMetric,
                        period: periodKey,
                        selectedWorkout: $selectedWorkout
                    )
                    .frame(height: 300) // <-- aumente aqui (250, 300, 350…)
                    .id(selectedSelection)

                    // Cards Máx / Mín conforme métrica selecionada
                    jumpdata(data: chartData, selectedMetric: selectedMetric)
                }

                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gradiente2, Color.gradiente2, Color.gradiente1]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

                suggestions()
                    .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("Seus jKKogos")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(Color("ColorPrimal"))
                    }
                }
            }
            .background(.gray.opacity(0.1))
            .foregroundColor(.white)
            // Carrega tudo ao entrar; o gráfico agrega por período em memória
            .onAppear {
                healthManager.fetchAllWorkouts()
            }
        }
    }

    func selectedselection() -> String {
        switch selectedSelection {
        case "D": return "Diário"
        case "S": return "Semanal"
        case "M": return "Mensal"
        case "6M": return "Semestral"
        case "A": return "Anual"
        default:  return "Mensal"
        }
    }

    func Period(selection: String) -> String {
        switch selection {
        case "D":  return "day"
        case "S":  return "week"
        case "M":  return "month"
        case "6M": return "sixmonth"
        case "A":  return "year"
        default:   return "month"
        }
    }
}

#Preview {
    EvolutionView()
        .preferredColorScheme(.dark)
}
