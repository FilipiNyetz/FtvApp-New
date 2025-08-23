//
//  JumpConfiguration.swift
//  FtvApp Watch App
//
//  Configuração simples para detecção de saltos no futevôlei
//

import Foundation

// MARK: - Configuração Simples

/// Configuração otimizada para futevôlei (mantida para compatibilidade)
struct JumpConfiguration {
    
    // Parâmetros otimizados para futevôlei
    let freefallThreshold: Double = 0.30    // Detecta início do salto
    let groundThreshold: Double = 1.25      // Detecta pouso
    let minSamples: Int = 3                 // Confirmação mínima
    
    /// Configuração padrão
    static let `default` = JumpConfiguration()
}