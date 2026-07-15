//
//  DIContainer.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import Swinject

final class DIContainer {


    static let shared = DIContainer()


    private let container: Container

    private init() {
        container = Container()
    }

    @discardableResult
    func register<T>(
        _ type: T.Type,
        factory: @escaping (DIContainer) -> T
    ) -> Self {
        container.register(type) { [weak self] _ in
            guard let self else { fatalError("DIContainer was deallocated") }
            return factory(self)
        }
        return self
    }

    @discardableResult
    func register<T>(
        _ type: T.Type,
        name: String,
        factory: @escaping (DIContainer) -> T
    ) -> Self {
        container.register(type, name: name) { [weak self] _ in
            guard let self else { fatalError("DIContainer was deallocated") }
            return factory(self)
        }
        return self
    }

    func resolve<T>(_ type: T.Type) -> T {
        guard let instance = container.resolve(type) else {
            fatalError("""
            ❌ DIContainer: Failed to resolve \(T.self).
            Did you forget to register it in a ModuleAssembly?
            """)
        }
        return instance
    }

    func resolve<T>(_ type: T.Type, name: String) -> T {
        guard let instance = container.resolve(type, name: name) else {
            fatalError("""
            ❌ DIContainer: Failed to resolve \(T.self) named "\(name)".
            Did you forget to register it in a ModuleAssembly?
            """)
        }
        return instance
    }
}
