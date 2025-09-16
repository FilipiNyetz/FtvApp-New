
import Foundation
import HealthKit
import CoreMotion
import Combine
import CoreGraphics

class managerPosition: NSObject, ObservableObject {
    
    private let motionManager = CMMotionManager()
    
    static let shared = managerPosition()
    
    @Published var localizacaoRodando: Bool = false
    @Published var origemDefinida: Bool = false
    @Published var posicaoInicial: CGPoint = .zero
    
    @Published var currentPosition: CGPoint = .zero
    @Published var path: [CGPoint] = []
    
    @Published var serializablePath: [[String:Double]] = []
    
    @Published var stepCount: Int = 0
    
    
    
    private var referenciaGuia: Double?
    private var filteredYaw: Double = 0.0
    
    private let STEP_THRESHOLD_HIGH: Double = 0.15
    private let STEP_THRESHOLD_LOW:  Double = 0.08
    
    private let ROTATION_LIMIT:      Double = 1.0
    private var isStepInProgress = false
    
    private var accelWindow: [Double] = []
    private let windowSize = 10
    private let STEP_SCALE: Double = 0.6  
    
    func setOrigem() {
        if self.path.isEmpty {
            let origem = CGPoint(x: 0, y: 0)
            self.currentPosition = origem
            self.path.append(origem)
            origemDefinida = true
            print("Origem definida: \(origem)")
        }
    }
    
    private let driftCorrectionThreshold: CGFloat = 0.5 
    private let smoothingFactor: CGFloat = 0.1 
    
    func applyDriftCorrection() {
        let dx = currentPosition.x - posicaoInicial.x
        let dy = currentPosition.y - posicaoInicial.y
        let distanceToOrigin = sqrt(dx*dx + dy*dy)
        
        if distanceToOrigin < driftCorrectionThreshold {
            currentPosition.x = posicaoInicial.x * smoothingFactor + currentPosition.x * (1 - smoothingFactor)
            currentPosition.y = posicaoInicial.y * smoothingFactor + currentPosition.y * (1 - smoothingFactor)
        }
    }
    
    
    @MainActor
    func startMotionUpdates() {
        referenciaGuia = nil
        currentPosition = .zero
        path = [.zero]
        stepCount = 0
        
        guard motionManager.isDeviceMotionAvailable else {
            print("Device Motion não está disponível")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 100.0
        
        let queue = OperationQueue()
        
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: queue) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            
            if self.referenciaGuia == nil {
                self.referenciaGuia = motion.attitude.yaw
                self.filteredYaw = motion.attitude.yaw
                print(String(format: "Ref yaw magnético definida: %.3f rad", self.referenciaGuia ?? 0))
            }
            self.processDeviceMotion(motion)
        }
        
        localizacaoRodando = true
    }
    
    @MainActor
    func processDeviceMotion(_ motion: CMDeviceMotion) {
        let forwardAccel = motion.userAcceleration.y
        let rotation = motion.rotationRate
        
        let isRotatingWrist = abs(rotation.x) > ROTATION_LIMIT ||
        abs(rotation.y) > ROTATION_LIMIT ||
        abs(rotation.z) > ROTATION_LIMIT
        
        let alpha = 0.2
        filteredYaw = alpha * motion.attitude.yaw + (1 - alpha) * filteredYaw
        
        if forwardAccel > STEP_THRESHOLD_HIGH && !isStepInProgress && !isRotatingWrist {
            isStepInProgress = true
            
            guard let referenciaGuia = self.referenciaGuia else { return }
            var rel = filteredYaw - referenciaGuia
            
            while rel > .pi { rel -= 2 * .pi }
            while rel < -.pi { rel += 2 * .pi }
            
            accelWindow.append(forwardAccel)
            if accelWindow.count > windowSize {
                accelWindow.removeFirst()
            }
            
            let stepLength: Double
            if let maxA = accelWindow.max(), let minA = accelWindow.min() {
                let diff = maxA - minA
                stepLength = STEP_SCALE * sqrt(sqrt(max(0, diff)))
            } else {
                stepLength = STEP_SCALE
            }
            
            let deltaX = stepLength * cos(rel)
            let deltaY = stepLength * -sin(rel)
            
            DispatchQueue.main.async {
                
                self.stepCount += 1
                
                self.currentPosition.x += deltaX
                self.currentPosition.y += deltaY
                
                self.applyDriftCorrection()
                
                self.path.append(self.currentPosition)
                print(String(format: "STEP ok | relYaw: %.3f rad | step=%.2fm | Δ(%.2f, %.2f) | pos(%.2f, %.2f) | count=%d",
                             rel, stepLength, deltaX, deltaY,
                             self.currentPosition.x, self.currentPosition.y,
                             self.path.count))
            }
            
        } else if forwardAccel < STEP_THRESHOLD_LOW {
            isStepInProgress = false
        }
    }
    
    @MainActor
        func stopMotionUpdates() async -> (path: [[String: Double]], steps: Int) {
            motionManager.stopDeviceMotionUpdates()
            
            try? await Task.sleep(nanoseconds: 50_000_000)
            
            print("Treino finalizado. Pontos coletados: \(path.count). Passos contados: \(stepCount)")
            
            guard !path.isEmpty else { return (path: [], steps: 0) }
            
            serializablePath = path.map { ["x": Double($0.x), "y": Double($0.y)] }
            
            print("Serializable dentro da funcao stopMotion: \(serializablePath.count)")
            
            return (path: serializablePath, steps: self.stepCount)
        }
    }
