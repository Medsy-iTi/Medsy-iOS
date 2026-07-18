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

    init() {
        AppAssembler.shared.assemble(modules: [
            CoreAssembly(),
            OnboardingAssembly(),
            AuthenticationAssembly(),
            CategoriesAssembly(),
			ProductsAssembly(),
            ProductDetailAssembly()
            ProductsFeatureAssembly(),
            ProfileAssembly()
        ])

        languageManager = AppAssembler.shared.container.resolve(LanguageManager.self)
        onboardingFactory = AppAssembler.shared.container.resolve(OnboardingFactory.self)
        authenticationFactory = AppAssembler.shared.container.resolve(AuthenticationFactory.self)
        logoutUseCase = AppAssembler.shared.container.resolve(LogoutUseCaseProtocol.self)
        appCoordinator = AppCoordinator(
            shouldShowOnboarding: onboardingFactory.shouldShow(),
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
                .localizedEnvironment()
                .environment(languageManager)
                .id(languageManager.currentLanguage)
			
        }
    }
}
