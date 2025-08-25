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
    
    private var dayChangeTimer: Timer?
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
    
    func startDayChangeTimer() {
        let now = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))!
        let interval = tomorrow.timeIntervalSince(now)
        
        dayChangeTimer?.invalidate()
        dayChangeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.calculateStreak()
                self?.startDayChangeTimer()
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
        let todaySOD = calendar.startOfDay(for: Date())
        let days = Set(workoutsByDay.keys.map { calendar.startOfDay(for: $0) })
        guard !days.isEmpty else {
            currentStreak = 0
            storedStreak = 0
            return
        }
        
        guard let lastDay = days.max() else {
            currentStreak = 0
            storedStreak = 0
            return
        }
        
        // Zera streak se houver gap >= 2 dias
        let gap = calendar.dateComponents([.day], from: lastDay, to: todaySOD).day ?? 0
        if gap >= 2 {
            currentStreak = 0
            storedStreak = 0
            return
        }
        
        // Conta dias consecutivos
        var streak = 0
        var cursor = lastDay
        while days.contains(cursor) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
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
