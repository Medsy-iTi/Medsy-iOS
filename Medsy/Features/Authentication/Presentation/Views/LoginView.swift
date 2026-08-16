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
    let onAuthenticated: () -> Void

    init(
        viewModel: LoginViewModel,
        onSignupTapped: @escaping () -> Void,
        onAuthenticated: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onSignupTapped = onSignupTapped
        self.onAuthenticated = onAuthenticated
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
    }

}

#Preview {
    LoginView(
        viewModel: LoginViewModel(loginUseCase: PreviewLoginUseCase()),
        onSignupTapped: {},
        onAuthenticated: {}
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
