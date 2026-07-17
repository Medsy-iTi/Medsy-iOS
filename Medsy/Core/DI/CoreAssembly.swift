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

        container.register(TokenStoreProtocol.self) { _ in
            KeychainTokenStore()
        }

        container.register(LogoutUseCaseProtocol.self) { container in
            LogoutUseCase(
                tokenStore: container.resolve(TokenStoreProtocol.self)
            )
        }

        container.register(NetworkTransportProtocol.self) { _ in
            NetworkTransport()
        }

        container.register(NetworkRequestBuilder.self) { container in
            NetworkRequestBuilder(
                languageManager: container.resolve(LanguageManager.self)
            )
        }

        container.register(NetworkServiceProtocol.self) { c in
            NetworkService(
                transport: c.resolve(NetworkTransportProtocol.self),
                requestBuilder: c.resolve(NetworkRequestBuilder.self),
                tokenStore: c.resolve(TokenStoreProtocol.self),
                tokenRefresher: c.resolve(TokenRefreshing.self)
            )
        }
    }
}
