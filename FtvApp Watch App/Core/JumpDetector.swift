//
//  JumpDetector.swift
//  FtvApp Watch App
//
//  Sistema simples de detecção de saltos para futevôlei
//

#if os(watchOS)

import Foundation
import CoreMotion

// MARK: - Jump Detector Simples

/// Detector de saltos simples para futevôlei
final class JumpDetector: ObservableObject {
    
    // MARK: - 🎯 VARIÁVEIS PRINCIPAIS DOS SALTOS
    
    ///  Altura do último salto (em metros)
    @Published var lastJumpHeight: Double = 0.0
    
    ///  ALTURA DO SALTO MAIS ALTO (em metros)  VARIÁVEL PRINCIPAL
    @Published var bestJumpHeight: Double = 0.0
    
    // MARK: - Componentes do Sistema
    
    private let motionManager = CMMotionManager()
    private let operationQueue = OperationQueue()
    
    // MARK: - Variáveis do Algoritmo
    
    private var isInFlight = false
    private var takeoffTime: TimeInterval?
    private var landingTime: TimeInterval?
    private var freefallCount = 0
    private var groundCount = 0
    private var stableCount = 0
    
    // Filtro de suavização
    private var previousAccel: Double = 1.0
    private var accelHistory: [Double] = []
    private let historySize = 5
    
    // Contador para logs
    private var logCounter = 0
    
    // MARK: - ""NÃO MEXER"" CONFIGURAÇÕES OTIMIZADAS PARA MOVIMENTOS RÁPIDOS DO FUTEVÔLEI
    
    private let freefallThreshold: Double = 0.5     // Mais sensível para movimentos rápidos
    private let groundThreshold: Double = 1.3       // Menos rigoroso para pousos rápidos
    private let minFreefallSamples = 2              // Detecção mais rápida
    private let minGroundSamples = 2                // Pouso mais rápido
    private let minFlightTime: Double = 0.06        // Tempo mínimo mais baixo (60ms)
    
    // MARK: - Métodos Públicos
    
    /// Inicia a detecção de saltos
    func start() {
        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Sensor de movimento não disponível")
            return
        }
        
        //  CONFIGURAÇÃO ULTRA RESPONSIVA PARA MOVIMENTOS RÁPIDOS
        motionManager.deviceMotionUpdateInterval = 1.0 / 100.0  // 100Hz para capturar movimentos muito rápidos
        
        // Configura fila de operações para processamento eficiente
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated
        
