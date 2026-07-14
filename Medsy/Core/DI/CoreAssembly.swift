//
//  CoreAssembly.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import Foundation

struct CoreAssembly: ModuleAssembly {
    func register(in container: DIContainer) {

        container.register(LanguageManager.self) { _ in
            LanguageManager.shared
        }

        container.register(AppSettings.self) { _ in
            AppSettings.shared
        }

        container.register(NetworkServiceProtocol.self) { c in
            NetworkService(
                languageManager: c.resolveUnwrapped(LanguageManager.self)
            )
        }
    }
}
