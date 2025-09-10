////
////  BaseWorkoutModel.swift
////  FtvApp
////
////  Created by Filipi Romão on 14/08/25.
////

import Foundation
import SwiftData


struct PathPoint: Codable {
    let x: Double
    let y: Double
}

@Model
final class JumpEntity {
    @Attribute(.unique) var id: UUID
    var workoutId: UUID  // UUID do workout no HealthStore
    var height: Double
    var date: Date
    
    init(height: Double, date: Date, workoutId: UUID) {
        self.id = UUID()
        self.height = height
        self.date = date
        self.workoutId = workoutId
    }
}

@Model
final class WorkoutPathEntity {
    @Attribute(.unique) var id: UUID
    var workoutId: UUID
    var pathData: Data  // aqui fica o array serializado
    var createdAt: Date
    
    init(workoutId: UUID, path: [PathPoint]) {
        self.id = UUID()
        self.workoutId = workoutId
        self.createdAt = Date()
        
        // Codifica o array de pontos em JSON
        let encoder = JSONEncoder()
        self.pathData = (try? encoder.encode(path)) ?? Data()
    }
    
    // Helper para recuperar o array de pontos
    func decodedPath() -> [PathPoint] {
        let decoder = JSONDecoder()
        return (try? decoder.decode([PathPoint].self, from: pathData)) ?? []
    }
}

struct Workout: Identifiable, Hashable, Codable{
    let id: UUID
    let idWorkoutType: Int
    let duration: TimeInterval
    let calories: Int
    let distance: Int
    let frequencyHeart: Double
    let dateWorkout: Date
    let higherJump: Double?
    let pointsPath: [[Double]]
}
