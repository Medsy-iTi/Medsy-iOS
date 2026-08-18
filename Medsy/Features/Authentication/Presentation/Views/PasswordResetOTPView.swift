//
//  PasswordResetOTPView.swift
//  Medsy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI

struct PasswordResetOTPView: View {
    @State private var viewModel: PasswordResetOTPViewModel
    let onVerified: (PasswordResetAuthorization) -> Void

    init(
        viewModel: PasswordResetOTPViewModel,
        onVerified: @escaping (PasswordResetAuthorization) -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onVerified = onVerified
    }

    var body: some View {
        AuthScreenContainer {
            AuthHeader(
                title: "auth.password_reset.otp.title".localized,
                subtitle: "auth.password_reset.otp.subtitle".localized
            )

            VStack(spacing: 18) {
                Text("auth.password_reset.otp.sent_to".localized(viewModel.email))
                    .font(.subheadline)
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)

                OTPInputView(
                    code: Binding(
                        get: { viewModel.code },
                        set: viewModel.updateCode
                    )
                )

                AuthValidationMessage(message: viewModel.validationMessage)

                PasswordResetResendView(
                    secondsRemaining: viewModel.resendSecondsRemaining,
                    isLoading: viewModel.isResending,
                    confirmationMessage: viewModel.resendConfirmationMessage
                ) {
                    Task { await viewModel.resend() }
                }
            }

            PrimaryButton(
                title: "auth.password_reset.otp.action".localized,
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
        .navigationTitle("auth.password_reset.otp.navigation_title".localized)
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
