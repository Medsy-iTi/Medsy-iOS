//
//  PharmacyAuthenticationAssembly.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

struct PharmacyAuthenticationAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(PharmacyAuthenticationActions.self) { _ in
            .placeholder
        }

        container.register(PharmacyAuthenticationFactory.self) { container in
            PharmacyAuthenticationFactory(
                actions: container.resolve(PharmacyAuthenticationActions.self)
            )
        }
    }
}
