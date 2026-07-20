//
//  ProfileCoordinatorView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct ProfileCoordinatorView: View {
    @Bindable var coordinator: ProfileCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.start()
                .navigationDestination(for: ProfileRoute.self) { route in
                    coordinator.destination(for: route)
                }
        }
    }
}