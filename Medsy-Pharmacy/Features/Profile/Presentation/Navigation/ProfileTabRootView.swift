//
//  ProfileTabRootView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct ProfileTabRootView: View {
    @State private var coordinator: ProfileCoordinator
    private let onLoggedOut: () -> Void

    init(container: PharmacyDIContainer, onLoggedOut: @escaping () -> Void) {
        _coordinator = State(initialValue: ProfileCoordinator(container: container))
        self.onLoggedOut = onLoggedOut
    }

    var body: some View {
        ProfileCoordinatorView(coordinator: coordinator)
            .onAppear {
                coordinator.onLoggedOut = onLoggedOut
                coordinator.onSessionExpired = onLoggedOut
            }
    }
}
