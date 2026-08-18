//
//  ForgotPasswordView.swift
//  Medsy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var viewModel: ForgotPasswordViewModel
    let onCodeRequested: (String) -> Void

    init(
        viewModel: ForgotPasswordViewModel,
        onCodeRequested: @escaping (String) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onCodeRequested = onCodeRequested
    }

    var body: some View {
        AuthScreenContainer {
            AuthHeader(
                title: "auth.password_reset.email.title".localized,
                subtitle: "auth.password_reset.email.subtitle".localized
            )

            CustomTextField(
                title: "auth.email".localized,
                type: .email,
                text: $viewModel.email,
                maximumLength: AuthenticationInputValidator.emailMaximumLength
            )

            AuthValidationMessage(message: viewModel.validationMessage)

            PrimaryButton(
                title: "auth.password_reset.email.action".localized,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.isLoading
            ) {
                Task {
                    if let email = await viewModel.submit() {
                        onCodeRequested(email)
                    }
                }
            }
        }
        .navigationTitle("auth.password_reset.email.navigation_title".localized)
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
