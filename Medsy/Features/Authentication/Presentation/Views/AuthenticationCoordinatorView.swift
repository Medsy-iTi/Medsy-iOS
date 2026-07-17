//
//  AuthenticationCoordinatorView.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import SwiftUI


struct AuthenticationCoordinatorView: View {
    @State private var coordinator: AuthenticationCoordinator

    init(coordinator: AuthenticationCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            LoginView(
                onSignupTapped: coordinator.showSignup,
                onAuthenticated: coordinator.finishAuthentication
            )
            .navigationDestination(for: AuthenticationRoute.self) { route in
                switch route {
                case .login:
                    LoginView(
                        onSignupTapped: coordinator.showSignup,
                        onAuthenticated: coordinator.finishAuthentication
                    )
                case .signup:
                    SignupView(
                        onLoginTapped: coordinator.showLogin,
                        onVerificationRequested: coordinator.showVerification
                    )
                case let .verification(email):
                    VerificationView(
                        email: email,
                        onAuthenticated: coordinator.finishAuthentication
                    )
                }
            }
        }
        .tint(AppColor.green)
    }
}
