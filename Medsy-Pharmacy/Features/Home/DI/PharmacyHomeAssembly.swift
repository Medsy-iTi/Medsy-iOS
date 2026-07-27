//
//  PharmacyHomeAssembly.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

struct PharmacyHomeAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(PharmacyHomeFactory.self) { container in
            PharmacyHomeFactory(
                getProfileUseCase: container.resolve(GetPharmacyProfileUseCaseProtocol.self),
                fetchOrdersUseCase: container.resolve(FetchPharmacyOrdersUseCaseProtocol.self),
                identityProvider: container.resolve(PharmacyIdentityProviding.self),
                sessionSettings: container.resolve(PharmacySessionSettings.self)
            )
        }
    }
}
