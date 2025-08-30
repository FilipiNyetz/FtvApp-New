////
////  BaseWorkoutModel.swift
////  FtvApp
////
////  Created by Filipi Romão on 14/08/25.
////

import Foundation
import SwiftData


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

struct Workout: Identifiable, Hashable{
    let id: UUID
    let idWorkoutType: Int
    let duration: TimeInterval
    let calories: Int
    let distance: Int
    let frequencyHeart: Double
    let dateWorkout: Date
    let higherJump: Double?
}
