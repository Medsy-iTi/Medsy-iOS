//
//  LoginView.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel: LoginViewModel
    let onSignupTapped: () -> Void
    let onForgotPasswordTapped: (String) -> Void
    let onAuthenticated: () -> Void
    let showsPasswordResetSuccess: Bool
    let onPasswordResetSuccessDismissed: () -> Void

    init(
        viewModel: LoginViewModel,
        onSignupTapped: @escaping () -> Void,
        onForgotPasswordTapped: @escaping (String) -> Void,
        onAuthenticated: @escaping () -> Void,
        showsPasswordResetSuccess: Bool,
        onPasswordResetSuccessDismissed: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSignupTapped = onSignupTapped
        self.onForgotPasswordTapped = onForgotPasswordTapped
        self.onAuthenticated = onAuthenticated
        self.showsPasswordResetSuccess = showsPasswordResetSuccess
        self.onPasswordResetSuccessDismissed = onPasswordResetSuccessDismissed
    }

    var body: some View {
        AuthScreenContainer {
            AuthHeader(
                title: "auth.login.title".localized,
                subtitle: "auth.login.subtitle".localized,
                showsBrand: true
            )

            VStack(spacing: 12) {
                CustomTextField(
                    title: "auth.email".localized,
                    type: .email,
                    text: $viewModel.email,
                    maximumLength: AuthenticationInputValidator.emailMaximumLength
                )
                CustomTextField(title: "auth.password".localized, type: .password, text: $viewModel.password)

                ForgotPasswordButton {
                    onForgotPasswordTapped(viewModel.email)
                }
            }

            AuthValidationMessage(message: viewModel.validationMessage)

            PrimaryButton(
                title: "auth.login.action".localized,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.isLoading
            ) {
                Task {
                    if await viewModel.submit() {
                        onAuthenticated()
                    }
                }
            }

            AuthPrompt(
                leadingText: "auth.no_account".localized,
                actionTitle: "auth.signup.link".localized,
                action: onSignupTapped
            )
        }
        .navigationBarBackButtonHidden()
        .showCustomAlert(
            title: "common.error".localized,
            alertMessage: Binding(
                get: { viewModel.alertMessage },
                set: { value in
                    if value == nil {
                        viewModel.dismissError()
                    }
                }
            )
        )
        .alert(
            "auth.password_reset.success.title".localized,
            isPresented: Binding(
                get: { showsPasswordResetSuccess },
                set: { if !$0 { onPasswordResetSuccessDismissed() } }
            )
        ) {
            Button("common.ok".localized, action: onPasswordResetSuccessDismissed)
        } message: {
            Text("auth.password_reset.success.message".localized)
        }
    }

}

#Preview {
    LoginView(
        viewModel: LoginViewModel(loginUseCase: PreviewLoginUseCase()),
        onSignupTapped: {},
        onForgotPasswordTapped: { _ in },
        onAuthenticated: {},
        showsPasswordResetSuccess: false,
        onPasswordResetSuccessDismissed: {}
    )
        .environment(LanguageManager.shared)
}

private struct PreviewLoginUseCase: LoginUseCaseProtocol {
    func execute(input: LoginInput) async throws -> AuthenticatedSession {
        AuthenticatedSession(
            accessToken: "",
            refreshToken: "",
            user: AuthenticatedUser(
                id: 0,
                email: input.email,
                firstName: "",
                lastName: "",
                role: "CUSTOMER",
                homeAddress: "",
                dateOfBirth: "",
                homeLatitude: nil,
                homeLongitude: nil
            )
        )
    }
}
