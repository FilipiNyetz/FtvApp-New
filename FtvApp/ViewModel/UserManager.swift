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
    
    func setBadgeTotalWorkout(totalWorkouts: Int){
        switch totalWorkouts {
        case totalWorkouts where totalWorkouts < 10:
            bagdeNames = ["1stGoal", "2ndGoal"]
            print("O icone vai ser um")
        case totalWorkouts where totalWorkouts < 50:
            bagdeNames = ["2ndGoal", "3rdGoal"]
            print("O icone vai ser dois")
        case totalWorkouts where totalWorkouts < 150:
            bagdeNames = ["3rdGoal", "4thGoal"]
            print("O icone vai ser tres")
        case totalWorkouts where totalWorkouts < 250:
            bagdeNames = ["4thGoal", "5thGoal"]
            print("O icone vai ser quatro")
        case totalWorkouts where totalWorkouts < 350:
            bagdeNames = ["5thGoal", "6thGoal"]
            print("O icone vai ser cinco")
        case totalWorkouts where totalWorkouts < 500:
            bagdeNames = ["6thGoal", "7thGoal"]
            print("O icone vai ser seis")
        case totalWorkouts where totalWorkouts < 650:
            bagdeNames = ["7thGoal", "8thGoal"]
            print("O icone vai ser sete")
        case totalWorkouts where totalWorkouts < 750:
            bagdeNames = ["8thGoal", "9thGoal"]
            print("O icone vai ser 8")
        case totalWorkouts where totalWorkouts < 850:
            bagdeNames = ["9thGoal", "10thGoal"]
            print("O icone vai ser nove")
        case totalWorkouts where totalWorkouts < 1000:
            bagdeNames = ["10thGoal", "11thGoal"]
            print("O icone vai ser 10")
        default :
            print("O icone vai ser 11")
        }
    }
    
    
}
