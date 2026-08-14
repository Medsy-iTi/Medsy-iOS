//
//  ErrorStateView.swift
//  Medsy
//
//  Created by Shahudaa on 22/07/2026.
//


import SwiftUI

struct ErrorStateView: View {
    let icon: String
    let message: String
    let retryTitle: String
    let onRetry: () -> Void

    init(
        icon: String = "wifi.exclamationmark",
        message: String,
        retryTitle: String = "pharmacy.orders.retry".localized,
        onRetry: @escaping () -> Void
    ) {
        self.icon = icon
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: PharmacySpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(PharmacyColor.textSecondary)

            Text(message)
                .font(PharmacyColor.sans(13))
                .foregroundStyle(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)

            PharmacyPrimaryButton(title: retryTitle, style: .soft, height: 40, action: onRetry)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PharmacySpacing.lg)
        .pharmacyCard(elevation: .subtle)
    }
}
