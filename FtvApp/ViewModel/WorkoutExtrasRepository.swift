
import Foundation
import SwiftData

protocol WorkoutExtrasStoring {
    func upsertHigherJump(_ jump: Double, for workoutID: String) async throws
    func upsertPointPath(_ path: [[Double]], for workoutID: String) async throws
    func upsertStepCount(_ stepCount: Int, for workoutID: String) async throws 
    func fetchExtrasMap(for workoutIDs: [String]) async throws -> [String: WorkoutExtras]
}

final class WorkoutExtrasRepository: WorkoutExtrasStoring {
    
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }

    @MainActor
    private func fetchOrCreateExtras(for workoutID: String) throws -> WorkoutExtras {
        let predicate = #Predicate<WorkoutExtras> { $0.workoutID == workoutID }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let existing = try container.mainContext.fetch(descriptor).first {
            return existing
        } else {
            let newExtras = WorkoutExtras(workoutID: workoutID)
            container.mainContext.insert(newExtras)
            print("🆕 Criado novo WorkoutExtras para o workoutID \(workoutID)")
            return newExtras
        }
    }
    
    
    @MainActor
    func upsertStepCount(_ stepCount: Int, for workoutID: String) async throws {
        let extras = try fetchOrCreateExtras(for: workoutID)
        
        extras.stepCount = stepCount
        extras.updatedAt = Date()
        
        try container.mainContext.save()
        print("💾 Salvo/Atualizado stepCount \(stepCount) para workoutID \(workoutID)")
    }
    
    @MainActor
    func upsertHigherJump(_ jump: Double, for workoutID: String) async throws {
        let extras = try fetchOrCreateExtras(for: workoutID)
        
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
        
        return results.reduce(into: [String: WorkoutExtras]()) { map, extras in
            map[extras.workoutID] = extras
        }
    }
}
