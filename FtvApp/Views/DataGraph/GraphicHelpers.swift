//
// GraphicHelpers.swift
// FtvApp
//
// Created by Joao pedro Leonel on 21/08/25.
//

import Foundation

// Janela do período atual (ancorada em "hoje")
func currentRange(for period: String, now: Date = Date()) -> ClosedRange<Date> {
    let cal = Calendar.current
    switch period {
    case "day":
        let start = cal.startOfDay(for: now)
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        return start...end

    case "week":
        let start = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let end   = cal.date(byAdding: .day, value: 7, to: start)!
        return start...end

    case "month":
        let start = cal.date(from: cal.dateComponents([.year, .month], from: now))!
        let end   = cal.date(byAdding: .month, value: 1, to: start)!
        return start...end

    case "sixmonth":
        let anchor = cal.date(from: cal.dateComponents([.year, .month], from: now))!
        let start  = cal.date(byAdding: .month, value: -5, to: anchor)!
        let end    = cal.date(byAdding: .month, value: 1, to: anchor)!
        return start...end

    case "year":
        let start = cal.date(from: cal.dateComponents([.year], from: now))!
        let end   = cal.date(byAdding: .year, value: 1, to: start)!
        return start...end

    default:
        return now...now
    }
}

// Filtra treinos que caem dentro da janela
func filter(_ workouts: [Workout], in range: ClosedRange<Date>) -> [Workout] {
    workouts.filter { range.contains($0.dateWorkout) }
}

func dataForChart(healthManager: HealthManager, period: String, selectedMetric: String) -> [Workout] {
    let range = currentRange(for: period)
    let scoped = filter(healthManager.workouts, in: range)

    switch period {
    case "day":
        // Sem agregação: só treinos do dia atual
        return scoped

    case "week", "month":
        // Agrega por dia, mas somente dentro da janela
        return aggregateByDay(workouts: scoped, selectedMetric: selectedMetric)

    case "sixmonth", "year":
        // Agrega por mês, dentro da janela
        return aggregateByMonth(workouts: scoped, selectedMetric: selectedMetric)

    default:
        return scoped
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
    case "day":                formatter.dateFormat = "HH:mm"
    case "week":               formatter.dateFormat = "E"
    case "month":              formatter.dateFormat = "d"
    case "sixmonth", "year":   formatter.dateFormat = "MMM"
    default:                   formatter.dateFormat = "d/M"
    }
    return formatter.string(from: date)
}

func updateSelection(for date: Date, in data: [Workout], selectedWorkout: inout Workout?) {
    let closest = data.min { abs($0.dateWorkout.timeIntervalSince(date)) < abs($1.dateWorkout.timeIntervalSince(date)) }
    selectedWorkout = closest
}

// Domínio sempre sincronizado com a janela do período.
// Bump de +1s no fim evita clipping da última barra.
func xDomain(data: [Workout], period: String) -> ClosedRange<Date> {
    let cal = Calendar.current
    var range = currentRange(for: period)
    if let bumpedEnd = cal.date(byAdding: .second, value: 1, to: range.upperBound) {
        range = range.lowerBound...bumpedEnd
    }
    return range
}
