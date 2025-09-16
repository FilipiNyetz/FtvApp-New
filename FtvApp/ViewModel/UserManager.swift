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
    
    @Published var earnedMedals: [String] = [] {
        didSet {
            UserDefaults.standard.set(earnedMedals, forKey: Self.earnedMedalsKey)
        }
    }
    
    private static let pendingKey = "pendingMedal"
    private static let earnedMedalsKey = "earnedMedalsKey"
    
    private let medalGoals: [(name: String, requiredWorkouts: Int)] = [
        ("2ndGoal", 10),
        ("3rdGoal", 50),
        ("4thGoal", 150),
        ("5thGoal", 250),
        ("6thGoal", 350),
        ("7thGoal", 500),
        ("8thGoal", 650),
        ("9thGoal", 750),
        ("10thGoal", 850),
        ("11thGoal", 1000)
    ]

    init() {
        self.pendingMedal = UserDefaults.standard.string(forKey: Self.pendingKey)
        self.earnedMedals = UserDefaults.standard.stringArray(forKey: Self.earnedMedalsKey) ?? []
    }
    
    
    func checkForNewMedal(totalWorkouts: Int) -> String? {
        print("🔎 Verificando medalhas para \(totalWorkouts) treinos. Medalhas já ganhas: \(earnedMedals)")
        
        if let newMedal = medalGoals.first(where: { goal in
            let condition1 = totalWorkouts >= goal.requiredWorkouts
            let condition2 = !earnedMedals.contains(goal.name)
            
            if condition1 && !condition2 {
                print("  - Checando meta '\(goal.name)': O usuário tem treinos suficientes, MAS JÁ GANHOU esta medalha.")
            }
            
            return condition1 && condition2
        }) {
            print("  -> Encontrou medalha para premiar: \(newMedal.name)")
            return newMedal.name
        }
        
        print("  -> Nenhuma medalha nova encontrada.")
        return nil
    }
    
    func awardMedal(_ medalName: String) {
        guard !earnedMedals.contains(medalName) else { return }
        earnedMedals.append(medalName)
    }

    
    func setBadgeTotalWorkout(totalWorkouts: Int) {
        if totalWorkouts < 10 {
            bagdeNames = ["1stGoal", "2ndGoal"]
            goalBadge = 10
        } else if let nextGoalIndex = medalGoals.firstIndex(where: { totalWorkouts < $0.requiredWorkouts }) {
            let currentGoal = medalGoals[nextGoalIndex - 1]
            let nextGoal = medalGoals[nextGoalIndex]
            bagdeNames = [currentGoal.name, nextGoal.name]
            goalBadge = nextGoal.requiredWorkouts
        } else {
            if let lastGoal = medalGoals.last {
                bagdeNames = [lastGoal.name, lastGoal.name] 
                goalBadge = lastGoal.requiredWorkouts
            }
        }
    }
    
    func badgeStartValue() -> Int {
        if let lastAchievedGoal = medalGoals.last(where: { earnedMedals.contains($0.name) }) {
            return lastAchievedGoal.requiredWorkouts
        }
        return 0
    }

    func setPendingMedal(_ name: String) {
        pendingMedal = name
    }

    func clearPendingMedal() {
        pendingMedal = nil
    }
}
