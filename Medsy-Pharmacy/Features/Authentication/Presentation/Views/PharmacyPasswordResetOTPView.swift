//
//  PharmacyPasswordResetOTPView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI

struct PharmacyPasswordResetOTPView: View {
    @State private var viewModel: PharmacyPasswordResetOTPViewModel
    let onVerified: (PharmacyPasswordResetAuthorization) -> Void

    init(
        viewModel: PharmacyPasswordResetOTPViewModel,
        onVerified: @escaping (PharmacyPasswordResetAuthorization) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onVerified = onVerified
    }

    var body: some View {
        PharmacyAuthScreenContainer {
            PharmacyAuthHeader(
                title: "pharmacy.auth.password_reset.otp.title".localized,
                subtitle: "pharmacy.auth.password_reset.otp.subtitle".localized,
                systemImage: "number.square.fill"
            )

            VStack(spacing: PharmacySpacing.md) {
                Text("pharmacy.auth.password_reset.otp.sent_to".localized(viewModel.email))
                    .font(PharmacyColor.sans(14))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .multilineTextAlignment(.center)

                PharmacyOTPInputView(
                    code: Binding(
                        get: { viewModel.code },
                        set: viewModel.updateCode
                    )
                )

                PharmacyAuthValidationMessage(message: viewModel.validationMessage)

                PharmacyPasswordResetResendView(
                    secondsRemaining: viewModel.resendSecondsRemaining,
                    isLoading: viewModel.isResending,
                    confirmationMessage: viewModel.resendConfirmationMessage
                ) {
                    Task { await viewModel.resend() }
                }
            }

            PharmacyPrimaryButton(
                title: "pharmacy.auth.password_reset.otp.action".localized,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.code.count != 6 || viewModel.isResending
            ) {
                Task {
                    if let authorization = await viewModel.verify() {
                        onVerified(authorization)
                    }
                }
            }
        }
        .navigationTitle("pharmacy.auth.password_reset.otp.navigation_title".localized)
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
