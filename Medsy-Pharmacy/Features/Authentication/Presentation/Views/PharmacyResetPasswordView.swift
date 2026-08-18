//
//  PharmacyResetPasswordView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI

struct PharmacyResetPasswordView: View {
    @State private var viewModel: PharmacyResetPasswordViewModel
    let onReset: () -> Void
    let onRequestNewCode: () -> Void

    init(
        viewModel: PharmacyResetPasswordViewModel,
        onReset: @escaping () -> Void,
        onRequestNewCode: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onReset = onReset
        self.onRequestNewCode = onRequestNewCode
    }

    var body: some View {
        PharmacyAuthScreenContainer {
            PharmacyAuthHeader(
                title: "pharmacy.auth.password_reset.password.title".localized,
                subtitle: "pharmacy.auth.password_reset.password.subtitle".localized,
                systemImage: "lock.rotation"
            )

            VStack(spacing: PharmacySpacing.sm) {
                PharmacyAuthTextField(
                    title: "pharmacy.auth.password_reset.password.new".localized,
                    kind: .newPassword,
                    text: $viewModel.newPassword
                )

                PharmacyAuthTextField(
                    title: "pharmacy.auth.confirm_password".localized,
                    kind: .confirmPassword,
                    text: $viewModel.confirmedPassword
                )
            }

            PharmacyPasswordRequirementsView()
            PharmacyAuthValidationMessage(message: viewModel.validationMessage)

            PharmacyPasswordResetExpiryView(
                secondsRemaining: viewModel.expirySecondsRemaining,
                onRequestNewCode: onRequestNewCode
            )

            PharmacyPrimaryButton(
                title: "pharmacy.auth.password_reset.password.action".localized,
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
        .navigationTitle("pharmacy.auth.password_reset.password.navigation_title".localized)
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
