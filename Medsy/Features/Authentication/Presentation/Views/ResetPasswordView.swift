//
//  ResetPasswordView.swift
//  Medsy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var viewModel: ResetPasswordViewModel
    let onReset: () -> Void
    let onRequestNewCode: () -> Void

    init(
        viewModel: ResetPasswordViewModel,
        onReset: @escaping () -> Void,
        onRequestNewCode: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onReset = onReset
        self.onRequestNewCode = onRequestNewCode
    }

    var body: some View {
        AuthScreenContainer {
            AuthHeader(
                title: "auth.password_reset.password.title".localized,
                subtitle: "auth.password_reset.password.subtitle".localized
            )

            VStack(spacing: 12) {
                CustomTextField(
                    title: "auth.password_reset.password.new".localized,
                    type: .newPassword,
                    text: $viewModel.newPassword,
                    maximumLength: AuthenticationInputValidator.passwordMaximumLength
                )

                CustomTextField(
                    title: "auth.confirm_password".localized,
                    type: .confirmPassword,
                    text: $viewModel.confirmedPassword,
                    maximumLength: AuthenticationInputValidator.passwordMaximumLength
                )
            }

            PasswordRequirementsView()
            AuthValidationMessage(message: viewModel.validationMessage)

            PasswordResetExpiryView(
                secondsRemaining: viewModel.expirySecondsRemaining,
                onRequestNewCode: onRequestNewCode
            )

            PrimaryButton(
                title: "auth.password_reset.password.action".localized,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.isExpired || viewModel.isLoading
            ) {
                Task {
                    if await viewModel.submit() {
                        onReset()
                    }
                }
            }
        }
        .navigationTitle("auth.password_reset.password.navigation_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .showCustomAlert(
            title: "common.error".localized,
            alertMessage: Binding(
                get: { viewModel.alertMessage },
                set: { if $0 == nil { viewModel.dismissError() } }
            )
        )
    }
}
