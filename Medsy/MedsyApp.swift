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

    init() {
        AppAssembler.shared.assemble(modules: [
            CoreAssembly(),
        ])

        languageManager = AppAssembler.shared.container.resolveUnwrapped(LanguageManager.self)
    }

    var body: some Scene {
        WindowGroup {
            ContentView().environment(languageManager)
        }
    }
}
