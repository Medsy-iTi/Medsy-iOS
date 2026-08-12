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
    let profileCoordinator: ProfileCoordinator

    init(selectedTab: PharmacyTab = .home) {
        self.selectedTab = selectedTab
        self.profileCoordinator = ProfileCoordinator(container: PharmacyAppAssembler.shared.container)
    }

    func select(_ tab: PharmacyTab) {
        selectedTab = tab
    }

    func showOrders() {
        select(.orders)
    }

	func showCompletedOrders() { 
		select(.completedOrders)
	}
}
