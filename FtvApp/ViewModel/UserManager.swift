//
//  UserViewModel.swift
//  FtvApp
//
//  Created by Filipi Romão on 23/08/25.
//

import Foundation
import SwiftUI

class UserManager: ObservableObject {

    @Published var bagdeNames: [String] = []
    @Published var goalBadge: Int = 10
    @Published var pendingMedal: String? {
        didSet {
            if let m = pendingMedal {
                UserDefaults.standard.set(m, forKey: Self.pendingKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.pendingKey)
            }
        }
    }
    @Published var lastUnlockedGoal: Int {
        didSet {
            UserDefaults.standard.set(lastUnlockedGoal, forKey: "lastUnlockedGoal")
        }
    }

    static let pendingKey = "pendingMedal"

    init() {
        pendingMedal = UserDefaults.standard.string(forKey: Self.pendingKey)
        lastUnlockedGoal = UserDefaults.standard.integer(forKey: "lastUnlockedGoal")
    }
    
    func setBadgeTotalWorkout(totalWorkouts: Int) {
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
        default:
            print("O icone vai ser 11")
        }
    }

    func badgeStartValue() -> Int {
        switch bagdeNames.first {
        case "2ndGoal": return 10
        case "3rdGoal": return 50
        case "4thGoal": return 150
        case "5thGoal": return 250
        case "6thGoal": return 350
        case "7thGoal": return 500
        case "8thGoal": return 650
        case "9thGoal": return 750
        case "10thGoal": return 850
        case "11thGoal": return 1000
        default: return 0
        }
    }
    func nextGoalBadge(for totalWorkouts: Int) -> Int {
        switch totalWorkouts {
        case ..<10: return 10
        case ..<50: return 50
        case ..<150: return 150
        case ..<250: return 250
        case ..<350: return 350
        case ..<500: return 500
        case ..<650: return 650
        case ..<750: return 750
        case ..<850: return 850
        case ..<1000: return 1000
        default: return 0
        }
    }

    func setPendingMedal(_ name: String) {
        pendingMedal = name
    }

    func clearPendingMedal() {
        pendingMedal = nil
    }

}
