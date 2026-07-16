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

    init() {
        AppAssembler.shared.assemble(modules: [
            CoreAssembly(),
            OnboardingAssembly(),
        ])

        languageManager = AppAssembler.shared.container.resolve(LanguageManager.self)
        onboardingFactory = AppAssembler.shared.container.resolve(OnboardingFactory.self)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(onboardingFactory: onboardingFactory)
                .localizedEnvironment()
                .environment(languageManager)
                .id(languageManager.currentLanguage)
        }
    }
}
