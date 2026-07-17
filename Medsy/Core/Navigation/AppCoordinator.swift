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
    private let authenticationStatusStore: UserDefaultsStatusStoreProtocol

    var route: AppRoute = .splash
    var selectedTab: AppTab = .home

    init(
        shouldShowOnboarding: Bool,
        authenticationStatusStore: UserDefaultsStatusStoreProtocol
    ) {
        self.shouldShowOnboarding = shouldShowOnboarding
        self.authenticationStatusStore = authenticationStatusStore
    }

    func finishSplash() {
        if authenticationStatusStore.isLoggedIn {
            selectedTab = .home
            route = .main
        } else {
            route = shouldShowOnboarding ? .onboarding : .authentication
        }
    }

    func finishOnboarding() {
        route = .authentication
    }

    func finishAuthentication() {
        authenticationStatusStore.setLoggedIn(true)
        selectedTab = .home
        route = .main
    }

    func logout() {
        authenticationStatusStore.setLoggedIn(false)
        selectedTab = .home
        route = .authentication
    }
}
