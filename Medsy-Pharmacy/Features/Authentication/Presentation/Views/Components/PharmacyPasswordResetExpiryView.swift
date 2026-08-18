//
//  PharmacyPasswordResetExpiryView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI
import Foundation

struct PharmacyPasswordResetExpiryView: View {
    let secondsRemaining: Int
    let onRequestNewCode: () -> Void

    var body: some View {
        VStack(spacing: PharmacySpacing.xs) {
            if secondsRemaining > 0 {
                Label(
                    "pharmacy.auth.password_reset.expires_in".localized(formattedTime),
                    systemImage: "clock"
                )
                .font(PharmacyColor.sans(13))
                .foregroundStyle(PharmacyColor.textSecondary)
            } else {
                Text("pharmacy.auth.password_reset.expired.message".localized)
                    .font(PharmacyColor.sans(13))
                    .foregroundStyle(PharmacyColor.danger)
                    .multilineTextAlignment(.center)

                Button(
                    "pharmacy.auth.password_reset.expired.action".localized,
                    action: onRequestNewCode
                )
                .font(PharmacyColor.sans(13, .semibold))
                .foregroundStyle(PharmacyColor.primary)
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
