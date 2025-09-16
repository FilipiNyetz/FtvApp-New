
import Foundation

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

func filter(_ workouts: [Workout], in range: ClosedRange<Date>) -> [Workout] {
    workouts.filter { range.contains($0.dateWorkout) }
}

func dataForChart(manager: HealthManager, period: String, selectedMetricId: String) -> [Workout] {
    let range = currentRange(for: period)
    let scoped = filter(manager.workouts, in: range)

    switch period {
    case "day":
        return scoped 

    case "week", "month":
        if selectedMetricId == "height" {
            return scoped
        }
        return aggregateByDay(workouts: scoped, selectedMetricId: selectedMetricId)

    case "sixmonth", "year":
        if selectedMetricId == "height" {
            
            return scoped
        }
        return aggregateByMonth(workouts: scoped, selectedMetricId: selectedMetricId)

    default:
        return scoped
    }
}
func aggregateByDay(workouts: [Workout], selectedMetricId: String) -> [Workout] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: workouts) { calendar.startOfDay(for: $0.dateWorkout) }

    var result: [Workout] = []

    for (date, dayWorkouts) in grouped {
        let values = dayWorkouts.map { valueForMetric($0, selectedMetricId) }
        let avg = values.reduce(0, +) / Double(values.count)

        var calories = 0
        var distance = 0
        var frequencyHeart = 0.0
        var higherJump: Double? = nil
        var stepCount = 0

        switch selectedMetricId {
        case "calories":
            calories = Int(avg)
        case "distance":
            distance = Int(avg)
        case "heartRate":
            frequencyHeart = avg
        case "height":
            let jumps = dayWorkouts.compactMap { $0.higherJump }
            higherJump = jumps.isEmpty ? nil : jumps.max()
        case "stepCount": 
            let steps = dayWorkouts.map { $0.stepCount }
            stepCount = Int(Double(steps.reduce(0, +)) / Double(steps.count))
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
            higherJump: higherJump,
            pointsPath: [],
            stepCount: stepCount
        )

        result.append(workout)
    }

    return result.sorted { $0.dateWorkout < $1.dateWorkout }
}

func aggregateByMonth(workouts: [Workout], selectedMetricId : String) -> [Workout] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: workouts) {
        calendar.date(from: calendar.dateComponents([.year, .month], from: $0.dateWorkout)) ?? $0.dateWorkout
    }

    var result: [Workout] = []

    for (date, monthWorkouts) in grouped {
        let values = monthWorkouts.map { valueForMetric($0, selectedMetricId) }
        let avg = values.reduce(0, +) / Double(values.count)

        var calories = 0
        var distance = 0
        var frequencyHeart = 0.0
        var higherJump: Double? = nil
        var stepCount = 0

        switch selectedMetricId {
        case "calories":
            calories = Int(avg)
        case "distance":
            distance = Int(avg)
        case "heartRate":
            frequencyHeart = avg
        case "height":
            let jumps = monthWorkouts.compactMap { $0.higherJump }
            higherJump = jumps.isEmpty ? nil : jumps.max()
        case "stepCount":
            let steps = monthWorkouts.map { $0.stepCount }
            stepCount = Int(Double(steps.reduce(0, +)) / Double(steps.count))
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
            higherJump: higherJump,
            pointsPath: [],
            stepCount: stepCount
        )

        result.append(workout)
    }

    return result.sorted { $0.dateWorkout < $1.dateWorkout }
}

func valueForMetric(_ workout: Workout, _ selectedMetricId  : String) -> Double {
    switch selectedMetricId {
    case "calories": return Double(workout.calories)
    case "distance": return Double(workout.distance)
    case "heartRate": return Double(workout.frequencyHeart)
    case "height": return workout.higherJump ?? 0
    case "stepCount": return Double(workout.stepCount) 
    default: return 0
    }
}

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

func updateSelection(for date: Date, in data: [Workout], selectedWorkout: inout Workout?) {
    let closest = data.min { abs($0.dateWorkout.timeIntervalSince(date)) < abs($1.dateWorkout.timeIntervalSince(date)) }
    selectedWorkout = closest
}

func xDomain(data: [Workout], period: String) -> ClosedRange<Date> {
    let cal = Calendar.current
    var range = currentRange(for: period)
    if let bumpedEnd = cal.date(byAdding: .second, value: 1, to: range.upperBound) {
        range = range.lowerBound...bumpedEnd
    }
    return range
}
