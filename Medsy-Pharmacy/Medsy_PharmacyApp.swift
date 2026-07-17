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

    init() {
        PharmacyAppAssembler.shared.assemble(modules: [
            PharmacyCoreAssembly()
        ])
        languageManager = PharmacyAppAssembler.shared.container.resolve(LanguageManager.self)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .pharmacyLocalizedEnvironment()
                .environment(languageManager)
                .id(languageManager.currentLanguage)
        }
    }
}
