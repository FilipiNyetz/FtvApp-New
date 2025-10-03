
import Foundation
import HealthKit
import SwiftUI

enum Sport: Int, CaseIterable, Identifiable {
    case footvolley   // usa HKWorkoutActivityType.soccer
    case volleyball   // .volleyball
    case beachTennis  // .tennis

    var id: Int { rawValue }

    var hkType: HKWorkoutActivityType {
        switch self {
        case .footvolley:   return .soccer
        case .volleyball:   return .volleyball
        case .beachTennis:  return .tennis
        }
    }

    var displayName: String {
        switch self {
        case .footvolley:   return "Futevôlei"
        case .volleyball:   return "Vôlei de praia"
        case .beachTennis:  return "Beach Tennis"
        }
    }

    static func from(hkType: HKWorkoutActivityType) -> Sport? {
        switch hkType {
        case .soccer:      return .footvolley
        case .volleyball:  return .volleyball
        case .tennis:      return .beachTennis
        default:           return nil
        }
    }
}

class HealthManager: ObservableObject, @unchecked Sendable {

    let healthStore = HKHealthStore()

    var wcSessionDelegate: PhoneWCSessionDelegate?

    @Published var workouts: [Workout] = []
    @Published var workoutsByDay: [Date: [Workout]] = [:]
    @Published var workoutsBySport: [Sport: [Workout]] = [:]
    @Published var totalWorkoutsCount: Int = 0
    @Published var currentStreak: Int = 0

    @AppStorage("streakUser") private var storedStreak: Int = 0

    var weekChangeTimer: Timer?
    private let calendar = Calendar.current
    var newWorkouts: [Workout] = []
    var workoutAnchor: HKQueryAnchor?

    init() {
        self.currentStreak = storedStreak
        if let delegate = self.wcSessionDelegate {
            delegate.healthManager = self
        }
        requestAuthorization()
        startObservingWorkouts()
    }

    private func requestAuthorization() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let typeWorkouts = HKObjectType.workoutType()
        let heartRate = HKQuantityType(.heartRate)
        let distance = HKQuantityType(.distanceWalkingRunning)

        let healthTypes: Set = [
            steps, calories, typeWorkouts, heartRate, distance,
        ]

