//
//  UserManager.swift
//  FtvApp
//
//  Created by Filipi Romão on 23/08/25.
//

import Foundation
import SwiftUI

class UserManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var bagdeNames: [String] = []
    @Published var goalBadge: Int = 10
    
    // Medalha pendente para ser exibida quando o app abrir
    @Published var pendingMedal: String? {
        didSet {
            if let m = pendingMedal {
                UserDefaults.standard.set(m, forKey: Self.pendingKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.pendingKey)
            }
        }
    }
    
    // ✅ NOVO: Lista de medalhas que o usuário já ganhou. É a chave da nova lógica.
    @Published var earnedMedals: [String] = [] {
        didSet {
            UserDefaults.standard.set(earnedMedals, forKey: Self.earnedMedalsKey)
        }
    }
    
    // MARK: - Keys for UserDefaults
    private static let pendingKey = "pendingMedal"
    private static let earnedMedalsKey = "earnedMedalsKey"
    
    // ✅ NOVO: Mapeamento centralizado de todas as metas e nomes de medalhas.
    // Isso remove a lógica duplicada e simplifica a verificação.
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
        // Carrega os dados salvos ao iniciar o app
        self.pendingMedal = UserDefaults.standard.string(forKey: Self.pendingKey)
        self.earnedMedals = UserDefaults.standard.stringArray(forKey: Self.earnedMedalsKey) ?? []
    }
    
    // MARK: - Medal Logic
    
    /// ✅ NOVO: Verifica se uma nova medalha foi conquistada com base no total de treinos.
    /// Retorna o nome da medalha a ser exibida, ou nil se nenhuma nova foi ganha.
    func checkForNewMedal(totalWorkouts: Int) -> String? {
        print("🔎 Verificando medalhas para \(totalWorkouts) treinos. Medalhas já ganhas: \(earnedMedals)")
        
        // Encontra a primeira medalha que o usuário atingiu a meta, mas que ainda não ganhou.
        if let newMedal = medalGoals.first(where: { goal in
            // Condição 1: O total de treinos é suficiente?
            let condition1 = totalWorkouts >= goal.requiredWorkouts
            // Condição 2: A medalha já foi ganha?
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
    
    /// ✅ NOVO: Adiciona uma medalha à lista de conquistadas e salva.
    func awardMedal(_ medalName: String) {
        guard !earnedMedals.contains(medalName) else { return }
        earnedMedals.append(medalName)
    }

    // MARK: - Badge Display Logic (UI)
    
    /// Define os ícones de badge atual e próximo a serem exibidos na ProgressBar.
    func setBadgeTotalWorkout(totalWorkouts: Int) {
        if totalWorkouts < 10 {
            bagdeNames = ["1stGoal", "2ndGoal"]
            goalBadge = 10
        } else if let nextGoalIndex = medalGoals.firstIndex(where: { totalWorkouts < $0.requiredWorkouts }) {
            // O usuário está entre duas metas
            let currentGoal = medalGoals[nextGoalIndex - 1]
            let nextGoal = medalGoals[nextGoalIndex]
            bagdeNames = [currentGoal.name, nextGoal.name]
            goalBadge = nextGoal.requiredWorkouts
        } else {
            // O usuário atingiu a última meta
            if let lastGoal = medalGoals.last {
                bagdeNames = [lastGoal.name, lastGoal.name] // Mostra a última medalha
                goalBadge = lastGoal.requiredWorkouts
            }
        }
    }
    
    /// Retorna o valor inicial da barra de progresso.
    func badgeStartValue() -> Int {
        // Encontra a maior meta que o usuário já alcançou
        if let lastAchievedGoal = medalGoals.last(where: { earnedMedals.contains($0.name) }) {
            return lastAchievedGoal.requiredWorkouts
        }
        // Se nenhuma foi alcançada (ou só a primeira), o início é 0
        return 0
    }

    // MARK: - Pending Medal Management
    func setPendingMedal(_ name: String) {
        pendingMedal = name
    }

    func clearPendingMedal() {
        pendingMedal = nil
    }
}
