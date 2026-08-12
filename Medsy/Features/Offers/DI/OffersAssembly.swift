//
//  OffersAssembly.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

struct OffersAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(OffersRemoteDataSourceProtocol.self) { container in
            OffersRemoteDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(OfferResultRepositoryProtocol.self) { container in
            OfferResultRepository(
                remoteDataSource: container.resolve(OffersRemoteDataSourceProtocol.self)
            )
        }

        container.register(GetOfferResultUseCaseProtocol.self) { container in
            GetOfferResultUseCase(
                repository: container.resolve(OfferResultRepositoryProtocol.self)
            )
        }

        container.register(ConfirmOfferUseCaseProtocol.self) { container in
            ConfirmOfferUseCase(
                repository: container.resolve(OfferResultRepositoryProtocol.self)
            )
        }
    }
}
