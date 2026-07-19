//
//  PharmacyOrdersAssembly.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

struct PharmacyOrdersAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(PharmacyOrdersFactory.self) { _ in
            PharmacyOrdersFactory(
                makeViewModel: {
                    PharmacyOrdersViewModel()
                }
            )
        }
    }
}
