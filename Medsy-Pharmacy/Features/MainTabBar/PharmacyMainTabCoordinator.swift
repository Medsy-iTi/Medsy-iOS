//
//  PharmacyMainTabCoordinator.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import Observation

@MainActor
@Observable
final class PharmacyMainTabCoordinator {
    var selectedTab: PharmacyTab

    init(selectedTab: PharmacyTab = .home) {
        self.selectedTab = selectedTab
    }

    func select(_ tab: PharmacyTab) {
        selectedTab = tab
    }
}
