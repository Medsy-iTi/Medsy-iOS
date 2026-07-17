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
    private let logoutUseCase: LogoutUseCaseProtocol

    var route: AppRoute = .splash
    var selectedTab: AppTab = .home

    init(shouldShowOnboarding: Bool, logoutUseCase: LogoutUseCaseProtocol) {
        self.shouldShowOnboarding = shouldShowOnboarding
        self.logoutUseCase = logoutUseCase
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
        logoutUseCase.execute()
        selectedTab = .home
        route = .authentication
    }
}
