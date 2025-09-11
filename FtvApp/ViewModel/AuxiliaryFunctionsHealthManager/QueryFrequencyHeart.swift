//
//  QueryFrequenciaCardiaca.swift
//  BeActiv
//
//  Created by Filipi Romão on 25/08/25.
//

import Foundation
import HealthKit

/// Consulta frequência cardíaca de um workout específico.
/// Retorna a média em BPM.
func queryFrequenciaCardiaca(
    workout: HKWorkout,
    healthStore: HKHealthStore,
    completionHandler: @escaping (Double) -> Void
) {
    guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
        completionHandler(0)
        return
    }
    
    let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate)
    
    let query = HKStatisticsQuery(
        quantityType: heartRateType,
        quantitySamplePredicate: predicate,
        options: .discreteAverage
    ) { _, result, error in
        if let error = error {
//            print("Erro ao buscar frequência cardíaca: \(error.localizedDescription)")
            completionHandler(0)
            return
        }
        
        let bpm = result?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
        completionHandler(bpm) // Chamado apenas uma vez por treino
    }
    
    healthStore.execute(query)
}
