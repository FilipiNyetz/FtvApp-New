//
//  GraphicViewModel.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
//
import Foundation
import SwiftUI
import Charts

class GraphicViewModel: ObservableObject {
    // MARK: - Propriedades de Entrada
    private let workouts: [Workout]
    private let period: String
    private let selectedMetric: String

    // MARK: - Propriedades Publicadas para a View
    @Published var dataPoints: [DataPoint] = []
    @Published var chartDomain: ClosedRange<Date> = Date()...Date()
    @Published var xAxisValues: [Date] = []
    @Published var xAxisLabelFormat: Date.FormatStyle = .dateTime.day().month()
    @Published var xAxisUnit: Calendar.Component = .day
    @Published var yAxisLabel: String = "Valor"
    @Published var barColor: Color = .red

    private let cal = Calendar.current

    init(healthManager: HealthManager, period: String, selectedMetric: String) {
        self.workouts = healthManager.workouts
        self.period = period
        self.selectedMetric = selectedMetric
        
        // Inicia o processamento dos dados
        processData()
    }

    // MARK: - Lógica Principal
    private func processData() {
        self.dataPoints = calculateDataPoints()
        self.chartDomain = calculateChartDomain()
        self.xAxisValues = calculateXAxisValues()
        self.xAxisLabelFormat = calculateXAxisLabelFormat()
        self.xAxisUnit = calculateXAxisUnit()
        self.yAxisLabel = getYAxisLabel()
        self.barColor = getBarColor()
    }

    // MARK: - Cálculos
    private func calculateDataPoints() -> [DataPoint] {
        if period == "year" || period == "sixmonth" {
            let months = monthsFor(period: period, end: Date())
            let grouped = Dictionary(grouping: workouts) { workout in
                startOfMonth(workout.dateWorkout)
            }
            return months.map { month -> DataPoint in
                let w = grouped[month] ?? []
                return DataPoint(date: month, value: aggregateValue(for: w))
            }
        }

        let groupedByDay = Dictionary(grouping: workouts) { workout in
            cal.startOfDay(for: workout.dateWorkout)
        }
        return groupedByDay
            .map { (day, w) in DataPoint(date: day, value: aggregateValue(for: w)) }
            .sorted { $0.date < $1.date }
    }

    private func calculateChartDomain() -> ClosedRange<Date> {
        let endDate = Date()
        switch period {
        case "week":
            let startDate = cal.date(byAdding: .day, value: -6, to: endDate)!
            return startDate...endDate
        case "month":
            let startDate = cal.date(byAdding: .month, value: -1, to: endDate)!
            return startDate...endDate
        case "sixmonth", "year":
            let months = monthsFor(period: period, end: endDate)
            if let first = months.first, let last = months.last {
                let endOfMonth = cal.date(byAdding: .month, value: 1, to: last)!
                return first...endOfMonth
            }
            return cal.date(byAdding: .year, value: -1, to: endDate)!...endDate
        default:
            let startDate = cal.date(byAdding: .day, value: -6, to: endDate)!
            return startDate...endDate
        }
    }

    private func calculateXAxisValues() -> [Date] {
        switch period {
        case "week":
            return (0..<7).compactMap { i in
                cal.date(byAdding: .day, value: -i, to: Date())
            }.reversed()
        case "month":
            var dates: [Date] = []
            for i in 0..<5 {
                if let date = cal.date(byAdding: .day, value: -(i * 7), to: Date()) {
                    dates.append(date)
                }
            }
            return dates.reversed()
        case "sixmonth", "year":
            // Os próprios dataPoints já servem como rótulos
            return self.dataPoints.map { $0.date }
        default:
            return []
        }
    }
    
    // MARK: - Funções de Formatação e Configuração
    private func calculateXAxisLabelFormat() -> Date.FormatStyle {
        switch period {
        case "week", "month": return .dateTime.day().month()
        case "sixmonth", "year": return .dateTime.month(.abbreviated).year(.twoDigits)
        default: return .dateTime.day().month()
        }
    }

    private func calculateXAxisUnit() -> Calendar.Component {
        switch period {
        case "week", "month": return .day
        case "sixmonth", "year": return .month
        default: return .day
        }
    }
    
    private func getYAxisLabel() -> String {
        switch selectedMetric {
        case "Batimento": return "BPM"
        case "Caloria": return "Calorias (kcal)"
        case "Distância": return "Distância (m)"
        default: return "Valor"
        }
    }
    
    private func getBarColor() -> Color {
        switch selectedMetric {
        case "Batimento": return .red
        case "Caloria": return .orange
        case "Distância": return .blue
        default: return .gray
        }
    }

    // MARK: - Helpers
    private func aggregateValue(for workouts: [Workout]) -> Double {
        switch selectedMetric {
        case "Batimento":
            let sum = workouts.reduce(0.0) { $0 + $1.frequencyHeart }
            return workouts.isEmpty ? 0 : sum / Double(workouts.count)
        case "Caloria":
            return Double(workouts.reduce(0) { $0 + $1.calories })
        case "Distância":
            return Double(workouts.reduce(0) { $0 + $1.distance })
        default:
            return 0.0
        }
    }
    
    private func startOfMonth(_ date: Date) -> Date {
        cal.date(from: cal.dateComponents([.year, .month], from: date))!
    }

    private func monthsFor(period: String, end endDate: Date) -> [Date] {
        let endMonth = startOfMonth(endDate)
        let count = (period == "sixmonth") ? 6 : 12
        return (0..<count).compactMap { i in
            cal.date(byAdding: .month, value: -(count - 1 - i), to: endMonth)
        }
    }
}
