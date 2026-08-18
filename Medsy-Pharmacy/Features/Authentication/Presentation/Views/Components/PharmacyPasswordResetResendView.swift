//
//  PharmacyPasswordResetResendView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI
import Foundation

struct PharmacyPasswordResetResendView: View {
    let secondsRemaining: Int
    let isLoading: Bool
    let confirmationMessage: String?
    let action: () -> Void

    var body: some View {
        VStack(spacing: PharmacySpacing.xs) {
            if secondsRemaining > 0 {
                Text("pharmacy.auth.password_reset.otp.resend_in".localized(formattedTime))
                    .font(PharmacyColor.sans(13))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .accessibilityLabel(
                        "pharmacy.auth.password_reset.otp.resend_accessibility".localized(
                            secondsRemaining
                        )
                    )
            } else {
                Button(action: action) {
                    if isLoading {
                        ProgressView().tint(PharmacyColor.primary)
                    } else {
                        Text("pharmacy.auth.password_reset.otp.resend".localized)
                            .font(PharmacyColor.sans(13, .semibold))
                    }
                }
                .foregroundStyle(PharmacyColor.primary)
                .disabled(isLoading)
            }

            if let confirmationMessage {
                Text(confirmationMessage)
                    .font(PharmacyColor.sans(13))
                    .foregroundStyle(PharmacyColor.primary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var formattedTime: String {
        "\(formattedNumber(secondsRemaining / 60)):\(formattedNumber(secondsRemaining % 60))"
    }

    private func formattedNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.minimumIntegerDigits = 2
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%02d", value)
    }
}
