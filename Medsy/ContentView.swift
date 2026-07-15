//
//  ContentView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import SwiftUI

struct ContentView: View {

    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        MainTabBarView()
            .localizedEnvironment()
            .id(languageManager.currentLanguage)
    }
}

#Preview {
    ContentView()
        .environment(LanguageManager.shared)
}
