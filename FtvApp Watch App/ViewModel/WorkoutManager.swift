//
//  WorkoutManager.swift
//  BeActiv Watch App
//
//  Created by Filipi Romão on 11/08/25.
//

import Foundation
import HealthKit
import CoreMotion
import Combine
import CoreGraphics

class WorkoutManager: NSObject, ObservableObject {

    // MARK: - HealthKit
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

    // MARK: - State
    @Published var running = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var heartRate: Double = 0
    @Published var averageHeartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?
    private var isEndingWorkout = false
    
    let motionManager = CMMotionManager()
    
    // Dados de Posição (PDR)
    @Published var currentPosition: CGPoint = .zero
    @Published var path: [CGPoint] = []
    
    // Referência unificada: YAW do CoreMotion (em radianos)
    var refYawRad: Double?
    
    // Constantes de detecção de passo (ajuste fino conforme necessário)
    let STEP_THRESHOLD_HIGH: Double = 0.20
    let STEP_THRESHOLD_LOW:  Double = 0.12
    let ROTATION_LIMIT:      Double = 1.0   // rad/s para ignorar giro de punho
    let STEP_LENGTH:         Double = 0.6  // metros por passo (aprox.)
    var isStepInProgress = false

    var timer: Timer?
    var startDate: Date?
    var accumulatedTime: TimeInterval = 0

    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?

    // MARK: - Workout Control

    func startWorkout(workoutType: HKWorkoutActivityType) {
        // 1. Zera todo o estado anterior
        self.accumulatedTime = 0
        self.elapsedTime = 0
        self.heartRate = 0
        self.averageHeartRate = 0
        self.activeEnergy = 0
        self.distance = 0
        self.workout = nil
        self.isEndingWorkout = false
        self.resetTimer()

        // 2. Configura e cria a nova sessão
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

        // 3. Inicia o treino
        startDate = Date()
        session.startActivity(with: startDate!)
        builder.beginCollection(withStart: startDate!) { _, _ in }
        print("▶ Treino iniciando...")
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
        print("▶ Sessão retomando...")
    }

    var onWorkoutEnded: ((HKWorkout) -> Void)?

    func endWorkout(shouldShowSummary: Bool = true, completion: (() -> Void)? = nil) {
        guard !isEndingWorkout else {
            print("⚠️ Tentativa de encerrar um treino que já está em processo de finalização.")
            return
        }
        isEndingWorkout = true
        guard let builder = builder else {
            print("⚠️ Nenhum workout builder ativo para encerrar")
            isEndingWorkout = false
            completion?()
            return
        }
        session?.end()
        builder.endCollection(withEnd: Date()) { _, error in
            if let error = error {
                print("❌ Erro ao encerrar coleta: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isEndingWorkout = false
                    completion?()
                }
                return
            }
            builder.finishWorkout { workout, _ in
                print("🏁 Treino finalizado e salvo:", workout ?? "Sem dados")
                DispatchQueue.main.async {
                    self.workout = workout
                    if let finalWorkout = workout, shouldShowSummary {
                        self.onWorkoutEnded?(finalWorkout)
                    }
                    completion?()
                    self.isEndingWorkout = false
                }
            }
        }
        resetTimer()
    }

    // MARK: - Timer Control
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

    // MARK: - Statistics (sem alterações)
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        DispatchQueue.main.async {
            switch statistics.quantityType {
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

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            // ✅ A LINHA QUE FALTAVA FOI ADICIONADA DE VOLTA
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

// MARK: - HKLiveWorkoutBuilderDelegate (sem alterações)
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
