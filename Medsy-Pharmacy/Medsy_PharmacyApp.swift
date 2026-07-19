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
    private let pharmacyManagementFactory: PharmacyManagementFactory
    private let onboardingFactory: PharmacyOnboardingFactory
    private let coordinator: RootCoordinator

    init() {
        PharmacyAppAssembler.shared.assemble(modules: [
            PharmacyCoreAssembly(),
            PharmacyAuthenticationAssembly(),
            PharmacyManagementAssembly(),
            OnboardingModuleAssembly()
        ])
        
        let container = PharmacyAppAssembler.shared.container
        languageManager = container.resolve(LanguageManager.self)
        authenticationFactory = container.resolve(PharmacyAuthenticationFactory.self)
        pharmacyManagementFactory = container.resolve(PharmacyManagementFactory.self)
        
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
                pharmacyManagementFactory: pharmacyManagementFactory,
                coordinator: coordinator
            )
            .pharmacyLocalizedEnvironment()
            .environment(languageManager)
            .id(languageManager.currentLanguage)
        }
    }
}
