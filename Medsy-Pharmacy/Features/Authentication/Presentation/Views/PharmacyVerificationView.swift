//
//  PharmacyVerificationView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

struct PharmacyVerificationView: View {
    @Bindable var viewModel: PharmacyVerificationViewModel
    let onVerified: () -> Void

    var body: some View {
        PharmacyAuthScreenContainer {
            PharmacyAuthHeader(
                title: "pharmacy.auth.verification.title".localized,
                subtitle: "pharmacy.auth.verification.subtitle".localized,
                systemImage: "envelope.fill"
            )

            VStack(spacing: PharmacySpacing.lg) {
                Text("pharmacy.auth.verification.sent_to".localized(viewModel.email))
                    .font(PharmacyColor.sans(14))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .multilineTextAlignment(.center)

                PharmacyOTPInputView(code: Binding(
                    get: { viewModel.code },
                    set: { value in
                        Task {
                            await viewModel.handle(.codeChanged(value))
                        }
                    }
                ))

                PharmacyAuthValidationMessage(message: viewModel.validationMessage)
            }

            PharmacyPrimaryButton(
                title: "pharmacy.auth.verification.action".localized,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.code.count != 6,
                action: verify
            )

            Button(resendTitle) {
                Task {
                    await viewModel.handle(.codeResendRequested)
                }
            }
                .font(PharmacyColor.sans(14, .semibold))
                .foregroundStyle(canResend ? PharmacyColor.primary : PharmacyColor.textSecondary)
                .disabled(!canResend)
        }
        .navigationTitle("pharmacy.auth.verification.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var canResend: Bool {
        viewModel.resendSecondsRemaining == 0 && !viewModel.isLoading
    }

    private var resendTitle: String {
        guard viewModel.resendSecondsRemaining > 0 else {
            return "pharmacy.auth.verification.resend".localized
        }

        return "pharmacy.auth.verification.resend_countdown".localized(viewModel.resendSecondsRemaining)
    }

    private func verify() {
        Task {
            if await viewModel.handle(.verificationSubmitted) {
                onVerified()
            }
        }
    }
}

#Preview {
    NavigationStack {
        PharmacyVerificationView(
            viewModel: PharmacyVerificationViewModel(
                email: "pharmacist@example.com",
                verifyAction: { _, _ in },
                resendAction: { _ in }
            ),
            onVerified: {}
        )
    }
    .environment(LanguageManager.shared)
}
