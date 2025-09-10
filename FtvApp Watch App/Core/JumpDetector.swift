//
//  JumpDetector.swift
//  FtvApp Watch App
//
//  Sistema simples de detecção de saltos para futevôlei
// 

#if os(watchOS)

import Foundation
import CoreMotion

final class JumpDetector: ObservableObject {
    
    // MARK: - 🎯 Variáveis principais
    @Published var lastJumpHeight: Double = 0.0
    @Published var bestJumpHeight: Double = 0.0
    
    // MARK: - Componentes
    private var motionManager = CMMotionManager()
    private var operationQueue = OperationQueue()
    private var isActive = false
    
    // MARK: - Estado interno
    private var isInFlight = false
    private var takeoffTime: TimeInterval?
    private var landingTime: TimeInterval?
    private var freefallCount = 0
    private var groundCount = 0
    
    // Filtro
    private var previousAccel: Double = 1.0
    private var accelHistory: [Double] = []
    
    // Logs
    private var logCounter = 0
    
    // MARK: - Configurações extremamente rigorosas
    private let freefallThreshold: Double = -0.8     // só considera decolagem se forte queda
    private let groundThreshold: Double = 1.0       // pouso detectado se impacto forte
    private let minFreefallSamples = 3
    private let minGroundSamples = 4
    private let minFlightTime: Double = 0.10
    private let minJumpInterval: Double = 0.35       // debounce para evitar contagem dupla
    private let maxJumpHeight: Double = 0.50
    private var lastLandingTime: TimeInterval = 0
    
    // MARK: - Início / parada
    func start() {
        isActive = true
        operationQueue = OperationQueue() // <- fila nova
        operationQueue.maxConcurrentOperationCount = 1

        CalibrationManager.shared.startCalibration {
            print("✅ Calibração concluída: baseline=\(CalibrationManager.shared.baselineGravity), sens=\(CalibrationManager.shared.sensitivity)")
        }
        
        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Sensor de movimento não disponível")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 100.0
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated
        
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: operationQueue) { [weak self] deviceMotion, error in
            guard let self = self, let motion = deviceMotion else {
                if let error = error {
                    print("⚠️ Erro no sensor: \(error.localizedDescription)")
                }
                return
            }
            self.processMotion(motion)
        }
        
        print("🚀 Detector de saltos iniciado")
    }
    
    private var stopTimestamp: TimeInterval?

    func stop() {
        isActive = false
        stopTimestamp = Date().timeIntervalSince1970

        motionManager.stopDeviceMotionUpdates()
        motionManager = CMMotionManager() // 🔥 recria do zero

        operationQueue.cancelAllOperations()
        resetFlight()
        print("⏹️ Detector de saltos parado")
    }
    
    func reset() {
          // Zere a altura do melhor pulo e qualquer outra variável de estado
          bestJumpHeight = 0.0
          print("Jump detector has been reset.")
      }
    
    // MARK: - Processamento de movimento
    private func processMotion(_ deviceMotion: CMDeviceMotion) {
        guard isActive else { return }
        if let stopTs = stopTimestamp, deviceMotion.timestamp > stopTs {
            return // ignora leitura que chegou depois do stop
        }
        
        let verticalAccRaw = extractVerticalAcceleration(from: deviceMotion)
        
        // 🔹 Ajusta pela calibração
        let baseline = CalibrationManager.shared.baselineGravity
        let sensitivity = max(0.5, CalibrationManager.shared.sensitivity) // garante >= 0.5
        let verticalAcc = applySmoothingFilter((verticalAccRaw - baseline) / sensitivity)
        
        let timestamp = deviceMotion.timestamp
        logCounter += 1
        
        if isInFlight {
            // Detecta pouso
            if verticalAcc > groundThreshold {
                groundCount += 1
                if groundCount >= minGroundSamples {
                    landingTime = timestamp
                    if let takeoff = takeoffTime {
                        let flightTime = timestamp - takeoff
                        if flightTime >= minFlightTime {
                            calculateJumpHeight()
                        }
                    }
                    lastLandingTime = timestamp
                    resetFlight()
                    print("🛬 Pouso detectado! (a=\(String(format: "%.2f", verticalAcc))g)")
                }
            } else {
                groundCount = 0
            }
        } else {
            if timestamp - lastLandingTime > minJumpInterval {
                if verticalAcc < freefallThreshold {
                    freefallCount += 1
                    if freefallCount >= minFreefallSamples {
                        takeoffTime = timestamp
                        isInFlight = true
                        print("🛫 Decolagem detectada")
                    }
                } else {
                    freefallCount = 0
                }
            }
        }
    }

    
    // MARK: - Extrai aceleração vertical
    private func extractVerticalAcceleration(from deviceMotion: CMDeviceMotion) -> Double {
        let userAcc = deviceMotion.userAcceleration
        let grav = deviceMotion.gravity
        let gravNorm = sqrt(grav.x * grav.x + grav.y * grav.y + grav.z * grav.z)
        guard gravNorm > 0 else { return 0 }
        let gravNormalized = (
            x: grav.x / gravNorm,
            y: grav.y / gravNorm,
            z: grav.z / gravNorm
        )
        let verticalAcc = userAcc.x * gravNormalized.x +
                          userAcc.y * gravNormalized.y +
                          userAcc.z * gravNormalized.z
        return verticalAcc
    }
    
    // MARK: - Filtro rápido
    private func applySmoothingFilter(_ rawAcceleration: Double) -> Double {
        accelHistory.append(rawAcceleration)
        if accelHistory.count > 2 {
            accelHistory.removeFirst()
        }

        guard !accelHistory.isEmpty else { return previousAccel }

        let weights = [0.7, 0.3]
        var weightedSum = 0.0
        var totalWeight = 0.0

        for (index, value) in accelHistory.enumerated() {
            let weight = weights[min(index, weights.count - 1)]
            weightedSum += value * weight
            totalWeight += weight
        }

        guard totalWeight > 0 else { return previousAccel }

        let average = weightedSum / totalWeight
        let alpha: Double = 0.6
        let smoothed = alpha * average + (1 - alpha) * previousAccel
        previousAccel = smoothed
        return smoothed
    }

    
    // MARK: - Cálculo de altura do salto
    private func calculateJumpHeight() {
        guard let start = takeoffTime, let end = landingTime else { return }
        var flightTime = end - start
        if flightTime.isNaN || flightTime.isInfinite || flightTime < 0 { return }

        // clamp
        if flightTime < minFlightTime { flightTime = minFlightTime }
        if flightTime > 0.6 { flightTime = 0.6 }

        let gravity: Double = 9.81
        let height = min(maxJumpHeight, gravity * pow(flightTime, 2) / 8.0)

        guard height > 0.01, height.isFinite else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.lastJumpHeight = height
            if height > self.bestJumpHeight {
                self.bestJumpHeight = height
                print("🏆 Novo recorde: \(Int(height * 100))cm")
            }
            print("✅ Salto válido: \(Int(height * 100))cm (t=\(String(format: "%.3f", flightTime))s)")
        }
    }



    
    // MARK: - Reset do voo
    private func resetFlight() {
        isInFlight = false
        takeoffTime = nil
        landingTime = nil
        groundCount = 0
        freefallCount = 0
    }
}

#else

/// Stub para outras plataformas
final class JumpDetector: ObservableObject {
    @Published var lastJumpHeight: Double = 0
    @Published var bestJumpHeight: Double = 0
    func start() { print("⚠️ JumpDetector só funciona no watchOS") }
    func stop() {}
}

#endif
