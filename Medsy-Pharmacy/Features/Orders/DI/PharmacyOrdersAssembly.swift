//
//  PharmacyOrdersAssembly.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

struct PharmacyOrdersAssembly: PharmacyModuleAssembly {
	func register(in container: PharmacyDIContainer) {
		container.register(PharmacyOrdersRepositoryProtocol.self) { c in
			PharmacyOrdersRepository(networkService: c.resolve(NetworkServiceProtocol.self))
		}

		container.register(FetchPharmacyOrdersUseCaseProtocol.self) { c in
			FetchPharmacyOrdersUseCase(repository: c.resolve(PharmacyOrdersRepositoryProtocol.self))
		}

		container.register(PharmacyIdentityProviding.self) { c in
			PharmacySessionSettings.shared
		}

		container.register(PharmacyOrdersFactory.self) { c in
			PharmacyOrdersFactory(
				fetchOrdersUseCase: c.resolve(FetchPharmacyOrdersUseCaseProtocol.self),
				getProfileUseCase: c.resolve(GetPharmacyProfileUseCaseProtocol.self),
				appSettings: c.resolve(PharmacyAppSettings.self),
				identityProvider: c.resolve()
			)
		}
	}
}
