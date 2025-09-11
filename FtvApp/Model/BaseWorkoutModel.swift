//
//  BaseWorkoutModel.swift
//  FtvApp
//

import Foundation
import SwiftData

// MARK: - Estrutura de um ponto do trajeto
struct PathPoint: Codable {
    let x: Double
    let y: Double
}

// MARK: - WorkoutExtras - Dados extras do workout (pulos e trajeto)
@Model
final class WorkoutExtras: @unchecked Sendable {
    @Attribute(.unique) var workoutID: String   // UUID string do HKWorkout
    var higherJump: Double?                     // maior pulo do treino
    var pointPath: [[Double]]?                  // trajeto como array de pares [x,y]
    var updatedAt: Date
    
    init(workoutID: String, higherJump: Double? = nil, pointPath: [[Double]]? = nil) {
        self.workoutID = workoutID
        self.higherJump = higherJump
        self.pointPath = pointPath
        self.updatedAt = Date()
    }
}

// MARK: - Pulos (mantido para compatibilidade e referência histórica)
@Model
final class JumpEntity {
    @Attribute(.unique) var id: UUID
    var workoutId: UUID        // UUID do workout no HealthKit
    var height: Double
    var date: Date
    
    init(height: Double, date: Date, workoutId: UUID) {
        self.id = UUID()
        self.height = height
        self.date = date
        self.workoutId = workoutId
    }
}

// MARK: - Trajetória do workout (mantido para compatibilidade)
@Model
final class WorkoutPathEntity {
    @Attribute(.unique) var id: UUID
    var workoutId: UUID
    var pathData: Data          // Array de PathPoint serializado
    var createdAt: Date
    
    init(workoutId: UUID, path: [PathPoint]) {
        self.id = UUID()
        self.workoutId = workoutId
        self.createdAt = Date()
        
        // Codifica o array de pontos em JSON
        let encoder = JSONEncoder()
        self.pathData = (try? encoder.encode(path)) ?? Data()
    }
    
    // Helper para decodificar o array de pontos
    func decodedPath() -> [PathPoint] {
        let decoder = JSONDecoder()
        return (try? decoder.decode([PathPoint].self, from: pathData)) ?? []
    }
}

// MARK: - Modelo temporário para exibição
// Não será salvo no SwiftData, apenas usado para agrupar os dados
struct Workout {
    let id: UUID                 // UUID do HealthKit workout
    let idWorkoutType: Int
    let duration: Double
    let calories: Int
    let distance: Int
    let frequencyHeart: Double
    let dateWorkout: Date
    let higherJump: Double?
    let pointsPath: [[Double]]   // Convertido de WorkoutPathEntity
}
