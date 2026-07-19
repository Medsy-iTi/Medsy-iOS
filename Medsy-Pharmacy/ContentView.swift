//
//  ContentView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import SwiftUI

struct ContentView: View {
    let onboardingFactory: PharmacyOnboardingFactory
    let authenticationFactory: PharmacyAuthenticationFactory
    @ObservedObject private var appSettings = PharmacyAppSettings.shared
    @State private var coordinator: RootCoordinator

    init(
        onboardingFactory: PharmacyOnboardingFactory,
        authenticationFactory: PharmacyAuthenticationFactory,
        coordinator: RootCoordinator
    ) {
        self.onboardingFactory = onboardingFactory
        self.authenticationFactory = authenticationFactory
        _coordinator = State(initialValue: coordinator)
    }

    var body: some View {
        Group {
            switch coordinator.flow {
            case .splash:
                SplashView {
                    coordinator.finishSplash()
                }
                .transition(.opacity)

            case .onboarding:
                onboardingFactory.makeCoordinator(onComplete: coordinator.finishOnboarding)
                    .makeView()
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                    removal: .opacity
                ))

            case .authentication:
                PharmacyAuthenticationRootView(
                    factory: authenticationFactory,
                    onAuthenticated: coordinator.finishAuthentication
                )
                .transition(.opacity)

            case .main:
					PharmacyMainTabView(
						coordinator: coordinator.mainTabCoordinator,
						onLoggedOut: coordinator.logout
					)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut(duration: 0.45), value: coordinator.flow)
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
    }
}

private struct PharmacyAuthenticationRootView: View {
    @State private var coordinator: PharmacyAuthenticationCoordinator

    init(
        factory: PharmacyAuthenticationFactory,
        onAuthenticated: @escaping () -> Void
    ) {
        _coordinator = State(
            initialValue: factory.makeCoordinator(
                onAuthenticated: onAuthenticated
            )
        )
    }

    var body: some View {
        PharmacyAuthenticationCoordinatorView(coordinator: coordinator)
    }
}

#Preview {
    ContentView(
        onboardingFactory: PharmacyOnboardingFactory(getPagesUseCase: GetOnboardingPagesUseCase(repository: OnboardingRepository())),
        authenticationFactory: PharmacyAuthenticationFactory(actions: .placeholder),
        coordinator: RootCoordinator(container: PharmacyDIContainer())
    )
    .environment(LanguageManager.shared)
}
