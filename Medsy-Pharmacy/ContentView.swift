//
//  ContentView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 16/07/2026.
//

import SwiftUI

struct ContentView: View {
    let authenticationFactory: PharmacyAuthenticationFactory
    @State private var isAuthenticated = false
    @ObservedObject private var appSettings = PharmacyAppSettings.shared

    var body: some View {
        Group {
            if isAuthenticated {
                PharmacyMainTabView(coordinator: PharmacyMainTabCoordinator())
            } else {
                PharmacyAuthenticationRootView(
                    factory: authenticationFactory,
                    onAuthenticated: { isAuthenticated = true }
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
        onAuthenticated: @escaping () -> Void
    ) {
        _coordinator = State(
            initialValue: factory.makeCoordinator(
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
        authenticationFactory: PharmacyAuthenticationFactory(
            actions: .placeholder,
            locationProvider: PreviewContentLocationProvider()
        )
    )
        .environment(LanguageManager.shared)
}

@MainActor
private final class PreviewContentLocationProvider: PharmacyLocationProviding {
    func currentLocation() async throws -> PharmacyLocation {
        PharmacyLocation(latitude: 30.0444, longitude: 31.2357, city: "Cairo", province: "Cairo")
    }

    func location(latitude: Double, longitude: Double) async throws -> PharmacyLocation {
        PharmacyLocation(latitude: latitude, longitude: longitude, city: "Cairo", province: "Cairo")
    }
}
