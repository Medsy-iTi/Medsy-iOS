//
//  PharmacyManagementAssembly.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

struct PharmacyManagementAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(PharmacyLocationResolving.self) { container in
            PharmacyLocationResolver(
                languageManager: container.resolve(LanguageManager.self)
            )
        }

        container.register(PharmacyManagementRemoteDataSourceProtocol.self) { container in
            PharmacyManagementRemoteDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(PharmacyManagementRepositoryProtocol.self) { container in
            PharmacyManagementRepository(
                remoteDataSource: container.resolve(PharmacyManagementRemoteDataSourceProtocol.self)
            )
        }

        container.register(GetMyPharmacyUseCaseProtocol.self) { container in
            GetMyPharmacyUseCase(
                repository: container.resolve(PharmacyManagementRepositoryProtocol.self)
            )
        }

        container.register(CreatePharmacyUseCaseProtocol.self) { container in
            CreatePharmacyUseCase(
                repository: container.resolve(PharmacyManagementRepositoryProtocol.self)
            )
        }

        container.register(UpdatePharmacyUseCaseProtocol.self) { container in
            UpdatePharmacyUseCase(
                repository: container.resolve(PharmacyManagementRepositoryProtocol.self)
            )
        }

        container.register(DeletePharmacyUseCaseProtocol.self) { container in
            DeletePharmacyUseCase(
                repository: container.resolve(PharmacyManagementRepositoryProtocol.self)
            )
        }

        container.register(PharmacyManagementActions.self) { container in
            .live(
                getMyPharmacyUseCase: container.resolve(GetMyPharmacyUseCaseProtocol.self),
                createPharmacyUseCase: container.resolve(CreatePharmacyUseCaseProtocol.self),
                updatePharmacyUseCase: container.resolve(UpdatePharmacyUseCaseProtocol.self),
                deletePharmacyUseCase: container.resolve(DeletePharmacyUseCaseProtocol.self),
                locationResolver: container.resolve(PharmacyLocationResolving.self)
            )
        }

        container.register(PharmacyManagementFactory.self) { container in
            PharmacyManagementFactory(
                actions: container.resolve(PharmacyManagementActions.self)
            )
        }
    }
}
