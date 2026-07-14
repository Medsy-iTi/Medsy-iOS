//
//  MedsyApp.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import SwiftUI

@main
struct MedsyApp: App {

    private let languageManager = LanguageManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(languageManager)
        }
    }
}
