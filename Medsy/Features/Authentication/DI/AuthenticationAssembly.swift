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

        container.register(AuthRefreshNetworkDataSourceProtocol.self) { container in
            AuthRefreshNetworkDataSource(
                transport: container.resolve(NetworkTransportProtocol.self),
                requestBuilder: container.resolve(NetworkRequestBuilder.self)
            )
        }

        container.register(RefreshTokenRepositoryProtocol.self) { container in
            RefreshTokenRepository(
                networkDataSource: container.resolve(AuthRefreshNetworkDataSourceProtocol.self)
            )
        }

        container.register(SignupUseCaseProtocol.self) { container in
            SignupUseCase(
                repository: container.resolve(AuthRepositoryProtocol.self)
            )
        }

        container.register(LoginUseCaseProtocol.self) { container in
            LoginUseCase(
                repository: container.resolve(AuthRepositoryProtocol.self),
                tokenStore: container.resolve(TokenStoreProtocol.self)
            )
        }

        container.register(VerificationUseCaseProtocol.self) { container in
            VerificationUseCase(
                repository: container.resolve(AuthRepositoryProtocol.self),
                tokenStore: container.resolve(TokenStoreProtocol.self)
            )
        }

        container.register(RefreshSessionUseCaseProtocol.self) { container in
            RefreshSessionUseCase(
                repository: container.resolve(RefreshTokenRepositoryProtocol.self)
            )
        }

        container.register(TokenRefreshing.self) { container in
            AuthTokenRefresher(
                refreshSessionUseCase: container.resolve(RefreshSessionUseCaseProtocol.self),
                tokenStore: container.resolve(TokenStoreProtocol.self)
            )
        }

        container.register(AuthenticationFactory.self) { container in
            AuthenticationFactory(
                loginUseCase: container.resolve(LoginUseCaseProtocol.self),
                signupUseCase: container.resolve(SignupUseCaseProtocol.self),
                verificationUseCase: container.resolve(VerificationUseCaseProtocol.self)
            )
        }
    }
}
