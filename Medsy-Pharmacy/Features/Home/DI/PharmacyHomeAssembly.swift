//
//  PharmacyHomeAssembly.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

struct PharmacyHomeAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(PharmacyDashboardRemoteDataSourceProtocol.self) { container in
            PharmacyDashboardRemoteDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(PharmacyDashboardRepositoryProtocol.self) { container in
            PharmacyDashboardRepository(
                remoteDataSource: container.resolve(PharmacyDashboardRemoteDataSourceProtocol.self)
            )
        }

        container.register(FetchPharmacyDashboardUseCaseProtocol.self) { container in
            FetchPharmacyDashboardUseCase(
                repository: container.resolve(PharmacyDashboardRepositoryProtocol.self)
            )
        }

        container.register(FetchAIDashboardSummaryUseCaseProtocol.self) { container in
            FetchAIDashboardSummaryUseCase(
                repository: container.resolve(PharmacyDashboardRepositoryProtocol.self)
            )
        }

        container.register(PharmacyHomeFactory.self) { container in
            PharmacyHomeFactory(
                getProfileUseCase: container.resolve(GetPharmacyProfileUseCaseProtocol.self),
                fetchDashboardUseCase: container.resolve(FetchPharmacyDashboardUseCaseProtocol.self),
                fetchAIDashboardSummaryUseCase: container.resolve(FetchAIDashboardSummaryUseCaseProtocol.self),
                sendHeartbeatUseCase: container.resolve(SendHeartbeatUseCaseProtocol.self),
                sessionSettings: container.resolve(PharmacySessionSettings.self)
            )
        }
    }
}
