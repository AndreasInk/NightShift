//
//  OnCallApp.swift
//  OnCall
//
//  Created by Andreas Ink on 8/22/23.
//

import SwiftUI
import SwiftData

// An app that wakes up the person in a lighter sleep stage
// For parents with a newborn baby or caregivers with a sick or elderly person

@main
struct OnCallApp: App {
    @StateObject var viewModel = ViewModel()
    @Environment(\.scenePhase) var scenePhase
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Schedule.self,
            Person.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(viewModel)
    }
}
