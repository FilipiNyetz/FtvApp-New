////
////  BaseWorkoutModel.swift
////  FtvApp
////
////  Created by Filipi Romão on 14/08/25.
////
//
import Foundation
import SwiftData
//
//struct Workout: Identifiable{
//    let id: UUID
//    let idWorkoutType: Int
//    let duration: Int
//    let calories: Int
//    let distance: Int
//    let frequencyHeart: Double
//DataTreino: Date
//}

@Model
class WorkoutModel: @unchecked Sendable{
    @Attribute(.unique)
    var id: UUID = UUID()
    
    var idWorkoutType: Int
    var dataWorkout: Date
    var duration: Int
    var calories: Int
    var distance: Int
    var frequencyHeart: Double
    
    init(idWorkoutType: Int, dataWorkout: Date,  duration: Int, calories: Int, distance: Int, frequencyHeart: Double) {
        self.idWorkoutType = idWorkoutType
        self.dataWorkout = dataWorkout
        self.duration = duration
        self.calories = calories
        self.distance = distance
        self.frequencyHeart = frequencyHeart
       
    }
}


