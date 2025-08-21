//
//  DataPoint.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
//
import Foundation

struct DataPoint: Identifiable {
    let date: Date
    let value: Double
    var id: Date { date }
}
