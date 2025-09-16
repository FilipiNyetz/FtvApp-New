
import Foundation
import HealthKit

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
        if error != nil {
            completionHandler(0)
            return
        }
        
        let bpm = result?.averageQuantity()?.doubleValue(for: HKUnit.count().unitDivided(by: .minute())) ?? 0
        completionHandler(bpm) 
    }
    
    healthStore.execute(query)
}
