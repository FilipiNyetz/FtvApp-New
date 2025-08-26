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
    
    let hrPredicate = HKQuery.predicateForObjects(from: workout)
    
    let hrQuery = HKSampleQuery(
        sampleType: heartRateType,
        predicate: hrPredicate,
        limit: HKObjectQueryNoLimit,
        sortDescriptors: nil
    ) { _, samples, error in
        
        guard error == nil else {
            print("Erro ao buscar frequências cardíacas: \(error!.localizedDescription)")
            completionHandler(0)
            return
        }
        
        guard let hrSamples = samples as? [HKQuantitySample], !hrSamples.isEmpty else {
            completionHandler(0)
            return
        }
        
        let total = hrSamples.reduce(0.0) { partial, sample in
            let bpm = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            return partial + bpm
        }
        
        let media = total / Double(hrSamples.count)
        completionHandler(media)
    }
    
    healthStore.execute(hrQuery)
}
