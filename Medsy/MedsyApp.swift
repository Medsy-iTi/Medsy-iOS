//
//  MedsyApp.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import SwiftUI

@main
struct MedsyApp: App {

    private let languageManager: LanguageManager
    private let onboardingFactory: OnboardingFactory
    private let authenticationFactory: AuthenticationFactory

    init() {
        AppAssembler.shared.assemble(modules: [
            CoreAssembly(),
            OnboardingAssembly(),
            AuthenticationAssembly(),
        ])

        languageManager = AppAssembler.shared.container.resolve(LanguageManager.self)
        onboardingFactory = AppAssembler.shared.container.resolve(OnboardingFactory.self)
        authenticationFactory = AppAssembler.shared.container.resolve(AuthenticationFactory.self)
    }

    var body: some Scene {
        WindowGroup {

			ProductDetailView(productId: "1")
				.localizedEnvironment()
				.environment(languageManager)
				.id(languageManager.currentLanguage)
			ProfileScreen()
                .localizedEnvironment()
                .environment(languageManager)
                .id(languageManager.currentLanguage)
			
        }
    }
}
