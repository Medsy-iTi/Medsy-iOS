//  PharmacyProfileAssembly.swift
//  Medsy
//
//  Created by Antoneos Philip on 20/07/2026.

import Foundation

struct PharmacyProfileAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(PharmacyProfileViewModel.self) { _ in
            PharmacyProfileViewModel()
        }
    }
}
