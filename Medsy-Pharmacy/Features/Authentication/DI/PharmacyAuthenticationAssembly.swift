//
//  PharmacyAuthenticationAssembly.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

struct PharmacyAuthenticationAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(PharmacyAuthenticationRemoteDataSourceProtocol.self) { container in
            PharmacyAuthenticationRemoteDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(PharmacyAuthenticationRepositoryProtocol.self) { container in
            PharmacyAuthenticationRepository(
                remoteDataSource: container.resolve(PharmacyAuthenticationRemoteDataSourceProtocol.self)
            )
        }

        container.register(PharmacySetupRepositoryProtocol.self) { container in
            PharmacySetupRepository(
                remoteDataSource: container.resolve(PharmacyAuthenticationRemoteDataSourceProtocol.self)
            )
        }

        container.register(PharmacyRegistrationUseCaseProtocol.self) { container in
            PharmacyRegistrationUseCase(
                repository: container.resolve(PharmacyAuthenticationRepositoryProtocol.self)
            )
        }

        container.register(PharmacyLoginUseCaseProtocol.self) { container in
            PharmacyLoginUseCase(
                repository: container.resolve(PharmacyAuthenticationRepositoryProtocol.self),
                tokenStore: container.resolve(TokenStoreProtocol.self)
            )
        }

        container.register(PharmacyVerificationUseCaseProtocol.self) { container in
            PharmacyVerificationUseCase(
                repository: container.resolve(PharmacyAuthenticationRepositoryProtocol.self),
                tokenStore: container.resolve(TokenStoreProtocol.self)
            )
        }

        container.register(GetPharmacyMembershipUseCaseProtocol.self) { container in
            GetPharmacyMembershipUseCase(
                repository: container.resolve(PharmacySetupRepositoryProtocol.self)
            )
        }

        container.register(CreatePharmacyUseCaseProtocol.self) { container in
            CreatePharmacyUseCase(
                repository: container.resolve(PharmacySetupRepositoryProtocol.self)
            )
        }

        container.register(PharmacyLocationProviding.self) { _ in
            PharmacyLocationService()
        }

        container.register(PharmacyAuthenticationActions.self) { container in
            .live(
                loginUseCase: container.resolve(PharmacyLoginUseCaseProtocol.self),
                registrationUseCase: container.resolve(PharmacyRegistrationUseCaseProtocol.self),
                verificationUseCase: container.resolve(PharmacyVerificationUseCaseProtocol.self),
                membershipUseCase: container.resolve(GetPharmacyMembershipUseCaseProtocol.self),
                createPharmacyUseCase: container.resolve(CreatePharmacyUseCaseProtocol.self),
                tokenStore: container.resolve(TokenStoreProtocol.self)
            )
        }

        container.register(PharmacyAuthenticationFactory.self) { container in
            PharmacyAuthenticationFactory(
                actions: container.resolve(PharmacyAuthenticationActions.self),
                locationProvider: container.resolve(PharmacyLocationProviding.self)
            )
        }
    }
}
