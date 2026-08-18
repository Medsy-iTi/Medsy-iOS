//
//  PasswordResetResendView.swift
//  Medsy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI
import Foundation

struct PasswordResetResendView: View {
    let secondsRemaining: Int
    let isLoading: Bool
    let confirmationMessage: String?
    let action: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            if secondsRemaining > 0 {
                Text("auth.password_reset.otp.resend_in".localized(formattedTime))
                    .font(.footnote)
                    .foregroundStyle(AppColor.textSec)
                    .accessibilityLabel(
                        "auth.password_reset.otp.resend_accessibility".localized(secondsRemaining)
                    )
            } else {
                Button(action: action) {
                    if isLoading {
                        ProgressView().tint(AppColor.green)
                    } else {
                        Text("auth.password_reset.otp.resend".localized)
                            .font(.footnote.weight(.semibold))
                    }
                }
                .foregroundStyle(AppColor.green)
                .disabled(isLoading)
            }

            if let confirmationMessage {
                Text(confirmationMessage)
                    .font(.footnote)
                    .foregroundStyle(AppColor.green)
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
