//
//  ContentView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import SwiftUI

struct ContentView: View {
    let authenticationFactory: PharmacyAuthenticationFactory
    @State private var authenticatedAccountType: PharmacyAccountType?
    @ObservedObject private var appSettings = PharmacyAppSettings.shared

    var body: some View {
        Group {
            if let authenticatedAccountType {
                PharmacyMainTabView(
                    coordinator: PharmacyMainTabCoordinator(),
                    accountType: authenticatedAccountType
                )
            } else {
                PharmacyAuthenticationRootView(
                    factory: authenticationFactory,
                    onAuthenticated: { authenticatedAccountType = $0 }
                )
            }
        }
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
    }
}

private struct PharmacyAuthenticationRootView: View {
    @State private var coordinator: PharmacyAuthenticationCoordinator

    init(
        factory: PharmacyAuthenticationFactory,
        onAuthenticated: @escaping (PharmacyAccountType) -> Void
    ) {
        _coordinator = State(
            initialValue: factory.makeCoordinator(
                onLoginRequested: {},
                onAuthenticated: onAuthenticated
            )
        )
    }

    var body: some View {
        PharmacyAuthenticationCoordinatorView(coordinator: coordinator)
    }
}

#Preview {
    ContentView(
        authenticationFactory: PharmacyAuthenticationFactory(actions: .placeholder)
    )
        .environment(LanguageManager.shared)
}
