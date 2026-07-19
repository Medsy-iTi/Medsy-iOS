//
//  PharmacyManagementAssembly.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

struct PharmacyManagementAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(PharmacyManagementActions.self) { _ in
            .placeholder
        }

        container.register(PharmacyManagementFactory.self) { container in
            PharmacyManagementFactory(
                actions: container.resolve(PharmacyManagementActions.self)
            )
        }
    }
}
