//
//  PharmacyDIContainer.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

@MainActor
final class PharmacyDIContainer {
    typealias Factory = (PharmacyDIContainer) -> Any

    private var factories: [ObjectIdentifier: Factory] = [:]
    private var instances: [ObjectIdentifier: Any] = [:]

    func register<T>(_ type: T.Type, factory: @escaping (PharmacyDIContainer) -> T) {
        factories[ObjectIdentifier(type)] = factory
    }

    func resolve<T>(_ type: T.Type = T.self) -> T {
        let key = ObjectIdentifier(type)

        if let instance = instances[key] as? T {
            return instance
        }

        guard let factory = factories[key], let instance = factory(self) as? T else {
            fatalError("No registered dependency for \(type)")
        }

        instances[key] = instance
        return instance
    }
}
