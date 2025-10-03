
import Foundation
import HealthKit
import SwiftUI
import CoreMotion
import Combine
import CoreGraphics

class WorkoutManager: NSObject, ObservableObject {
    
    let healthStore = HKHealthStore()
    
    override init() {
        super.init()
        requestAuthorization()
    }
    
    func requestAuthorization() {
        let healthTypes: Set = [
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned),
            HKObjectType.workoutType(),
            HKQuantityType(.heartRate),
            HKQuantityType(.distanceWalkingRunning)
        ]
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: healthTypes, read: healthTypes)
                print("✅ HealthKit authorization granted")
            } catch {
                print("❌ HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    @Published var running = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var heartRate: Double = 0
    @Published var averageHeartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?
    @Published var preWorkoutJumpHeight: Int? = nil
    @Published var stepCount: Int = 0
    private var isEndingWorkout = false
    @ObservedObject var positionManager = managerPosition.shared
    @Published var serializablePath: [[String: Double]] = []
    @Published var selectedWorkoutType: HKWorkoutActivityType?
    
    
    private let motionManager = CMMotionManager()
    
    
    var timer: Timer?
    var startDate: Date?
    var accumulatedTime: TimeInterval = 0
    
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    
    @MainActor
    func startWorkout(workoutType: HKWorkoutActivityType) {
        self.selectedWorkoutType = workoutType
        self.accumulatedTime = 0
        self.elapsedTime = 0
        self.heartRate = 0
        self.averageHeartRate = 0
        self.activeEnergy = 0
        self.distance = 0
        self.workout = nil
        self.isEndingWorkout = false
        self.resetTimer()
        self.stepCount = 0
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .outdoor
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
        } catch {
            print("❌ Failed to start workout session: \(error.localizedDescription)")
            return
        }
        guard let session = session, let builder = builder else { return }
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        session.delegate = self
        builder.delegate = self
        
        startDate = Date()
        session.startActivity(with: startDate!)
        builder.beginCollection(withStart: startDate!) { _, _ in }
        print("▶️ Treino iniciando...")
        positionManager.startMotionUpdates()
    }
    
    func pause() {
        guard let session = session, session.state == .running else { return }
        session.pause()
        print("⚡ Sessão pausando...")
    }
    
    func resume() {
        guard let session = session, session.state == .paused else { return }
        session.resume()
        startDate = Date()
        print("▶️ Sessão retomando...")
    }
    
    var onWorkoutEnded: ((HKWorkout) -> Void)?
    
    @MainActor
        func endWorkout(shouldShowSummary: Bool = true) async {
            guard !isEndingWorkout else {
                print(
                    "⚠️ Tentativa de encerrar um treino que já está em processo de finalização."
                )
                return
            }
            isEndingWorkout = true
            
            defer {
                isEndingWorkout = false
                resetTimer()
            }
            
            if positionManager.localizacaoRodando {
                let pdrResult = await positionManager.stopMotionUpdates()
                
                self.serializablePath = pdrResult.path
                self.stepCount = pdrResult.steps
                
                print(
                    "📌 Path salvo no WorkoutManager: \(self.serializablePath.count) pontos"
                )
                print("👣 Passos do PDR salvos: \(self.stepCount)")
            }
            
            guard let session = session, let builder = builder else {
                print("⚠️ Nenhum workout builder ativo para encerrar.")
                return
            }
            
            session.end()
            
            do {
                try await withCheckedThrowingContinuation {
                    (continuation: CheckedContinuation<Void, Error>) in
                    builder.endCollection(withEnd: Date()) { success, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                    }
                }
                
                let finalWorkout: HKWorkout =
                try await withCheckedThrowingContinuation {
                    (continuation: CheckedContinuation<HKWorkout, Error>) in
                    builder.finishWorkout { workout, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let workout = workout {
                            continuation.resume(returning: workout)
                        } else {
                        }
                    }
                }
                
                print("🏁 Treino finalizado e salvo:", finalWorkout)
                self.workout = finalWorkout
                
                if shouldShowSummary, let workoutToShow = self.workout {
                    self.onWorkoutEnded?(workoutToShow)
                }
                
            } catch {
                print(
                    "❌ Erro ao finalizar o treino no HealthKit: \(error.localizedDescription)"
                )
            }
        }
    
    private func startTimer() {
        timer?.invalidate()
        guard startDate != nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.running else { return }
            self.elapsedTime = self.accumulatedTime + Date().timeIntervalSince(self.startDate!)
        }
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        if let start = startDate {
            accumulatedTime += Date().timeIntervalSince(start)
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        elapsedTime = 0
        accumulatedTime = 0
        startDate = nil
    }
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .stepCount):
                let unit = HKUnit.count()
                let steps = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0
                self.stepCount = Int(steps)
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: unit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: unit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let unit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
                HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let unit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0
            default:
                return
            }
        }
    }
}

extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
            
            print("HK Session State Changed to: \(toState.rawValue) -> Running is \(self.running)")
            
            if self.running {
                self.startTimer()
            } else {
                self.pauseTimer()
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("❌ Workout session failed: \(error.localizedDescription)")
    }
}

extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { return }
            let statistics = workoutBuilder.statistics(for: quantityType)
            updateForStatistics(statistics)
        }
    }
}
