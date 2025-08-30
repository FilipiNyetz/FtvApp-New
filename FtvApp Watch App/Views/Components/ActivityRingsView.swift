//
//  ActivityRingsView.swift
//  FtvApp Watch App
//
//  Created by Gustavo Souto Pereira on 14/08/25.
//

import Foundation
import HealthKit
import SwiftUI
import WatchKit

struct ActivityRingsView: WKInterfaceObjectRepresentable {
    
    let healthStore: HKHealthStore
    
    func makeWKInterfaceObject(context: Context) -> WKInterfaceActivityRing {
        let activityRingsObject = WKInterfaceActivityRing()
        
        startActivityRingsUpdates(activityRingsObject)
        
        return activityRingsObject
    }
    
    func updateWKInterfaceObject(_ wkInterfaceObject: WKInterfaceActivityRing, context: Context) {
    }
    
    private func startActivityRingsUpdates(_ activityRingsObject: WKInterfaceActivityRing) {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.era, .year, .month, .day], from: Date())
        components.calendar = calendar
        
        let predicate = HKQuery.predicateForActivitySummary(with: components)
        
        let query = HKActivitySummaryQuery(predicate: predicate) { _, summaries, _ in
            DispatchQueue.main.async {
                activityRingsObject.setActivitySummary(summaries?.first, animated: true)
            }
        }
        
        query.updateHandler = { _, summaries, _ in
            DispatchQueue.main.async {
                activityRingsObject.setActivitySummary(summaries?.first, animated: true)
            }
        }
        
        healthStore.execute(query)
    }
}

