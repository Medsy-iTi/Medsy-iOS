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
	private let completedOrdersFactory: PharmacyCompletedOrdersFactory
    private let coordinator: RootCoordinator
    private let heartbeatService: PharmacyHeartbeatService
    @ObservedObject private var appSettings = PharmacyAppSettings.shared

    init() {
        PharmacyAppAssembler.shared.assemble(modules: [
            PharmacyCoreAssembly(),
            PharmacyAuthenticationAssembly(),
            OnboardingModuleAssembly(),
            ProfileAssembly(),
            PresenceAssembly(),
            PharmacyHomeAssembly(),
            PharmacyOrdersAssembly(),
            PharmacyRequestDetailsAssembly(),
			CompletedOrdersAssembly()
        ])

        let container = PharmacyAppAssembler.shared.container
        languageManager = container.resolve(LanguageManager.self)
        authenticationFactory = container.resolve(PharmacyAuthenticationFactory.self)
        homeFactory = container.resolve(PharmacyHomeFactory.self)
        ordersFactory = container.resolve(PharmacyOrdersFactory.self)
		completedOrdersFactory = container.resolve(PharmacyCompletedOrdersFactory.self)
        heartbeatService = container.resolve(PharmacyHeartbeatService.self)

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
				completedOrdersFactory: completedOrdersFactory,
                coordinator: coordinator
            )
            .task {
                heartbeatService.startHeartbeat()
                print("[Medsy_PharmacyApp] 🚀 App launched — heartbeat started")
            }
            .pharmacyLocalizedEnvironment()
            .environment(languageManager)
            .id("\(languageManager.currentLanguage.rawValue)-\(PharmacyAppSettings.shared.isDarkMode)")
        }
    }
}
