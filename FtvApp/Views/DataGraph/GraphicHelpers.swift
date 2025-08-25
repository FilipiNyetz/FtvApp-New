//
// GraphicHelpers.swift
// FtvApp
//
// Created by Joao pedro Leonel on 21/08/25.
//

import Foundation

func dataForChart(healthManager: HealthManager, period: String, selectedMetric: String) -> [Workout] {
    let calendar = Calendar.current
    switch period {
    case "day":
        // Apenas treinos do dia atual (sem agregação)
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return healthManager.workouts.filter { $0.dateWorkout >= start && $0.dateWorkout < end }

    case "week", "month":
        // Uma média por dia (caso haja mais de um treino no mesmo dia)
        return aggregateByDay(workouts: healthManager.workouts, selectedMetric: selectedMetric)

    case "sixmonth", "year":
        // Uma média por mês
        return aggregateByMonth(workouts: healthManager.workouts, selectedMetric: selectedMetric)

    default:
        return healthManager.workouts
    }
}

func aggregateByDay(workouts: [Workout], selectedMetric: String) -> [Workout] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: workouts) {
        calendar.startOfDay(for: $0.dateWorkout)
    }
    return grouped.map { (date, workouts) in
        let avg = workouts.map { valueForMetric($0, selectedMetric) }.reduce(0, +) / Double(workouts.count)
        return Workout(
            id: UUID(),
            idWorkoutType: 0,
            duration: 0,
            calories: selectedMetric == "Caloria" ? Int(avg) : 0,
            distance: selectedMetric == "Distância" ? Int(avg) : 0,
            frequencyHeart: selectedMetric == "Batimento" ? avg : 0,
            dateWorkout: date
        )
    }
    .sorted { $0.dateWorkout < $1.dateWorkout }
}

func aggregateByMonth(workouts: [Workout], selectedMetric: String) -> [Workout] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: workouts) {
        calendar.date(from: calendar.dateComponents([.year, .month], from: $0.dateWorkout)) ?? $0.dateWorkout
    }
    return grouped.map { (date, workouts) in
        let avg = workouts.map { valueForMetric($0, selectedMetric) }.reduce(0, +) / Double(workouts.count)
        return Workout(
            id: UUID(),
            idWorkoutType: 0,
            duration: 0,
            calories: selectedMetric == "Caloria" ? Int(avg) : 0,
            distance: selectedMetric == "Distância" ? Int(avg) : 0,
            frequencyHeart: selectedMetric == "Batimento" ? avg : 0,
            dateWorkout: date
        )
    }
    .sorted { $0.dateWorkout < $1.dateWorkout }
}

func valueForMetric(_ workout: Workout, _ selectedMetric: String) -> Double {
    switch selectedMetric {
    case "Caloria":   return Double(workout.calories)
    case "Distância": return Double(workout.distance)
    case "Batimento": return Double(workout.frequencyHeart)
    default:          return 0
    }
}

func xLabel(for date: Date, period: String) -> String {
    let formatter = DateFormatter()
    switch period {
    case "day":
        formatter.dateFormat = "HH:mm"
    case "week":
        formatter.dateFormat = "E"
    case "month":
        formatter.dateFormat = "d"
    case "sixmonth", "year":
        formatter.dateFormat = "MMM"
    default:
        formatter.dateFormat = "d/M"
    }
    return formatter.string(from: date)
}

func updateSelection(for date: Date, in data: [Workout], selectedWorkout: inout Workout?) {
    let closest = data.min { abs($0.dateWorkout.timeIntervalSince(date)) < abs($1.dateWorkout.timeIntervalSince(date)) }
    selectedWorkout = closest
}

func xDomain(data: [Workout], period: String) -> ClosedRange<Date> {
    let calendar = Calendar.current

    // Quando não há dados, ainda assim mostramos um domínio "cheio" para o período selecionado
    if data.isEmpty {
        let now = Date()
        switch period {
        case "day":
            let start = calendar.startOfDay(for: now)
            let end   = calendar.date(byAdding: .day, value: 1, to: start) ?? now
            return start...end
        case "week":
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
            let endOfWeek   = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? now
            return startOfWeek...endOfWeek
        case "month":
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let endOfMonth   = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? now
            return startOfMonth...endOfMonth
        case "sixmonth":
            let anchorMonth  = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let start6       = calendar.date(byAdding: .month, value: -5, to: anchorMonth) ?? now
            let end6         = calendar.date(byAdding: .month, value: 1, to: anchorMonth) ?? now
            return start6...end6
        case "year":
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now)) ?? now
            let endOfYear   = calendar.date(byAdding: .year, value: 1, to: startOfYear) ?? now
            return startOfYear...endOfYear
        default:
            return now...now
        }
    }

    // Com dados: usa min/max e normaliza para o período
    guard let min = data.map({ $0.dateWorkout }).min(),
          let max = data.map({ $0.dateWorkout }).max() else {
        let today = Date()
        return today...today
    }

    switch period {
    case "day":
        let start = calendar.startOfDay(for: min)
        let end   = calendar.date(byAdding: .day, value: 1, to: start) ?? max
        return start...end
    case "week":
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: min)) ?? min
        let endOfWeek   = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? max
        return startOfWeek...endOfWeek
    case "month":
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: min)) ?? min
        let endOfMonth   = calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? max
        return startOfMonth...endOfMonth
    case "sixmonth":
        let anchorMonth  = calendar.date(from: calendar.dateComponents([.year, .month], from: max)) ?? max
        let start6       = calendar.date(byAdding: .month, value: -5, to: anchorMonth) ?? min
        let end6         = calendar.date(byAdding: .month, value: 1, to: anchorMonth) ?? max
        return start6...end6
    case "year":
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: min)) ?? min
        let endOfYear   = calendar.date(byAdding: .year, value: 1, to: startOfYear) ?? max
        return startOfYear...endOfYear
    default:
        return min...max
    }
}
