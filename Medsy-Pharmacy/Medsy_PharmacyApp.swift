//
//  Medsy_PharmacyApp.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import SwiftUI

@main
struct Medsy_PharmacyApp: App {
    private let languageManager: LanguageManager
    private let authenticationFactory: PharmacyAuthenticationFactory
    private let onboardingFactory: PharmacyOnboardingFactory
    private let homeFactory: PharmacyHomeFactory
    private let ordersFactory: PharmacyOrdersFactory
    private let coordinator: RootCoordinator

    init() {
        PharmacyAppAssembler.shared.assemble(modules: [
            PharmacyCoreAssembly(),
            PharmacyAuthenticationAssembly(),
            OnboardingModuleAssembly(),
            PharmacyHomeAssembly(),
            PharmacyOrdersAssembly()
        ])
        
        let container = PharmacyAppAssembler.shared.container
        languageManager = container.resolve(LanguageManager.self)
        authenticationFactory = container.resolve(PharmacyAuthenticationFactory.self)
        homeFactory = container.resolve(PharmacyHomeFactory.self)
        ordersFactory = container.resolve(PharmacyOrdersFactory.self)
        
        onboardingFactory = PharmacyOnboardingFactory(
            getPagesUseCase: container.resolve(GetOnboardingPagesUseCaseProtocol.self)
        )
        coordinator = RootCoordinator(container: container)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                onboardingFactory: onboardingFactory,
                authenticationFactory: authenticationFactory,
                homeFactory: homeFactory,
                ordersFactory: ordersFactory,
                coordinator: coordinator
            )
            .pharmacyLocalizedEnvironment()
            .environment(languageManager)
            .id(languageManager.currentLanguage)
        }
    }
}
