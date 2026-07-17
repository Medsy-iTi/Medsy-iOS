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
                .disabled(viewModel.isLoading)

                PharmacyAuthValidationMessage(message: viewModel.validationMessage)
            }

            PharmacyPrimaryButton(
                title: "pharmacy.auth.verification.action".localized,
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.code.count != 6,
                action: verify
            )

        }
        .navigationTitle("pharmacy.auth.verification.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isLoading)
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
                verifyAction: { _, _ in }
            ),
            onVerified: {}
        )
    }
    .environment(LanguageManager.shared)
}
