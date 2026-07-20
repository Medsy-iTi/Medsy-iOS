//
//  PharmacyHomeAssembly.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

struct PharmacyHomeAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(PharmacyHomeFactory.self) { _ in
            PharmacyHomeFactory()
        }
    }
}
