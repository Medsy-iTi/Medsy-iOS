//
//  AppRootView.swift
//  Medsy
//
//  Created by Ehab Salah on 15/07/2026.
//

import SwiftUI

struct AppRootView: View {
    private let onboardingFactory: OnboardingFactory
    private let authenticationFactory: AuthenticationFactory
    @ObservedObject private var appSettings = AppSettings.shared
    @State private var coordinator: AppCoordinator

    init(
        onboardingFactory: OnboardingFactory,
        authenticationFactory: AuthenticationFactory,
        coordinator: AppCoordinator
    ) {
        self.onboardingFactory = onboardingFactory
        self.authenticationFactory = authenticationFactory
        _coordinator = State(initialValue: coordinator)
    }

    var body: some View {
        Group {
            switch coordinator.route {
            case .splash:
                AnimatedSplashView {
                    coordinator.finishSplash()
                }
            case .onboarding:
                onboardingFactory.makeCoordinator(onComplete: coordinator.finishOnboarding)
                    .makeView()
                .transition(.opacity)
            case .authentication:
                AuthenticationCoordinatorView(
                    coordinator: authenticationFactory.makeCoordinator(
                        onAuthenticated: coordinator.finishAuthentication
                    )
                )
                .transition(.opacity)
            case .main:
                MainTabBarView(
                    coordinator: MainTabCoordinator(
                        selectedTab: coordinator.selectedTab,
                        onTabSelected: { coordinator.selectedTab = $0 },
                        onLogout: coordinator.logout
                    )
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.route)
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
    }
}
