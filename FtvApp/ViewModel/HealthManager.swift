import Foundation
import HealthKit
import SwiftUI

class HealthManager: ObservableObject, @unchecked Sendable {
    
    let healthStore = HKHealthStore()
    
    @Published var workouts: [Workout] = []
    @Published var workoutsByDay: [Date: [Workout]] = [:]
    @Published var totalWorkoutsCount: Int = 0
    @Published var currentStreak: Int = 0
    @AppStorage("streakUser") private var storedStreak: Int = 0
    
    var weekChangeTimer: Timer?
    private let calendar = Calendar.current
    
    init() {
        self.currentStreak = storedStreak
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let typeWorkouts = HKObjectType.workoutType()
        let heartRate = HKQuantityType(.heartRate)
        let distance = HKQuantityType(.distanceWalkingRunning)
        
        let healthTypes: Set = [steps, calories, typeWorkouts, heartRate, distance]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: healthTypes, read: healthTypes)
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }
    
    
    func startWeekChangeTimer() {
        weekChangeTimer?.invalidate() // se já existir, cancela
        
        let now = Date()
        let calendar = Calendar.current
        
        // Descobre o início da próxima semana
        guard let nextWeek = calendar.nextDate(after: now, matching: DateComponents(weekday: calendar.firstWeekday), matchingPolicy: .nextTime) else {
            return
        }
        
        let interval = nextWeek.timeIntervalSince(now)
        
        weekChangeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.calculateStreak()
                self?.startWeekChangeTimer()
            }
        }
    }
    
    
    // Atualiza workouts agrupados por dia e recalcula streak
    @MainActor
    func updateWorkoutsByDay() {
        let grouped = Dictionary(grouping: workouts) { workout in
            calendar.startOfDay(for: workout.dateWorkout)
        }
        
        self.workoutsByDay = grouped
        self.totalWorkoutsCount = workouts.count
        
        calculateStreak()
    }
    
    // Calcula streak baseada em dias únicos de treino
    @MainActor
    func calculateStreak() {
        let today = Date()
        
        // Pegar apenas os dias únicos com treino
        let workoutDays = Set(workoutsByDay.keys.map { calendar.startOfDay(for: $0) })
        guard !workoutDays.isEmpty else {
            currentStreak = 0
            storedStreak = 0
            return
        }
        
        // Converter para semanas únicas (ano + semana)
        var weeks: [(year: Int, week: Int)] = []
        for day in workoutDays {
            let year = calendar.component(.yearForWeekOfYear, from: day)
            let weekOfYear = calendar.component(.weekOfYear, from: day)
            let weekKey = (year, weekOfYear)
            if !weeks.contains(where: { $0 == weekKey }) {
                weeks.append(weekKey)
            }
        }
        
        // Ordenar semanas cronologicamente
        weeks.sort {
            if $0.year == $1.year {
                return $0.week < $1.week
            }
            return $0.year < $1.year
        }
        
        // Calcular streak
        var streak = 0
        var lastWeek: (year: Int, week: Int)? = nil
        
        for week in weeks {
            if let last = lastWeek {
                if (week.year == last.year && week.week == last.week + 1) ||
                    (week.year == last.year + 1 && last.week == 52 && week.week == 1) {
                    // semana consecutiva
                    streak += 1
                } else {
                    // quebrou sequência → reinicia streak
                    streak = 1
                }
            } else {
                streak = 1
            }
            lastWeek = week
        }
        
        // ⚠️ Se já passou uma semana inteira sem treino, zera streak
        if let last = lastWeek {
            let currentYear = calendar.component(.yearForWeekOfYear, from: today)
            let currentWeek = calendar.component(.weekOfYear, from: today)
            if (currentYear == last.year && currentWeek > last.week + 1) ||
                (currentYear > last.year && !(last.week == 52 && currentWeek == 1)) {
                streak = 0
            }
        }
        
        currentStreak = streak
        storedStreak = streak
    }
    
    
    // Chama fetch de workouts do mês
    func fetchMonthWorkouts(for month: Date) {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let range = calendar.range(of: .day, in: .month, for: month)!
        let endOfMonth = calendar.date(byAdding: .day, value: range.count, to: startOfMonth)!
        
        fetchDataWorkout(endDate: endOfMonth, period: "month")
    }
    
    func fetchDataWorkout(endDate: Date, period: String) {
        // lógica de data
        let startDate: Date
        let adjustedEndDate: Date
        switch period {
        case "day":
            startDate = calendar.startOfDay(for: endDate)
            adjustedEndDate = calendar.date(byAdding: .day, value: 1, to: startDate)!.addingTimeInterval(-1)
        case "week":
            adjustedEndDate = endDate
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: adjustedEndDate)!
        case "month":
            adjustedEndDate = endDate
            startDate = calendar.date(byAdding: .month, value: -1, to: adjustedEndDate)!
        case "year":
            adjustedEndDate = endDate
            startDate = calendar.date(byAdding: .year, value: -1, to: adjustedEndDate)!
        default: return
        }
        
        DispatchQueue.main.async { self.workouts.removeAll() }
        
        let workoutType = HKObjectType.workoutType()
        let timePredicate = HKQuery.predicateForSamples(withStart: startDate, end: adjustedEndDate)
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .soccer)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timePredicate, workoutPredicate])
        
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: 50, sortDescriptors: nil) { _, samples, error in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                print("Erro ao buscar workouts: \(error?.localizedDescription ?? "desconhecido")")
                return
            }
            
            var newWorkouts: [Workout] = []
            let group = DispatchGroup()
            
            for workout in workouts {
                group.enter()
                
                self.queryFrequenciaCardiaca(workout: workout, healthStore: self.healthStore) { bpm in
                    let summary = Workout(
                        id: UUID(),
                        idWorkoutType: Int(workout.workoutActivityType.rawValue),
                        duration: workout.duration,
                        calories: Int(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0),
                        distance: Int(workout.totalDistance?.doubleValue(for: .meter()) ?? 0),
                        frequencyHeart: bpm,
                        dateWorkout: workout.endDate
                    )
                    newWorkouts.append(summary)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.workouts = newWorkouts.sorted { $0.dateWorkout < $1.dateWorkout }
                self.updateWorkoutsByDay() // só chama após todos os workouts serem carregados
            }
        }
        
        healthStore.execute(query)
    }
    
    // Placeholder para consulta de BPM
    private func queryFrequenciaCardiaca(workout: HKWorkout, healthStore: HKHealthStore, completion: @escaping (Double) -> Void) {
        // Aqui você faz sua lógica real de frequência cardíaca
        completion(0)
    }
}
