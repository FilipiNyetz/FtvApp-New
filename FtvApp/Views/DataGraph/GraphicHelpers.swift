//
// GraphicHelpers.swift
// FtvApp
//
// Created by Joao pedro Leonel on 21/08/25.
// Atualizado por Filipi Romao
//

import Foundation

// MARK: - Janela do período atual (ancorada em "hoje")
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

// MARK: - Filtra treinos que caem dentro da janela
func filter(_ workouts: [Workout], in range: ClosedRange<Date>) -> [Workout] {
    workouts.filter { range.contains($0.dateWorkout) }
}

// MARK: - Dados para gráfico
func dataForChart(manager: HealthManager, period: String, selectedMetric: String) -> [Workout] {
    let range = currentRange(for: period)
    let scoped = filter(manager.workouts, in: range)

    switch period {
    case "day":
        return scoped // sem criar novos workouts

    case "week", "month":
        // Se não quiser calcular média de altura, apenas use os workouts existentes
        if selectedMetric == "Altura" {
            return scoped
        }
        return aggregateByDay(workouts: scoped, selectedMetric: selectedMetric)

    case "sixmonth", "year":
        if selectedMetric == "Altura" {
            
            return scoped
        }
        return aggregateByMonth(workouts: scoped, selectedMetric: selectedMetric)

    default:
        return scoped
    }
}


// MARK: - Agregação diária
func aggregateByDay(workouts: [Workout], selectedMetric: String) -> [Workout] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: workouts) { calendar.startOfDay(for: $0.dateWorkout) }

    var result: [Workout] = []

    for (date, dayWorkouts) in grouped {
        // Calcula a métrica
        let values = dayWorkouts.map { valueForMetric($0, selectedMetric) }
        let avg = values.reduce(0, +) / Double(values.count)

        // Campos agregados
        var calories = 0
        var distance = 0
        var frequencyHeart = 0.0
        var higherJump: Double? = nil

        switch selectedMetric {
        case "Caloria":
            calories = Int(avg)
        case "Distância":
            distance = Int(avg)
        case "Batimento":
            frequencyHeart = avg
        case "Altura":
            let jumps = dayWorkouts.compactMap { $0.higherJump }
            higherJump = jumps.isEmpty ? nil : jumps.max()
        default:
            break
        }

        let workout = Workout(
            id: UUID(),
            idWorkoutType: 0,
            duration: 0,
            calories: calories,
            distance: distance,
            frequencyHeart: frequencyHeart,
            dateWorkout: date,
            higherJump: higherJump
        )

        result.append(workout)
    }

    return result.sorted { $0.dateWorkout < $1.dateWorkout }
}

// MARK: - Agregação mensal
func aggregateByMonth(workouts: [Workout], selectedMetric: String) -> [Workout] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: workouts) {
        calendar.date(from: calendar.dateComponents([.year, .month], from: $0.dateWorkout)) ?? $0.dateWorkout
    }

    var result: [Workout] = []

    for (date, monthWorkouts) in grouped {
        let values = monthWorkouts.map { valueForMetric($0, selectedMetric) }
        let avg = values.reduce(0, +) / Double(values.count)

        var calories = 0
        var distance = 0
        var frequencyHeart = 0.0
        var higherJump: Double? = nil

        switch selectedMetric {
        case "Caloria":
            calories = Int(avg)
        case "Distância":
            distance = Int(avg)
        case "Batimento":
            frequencyHeart = avg
        case "Altura":
            let jumps = monthWorkouts.compactMap { $0.higherJump }
            higherJump = jumps.isEmpty ? nil : jumps.max()
        default:
            break
        }

        let workout = Workout(
            id: UUID(),
            idWorkoutType: 0,
            duration: 0,
            calories: calories,
            distance: distance,
            frequencyHeart: frequencyHeart,
            dateWorkout: date,
            higherJump: higherJump
        )

        result.append(workout)
    }

    return result.sorted { $0.dateWorkout < $1.dateWorkout }
}

// MARK: - Valor de métrica
func valueForMetric(_ workout: Workout, _ selectedMetric: String) -> Double {
    switch selectedMetric {
    case "Caloria": return Double(workout.calories)
    case "Distância": return Double(workout.distance)
    case "Batimento": return Double(workout.frequencyHeart)
    case "Altura": return workout.higherJump ?? 0
    default: return 0
    }
}

// MARK: - Labels eixo X em pt-BR
func localizedXAxisLabel(for date: Date, period: String) -> String {
    let loc = Locale(identifier: "pt_BR")
    let df = DateFormatter()
    df.locale = loc
    df.calendar = Calendar(identifier: .gregorian)

    switch period {
    case "day":
        df.dateFormat = "HH:mm"
        return df.string(from: date)
    case "week":
        let idx = Calendar.current.component(.weekday, from: date) - 1
        let sym = df.shortWeekdaySymbols[idx]
        return String(sym.replacingOccurrences(of: ".", with: "").prefix(3))
    case "month":
        df.dateFormat = "d"
        return df.string(from: date)
    case "sixmonth", "year":
        let idx = Calendar.current.component(.month, from: date) - 1
        let sym = df.shortMonthSymbols[idx]
        return String(sym.replacingOccurrences(of: ".", with: "").prefix(3))
    default:
        df.dateFormat = "d/M"
        return df.string(from: date)
    }
}

func xLabelPtBR(for date: Date, period: String) -> String {
    localizedXAxisLabel(for: date, period: period)
}

// MARK: - Seleção do treino mais próximo
func updateSelection(for date: Date, in data: [Workout], selectedWorkout: inout Workout?) {
    let closest = data.min { abs($0.dateWorkout.timeIntervalSince(date)) < abs($1.dateWorkout.timeIntervalSince(date)) }
    selectedWorkout = closest
}

// MARK: - Domínio do eixo X
func xDomain(data: [Workout], period: String) -> ClosedRange<Date> {
    let cal = Calendar.current
    var range = currentRange(for: period)
    if let bumpedEnd = cal.date(byAdding: .second, value: 1, to: range.upperBound) {
        range = range.lowerBound...bumpedEnd
    }
    return range
}
