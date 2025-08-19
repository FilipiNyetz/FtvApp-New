//
//  DataManager.swift
//  FtvApp
//
//  Created by Filipi Romão on 18/08/25.
//

import Foundation
import SwiftData

class DataManager: ObservableObject {
    
    @MainActor
    func saveOnDB(context: ModelContext, workouts: [WorkoutModel], numberOfWorkoutsSaveds: Int) async throws {
        print("Chama o save")
        
        
        for workout in workouts {
            print(workout.distance)
        }
        print("Total de workouts que chegaram na func: \(workouts.count)")
        print("Total de treinos já salvos: \(numberOfWorkoutsSaveds)")
        
        
        guard numberOfWorkoutsSaveds < workouts.count else {
            print("Nenhum treino novo para salvar")
            return
        }

        for workout in workouts[numberOfWorkoutsSaveds...] {
            // insere direto (ou checa duplicado antes)
            context.insert(workout)
            do {
                print("Tentando salvar um treino")
                try context.save()
                print("Treino salvo com sucesso!")
            } catch {
                print("Erro ao salvar: \(error.localizedDescription)")
            }
        }
    }

    
    
}
