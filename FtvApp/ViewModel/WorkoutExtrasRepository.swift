//
//  WorkoutExtrasRepository.swift
//  FtvApp
//
//  Repository para gerenciar dados extras dos workouts (higherJump e pointPath)
//  Segue o padrão de persistir primeiro, depois buscar para evitar corridas
//

import Foundation
import SwiftData

/// Protocol para abstração do acesso aos dados extras dos workouts
protocol WorkoutExtrasStoring {
    func upsertHigherJump(_ jump: Double, for workoutID: String) async throws
    func upsertPointPath(_ path: [[Double]], for workoutID: String) async throws
    func fetchExtrasMap(for workoutIDs: [String]) async throws -> [String: WorkoutExtras]
}

/// Repository centralizado para WorkoutExtras
final class WorkoutExtrasRepository: WorkoutExtrasStoring {
    
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    /// Upsert (insert ou update) do higherJump para um workout
    /// - Parameters:
    ///   - jump: Valor do pulo em centímetros
    ///   - workoutID: UUID string do workout
    @MainActor
    func upsertHigherJump(_ jump: Double, for workoutID: String) async throws {
        let descriptor = FetchDescriptor<WorkoutExtras>(
            predicate: #Predicate<WorkoutExtras> { $0.workoutID == workoutID }
        )
        
        let existing = try container.mainContext.fetch(descriptor).first
        
        if let workoutExtras = existing {
            // Atualiza apenas se o novo pulo for maior
            if let currentJump = workoutExtras.higherJump {
                workoutExtras.higherJump = max(currentJump, jump)
            } else {
                workoutExtras.higherJump = jump
            }
            workoutExtras.updatedAt = Date()
            print("♻️ Atualizado higherJump existente: \(workoutExtras.higherJump ?? 0) para workoutID \(workoutID)")
        } else {
            // Cria nova entrada
            let newExtras = WorkoutExtras(workoutID: workoutID, higherJump: jump)
            container.mainContext.insert(newExtras)
            print("🆕 Criado WorkoutExtras com higherJump: \(jump) para workoutID \(workoutID)")
        }
        
        try container.mainContext.save()
        print("✅ HigherJump salvo para workoutID \(workoutID)")
    }
    
    /// Upsert (insert ou update) do pointPath para um workout
    /// - Parameters:
    ///   - path: Array de pontos como [[x, y]]
    ///   - workoutID: UUID string do workout
    @MainActor
    func upsertPointPath(_ path: [[Double]], for workoutID: String) async throws {
        let descriptor = FetchDescriptor<WorkoutExtras>(
            predicate: #Predicate<WorkoutExtras> { $0.workoutID == workoutID }
        )
        
        let existing = try container.mainContext.fetch(descriptor).first
        
        if let workoutExtras = existing {
            // Atualiza path existente
            workoutExtras.pointPath = path
            workoutExtras.updatedAt = Date()
            print("♻️ Atualizado pointPath existente com \(path.count) pontos para workoutID \(workoutID)")
        } else {
            // Cria nova entrada
            let newExtras = WorkoutExtras(workoutID: workoutID, pointPath: path)
            container.mainContext.insert(newExtras)
            print("🆕 Criado WorkoutExtras com pointPath: \(path.count) pontos para workoutID \(workoutID)")
        }
        
        try container.mainContext.save()
        print("✅ PointPath salvo para workoutID \(workoutID)")
    }
    
    /// Busca extras para múltiplos workouts em uma única query
    /// - Parameter workoutIDs: Array de UUIDs string dos workouts
    /// - Returns: Dicionário mapeando workoutID → WorkoutExtras
    @MainActor
    func fetchExtrasMap(for workoutIDs: [String]) async throws -> [String: WorkoutExtras] {
        guard !workoutIDs.isEmpty else { return [:] }
        
        let descriptor = FetchDescriptor<WorkoutExtras>(
            predicate: #Predicate<WorkoutExtras> { workoutExtras in
                workoutIDs.contains(workoutExtras.workoutID)
            }
        )
        
        let results = try container.mainContext.fetch(descriptor)
        print("📦 Encontrados \(results.count) WorkoutExtras para \(workoutIDs.count) workoutIDs")
        
        var extrasMap: [String: WorkoutExtras] = [:]
        for extras in results {
            extrasMap[extras.workoutID] = extras
        }
        
        return extrasMap
    }
}
