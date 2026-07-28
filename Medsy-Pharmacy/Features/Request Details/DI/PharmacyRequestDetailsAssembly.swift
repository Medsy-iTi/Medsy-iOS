// PharmacyRequestDetailsAssembly.swift

import Foundation

struct PharmacyRequestDetailsAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(PharmacyRequestDetailsRepositoryProtocol.self) { c in
            PharmacyRequestDetailsRepository(networkService: c.resolve(NetworkServiceProtocol.self))
        }

        container.register(FetchPharmacyRequestDetailsUseCaseProtocol.self) { c in
            FetchPharmacyRequestDetailsUseCase(repository: c.resolve(PharmacyRequestDetailsRepositoryProtocol.self))
        }

        container.register(PharmacyRequestsRepositoryProtocol.self) { c in
            PharmacyRequestsRepository(networkService: c.resolve(NetworkServiceProtocol.self))
        }

        container.register(FetchPharmacyRequestsUseCaseProtocol.self) { c in
            FetchPharmacyRequestsUseCase(repository: c.resolve(PharmacyRequestsRepositoryProtocol.self))
        }

        container.register(SendOfferUseCaseProtocol.self) { c in
            SendOfferUseCase(repository: c.resolve(PharmacyRequestsRepositoryProtocol.self))
        }

        container.register(PrescriptionImageDataSource.self) { c in
            PrescriptionImageDataSource(networkService: c.resolve(NetworkServiceProtocol.self))
        }

        container.register(SearchProductsUseCaseProtocol.self) { c in
            SearchProductsUseCase(repository: c.resolve(PharmacyRequestsRepositoryProtocol.self))
        }
    }
}
