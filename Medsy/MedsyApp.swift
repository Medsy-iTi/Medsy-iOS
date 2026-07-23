//
//  MedsyApp.swift
//  Medsy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

@main
struct MedsyApp: App {

    private let languageManager: LanguageManager
    private let onboardingFactory: OnboardingFactory
    private let authenticationFactory: AuthenticationFactory
    private let logoutUseCase: LogoutUseCaseProtocol
    private let appCoordinator: AppCoordinator
    private let heartbeatService: HeartbeatService

    init() {
        AppAssembler.shared.assemble(modules: [
            CoreAssembly(),
            OnboardingAssembly(),
            AuthenticationAssembly(),
            CategoriesAssembly(),
            ProductsAssembly(),
            ProductDetailAssembly(),
            ProductsFeatureAssembly(),
            CartAssembly(),
            ProfileAssembly(),
            PharmacyProfileAssembly(),
            OrdersAssembly(),
            PresenceAssembly()
        ])

        languageManager = AppAssembler.shared.container.resolve(LanguageManager.self)
        onboardingFactory = AppAssembler.shared.container.resolve(OnboardingFactory.self)
        authenticationFactory = AppAssembler.shared.container.resolve(AuthenticationFactory.self)
        logoutUseCase = AppAssembler.shared.container.resolve(LogoutUseCaseProtocol.self)
        heartbeatService = AppAssembler.shared.container.resolve(HeartbeatService.self)
        appCoordinator = AppCoordinator(
            shouldShowOnboarding: onboardingFactory.shouldShow(),
            authenticationStatusStore: AppAssembler.shared.container.resolve(UserDefaultsStatusStoreProtocol.self),
            logoutUseCase: logoutUseCase
        )
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(
                onboardingFactory: onboardingFactory,
                authenticationFactory: authenticationFactory,
                coordinator: appCoordinator
            )
            .task {
                heartbeatService.startHeartbeat()
                print("[MedsyApp] 🚀 Customer App launched — heartbeat started")
            }
            .localizedEnvironment()
            .environment(languageManager)
            .id(languageManager.currentLanguage)
        }
    }
}
