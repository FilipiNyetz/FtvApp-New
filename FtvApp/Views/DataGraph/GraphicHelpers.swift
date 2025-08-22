//
//  GraphicHelpers.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 21/08/25.
//

import Foundation

func dataForChart(healthManager: HealthManager, period: String, selectedMetric: String) -> [Workout] {
    switch period {
    case "sixmonth", "year":
        return aggregateByMonth(workouts: healthManager.workouts, selectedMetric: selectedMetric)
    default:
        return healthManager.workouts
    }
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
    case "Caloria": return Double(workout.calories)
    case "Distância": return Double(workout.distance)
    case "Batimento": return workout.frequencyHeart
    default: return 0
    }
}

func xLabel(for date: Date, period: String) -> String {
    let formatter = DateFormatter()
    if period == "sixmonth" || period == "year" {
        formatter.dateFormat = "MMM"
    } else {
        formatter.dateFormat = "dd/MM"
    }
    return formatter.string(from: date)
}

func updateSelection(for date: Date, in data: [Workout], selectedWorkout: inout Workout?) {
    if let found = data.min(by: {
        abs($0.dateWorkout.timeIntervalSince(date)) < abs($1.dateWorkout.timeIntervalSince(date))
    }) {
        selectedWorkout = found
    }
}

func xDomain(data: [Workout]) -> ClosedRange<Date> {
    guard let min = data.map({ $0.dateWorkout }).min(),
          let max = data.map({ $0.dateWorkout }).max() else {
        return Date()...Date()
    }
    // adiciona 1 dia de margem nas extremidades
    let calendar = Calendar.current
    let start = calendar.date(byAdding: .day, value: -1, to: min) ?? min
    let end = calendar.date(byAdding: .day, value: 1, to: max) ?? max
    return start...end
}

