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
    @State private var selectedWorkout: Workout?

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

                Divider()

                suggestions()
                    .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(.gray.opacity(0.1))
            .foregroundColor(.white)
            .onAppear {
                healthManager.fetchDataWorkout(endDate: Date(), period: Period(selection: selectedSelection))
            }
            .onChange(of: selectedSelection) { _, newSelection in
                healthManager.fetchDataWorkout(endDate: Date(), period: Period(selection: newSelection))
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
