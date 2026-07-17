//  PharmacyAuthenticationAssembly.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation

struct PharmacyAuthenticationAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(PharmacyAuthNetworkDataSourceProtocol.self) { container in
            PharmacyAuthNetworkDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(PharmacyAuthRepositoryProtocol.self) { container in
            PharmacyAuthRepository(
                networkDataSource: container.resolve(PharmacyAuthNetworkDataSourceProtocol.self)
            )
        }

        container.register(PharmacyLoginUseCaseProtocol.self) { container in
            PharmacyLoginUseCase(
                repository: container.resolve(PharmacyAuthRepositoryProtocol.self),
                tokenStore: container.resolve(TokenStoreProtocol.self)
            )
        }
    }
}
