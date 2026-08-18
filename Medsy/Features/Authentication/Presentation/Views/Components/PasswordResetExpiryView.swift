//
//  PasswordResetExpiryView.swift
//  Medsy
//
//  Created by Ehab Salah on 18/08/2026.
//

import SwiftUI
import Foundation

struct PasswordResetExpiryView: View {
    let secondsRemaining: Int
    let onRequestNewCode: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            if secondsRemaining > 0 {
                Label(
                    "auth.password_reset.expires_in".localized(formattedTime),
                    systemImage: "clock"
                )
                .font(.footnote)
                .foregroundStyle(AppColor.textSec)
            } else {
                Text("auth.password_reset.expired.message".localized)
                    .font(.footnote)
                    .foregroundStyle(AppColor.errorRed)
                    .multilineTextAlignment(.center)

                Button("auth.password_reset.expired.action".localized, action: onRequestNewCode)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColor.green)
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
