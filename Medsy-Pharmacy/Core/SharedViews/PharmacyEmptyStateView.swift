//
//  PharmacyEmptyStateView.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//



import SwiftUI

struct PharmacyEmptyStateView: View {
    let lottieName: String
    let title: String
    let message: String
    var retryTitle: String? = nil
    var onRetry: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: PharmacySpacing.md) {
            Spacer()

			PharmacyLottieView(animationName: lottieName)
                .frame(width: 200, height: 200)

            Text(title)
                .font(PharmacyColor.sans(18, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Text(message)
                .font(PharmacyColor.sans(14))
                .foregroundStyle(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, PharmacySpacing.xl)
            
            if let retryTitle = retryTitle, let onRetry = onRetry {
				PharmacyPrimaryButton(title: retryTitle, action: onRetry)
                .padding(.top, PharmacySpacing.md)
            }

			Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PharmacySpacing.md)
    }
}

