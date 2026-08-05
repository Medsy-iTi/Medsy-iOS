//
//  ProfileTabRootView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct ProfileTabRootView: View {
    var coordinator: ProfileCoordinator
    private let onLoggedOut: () -> Void

    init(coordinator: ProfileCoordinator, onLoggedOut: @escaping () -> Void) {
        self.coordinator = coordinator
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
