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

            HeaderEvolution(selectedMetric: $selectedMetric)

            ScrollView {
                let periodKey = Period(selection: selectedSelection)
                let chartData = dataForChart(
                    healthManager: healthManager,
                    period: periodKey,
                    selectedMetric: selectedMetric
                )

                VStack {
                    VStack {
                        HStack {
                            Picker("Período", selection: $selectedSelection) {
                                ForEach(["D", "S", "M", "6M", "A"], id: \.self)
                                { periodo in
                                    Text(periodo).tag(periodo)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.bottom, 8)
                            Spacer()
                        }
                        .padding()

                        GraphicChart(
                            data: chartData,
                            selectedMetric: selectedMetric,
                            period: periodKey,
                            selectedWorkout: $selectedWorkout
                        )
                        .frame(height: 300)
                        .id(selectedSelection)
                        .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 0, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.progressBarBGLight,
                                        Color.progressBarBGDark,
                                        Color.progressBarBGDark,
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .opacity(0.5)
                            )
                    )
                    .padding(.bottom, -7)
                    Divider()

                    jumpdata(data: chartData, selectedMetric: selectedMetric)
                        .padding()
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gradiente2, Color.gradiente2,
                            Color.gradiente1,
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                )
                .padding(.top, -8)
                .padding(.bottom, -8)
                Divider()

                suggestions()
                    .padding()
            }
            .scrollIndicators(.hidden)
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
                            Text("Seus jogos")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(Color("ColorPrimal"))
                    }
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .background(Color.gray.opacity(0.1).ignoresSafeArea())
            .onAppear {
                healthManager.fetchAllWorkouts()
            }
        }
    }

    func selectedselection() -> String {
        switch selectedSelection {
        case "D": return "Hoje"
        case "S": return "Esta Semana"
        case "M": return "Este Mês"
        case "6M": return "Este Semestre"
        case "A": return "Este Ano"
        default: return "Este Mês"
        }
    }

    func Period(selection: String) -> String {
        switch selection {
        case "D": return "day"
        case "S": return "week"
        case "M": return "month"
        case "6M": return "sixmonth"
        case "A": return "year"
        default: return "month"
        }
    }
}

#Preview {
    EvolutionView()
        .preferredColorScheme(.dark)
}
