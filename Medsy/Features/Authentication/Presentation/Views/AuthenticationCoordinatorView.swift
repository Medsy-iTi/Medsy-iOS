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
                viewModel: coordinator.makeLoginViewModel(),
                onSignupTapped: coordinator.showSignup,
                onForgotPasswordTapped: coordinator.showForgotPassword,
                onAuthenticated: coordinator.finishAuthentication,
                showsPasswordResetSuccess: coordinator.showsPasswordResetSuccess,
                onPasswordResetSuccessDismissed: coordinator.dismissPasswordResetSuccess
            )
            .navigationDestination(for: AuthenticationRoute.self) { route in
                switch route {
                case .login:
                    LoginView(
                        viewModel: coordinator.makeLoginViewModel(),
                        onSignupTapped: coordinator.showSignup,
                        onForgotPasswordTapped: coordinator.showForgotPassword,
                        onAuthenticated: coordinator.finishAuthentication,
                        showsPasswordResetSuccess: coordinator.showsPasswordResetSuccess,
                        onPasswordResetSuccessDismissed: coordinator.dismissPasswordResetSuccess
                    )
                case .signup:
                    SignupView(
                        viewModel: coordinator.makeSignupViewModel(),
                        onLoginTapped: coordinator.showLogin,
                        onVerificationRequested: coordinator.showVerification
                    )
                case let .verification(email):
                    VerificationView(
                        email: email,
                        viewModel: coordinator.makeVerificationViewModel(),
                        onAuthenticated: coordinator.finishAuthentication
                    )
                case .forgotPassword:
                    if let viewModel = coordinator.forgotPasswordViewModel {
                        ForgotPasswordView(
                            viewModel: viewModel,
                            onCodeRequested: coordinator.showPasswordResetOTP
                        )
                    }
                case .passwordResetOTP:
                    if let viewModel = coordinator.passwordResetOTPViewModel {
                        PasswordResetOTPView(
                            viewModel: viewModel,
                            onVerified: coordinator.showResetPassword
                        )
                    }
                case .resetPassword:
                    if let viewModel = coordinator.resetPasswordViewModel {
                        ResetPasswordView(
                            viewModel: viewModel,
                            onReset: coordinator.finishPasswordReset,
                            onRequestNewCode: coordinator.requestAnotherResetCode
                        )
                    }
                }
            }
        }
        .tint(AppColor.green)
    }
}
