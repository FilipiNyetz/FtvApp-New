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
    
    var wcSessionDelegate: PhoneWCSessionDelegate?
    
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
    var workoutAnchor: HKQueryAnchor?
    
    // MARK: - Init
    init() {
        self.currentStreak = storedStreak
        requestAuthorization()
        startObservingWorkouts()
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
    @MainActor
    func fetchAllWorkouts(until endDate: Date = Date()) {
        self.workouts.removeAll()
        self.newWorkouts.removeAll()
        self.totalWorkoutsCount = 0
        
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
                return
            }
            
            let group = DispatchGroup()
            var tempWorkouts: [Workout] = []
            
            for workout in workouts {
                group.enter()
                
                queryFrequenciaCardiaca(workout: workout, healthStore: self.healthStore) { bpm in
                    let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
                    var calories = 0.0
                    if let totalEnergy = workout.statistics(for: energyType)?.sumQuantity() {
                        calories = totalEnergy.doubleValue(for: .kilocalorie())
                    }
                    
                    Task { @MainActor in
                        // Monta Workout básico primeiro (sem dados extras)
                        let summary = Workout(
                            id: workout.uuid,
                            idWorkoutType: Int(workout.workoutActivityType.rawValue),
                            duration: workout.duration,
                            calories: Int(calories),
                            distance: Int(workout.totalDistance?.doubleValue(for: .meter()) ?? 0),
                            frequencyHeart: bpm,
                            dateWorkout: workout.endDate,
                            higherJump: 0.0,  // Será preenchido no merge posterior
                            pointsPath: []    // Será preenchido no merge posterior
                        )
                        
                        tempWorkouts.append(summary)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                Task { @MainActor in
                    let uniqueWorkouts = Array(Dictionary(grouping: tempWorkouts, by: { $0.id }).values.map { $0.first! })
                    
                    // 🔹 Fazer merge com dados extras do SwiftData
                    let enrichedWorkouts = await self.enrichWorkoutsWithExtras(uniqueWorkouts)
                    
                    self.newWorkouts = enrichedWorkouts.sorted { $0.dateWorkout < $1.dateWorkout }
                    self.workouts = self.newWorkouts
                    self.totalWorkoutsCount = self.workouts.count
                    self.updateWorkoutsByDay(filtered: self.workouts)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Enrichment com dados extras
    /// Enriquece workouts básicos com dados extras (higherJump e pointPath) do SwiftData
    /// Executa uma única query para buscar todos os extras necessários
    @MainActor
    private func enrichWorkoutsWithExtras(_ workouts: [Workout]) async -> [Workout] {
        guard let wcSessionDelegate = wcSessionDelegate else {
            print("⚠️ wcSessionDelegate não disponível")
            return workouts
        }
        
        let workoutIDs = workouts.map { $0.id.uuidString }
        
        do {
            let extrasRepository = wcSessionDelegate.getExtrasRepository()
            let extrasMap = try await extrasRepository.fetchExtrasMap(for: workoutIDs)
            
            print("📦 Fazendo merge de \(workouts.count) workouts com \(extrasMap.count) extras")
            
            return workouts.map { workout in
                let workoutIDString = workout.id.uuidString
                if let extras = extrasMap[workoutIDString] {
                    return Workout(
                        id: workout.id,
                        idWorkoutType: workout.idWorkoutType,
                        duration: workout.duration,
                        calories: workout.calories,
                        distance: workout.distance,
                        frequencyHeart: workout.frequencyHeart,
                        dateWorkout: workout.dateWorkout,
                        higherJump: extras.higherJump ?? 0.0,
                        pointsPath: extras.pointPath ?? []
                    )
                } else {
                    // Sem dados extras, mantém os valores padrão
                    return workout
                }
            }
        } catch {
            print("❌ Erro ao buscar extras: \(error)")
            return workouts
        }
    }
    
    // MARK: - Fetch por período (mantida!)
    func fetchDataWorkout(endDate: Date, period: String) {
        self.workouts.removeAll()
        self.newWorkouts.removeAll()
        self.totalWorkoutsCount = 0
        
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
        
        let query = HKSampleQuery(
            sampleType: workoutType,
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
                    let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
                    var calories = 0.0
                    if let totalEnergy = workout.statistics(for: energyType)?.sumQuantity() {
                        calories = totalEnergy.doubleValue(for: .kilocalorie())
                    }
                    
                    Task { @MainActor in
                        // Monta Workout básico primeiro (sem dados extras)
                        let summary = Workout(
                            id: workout.uuid,
                            idWorkoutType: Int(workout.workoutActivityType.rawValue),
                            duration: workout.duration,
                            calories: Int(calories),
                            distance: Int(workout.totalDistance?.doubleValue(for: .meter()) ?? 0),
                            frequencyHeart: bpm,
                            dateWorkout: workout.endDate,
                            higherJump: 0.0,  // Será preenchido no merge posterior
                            pointsPath: []    // Será preenchido no merge posterior
                        )
                        
                        self.newWorkouts.append(summary)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                Task { @MainActor in
                    // 🔹 Fazer merge com dados extras do SwiftData
                    let enrichedWorkouts = await self.enrichWorkoutsWithExtras(self.newWorkouts)
                    
                    self.workouts = enrichedWorkouts.sorted { $0.dateWorkout < $1.dateWorkout }
                    self.totalWorkoutsCount = self.workouts.count
                    self.updateWorkoutsByDay(filtered: self.workouts)
                }
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
    
    //observar novos treinos diretamente no health kit
    func startObservingWorkouts() {
        let workoutType = HKObjectType.workoutType()

        // 1. ObserverQuery avisa quando há novos treinos
        let observerQuery = HKObserverQuery(sampleType: workoutType, predicate: nil) { [weak self] _, _, error in
            guard let self = self else { return }
            if let error = error {
                print("Erro no observer: \(error.localizedDescription)")
                return
            }

            // Sempre que chegar dado novo, re-fetch
            self.fetchNewWorkouts()
        }

        healthStore.execute(observerQuery)
        healthStore.enableBackgroundDelivery(for: workoutType, frequency: .immediate) { success, error in
            if success {
                print("Background delivery habilitado ✅")
            } else {
                print("Erro background delivery: \(error?.localizedDescription ?? "")")
            }
        }
    }

    private func fetchNewWorkouts() {
        let workoutType = HKObjectType.workoutType()
//        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)

        let query = HKAnchoredObjectQuery(
            type: workoutType,
            predicate: nil,
            anchor: workoutAnchor,
            limit: HKObjectQueryNoLimit,
            resultsHandler: { [weak self] _, samples, _, newAnchor, error in
                guard let self = self else { return }
                if let error = error {
                    print("Erro no anchored query: \(error.localizedDescription)")
                    return
                }
                self.workoutAnchor = newAnchor

                guard let workouts = samples as? [HKWorkout], !workouts.isEmpty else { return }

                Task { @MainActor in
                    // 🔁 Reaproveita sua lógica existente
                    self.fetchAllWorkouts()
                }
            }
        )

        healthStore.execute(query)
    }
}
