//
//  PharmacyVerificationView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

struct PharmacyVerificationView: View {
    let email: String
    @Binding var code: String
    let validationMessage: String?
    let isLoading: Bool
    let resendSecondsRemaining: Int
    let onVerify: () -> Void
    let onResend: () -> Void

    var body: some View {
        PharmacyAuthScreenContainer {
            PharmacyAuthHeader(
                title: "pharmacy.auth.verification.title".localized,
                subtitle: "pharmacy.auth.verification.subtitle".localized,
                systemImage: "envelope.fill"
            )

            VStack(spacing: PharmacySpacing.lg) {
                Text("pharmacy.auth.verification.sent_to".localized(email))
                    .font(PharmacyColor.sans(14))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .multilineTextAlignment(.center)

                PharmacyOTPInputView(code: $code)

                PharmacyAuthValidationMessage(message: validationMessage)
            }

            PharmacyPrimaryButton(
                title: "pharmacy.auth.verification.action".localized,
                isLoading: isLoading,
                isDisabled: code.count != 6,
                action: onVerify
            )

            Button(resendTitle, action: onResend)
                .font(PharmacyColor.sans(14, .semibold))
                .foregroundStyle(canResend ? PharmacyColor.primary : PharmacyColor.textSecondary)
                .disabled(!canResend)
        }
        .navigationTitle("pharmacy.auth.verification.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var canResend: Bool {
        resendSecondsRemaining == 0 && !isLoading
    }

    private var resendTitle: String {
        guard resendSecondsRemaining > 0 else {
            return "pharmacy.auth.verification.resend".localized
        }

        return "pharmacy.auth.verification.resend_countdown".localized(resendSecondsRemaining)
    }
}

#Preview {
    NavigationStack {
        PharmacyVerificationView(
            email: "pharmacist@example.com",
            code: .constant("123"),
            validationMessage: nil,
            isLoading: false,
            resendSecondsRemaining: 32,
            onVerify: {},
            onResend: {}
        )
    }
    .environment(LanguageManager.shared)
}
