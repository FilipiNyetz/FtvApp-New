////
////  BaseWorkoutModel.swift
////  FtvApp
////
////  Created by Filipi Romão on 14/08/25.
////

import Foundation


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
