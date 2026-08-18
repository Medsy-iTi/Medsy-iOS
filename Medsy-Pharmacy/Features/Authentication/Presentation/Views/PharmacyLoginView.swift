//  PharmacyLoginView.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 17/07/2026.
//

import SwiftUI

struct PharmacyLoginView: View {
    @State private var viewModel: PharmacyLoginViewModel
    let onSignupTapped: () -> Void
    let onForgotPasswordTapped: (String) -> Void
    let onAuthenticated: () -> Void
    let showsPasswordResetSuccess: Bool
    let onPasswordResetSuccessDismissed: () -> Void

    init(
        viewModel: PharmacyLoginViewModel,
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
        PharmacyAuthScreenContainer {
            PharmacyAuthHeader(
                title: "pharmacy.auth.login.title".localized,
                subtitle: "pharmacy.auth.login.subtitle".localized
            )

            VStack(spacing: PharmacySpacing.md) {
                VStack(spacing: PharmacySpacing.sm) {
                    PharmacyAuthTextField(
                        title: "pharmacy.auth.email".localized,
                        kind: .email,
                        text: $viewModel.email
                    )

                    PharmacyAuthTextField(
                        title: "pharmacy.auth.password".localized,
                        kind: .password,
                        text: $viewModel.password
                    )

                    PharmacyForgotPasswordButton {
                        onForgotPasswordTapped(viewModel.email)
                    }
                }

                Spacer().frame(height: 24)

                PharmacyAuthValidationMessage(message: viewModel.validationMessage)

                PharmacyPrimaryButton(
                    title: "pharmacy.auth.login.action".localized,
                    isLoading: viewModel.isLoading,
                    isDisabled: viewModel.isLoading
                ) {
                    Task {
                        if await viewModel.submit() {
                            onAuthenticated()
                        }
                    }
                }
            }

            PharmacyAuthPrompt(
                leadingText: "pharmacy.auth.no_account".localized,
                actionTitle: "pharmacy.auth.signup.link".localized,
                action: onSignupTapped
            )
            .padding(.top, PharmacySpacing.xs)
        }
        .navigationBarBackButtonHidden()
        .alert(
            "common.error".localized,
            isPresented: Binding(
                get: { viewModel.alertMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.dismissError()
                    }
                }
            )
        ) {
            Button("common.ok".localized) {
                viewModel.dismissError()
            }
        } message: {
            if let alertMessage = viewModel.alertMessage {
                Text(alertMessage)
            }
        }
        .alert(
            "pharmacy.auth.password_reset.success.title".localized,
            isPresented: Binding(
                get: { showsPasswordResetSuccess },
                set: { if !$0 { onPasswordResetSuccessDismissed() } }
            )
        ) {
            Button("common.ok".localized, action: onPasswordResetSuccessDismissed)
        } message: {
            Text("pharmacy.auth.password_reset.success.message".localized)
        }
    }
}

#Preview {
    PharmacyLoginView(
        viewModel: PharmacyLoginViewModel(
            loginAction: { _ in
                PharmacyAuthenticatedSession(
                    accessToken: "",
                    refreshToken: "",
                    user: PharmacyAuthenticatedUser(
                        id: 0,
                        email: "",
                        firstName: "",
                        lastName: "",
                        role: "",
                        homeAddress: nil,
                        dateOfBirth: nil
                    )
                )
            }
        ),
        onSignupTapped: {},
        onForgotPasswordTapped: { _ in },
        onAuthenticated: {},
        showsPasswordResetSuccess: false,
        onPasswordResetSuccessDismissed: {}
    )
    .environment(LanguageManager.shared)
}
