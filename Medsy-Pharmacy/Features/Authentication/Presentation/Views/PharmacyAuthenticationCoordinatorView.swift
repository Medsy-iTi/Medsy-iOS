//
//  PharmacyAuthenticationCoordinatorView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

struct PharmacyAuthenticationCoordinatorView: View {
    @State private var coordinator: PharmacyAuthenticationCoordinator

    init(coordinator: PharmacyAuthenticationCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            PharmacyLoginView(
                viewModel: coordinator.loginViewModel,
                onSignupTapped: coordinator.showSignup,
                onAuthenticated: coordinator.finishVerification
            )
            .navigationDestination(for: PharmacyAuthenticationRoute.self) { route in
                destination(for: route)
            }
        }
        .tint(PharmacyColor.primary)
    }

    @ViewBuilder
    private func destination(for route: PharmacyAuthenticationRoute) -> some View {
        switch route {
        case .login:
            PharmacyLoginView(
                viewModel: coordinator.loginViewModel,
                onSignupTapped: coordinator.showSignup,
                onAuthenticated: coordinator.finishVerification
            )
        case .registrationDetails:
            PharmacyRegistrationDetailsView(
                viewModel: coordinator.registrationViewModel,
                onContinue: coordinator.submitDetails
            )
        case .accountSetup:
            PharmacyRegistrationAccountView(
                viewModel: coordinator.registrationViewModel,
                onRegister: coordinator.submitRegistration
            )
        case .verification:
            if let viewModel = coordinator.verificationViewModel {
                PharmacyVerificationView(
                    viewModel: viewModel,
                    onVerified: coordinator.finishVerification
                )
            }
        }
    }

}
