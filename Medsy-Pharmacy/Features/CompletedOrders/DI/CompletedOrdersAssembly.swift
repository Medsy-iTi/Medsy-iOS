//
//  CompletedOrdersAssembly.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//

import Foundation

struct CompletedOrdersAssembly: PharmacyModuleAssembly {
	func register(in container: PharmacyDIContainer) {
		container.register(CompletedOrdersRemoteDataSourceProtocol.self) { container in
			CompletedOrdersRemoteDataSource(
				networkService: container.resolve(NetworkServiceProtocol.self)
			)
		}

		container.register(CompletedOrdersRepositoryProtocol.self) { container in
			CompletedOrdersRepository(
				remoteDataSource: container.resolve(CompletedOrdersRemoteDataSourceProtocol.self)
			)
		}

		container.register(GetCompletedOrdersUseCaseProtocol.self) { container in
			GetCompletedOrdersUseCase(
				repository: container.resolve(CompletedOrdersRepositoryProtocol.self)
			)
		}

		container.register(PharmacyCompletedOrdersFactory.self) { container in
			PharmacyCompletedOrdersFactory(
				getCompletedOrdersUseCase: container.resolve(GetCompletedOrdersUseCaseProtocol.self),
				identityProvider: container.resolve(PharmacyIdentityProviding.self)
			)
		}
	}
}
