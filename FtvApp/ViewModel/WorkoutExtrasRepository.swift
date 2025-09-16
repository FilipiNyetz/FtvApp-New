//
//  WorkoutExtrasRepository.swift
//  FtvApp
//
//  Repository para gerenciar dados extras dos workouts (higherJump e pointPath)
//  Segue o padrão de persistir primeiro, depois buscar para evitar corridas
//

import Foundation
import SwiftData

/// Protocolo para abstração do acesso aos dados extras dos workouts
protocol WorkoutExtrasStoring {
    func upsertHigherJump(_ jump: Double, for workoutID: String) async throws
    func upsertPointPath(_ path: [[Double]], for workoutID: String) async throws
    func upsertStepCount(_ stepCount: Int, for workoutID: String) async throws // Adicione ao protocolo
    func fetchExtrasMap(for workoutIDs: [String]) async throws -> [String: WorkoutExtras]
}

/// Repository centralizado para WorkoutExtras
final class WorkoutExtrasRepository: WorkoutExtrasStoring {
    
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }

    @MainActor
    private func fetchOrCreateExtras(for workoutID: String) throws -> WorkoutExtras {
        let predicate = #Predicate<WorkoutExtras> { $0.workoutID == workoutID }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        // Tenta buscar um objeto existente
        if let existing = try container.mainContext.fetch(descriptor).first {
            return existing
        } else {
            // Se não encontrar, cria um novo, insere no contexto e retorna
            let newExtras = WorkoutExtras(workoutID: workoutID)
            container.mainContext.insert(newExtras)
            print("🆕 Criado novo WorkoutExtras para o workoutID \(workoutID)")
            return newExtras
        }
    }
    
    // ==================================================================
    // PASSO 2: SIMPLIFIQUE TODAS AS FUNÇÕES "UPSERT" USANDO A FUNÇÃO AUXILIAR
    // ==================================================================
    
    @MainActor
    func upsertStepCount(_ stepCount: Int, for workoutID: String) async throws {
        // Agora esta chamada funciona
        let extras = try fetchOrCreateExtras(for: workoutID)
        
        extras.stepCount = stepCount
        extras.updatedAt = Date()
        
        try container.mainContext.save()
        print("💾 Salvo/Atualizado stepCount \(stepCount) para workoutID \(workoutID)")
    }
    
    @MainActor
    func upsertHigherJump(_ jump: Double, for workoutID: String) async throws {
        let extras = try fetchOrCreateExtras(for: workoutID)
        
        // Atualiza apenas se o novo pulo for maior ou se não houver um pulo atual
        if let currentJump = extras.higherJump {
            extras.higherJump = max(currentJump, jump)
        } else {
            extras.higherJump = jump
        }
        extras.updatedAt = Date()
        
        try container.mainContext.save()
        print("✅ Salvo/Atualizado higherJump para workoutID \(workoutID)")
    }
    
    @MainActor
    func upsertPointPath(_ path: [[Double]], for workoutID: String) async throws {
        let extras = try fetchOrCreateExtras(for: workoutID)
        
        extras.pointPath = path
        extras.updatedAt = Date()
        
        try container.mainContext.save()
        print("✅ Salvo/Atualizado pointPath para workoutID \(workoutID)")
    }
    
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
        
        // Converte o array de resultados em um dicionário para busca rápida
        return results.reduce(into: [String: WorkoutExtras]()) { map, extras in
            map[extras.workoutID] = extras
        }
    }
}
