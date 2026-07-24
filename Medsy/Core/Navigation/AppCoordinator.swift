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
    case cart
    case chatbot
    case offers
    case orders
    case profile
}

@MainActor
@Observable
final class AppCoordinator {
    private let shouldShowOnboarding: Bool
    private let authenticationStatusStore: UserDefaultsStatusStoreProtocol
    private let logoutUseCase: LogoutUseCaseProtocol

    var route: AppRoute = .splash
    var selectedTab: AppTab = .home

    init(
        shouldShowOnboarding: Bool,
        authenticationStatusStore: UserDefaultsStatusStoreProtocol,
        logoutUseCase: LogoutUseCaseProtocol
    ) {
        self.shouldShowOnboarding = shouldShowOnboarding
        self.authenticationStatusStore = authenticationStatusStore
        self.logoutUseCase = logoutUseCase
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
        Task {
            await logoutUseCase.execute()
            authenticationStatusStore.setLoggedIn(false)
            selectedTab = .home
            route = .authentication
        }
    }
}
