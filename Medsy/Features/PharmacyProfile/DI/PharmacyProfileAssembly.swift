//
//  PharmacyProfileAssembly.swift
//  Medsy
//
//  Created by Antoneos Philip on 21/07/2026.
//

import Foundation

struct PharmacyProfileAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(PharmacyRemoteDataSourceProtocol.self) { container in
            PharmacyRemoteDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(PharmacyRepositoryProtocol.self) { container in
            PharmacyRepository(
                remoteDataSource: container.resolve(PharmacyRemoteDataSourceProtocol.self)
            )
        }

        container.register(FetchPharmacyProfileUseCaseProtocol.self) { container in
            FetchPharmacyProfileUseCase(
                repository: container.resolve(PharmacyRepositoryProtocol.self)
            )
        }

        container.register(PharmacyProfileViewModel.self) { container in
            PharmacyProfileViewModel(
                fetchPharmacyProfileUseCase: container.resolve(FetchPharmacyProfileUseCaseProtocol.self)
            )
        }
    }
}
