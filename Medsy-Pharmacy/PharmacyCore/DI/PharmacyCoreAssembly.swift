//
//  PharmacyCoreAssembly.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

struct PharmacyCoreAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(LanguageManager.self) { _ in
            LanguageManager.shared
        }

        container.register(PharmacyAppSettings.self) { _ in
            PharmacyAppSettings.shared
        }

        container.register(NetworkServiceProtocol.self) { c in
            NetworkService(languageManager: c.resolve(LanguageManager.self))
        }
    }
}
