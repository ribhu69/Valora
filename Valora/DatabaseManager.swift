//
//  DatabaseManager.swift
//  Valora
//
//  Created by Arkaprava Ghosh on 21/09/24.
//

import Foundation
import SwiftData

class DatabaseManager {
    
    static let shared = DatabaseManager()
    var context : ModelContext
    var sharedContainer: ModelContainer = {
        let schema = Schema(
            [
                Credential.self,
            ]
        )
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    private init() {
        self.context = .init(sharedContainer)
    }

    func getModelContext() -> ModelContext {
        return context
    }
    
    func getContainer() -> ModelContainer {
        return sharedContainer
    }
}
