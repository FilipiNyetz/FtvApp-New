//
//  DayInfo.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 18/08/25.
//

import Foundation

// MARK: - Modelo de dados para cada dia

struct DayInfo {
    var hasCompletedTraining: Bool = false  // Se o usuário finalizou treino/jogo neste dia
    var gameTimes: [String] = []           // Horários dos jogos (ex: ["09:12", "11:46"])
    
    var hasGames: Bool {
        return !gameTimes.isEmpty
    }
}

// MARK: - Dados de exemplo

struct SampleData {
    static func createCalendarData() -> [Date: DayInfo] {
        var data: [Date: DayInfo] = [:]
        let calendar = Calendar.current
        
        // Exemplo para agosto de 2025
        let exampleMonth = calendar.date(from: DateComponents(year: 2025, month: 8, day: 1))!
        
        // Dias com treinos finalizados
        let trainingDays = [8]
        for day in trainingDays {
            let date = calendar.date(bySetting: .day, value: day, of: exampleMonth)!
            data[date] = DayInfo(hasCompletedTraining: true)
        }
        
        // Dia 8 com jogos
        let dayWithGames = calendar.date(bySetting: .day, value: 8, of: exampleMonth)!
        data[dayWithGames] = DayInfo(
            hasCompletedTraining: true,
            gameTimes: ["09:12", "11:46", "19:23", "20:57"]
        )
        
        return data
    }
}
