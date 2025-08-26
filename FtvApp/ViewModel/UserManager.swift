//
//  UserViewModel.swift
//  FtvApp
//
//  Created by Filipi Romão on 23/08/25.
//

import Foundation
import SwiftUI

class UserManager: ObservableObject{
    
    @Published var bagdeNames: [String] = []
    @Published var goalBadge: Int = 10
    
    func setBadgeTotalWorkout(totalWorkouts: Int){
        switch totalWorkouts {
        case totalWorkouts where totalWorkouts < 10:
            bagdeNames = ["1stGoal", "2ndGoal"]
            
            
        case totalWorkouts where totalWorkouts < 50:
            bagdeNames = ["2ndGoal", "3rdGoal"]
            goalBadge = 50
            
        case totalWorkouts where totalWorkouts < 150:
            bagdeNames = ["3rdGoal", "4thGoal"]
            goalBadge = 150
            
        case totalWorkouts where totalWorkouts < 250:
            bagdeNames = ["4thGoal", "5thGoal"]
            goalBadge = 250
            
        case totalWorkouts where totalWorkouts < 350:
            bagdeNames = ["5thGoal", "6thGoal"]
            goalBadge = 350
            
        case totalWorkouts where totalWorkouts < 500:
            bagdeNames = ["6thGoal", "7thGoal"]
            goalBadge = 500
            
        case totalWorkouts where totalWorkouts < 650:
            bagdeNames = ["7thGoal", "8thGoal"]
            goalBadge = 650
        case totalWorkouts where totalWorkouts < 750:
            bagdeNames = ["8thGoal", "9thGoal"]
            goalBadge = 750
            
        case totalWorkouts where totalWorkouts < 850:
            bagdeNames = ["9thGoal", "10thGoal"]
            goalBadge = 850
            
        case totalWorkouts where totalWorkouts < 1000:
            bagdeNames = ["10thGoal", "11thGoal"]
            goalBadge = 1000
        default :
            print("O icone vai ser 11")
        }
    }
    
    
}
