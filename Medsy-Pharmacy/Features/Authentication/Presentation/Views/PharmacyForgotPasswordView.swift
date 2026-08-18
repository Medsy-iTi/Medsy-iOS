//
//  PharmacyForgotPasswordView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI

struct PharmacyForgotPasswordView: View {
    @State private var viewModel: PharmacyForgotPasswordViewModel
    let onCodeRequested: (String) -> Void

    init(
        viewModel: PharmacyForgotPasswordViewModel,
        onCodeRequested: @escaping (String) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onCodeRequested = onCodeRequested
    }

    var body: some View {
        PharmacyAuthScreenContainer {
            PharmacyAuthHeader(
                title: "pharmacy.auth.password_reset.email.title".localized,
                subtitle: "pharmacy.auth.password_reset.email.subtitle".localized,
                systemImage: "envelope.badge"
            )

            PharmacyAuthTextField(
                title: "pharmacy.auth.email".localized,
                kind: .email,
                text: $viewModel.email
            )

            PharmacyAuthValidationMessage(message: viewModel.validationMessage)

            PharmacyPrimaryButton(
                title: "pharmacy.auth.password_reset.email.action".localized,
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
        .navigationTitle("pharmacy.auth.password_reset.email.navigation_title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "common.error".localized,
            isPresented: Binding(
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.dismissError() } }
            )
        ) {
            Button("common.ok".localized) { viewModel.dismissError() }
        } message: {
            if let message = viewModel.alertMessage { Text(message) }
        }
    }
}
