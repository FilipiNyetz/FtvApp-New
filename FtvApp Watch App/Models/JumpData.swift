////
////  JumpData.swift
////  FtvApp Watch App
////
////  Modelo simples de dados de salto
////
//
//import Foundation
//
//// MARK: - Dados Simples do Salto
//
///// Dados básicos de um salto
//struct JumpData: Codable {
//    /// Altura do último salto em metros
//    let lastHeight: Double
//    
//    /// Altura do melhor salto em metros 
//    let bestHeight: Double
//    
//    /// Timestamp do salto
//    let timestamp: Date
//    
//    /// Inicializador simples
//    init(lastHeight: Double = 0.0,
//         bestHeight: Double = 0.0,
//         timestamp: Date = Date()) {
//        self.lastHeight = lastHeight
//        self.bestHeight = bestHeight
//        self.timestamp = timestamp
//    }
//}
//
//// MARK: - Extensões Úteis
//
//extension JumpData {
//    /// Altura do último salto em centímetros
//    var lastHeightCM: Double {
//        lastHeight * 100
//    }
//    
//    /// Altura do melhor salto em centímetros
//    var bestHeightCM: Double {
//        bestHeight * 100
//    }
//    
//    /// Verifica se é um salto válido
//    var isValidJump: Bool {
//        lastHeight > 0
//    }
//}
