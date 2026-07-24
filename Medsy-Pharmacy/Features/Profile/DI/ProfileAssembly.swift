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

        container.register(DeletePharmacyUseCaseProtocol.self) { container in
            DeletePharmacyUseCase(repository: container.resolve(ProfileRepositoryProtocol.self))
        }

        container.register(RemovePharmacistUseCaseProtocol.self) { container in
            RemovePharmacistUseCase(repository: container.resolve(ProfileRepositoryProtocol.self))
        }

        container.register(InvitePharmacistUseCaseProtocol.self) { container in
            InvitePharmacistUseCase(repository: container.resolve(ProfileRepositoryProtocol.self))
        }

        container.register(UpdatePharmacistUseCaseProtocol.self) { container in
            UpdatePharmacistUseCase(repository: container.resolve(ProfileRepositoryProtocol.self))
        }

        container.register(LogoutUseCaseProtocol.self) { container in
            LogoutUseCase(
                repository: container.resolve(ProfileRepositoryProtocol.self),
                tokenStore: container.resolve(TokenStoreProtocol.self),
				pharmacyIdentityProvidor: container.resolve(PharmacyIdentityProviding.self)
            )
        }

        container.register(GoOnDutyUseCaseProtocol.self) { container in
            GoOnDutyUseCase(repository: container.resolve(ProfileRepositoryProtocol.self))
        }

        container.register(GoOffDutyUseCaseProtocol.self) { container in
            GoOffDutyUseCase(repository: container.resolve(ProfileRepositoryProtocol.self))
        }
    }
}
