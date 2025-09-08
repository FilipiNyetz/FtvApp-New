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
    @ObservedObject var wcSessionDelegate: PhoneWCSessionDelegate
    @State private var selectedSelection = "M"
    @State private var selectedMetricId: String = "heartRate"
    @ObservedObject var manager: HealthManager
    @State private var selectedWorkout: Workout?
    
    
    var body: some View {
        
        NavigationStack {
            HeaderEvolution(selectedMetricId: $selectedMetricId)
            
            ScrollView {
                // Dados do gráfico (filtrados/agregados p/ período + métrica)
                let periodKey = Period(selection: selectedSelection)
                let chartData = dataForChart(
                    manager: manager,
                    period: periodKey,
                    selectedMetricId: selectedMetricId
                )
                
                VStack {
                    VStack{
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
                        .padding()
                        
                        // Gráfico
                        GraphicChart(
                            data: chartData,
                            selectedMetric: selectedMetricId,
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
                                    colors: [Color.progressBarBGLight, Color.progressBarBGDark,Color.progressBarBGDark],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                                .opacity(0.5)
                            )
                    )
                    .padding(.bottom, -7)
                    Divider()
                    //.padding(.horizontal)
                    
                    // Cards Máx / Mín conforme métrica selecionada
                    jumpdata(data: chartData, selectedMetric: selectedMetricId)
                        .padding()
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gradiente2, Color.gradiente2, Color.gradiente1]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                )
                .padding(.top, -8)
                .padding(.bottom, -8)
                Divider()
                
                SuggestionsDynamic(
                    selectedMetricId: selectedMetricId,
                    maxValue: maxValueForMetric
                )
                .padding(.horizontal)
                .padding(.bottom, 24)
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
            //   .toolbarBackground(.visible, for: .navigationBar)
            .background(Color.gray.opacity(0.1).ignoresSafeArea())
            
            // Carrega tudo ao entrar; o gráfico agrega por período em memória
//            .onAppear {
//                manager.fetchAllWorkouts()
//            }
        }
    }
    
    func selectedselection() -> String {
        switch selectedSelection {
        case "D": return "Hoje"
        case "S": return "Esta Semana"
        case "M": return "Este Mês"
        case "6M": return "Este Semestre"
        case "A": return "Este Ano"
        default:  return "Este Mês"
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
    /// Máximo da métrica selecionada (usado pelas Sugestões)
    private var maxValueForMetric: Double {
        switch selectedMetricId {
        case "heartRate":
            return Double(manager.workouts.map(\.frequencyHeart).max() ?? 0)
        case "calories":
            return Double(manager.workouts.map(\.calories).max() ?? 0)
        case "distance":
            return Double(manager.workouts.map(\.distance).max() ?? 0)
        case "height":
            return 0 // se adicionar altura no modelo, troque por Double(workout.height ?? 0)
        default:
            return 0
        }
    }
}


