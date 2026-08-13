//
//  ContentView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 13/07/2026.
//

import SwiftUI

@MainActor
struct ContentView: View {

    var body: some View {
        MainTabBarView(coordinator: MainTabCoordinator())
            .localizedEnvironment()
    }
}

#Preview {
    ContentView()
        .environment(LanguageManager.shared)
}
