//
//  PharmacyAppAssembler.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

@MainActor
final class PharmacyAppAssembler {
    static let shared = PharmacyAppAssembler()

    let container = PharmacyDIContainer()

    private init() {}

    func assemble(modules: [PharmacyModuleAssembly]) {
        modules.forEach { $0.register(in: container) }
    }
}
