//
//  ProfileErrorView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct ProfileErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: PharmacySpacing.md) {
            Spacer(minLength: 40)

            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(PharmacyColor.textSecondary)

            Text(message)
                .font(PharmacyColor.sans(15, .medium))
                .foregroundStyle(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, PharmacySpacing.lg)

            PharmacyPrimaryButton(title: "retry".localized, action: retryAction)
                .frame(maxWidth: 220)

            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity)
    }
}
