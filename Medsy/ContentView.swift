//
//  ContentView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import SwiftUI

@MainActor
struct ContentView: View {

    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        MainTabBarView(coordinator: MainTabCoordinator())
            .localizedEnvironment()
            .id(languageManager.currentLanguage)
    }
}

#Preview {
    ContentView()
        .environment(LanguageManager.shared)
}
