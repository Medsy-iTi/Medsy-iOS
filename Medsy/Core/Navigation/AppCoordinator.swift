//
//  AppCoordinator.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import Observation

enum AppRoute {
    case splash
    case onboarding
    case authentication
    case main
}

enum AppTab: Int, CaseIterable {
    case home
    case favorites
    case offers
    case orders
    case profile
}

@MainActor
@Observable
final class AppCoordinator {
    private let shouldShowOnboarding: Bool

    var route: AppRoute = .splash
    var selectedTab: AppTab = .home

    init(shouldShowOnboarding: Bool) {
        self.shouldShowOnboarding = shouldShowOnboarding
    }

    func finishSplash() {
        route = shouldShowOnboarding ? .onboarding : .authentication
    }

    func finishOnboarding() {
        route = .authentication
    }

    func finishAuthentication() {
        selectedTab = .home
        route = .main
    }

    func logout() {
        selectedTab = .home
        route = .authentication
    }
}
