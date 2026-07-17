//
//  AuthenticationAssembly.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

struct AuthenticationAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(AuthNetworkDataSourceProtocol.self) { container in
            AuthNetworkDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(AuthRepositoryProtocol.self) { container in
            AuthRepository(
                networkDataSource: container.resolve(AuthNetworkDataSourceProtocol.self)
            )
        }

        container.register(SignupUseCaseProtocol.self) { container in
            SignupUseCase(
                repository: container.resolve(AuthRepositoryProtocol.self)
            )
        }

        container.register(AuthenticationFactory.self) { container in
            AuthenticationFactory(
                signupUseCase: container.resolve(SignupUseCaseProtocol.self)
            )
        }
    }
}
