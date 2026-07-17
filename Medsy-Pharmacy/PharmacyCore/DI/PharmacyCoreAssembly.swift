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

        container.register(NetworkTransportProtocol.self) { _ in
            NetworkTransport()
        }

        container.register(NetworkRequestBuilder.self) { container in
            NetworkRequestBuilder(
                languageManager: container.resolve(LanguageManager.self)
            )
        }

        container.register(NetworkServiceProtocol.self) { container in
            NetworkService(
                transport: container.resolve(NetworkTransportProtocol.self),
                requestBuilder: container.resolve(NetworkRequestBuilder.self)
            )
        }
    }
}