        motionManager.startDeviceMotionUpdates(
            using: .xArbitraryZVertical,  // Referência vertical estável
            to: operationQueue
        ) { [weak self] deviceMotion, error in
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
    
    /// Para a detecção
    func stop() {
        motionManager.stopDeviceMotionUpdates()
        print("⏹️ Detector de saltos parado")
    }
    
    // MARK: - ALGORITMO PRINCIPAL DE CÁLCULO DO SALTO
    
    /// Processa os dados do sensor de movimento com filtro inteligente
    private func processMotion(_ deviceMotion: CMDeviceMotion) {
        // Aplica filtro suave para reduzir ruído mantendo responsividade
        let rawAcceleration = extractVerticalAcceleration(from: deviceMotion)
        let acceleration = applySmoothingFilter(rawAcceleration)
        let timestamp = deviceMotion.timestamp
        
        // Log periódico para debug (a cada 60 amostras = ~1s)
        logCounter += 1
        if logCounter % 60 == 0 {
            print("📊 Aceleração: \(String(format: "%.2f", acceleration))g | Em voo: \(isInFlight)")
        }
        
        if isInFlight {
            //  DURANTE O VOO - Detecta pouso
            if acceleration > groundThreshold {
                groundCount += 1
                if groundCount >= minGroundSamples {
                    landingTime = timestamp
                    
                    //  VALIDAÇÃO: Verifica se o tempo de voo é válido
                    if let takeoff = takeoffTime {
                        let flightTime = timestamp - takeoff
                        if flightTime >= minFlightTime {
                            calculateJumpHeight()
                            print("🛬 Pouso detectado! (a=\(String(format: "%.2f", acceleration))g)")
                        } else {
                            print("⚠️ Movimento muito rápido, não é salto (t=\(String(format: "%.3f", flightTime))s)")
                        }
                    }
                    resetFlight()
                }
            } else {
                groundCount = 0
            }
            
        } else {
            //  NO CHÃO - Detecta início do salto
            
            // Detecta queda livre (início do salto)
            if acceleration < freefallThreshold {
                freefallCount += 1
                if freefallCount >= minFreefallSamples {
                    takeoffTime = timestamp
                    isInFlight = true
                    freefallCount = 0
                    print("🛫 SALTO DETECTADO! (a=\(String(format: "%.2f", acceleration))g)")
                }
            } else {
                freefallCount = 0
            }
            
            // Log apenas quando confirma o salto (reduz spam no console)
        }
    }
    
    /// Extrai aceleração vertical do movimento do dispositivo
    private func extractVerticalAcceleration(from deviceMotion: CMDeviceMotion) -> Double {
        let gravity = deviceMotion.gravity
        let totalAccel = (
            x: deviceMotion.userAcceleration.x + gravity.x,
            y: deviceMotion.userAcceleration.y + gravity.y,
            z: deviceMotion.userAcceleration.z + gravity.z
        )
        
        // Calcula magnitude da aceleração total
        let magnitude = sqrt(totalAccel.x * totalAccel.x +
                           totalAccel.y * totalAccel.y +
                           totalAccel.z * totalAccel.z)
        return magnitude
    }
    
    ///  Aplica filtro otimizado para movimentos rápidos do futevôlei
    private func applySmoothingFilter(_ rawAcceleration: Double) -> Double {
        // Janela ainda menor para máxima responsividade em movimentos rápidos
        accelHistory.append(rawAcceleration)
        if accelHistory.count > 2 {  // Apenas 2 amostras para ultra responsividade
            accelHistory.removeFirst()
        }
        
        // Filtro ponderado com ainda mais peso no valor atual
        let weights = [0.7, 0.3]  // 70% no valor mais recente
        var weightedSum = 0.0
        var totalWeight = 0.0
        
        for (index, value) in accelHistory.enumerated() {
            let weight = weights[min(index, weights.count - 1)]
            weightedSum += value * weight
            totalWeight += weight
        }
        
        let average = weightedSum / totalWeight
        
        // Filtro exponencial mais responsivo para movimentos rápidos
        let alpha: Double = 0.6  // Muito responsivo para futevôlei
        let smoothed = alpha * average + (1 - alpha) * previousAccel
        previousAccel = smoothed
        
        return smoothed
    }
    
    ///  CALCULA A ALTURA DO SALTO - ALGORITMO CALIBRADO E PRECISO
    private func calculateJumpHeight() {
        guard let start = takeoffTime, let end = landingTime else { return }
        
        // Tempo de voo total
        let flightTime = end - start
        
        //  VALIDAÇÃO DO TEMPO DE VOO (menos rigorosa para movimentos rápidos)
        guard flightTime >= minFlightTime && flightTime < 1.5 else {
            print("⚠️ Tempo de voo inválido: \(String(format: "%.3f", flightTime))s")
            return
        }
        
        //  FÓRMULA FÍSICA APRIMORADA: h = g × t² / 8
        let gravity: Double = 9.81
        var height = gravity * flightTime * flightTime / 8.0
        
        // 🔧 CALIBRAÇÃO MELHORADA PARA FUTEVÔLEI
        // Compensação para delay de sensores (~30ms típico em movimentos rápidos)
        let sensorDelay = 0.03  // 30ms
        let adjustedTime = flightTime + sensorDelay
        height = gravity * adjustedTime * adjustedTime / 8.0
        
        // Fator de calibração mais próximo da realidade
        let calibrationFactor = 1.15  // Aumentado para compensar subestimação
        height *= calibrationFactor
        
        //  VALIDAÇÃO FINAL DA ALTURA (mais permissiva)
        guard height > 0.01 && height < 3.0 else {
            print("⚠️ Altura calculada fora do range: \(String(format: "%.0f", height * 100))cm")
            return
        }
        
        //  ATUALIZA AS VARIÁVEIS PRINCIPAIS
        DispatchQueue.main.async { [weak self] in
            self?.lastJumpHeight = height
            
            //  ATUALIZA O SALTO MAIS ALTO
            if height > (self?.bestJumpHeight ?? 0) {
                self?.bestJumpHeight = height
                print("🏆 Novo recorde: \(String(format: "%.0f", height * 100))cm")
            }
            
            print("✅ Salto válido: \(String(format: "%.0f", height * 100))cm (t=\(String(format: "%.3f", flightTime))s)")
        }
    }
    
    /// Reseta o estado do voo
    private func resetFlight() {
        isInFlight = false
        takeoffTime = nil
        landingTime = nil
        groundCount = 0
        freefallCount = 0
        stableCount = 0
    }
}

#else

// MARK: - Stub para outras plataformas

final class JumpDetector: ObservableObject {
    @Published var lastJumpHeight: Double = 0
    @Published var bestJumpHeight: Double = 0
    
    func start() {
        print("⚠️ JumpDetector só funciona no watchOS")
    }
    
    func stop() { }
}

#endif
