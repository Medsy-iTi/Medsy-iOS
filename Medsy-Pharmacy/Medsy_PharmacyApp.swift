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

    init() {
        PharmacyAppAssembler.shared.assemble(modules: [
            PharmacyCoreAssembly(),
            PharmacyAuthenticationAssembly()
        ])
        languageManager = PharmacyAppAssembler.shared.container.resolve(LanguageManager.self)
        authenticationFactory = PharmacyAppAssembler.shared.container.resolve(PharmacyAuthenticationFactory.self)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(authenticationFactory: authenticationFactory)
                .pharmacyLocalizedEnvironment()
                .environment(languageManager)
                .id(languageManager.currentLanguage)
        }
    }
}
