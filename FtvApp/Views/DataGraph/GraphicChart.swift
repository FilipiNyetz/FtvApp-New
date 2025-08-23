//
// GraphicChart.swift
// FtvApp
//
// Created by Joao pedro Leonel on 21/08/25.
//

import SwiftUI
import Charts

struct GraphicChart: View {
    var data: [Workout]
    var selectedMetric: String
    var period: String
    @Binding var selectedWorkout: Workout?

    var body: some View {
        Chart {
            // Barras do gráfico
            ForEach(data, id: \.id) { workout in
                BarMark(
                    x: .value("Data", workout.dateWorkout),
                    y: .value(selectedMetric, valueForMetric(workout, selectedMetric))
                )
                .foregroundStyle(Color.colorPrimal.gradient)
                .position(by: .value("Tipo", selectedMetric))
                .opacity(selectedWorkout?.id == workout.id ? 1 : 0.7)
            }

            // Ponto e linha de seleção
            if let workout = selectedWorkout {
                PointMark(
                    x: .value("Data", workout.dateWorkout),
                    y: .value(selectedMetric, valueForMetric(workout, selectedMetric))
                )
                .symbolSize(100)
                .foregroundStyle(.white)

                RuleMark(x: .value("Data", workout.dateWorkout))
                    .foregroundStyle(.white)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    .annotation(position: .top) {
                        VStack(spacing: 4) {
                            Text(xLabel(for: workout.dateWorkout, period: period))
                                .font(.caption2)
                            Text("\(valueForMetric(workout, selectedMetric), specifier: "%.0f")")
                                .font(.caption)
                                .bold()
                        }
                        .padding(6)
                        .background(.black.opacity(0.6))
                        .cornerRadius(6)
                    }
            }
        }
        // Escala X ajustada pelo período
        .chartXScale(domain: xDomain(data: data, period: period), range: .plotDimension(padding: 8))
        // Eixo X com ticks automáticos por período
        .chartXAxis {
            switch period {
            case "day":
                AxisMarks(values: .stride(by: .hour, count: 2)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.hour().minute())
                }
            case "week":
                AxisMarks(values: .stride(by: .day, count: 1)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            case "month":
                AxisMarks(values: .stride(by: .day, count: 2)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day())
                }
            case "sixmonth", "year":
                AxisMarks(values: .stride(by: .month, count: 1)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            default:
                AxisMarks()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        // Interação com drag para selecionar barra
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if let date: Date = proxy.value(atX: value.location.x) {
                                    updateSelection(for: date, in: data, selectedWorkout: &selectedWorkout)
                                }
                            }
                            .onEnded { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    selectedWorkout = nil
                                }
                            }
                    )
            }
        }
    }
}
