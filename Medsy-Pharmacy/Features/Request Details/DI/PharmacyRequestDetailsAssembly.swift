//  PharmacyRequestDetailsAssembly.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import Foundation

struct PharmacyRequestDetailsAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(PharmacyRequestDetailsRepositoryProtocol.self) { c in
            PharmacyRequestDetailsRepository(networkService: c.resolve(NetworkServiceProtocol.self))
        }

        container.register(FetchPharmacyRequestDetailsUseCaseProtocol.self) { c in
            FetchPharmacyRequestDetailsUseCase(repository: c.resolve(PharmacyRequestDetailsRepositoryProtocol.self))
        }
    }
}
