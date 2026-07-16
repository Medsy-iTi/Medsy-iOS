//
//  PharmacyModuleAssembly.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Foundation

@MainActor
protocol PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer)
}