        Task {
            do {
                try await healthStore.requestAuthorization(
                    toShare: healthTypes,
                    read: healthTypes
                )
            } catch {
                print("Error fetching data: \(error)")
            }
        }
    }
    
        private func fetchWorkoutData(for workout: HKWorkout) async -> Workout? {
            return await withCheckedContinuation { continuation in
                queryFrequenciaCardiaca(
                    workout: workout,
                    healthStore: self.healthStore
                ) { bpm in
                    let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
                    let calories: Int
                    if let totalEnergy = workout.statistics(for: energyType)?.sumQuantity() {
                        calories = Int(totalEnergy.doubleValue(for: .kilocalorie()))
                    } else {
                        calories = 0
                    }
                    
                    let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
                    let predicateSteps = HKQuery.predicateForObjects(from: workout)
                    let stepsQuery = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicateSteps, options: .cumulativeSum) { _, result, _ in
                        var steps = 0.0
                        if let sum = result?.sumQuantity() {
                            steps = sum.doubleValue(for: .count())
                        }
                        
                        let summary = Workout(
                            id: workout.uuid,
                            idWorkoutType: Int(workout.workoutActivityType.rawValue),
                            duration: workout.duration,
                            calories: calories,
                            distance: Int(workout.totalDistance?.doubleValue(for: .meter()) ?? 0),
                            frequencyHeart: bpm,
                            dateWorkout: workout.endDate,
                            higherJump: 0.0,
                            pointsPath: [],
                            stepCount: Int(steps)
                        )
                        
                        continuation.resume(returning: summary)
                    }
                    self.healthStore.execute(stepsQuery)
                }
            }
        }

    func startWeekChangeTimer() {
        weekChangeTimer?.invalidate()

        let now = Date()
        let calendar = Calendar.current

        guard
            let nextWeek = calendar.nextDate(
                after: now,
                matching: DateComponents(weekday: calendar.firstWeekday),
                matchingPolicy: .nextTime
            )
        else { return }

        let interval = nextWeek.timeIntervalSince(now)

        weekChangeTimer = Timer.scheduledTimer(
            withTimeInterval: interval,
            repeats: false
        ) { [weak self] _ in
            Task { @MainActor in
                self?.calculateStreak(from: self?.workouts ?? [])
                self?.startWeekChangeTimer()
            }
        }
    }

    @MainActor
    func updateWorkoutsByDay(filtered: [Workout]) {
        let grouped = Dictionary(grouping: filtered) { workout in
            calendar.startOfDay(for: workout.dateWorkout)
        }

        self.workoutsByDay = grouped
        self.totalWorkoutsCount = filtered.count

        calculateStreak(from: filtered)
    }

    @MainActor
    private func calculateStreak(from workouts: [Workout]) {
        let today = Date()

        let workoutDays = Set(
            workouts.map { calendar.startOfDay(for: $0.dateWorkout) }
        )
        guard !workoutDays.isEmpty else {
            currentStreak = 0
            storedStreak = 0
            return
        }

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

        var streak = 0
        var lastWeek: (year: Int, week: Int)? = nil

        for week in weeks {
            if let last = lastWeek {
                if (week.year == last.year && week.week == last.week + 1)
                    || (week.year == last.year + 1 && last.week == 52
                        && week.week == 1)
                {
                    streak += 1
                } else {
                    streak = 1
                }
            } else {
                streak = 1
            }
            lastWeek = week
        }

        if let last = lastWeek {
            let currentYear = calendar.component(
                .yearForWeekOfYear,
                from: today
            )
            let currentWeek = calendar.component(.weekOfYear, from: today)
            if (currentYear == last.year && currentWeek > last.week + 1)
                || (currentYear > last.year
                    && !(last.week == 52 && currentWeek == 1))
            {
                streak = 0
            }
        }

        currentStreak = streak
        storedStreak = streak
    }
    
    private func makePredicate(start: Date?, end: Date?, sports: [Sport]?) -> NSPredicate? {
        var subs: [NSPredicate] = []

        if let start, let end {
            subs.append(HKQuery.predicateForSamples(withStart: start, end: end))
        } else if let end {
            subs.append(HKQuery.predicateForSamples(withStart: .distantPast, end: end))
        }

        if let sports, !sports.isEmpty {
            // Combine vários esportes (se um dia crescer a lista)
            let sportPreds = sports.map { HKQuery.predicateForWorkouts(with: $0.hkType) }
            subs.append(NSCompoundPredicate(orPredicateWithSubpredicates: sportPreds))
        }

        guard !subs.isEmpty else { return nil }
        return NSCompoundPredicate(andPredicateWithSubpredicates: subs)
    }

    @MainActor
    func fetchAllWorkouts(until endDate: Date = Date(), sport: Sport? = nil) {
        self.workouts.removeAll()
        self.newWorkouts.removeAll()
        self.totalWorkoutsCount = 0

        let workoutType = HKObjectType.workoutType()
        let predicate = makePredicate(start: .distantPast, end: endDate, sports: sport.map { [$0] })
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

            Task { @MainActor in
                var temp: [Workout] = []

                await withTaskGroup(of: Workout?.self) { group in
                    for w in workouts { group.addTask { await self.fetchWorkoutData(for: w) } }
                    for await s in group { if let s { temp.append(s) } }
                }

                let unique = Array(Dictionary(grouping: temp, by: { $0.id }).values.compactMap(\.first))
                let enriched = await self.enrichWorkoutsWithExtras(unique)
                self.newWorkouts = enriched.sorted { $0.dateWorkout < $1.dateWorkout }
                self.workouts = self.newWorkouts
                self.totalWorkoutsCount = self.workouts.count
                self.updateWorkoutsByDay(filtered: self.workouts)

                // preenche o dicionário por esporte também
                self.indexBySport(self.workouts)
            }
        }
        healthStore.execute(query)
    }

    @MainActor
    private func indexBySport(_ items: [Workout]) {
        var dict: [Sport: [Workout]] = [:]

        for wk in items {
            guard
                let hkType = HKWorkoutActivityType(rawValue: UInt(wk.idWorkoutType)),
                let sport = Sport.from(hkType: hkType)
            else { continue }

            dict[sport, default: []].append(wk)
        }

        self.workoutsBySport = dict
    }

    @MainActor
    private func enrichWorkoutsWithExtras(_ workouts: [Workout]) async
        -> [Workout]
    {
        guard let wcSessionDelegate = wcSessionDelegate else {
            print("⚠️ wcSessionDelegate não disponível")
            return workouts
        }

        let workoutIDs = workouts.map { $0.id.uuidString }

        do {
            let extrasRepository = wcSessionDelegate.getExtrasRepository()
            let extrasMap = try await extrasRepository.fetchExtrasMap(
                for: workoutIDs
            )

            print(
                "🔎 Chaves encontradas no banco de dados (Extras Map): \(extrasMap.keys)"
            )
            print(
                "📦 Fazendo merge de \(workouts.count) workouts com \(extrasMap.count) extras..."
            )

            return workouts.map { workout in
                let workoutIDString = workout.id.uuidString

                print(
                    "   -> Processando workout do HealthKit com ID: \(workoutIDString)"
                )
                if let key = extrasMap.keys.first(where: {
                    $0.caseInsensitiveCompare(workoutIDString) == .orderedSame
                }),
                    let extras = extrasMap[key]
                {

                    print(
                        "      ✅ SUCESSO: Combinação encontrada para \(workoutIDString). Adicionando \(extras.pointPath?.count ?? 0) pontos."
                    )
                    return Workout(
                        id: workout.id,
                        idWorkoutType: workout.idWorkoutType,
                        duration: workout.duration,
                        calories: workout.calories,
                        distance: workout.distance,
                        frequencyHeart: workout.frequencyHeart,
                        dateWorkout: workout.dateWorkout,
                        higherJump: extras.higherJump ?? 0.0,
                        pointsPath: extras.pointPath ?? [],
                        stepCount: extras.stepCount ?? workout.stepCount
                    )
                } else {
                    print(
                        "      ❌ FALHA: Nenhuma combinação encontrada para \(workoutIDString) no mapa de extras."
                    )
                    return workout  
                }
            }
        } catch {
            print("❌ Erro ao buscar extras: \(error)")
            return workouts
        }
    }
    
    

    func fetchDataWorkout(endDate: Date, period: String, sport: Sport? = nil) {
        self.workouts.removeAll()
        self.newWorkouts.removeAll()
        self.totalWorkoutsCount = 0

        // calcula janela de datas (como você já faz)
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
        let predicate = makePredicate(start: startDate, end: adjustedEndDate, sports: sport.map { [$0] })

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

            var collected: [Workout] = []
            for workout in workouts {
                group.enter()
                queryFrequenciaCardiaca(workout: workout, healthStore: self.healthStore) { bpm in
                    let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
                    let calories: Int
                    if let totalEnergy = workout.statistics(for: energyType)?.sumQuantity() {
                        calories = Int(totalEnergy.doubleValue(for: .kilocalorie()))
                    } else {
                        calories = 0
                    }

                    let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
                    let predicateSteps = HKQuery.predicateForObjects(from: workout)
                    let stepsQuery = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicateSteps, options: .cumulativeSum) { _, result, _ in
                        var steps = 0.0
                        if let sum = result?.sumQuantity() {
                            steps = sum.doubleValue(for: .count())
                        }

                        Task { @MainActor in
                            collected.append(
                                Workout(
                                    id: workout.uuid,
                                    idWorkoutType: Int(workout.workoutActivityType.rawValue),
                                    duration: workout.duration,
                                    calories: calories,
                                    distance: Int(workout.totalDistance?.doubleValue(for: .meter()) ?? 0),
                                    frequencyHeart: bpm,
                                    dateWorkout: workout.endDate,
                                    higherJump: 0.0,
                                    pointsPath: [],
                                    stepCount: Int(steps)
                                )
                            )
                            group.leave()
                        }
                    }
                    self.healthStore.execute(stepsQuery)
                }
            }

            // ⚠️ O notify precisa estar FORA do loop
            group.notify(queue: .main) {
                Task { @MainActor in
                    let unique = Array(Dictionary(grouping: collected, by: { $0.id }).values.compactMap(\.first))
                    let enriched = await self.enrichWorkoutsWithExtras(unique)
                    self.workouts = enriched.sorted { $0.dateWorkout < $1.dateWorkout }
                    self.totalWorkoutsCount = self.workouts.count
                    self.updateWorkoutsByDay(filtered: self.workouts)
                    self.indexBySport(self.workouts)
                }
            }
        }

        healthStore.execute(query)
    }

    func filterWorkouts(period: String, sport: Sport?, referenceDate: Date = Date()) {
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

        let base = (sport != nil) ? (workoutsBySport[sport!] ?? []) : workouts
        let filtered = base.filter { $0.dateWorkout >= startDate && $0.dateWorkout < endDate }

        Task { @MainActor in
            self.updateWorkoutsByDay(filtered: filtered)
        }
    }

    func startObservingWorkouts() {
        let workoutType = HKObjectType.workoutType()

        let observerQuery = HKObserverQuery(
            sampleType: workoutType,
            predicate: nil
        ) { [weak self] _, _, error in
            guard let self = self else { return }
            if let error = error {
                print("Erro no observer: \(error.localizedDescription)")
                return
            }

            self.fetchNewWorkouts()
        }

        healthStore.execute(observerQuery)
        healthStore.enableBackgroundDelivery(
            for: workoutType,
            frequency: .immediate
        ) { success, error in
            if success {
                print("Background delivery habilitado ✅")
            } else {
                print(
                    "Erro background delivery: \(error?.localizedDescription ?? "")"
                )
            }
        }
    }

    private func fetchNewWorkouts() {
        let workoutType = HKObjectType.workoutType()

        let query = HKAnchoredObjectQuery(
            type: workoutType,
            predicate: nil,
            anchor: workoutAnchor,
            limit: HKObjectQueryNoLimit,
            resultsHandler: { [weak self] _, samples, _, newAnchor, error in
                guard let self = self else { return }
                if let error = error {
                    print(
                        "Erro no anchored query: \(error.localizedDescription)"
                    )
                    return
                }
                self.workoutAnchor = newAnchor

                guard let workouts = samples as? [HKWorkout], !workouts.isEmpty
                else { return }

                Task { @MainActor in
                    self.fetchAllWorkouts()
                }
            }
        )

        healthStore.execute(query)
    }
}
