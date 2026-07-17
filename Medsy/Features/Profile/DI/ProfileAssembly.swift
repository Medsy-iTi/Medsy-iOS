//
//  ProfileAssembly.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

struct ProfileAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(ProfileRemoteDataSourceProtocol.self) { container in
            ProfileRemoteDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(ProfileRepositoryProtocol.self) { container in
            ProfileRepository(
                remoteDataSource: container.resolve(ProfileRemoteDataSourceProtocol.self)
            )
        }

        container.register(GetCustomerProfileUseCaseProtocol.self) { container in
            GetCustomerProfileUseCase(
                repository: container.resolve(ProfileRepositoryProtocol.self)
            )
        }

        container.register(UpdateCustomerProfileUseCaseProtocol.self) { container in
            UpdateCustomerProfileUseCase(
                repository: container.resolve(ProfileRepositoryProtocol.self)
            )
        }

        container.register(ProfileViewModel.self) { container in
            ProfileViewModel(
                getCustomerProfileUseCase: container.resolve(GetCustomerProfileUseCaseProtocol.self),
                updateCustomerProfileUseCase: container.resolve(UpdateCustomerProfileUseCaseProtocol.self)
            )
        }
    }
}
