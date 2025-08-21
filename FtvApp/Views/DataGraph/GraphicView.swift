//
//  GraphicView.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
//
import SwiftUI
import Charts

struct GraphicView: View {
    // A View agora depende do ViewModel.
    // @StateObject garante que o ViewModel viva enquanto a View estiver na tela.
    @StateObject private var viewModel: GraphicViewModel

    // O inicializador agora cria o ViewModel, passando as dependências.
    init(healthManager: HealthManager, period: String, selectedMetric: String) {
        _viewModel = StateObject(wrappedValue: GraphicViewModel(
            healthManager: healthManager,
            period: period,
            selectedMetric: selectedMetric
        ))
    }

    var body: some View {
        VStack {
            // A View verifica o estado do ViewModel para decidir o que mostrar.
            if viewModel.dataPoints.allSatisfy({ $0.value == 0 }) {
                Text("Nenhum dado de treino encontrado para o período selecionado.")
                    .frame(height: 300)
                    .foregroundColor(.secondary)
            } else {
                Chart {
                    ForEach(viewModel.dataPoints) { item in
                        if item.value > 0 {
                            BarMark(
                                x: .value("Data", item.date, unit: viewModel.xAxisUnit),
                                y: .value(viewModel.yAxisLabel, item.value),
                                width: .fixed(5)
                            )
                            .foregroundStyle(viewModel.barColor.gradient)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: viewModel.xAxisValues) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: viewModel.xAxisLabelFormat)
                    }
                }
                .chartXScale(domain: viewModel.chartDomain)
                .frame(height: 300)
                .padding()
            }
        }
    }
}
