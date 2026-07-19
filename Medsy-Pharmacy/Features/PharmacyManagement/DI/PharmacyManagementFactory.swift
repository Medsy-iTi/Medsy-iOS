//
//  PharmacyManagementFactory.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

struct PharmacyManagementFactory {
    private let actions: PharmacyManagementActions

    init(actions: PharmacyManagementActions) {
        self.actions = actions
    }

    @MainActor
    func makeCoordinator() -> PharmacyManagementCoordinator {
        PharmacyManagementCoordinator(actions: actions)
    }
}
