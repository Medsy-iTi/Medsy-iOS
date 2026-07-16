//
//  MainTabCoordinator.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import Observation


@MainActor
@Observable
final class MainTabCoordinator {
    var selectedTab: AppTab
    private let onTabSelected: (AppTab) -> Void
    private let onLogout: () -> Void

    init(
        selectedTab: AppTab = .home,
        onTabSelected: @escaping (AppTab) -> Void = { _ in },
        onLogout: @escaping () -> Void = {}
    ) {
        self.selectedTab = selectedTab
        self.onTabSelected = onTabSelected
        self.onLogout = onLogout
    }

    func select(_ tab: AppTab) {
        selectedTab = tab
        onTabSelected(tab)
    }

    func logout() {
        onLogout()
    }
}
