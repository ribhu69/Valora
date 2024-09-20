//
//  ValoraApp.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 20/09/24.
//

import SwiftUI
import SwiftData

@main
struct ValoraApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Credential.self
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
            ValoraTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
