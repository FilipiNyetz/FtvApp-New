//
//  graphic.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
import SwiftUI
import Charts

struct graphic: View {
    @ObservedObject var healthManager : HealthManager
    var period: String
    var selectedMetric: String
    
    func xAxisLabelFormat() -> Date.FormatStyle {
            switch period {
            case "week", "month":
                return .dateTime.day().month()
            case "sixmonth", "year":
                return .dateTime.month().year()
            default:
                return .dateTime.day().month()
            }
        }
    
    var xAxisUnit: Calendar.Component {
        switch period {
        case "week", "month":
            return .day
        case "sixmonth", "year":
            return .month
        default:
            return .day
        }
    }

    
    var body: some View {
        VStack {
            if healthManager.workouts.isEmpty {
                Text("Nenhum dado de treino encontrado para o período selecionado.")
                    .frame(height: 300)
                    .foregroundColor(.secondary)
            } else {
                Chart {
                    ForEach(healthManager.workouts) { workout in
                        switch selectedMetric {
                        case "Batimento":
                            BarMark(
                                x: .value("Data", workout.dateWorkout, unit: xAxisUnit),
                                y: .value("BPM", workout.frequencyHeart)
                            )
                            .foregroundStyle(.red.gradient)
                            .position(by: .value("Treino", workout.id.uuidString))

                        case "Caloria":
                            BarMark(
                                x: .value("Data", workout.dateWorkout, unit: xAxisUnit),
                                y: .value("Calorias (kcal)", workout.calories)
                            )
                            .foregroundStyle(.orange.gradient)
                            .position(by: .value("Treino", workout.id.uuidString))

                        case "Distância":
                            BarMark(
                                x: .value("Data", workout.dateWorkout, unit: xAxisUnit),
                                y: .value("Distância (m)", workout.distance)
                            )
                            .foregroundStyle(.blue.gradient)
                            .position(by: .value("Treino", workout.id.uuidString))
                            
                        default:
                            BarMark(
                                x: .value("Data", workout.dateWorkout, unit: xAxisUnit),
                                y: .value("BPM", workout.frequencyHeart)
                            )
                            .foregroundStyle(.red.gradient)
                            .position(by: .value("Treino", workout.id.uuidString))
                        }
                    }
                }
                .chartXAxis { // é um modificador para customizar a aparencia do eixo x no grafico
                    AxisMarks(values: .automatic) { value in // define marcadores
                        AxisGridLine() // desenha linhas de grade vertical no grafico
                        AxisTick()// desenha pequenos traços no eixo
                        if let _ = value.as(Date.self) {
                            AxisValueLabel(format: xAxisLabelFormat()) //define o formato do texto para cada marcador como dia/mes/ano
                        }
                    }
                }
                .frame(height: 300)
                .padding()
            }
        }
    }
}

