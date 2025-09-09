//
//  CalibrationManager.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 05/09/25.
//

import Foundation
import Foundation
import CoreMotion

class CalibrationManager: ObservableObject {
    static let shared = CalibrationManager()
    
    @Published var isCalibrated: Bool = false
    @Published var baselineGravity: Double = 0.0
    @Published var sensitivity: Double = 0.0
    
    private let motionManager = CMMotionManager()
    
    private init() {
        loadCalibration()
    }
    
    func startCalibration(completion: @escaping () -> Void) {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
            guard let motion = motion else { return }
            
            // Captura o valor médio da gravidade no eixo Z como baseline
            self.baselineGravity = motion.gravity.z
            // Define sensibilidade inicial com base em aceleração média
            self.sensitivity = max(0.2, abs(motion.userAcceleration.z) + 0.05)
            
            self.isCalibrated = true
            self.saveCalibration()
            self.motionManager.stopDeviceMotionUpdates()
            completion()
        }
    }
    
    private func saveCalibration() {
        let defaults = UserDefaults.standard
        defaults.set(baselineGravity, forKey: "baselineGravity")
        defaults.set(sensitivity, forKey: "sensitivity")
        defaults.set(isCalibrated, forKey: "isCalibrated")
    }
    
    private func loadCalibration() {
        let defaults = UserDefaults.standard
        self.baselineGravity = defaults.double(forKey: "baselineGravity")
        self.sensitivity = defaults.double(forKey: "sensitivity")
        self.isCalibrated = defaults.bool(forKey: "isCalibrated")
    }
}
