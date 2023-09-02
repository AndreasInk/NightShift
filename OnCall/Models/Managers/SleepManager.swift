//
//  SleepManager.swift
//  OnCall
//
//  Created by Andreas Ink on 8/22/23.
//

import SwiftUI
import HealthKit

class HealthManager {
    let healthStore = HKHealthStore()

    func requestPermission() async throws {
        let quantityTypes: [HKQuantityTypeIdentifier] = [
            .heartRate,
            .environmentalAudioExposure,
            .oxygenSaturation,
            .respiratoryRate
        ]
        let typesToRead: Set<HKObjectType> = Set(quantityTypes.compactMap { HKObjectType.quantityType(forIdentifier: $0) })
        let readTypes: Set<HKObjectType> = [HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!]
      
        
        return try await healthStore.requestAuthorization(toShare: [], read: typesToRead.union(readTypes))
    }
    
    func queryHealthData(typeIdentifier: HKQuantityTypeIdentifier, from startDate: Date, to endDate: Date) async throws -> [HKSample] {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: typeIdentifier) else {
            throw CustomError.invalidType // Replace with appropriate error handling
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let anchorDescriptor =
        HKAnchoredObjectQueryDescriptor(
            predicates: [.quantitySample(type: quantityType)],
                anchor: nil)
        
        
        let results = try await anchorDescriptor.result(for: healthStore)
        
        let samples = results.addedSamples
        return samples
    }

    func querySleepData(from startDate: Date, to endDate: Date) async throws -> [SleepData] {
        let bloodOxygenSamples = try await queryHealthData(typeIdentifier: .oxygenSaturation, from: startDate, to: endDate)

        let heartRateSamples = try await queryHealthData(typeIdentifier: .heartRate, from: startDate, to: endDate)
        let respirationRateSamples = try await queryHealthData(typeIdentifier: .respiratoryRate, from: startDate, to: endDate)

        let decibelSamples = try await queryHealthData(typeIdentifier: .environmentalAudioExposure, from: startDate, to: endDate)

        // Define the sleep analysis type
      

        // Create the predicate for the date range
      
        let anchorDescriptor =
        HKAnchoredObjectQueryDescriptor(
            predicates: [.categorySample(type: .init(.sleepAnalysis))],
                anchor: nil)
        
        
        let results = try await anchorDescriptor.result(for: healthStore)
        
        let sleepSamples = results.addedSamples

        // Map sleep samples and other health metrics to the SleepData struct
        let sleepData = sleepSamples.map { sample in
            SleepData(
                date: sample.startDate,
                bloodOxygen: valueForDate(bloodOxygenSamples, date: sample.startDate, unit: .percent()), // Example mapping function
                heartRate: valueForDate(heartRateSamples, date: sample.startDate, unit: .count().unitDivided(by: .minute())), // Example mapping function
                respirationRate: valueForDate(respirationRateSamples, date: sample.startDate, unit: .count().unitDivided(by: .minute())), // Example mapping function
                decibels: valueForDate(decibelSamples, date: sample.startDate, unit: .decibelHearingLevel())
            )
        }

        return sleepData
    }

    func valueForDate(_ samples: [HKSample], date: Date, unit: HKUnit) -> Double {
        guard let quantitySamples = samples as? [HKQuantitySample] else {
            return 0
        }
        
        // Find the sample that matches the date
        if let matchingSample = quantitySamples.first(where: { sample in
            // You may need to adjust the comparison based on how precisely the dates need to match
            return Calendar.current.isDate(sample.startDate, equalTo: date, toGranularity: .hour)
        }) {
            // Extract and return the quantity value for the matching sample
            return matchingSample.quantity.doubleValue(for: unit)
        }
        
        return 0
    }

}
struct SleepData {
    var date: Date
    var bloodOxygen: Double
    var heartRate: Double
    var respirationRate: Double
    var decibels: Double
}
struct CustomError: Error {
    static let invalidType = CustomError()
}
