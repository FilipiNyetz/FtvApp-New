//
//  HealthManager.swift
//  BeActiv
//
//  Created by Filipi Romão on 25/08/25.
//

import Foundation
import HealthKit
import SwiftUI


class HealthManager: ObservableObject, @unchecked Sendable {
    
    let healthStore = HKHealthStore()
    
    // Todos os treinos históricos
    @Published var workouts: [Workout] = []
    // Treinos agrupados por dia (baseado nos workouts filtrados)
    @Published var workoutsByDay: [Date: [Workout]] = [:]
    // Total de treinos (baseado nos workouts filtrados)
    @Published var totalWorkoutsCount: Int = 0
    // Streak atual
    @Published var currentStreak: Int = 0
    
    @AppStorage("streakUser") private var storedStreak: Int = 0
    
    var weekChangeTimer: Timer?
    private let calendar = Calendar.current
    var newWorkouts: [Workout] = []
    
    // MARK: - Init
    init() {
        self.currentStreak = storedStreak
        requestAuthorization()
    }
    
    // MARK: - Authorization
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
    
    // MARK: - Timer para reset semanal
    func startWeekChangeTimer() {
        weekChangeTimer?.invalidate()
        
        let now = Date()
        let calendar = Calendar.current
        
        guard let nextWeek = calendar.nextDate(
            after: now,
            matching: DateComponents(weekday: calendar.firstWeekday),
            matchingPolicy: .nextTime
        ) else { return }
        
        let interval = nextWeek.timeIntervalSince(now)
        
        weekChangeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.calculateStreak(from: self?.workouts ?? [])
                self?.startWeekChangeTimer()
            }
        }
    }
    
    // MARK: - Atualiza workouts agrupados
    @MainActor
    func updateWorkoutsByDay(filtered: [Workout]) {
        let grouped = Dictionary(grouping: filtered) { workout in
            calendar.startOfDay(for: workout.dateWorkout)
        }
        
        self.workoutsByDay = grouped
        self.totalWorkoutsCount = filtered.count
        
        calculateStreak(from: filtered)
    }
    
    // MARK: - Streak semanal
    @MainActor
    private func calculateStreak(from workouts: [Workout]) {
        let today = Date()
        
        let workoutDays = Set(workouts.map { calendar.startOfDay(for: $0.dateWorkout) })
        guard !workoutDays.isEmpty else {
            currentStreak = 0
            storedStreak = 0
            return
        }
        
        // converte para semanas
        var weeks: [(year: Int, week: Int)] = []
        for day in workoutDays {
            let year = calendar.component(.yearForWeekOfYear, from: day)
            let weekOfYear = calendar.component(.weekOfYear, from: day)
            let weekKey = (year, weekOfYear)
            if !weeks.contains(where: { $0 == weekKey }) {
                weeks.append(weekKey)
            }
        }
        
        weeks.sort {
            if $0.year == $1.year { return $0.week < $1.week }
            return $0.year < $1.year
        }
        
        // streak
        var streak = 0
        var lastWeek: (year: Int, week: Int)? = nil
        
        for week in weeks {
            if let last = lastWeek {
                if (week.year == last.year && week.week == last.week + 1) ||
                    (week.year == last.year + 1 && last.week == 52 && week.week == 1) {
                    streak += 1
                } else {
                    streak = 1
                }
            } else {
                streak = 1
            }
            lastWeek = week
        }
        
        // se passou uma semana sem treino → zera
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
    
    // MARK: - Fetch histórico completo
    func fetchAllWorkouts(until endDate: Date = Date()) {
        
        // Limpa arrays antes da busca
        DispatchQueue.main.async {
            self.workouts.removeAll()
            self.newWorkouts.removeAll()
            self.totalWorkoutsCount = 0
        }
        
        let workoutType = HKObjectType.workoutType()
        let timePredicate = HKQuery.predicateForSamples(withStart: .distantPast, end: endDate)
        
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .soccer)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timePredicate, workoutPredicate])
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                print("Erro ao buscar workouts: \(error?.localizedDescription ?? "desconhecido")")
                return
            }
            
            if workouts.isEmpty {
                print("Nenhum treino encontrado")
            }
            
            let group = DispatchGroup()
            var tempWorkouts: [Workout] = []
            let tempQueue = DispatchQueue(label: "tempWorkoutsQueue") // fila serial para evitar race conditions
            
            for workout in workouts {
                group.enter()
                
                queryFrequenciaCardiaca(workout: workout, healthStore: self.healthStore) { bpm in
                    let summary = Workout(
                        id: workout.uuid, // UUID do HealthKit garante unicidade
                        idWorkoutType: Int(workout.workoutActivityType.rawValue),
                        duration: workout.duration,
                        calories: Int(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0),
                        distance: Int(workout.totalDistance?.doubleValue(for: .meter()) ?? 0),
                        frequencyHeart: bpm,
                        dateWorkout: workout.endDate
                    )
                    
                    tempQueue.async {
                        tempWorkouts.append(summary)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                // Remove duplicados pelo mesmo id (HealthKit UUID)
                let uniqueWorkouts = Array(Dictionary(grouping: tempWorkouts, by: { $0.id }).values.map { $0.first! })
                
                self.newWorkouts = uniqueWorkouts.sorted { $0.dateWorkout < $1.dateWorkout }
                self.workouts = self.newWorkouts
                self.totalWorkoutsCount = self.workouts.count
                
                self.updateWorkoutsByDay(filtered: self.workouts)
                
            }
        }
        
        healthStore.execute(query)
    }
    
    
    
    
    // MARK: - Fetch por período (mantida!)
    func fetchDataWorkout(endDate: Date, period: String) {
        
        DispatchQueue.main.async {
            self.workouts.removeAll()
            self.newWorkouts.removeAll()
            self.totalWorkoutsCount = 0
        }
        
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
        case "sixmonth":
            adjustedEndDate = endDate
            startDate = calendar.date(byAdding: .month, value: -6, to: adjustedEndDate)!
        case "year":
            adjustedEndDate = endDate
            startDate = calendar.date(byAdding: .year, value: -1, to: adjustedEndDate)!
        default:
            return
        }
        
        let workoutType = HKObjectType.workoutType()
        let timePredicate = HKQuery.predicateForSamples(withStart: startDate, end: adjustedEndDate)
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .soccer)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [timePredicate, workoutPredicate])
        
        let query = HKSampleQuery(sampleType: workoutType,
                                  predicate: predicate,
                                  limit: HKObjectQueryNoLimit,
                                  sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)]
                                  ) { _, samples, error in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                print("Erro ao buscar workouts: \(error?.localizedDescription ?? "desconhecido")")
                return
            }
            
            let group = DispatchGroup()
            
            for workout in workouts {
                group.enter()
                
                queryFrequenciaCardiaca(workout: workout, healthStore: self.healthStore) { bpm in
                    let summary = Workout(
                        id: UUID(),
                        idWorkoutType: Int(workout.workoutActivityType.rawValue),
                        duration: workout.duration,
                        calories: Int(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0),
                        distance: Int(workout.totalDistance?.doubleValue(for: .meter()) ?? 0),
                        frequencyHeart: bpm,
                        dateWorkout: workout.endDate
                    )
                    self.newWorkouts.append(summary)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.workouts = self.newWorkouts.sorted { $0.dateWorkout < $1.dateWorkout }
                self.totalWorkoutsCount = self.workouts.count // ⚡ atualiza o total corretamente
                self.updateWorkoutsByDay(filtered: self.workouts)
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Filtro em memória
    func filterWorkouts(period: String, referenceDate: Date = Date()) {
        let startDate: Date
        let endDate: Date
        
        switch period {
        case "day":
            startDate = calendar.startOfDay(for: referenceDate)
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        case "week":
            endDate = referenceDate
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: endDate)!
        case "month":
            endDate = referenceDate
            startDate = calendar.date(byAdding: .month, value: -1, to: endDate)!
        case "year":
            endDate = referenceDate
            startDate = calendar.date(byAdding: .year, value: -1, to: endDate)!
        default:
            startDate = .distantPast
            endDate = Date()
        }
        
        let filtered = workouts.filter {
            $0.dateWorkout >= startDate && $0.dateWorkout < endDate
        }
        
        Task { @MainActor in
            self.updateWorkoutsByDay(filtered: filtered)
        }
    }
}
