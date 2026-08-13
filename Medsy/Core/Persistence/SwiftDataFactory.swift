//
//  SwiftDataFactory.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

import Foundation
import SwiftData

struct SwiftDataStoreConfiguration: Hashable {
    let name: String
    let isStoredInMemoryOnly: Bool

    static func persistent(name: String) -> SwiftDataStoreConfiguration {
        SwiftDataStoreConfiguration(name: name, isStoredInMemoryOnly: false)
    }

    static func inMemory(name: String = UUID().uuidString) -> SwiftDataStoreConfiguration {
        SwiftDataStoreConfiguration(name: name, isStoredInMemoryOnly: true)
    }
}

final class SwiftDataFactory {
    static let shared = SwiftDataFactory()

    private var containers: [String: ModelContainer] = [:]
    private let lock = NSLock()

    private init() {}

    func makeContainer(
        for schema: Schema,
        configuration: SwiftDataStoreConfiguration
    ) throws -> ModelContainer {
        if !configuration.isStoredInMemoryOnly {
            lock.lock()
            defer { lock.unlock() }

            if let existing = containers[configuration.name] {
                return existing
            }

            let container = try buildContainer(for: schema, configuration: configuration)
            containers[configuration.name] = container
            return container
        }

        return try buildContainer(for: schema, configuration: configuration)
    }

    private func buildContainer(
        for schema: Schema,
        configuration: SwiftDataStoreConfiguration
    ) throws -> ModelContainer {
        let modelConfiguration = ModelConfiguration(
            configuration.name,
            schema: schema,
            isStoredInMemoryOnly: configuration.isStoredInMemoryOnly
        )
        return try ModelContainer(for: schema, configurations: modelConfiguration)
    }
}
