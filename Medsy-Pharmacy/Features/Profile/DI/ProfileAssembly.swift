//
//  ProfileAssembly.swift
//  Medsy-Pharmacy
//

import Foundation

struct ProfileAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(ProfileRepositoryProtocol.self) { container in
            ProfileRepository(
                networkService: container.resolve(NetworkServiceProtocol.self),
                tokenStore: container.resolve(TokenStoreProtocol.self)
            )
        }

        container.register(GetPharmacyProfileUseCaseProtocol.self) { container in
            GetPharmacyProfileUseCase(repository: container.resolve(ProfileRepositoryProtocol.self))
        }

        container.register(PharmacyUpdateProfileUseCaseProtocol.self) { container in
            PharmacyUpdateProfileUseCase(repository: container.resolve(ProfileRepositoryProtocol.self))
        }

        container.register(LeavePharmacyUseCaseProtocol.self) { container in
            LeavePharmacyUseCase(repository: container.resolve(ProfileRepositoryProtocol.self))
        }

        container.register(UpdatePharmacyUseCaseProtocol.self) { container in
            UpdatePharmacyUseCase(repository: container.resolve(ProfileRepositoryProtocol.self))
        }

        container.register(LogoutUseCaseProtocol.self) { container in
            LogoutUseCase(
                repository: container.resolve(ProfileRepositoryProtocol.self),
                tokenStore: container.resolve(TokenStoreProtocol.self)
            )
        }
    }
}
