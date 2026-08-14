//
//  PharmacyCardContainer.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import SwiftUI



// MARK: - Error state

/// Reusable full-screen error state with a retry action.
struct PharmacyErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: PharmacySpacing.lg) {
            PharmacyIconTile(
                systemImage: "exclamationmark.triangle.fill",
                tint: PharmacyColor.warning,
                background: PharmacyColor.warningSoft,
                size: 64,
                iconSize: 26
            )

            Text(message)
                .font(PharmacyColor.sans(15))
                .foregroundStyle(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, PharmacySpacing.lg)

            PharmacyPrimaryButton(
                title: "common.retry".localized,
                style: .soft,
                action: onRetry
            )
        }
        .padding(PharmacySpacing.lg)
        .pharmacyCard(elevation: .raised)
        .padding(PharmacySpacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PharmacyColor.bg)
    }
}

// MARK: - Section divider

/// Thin divider tinted to the theme's border color, saving the
/// repeated `Divider().background(PharmacyColor.border)` pattern.
struct PharmacyDivider: View {
    var body: some View {
        Divider().background(PharmacyColor.border)
    }
}

// MARK: - Badge

/// Small rounded pill badge (e.g. status / fulfillment indicators),
/// reusable anywhere a colored capsule label is needed.
struct PharmacyBadge: View {
    let text: String
    var systemImage: String? = nil
    var tint: Color = PharmacyColor.primary
    var tintSoft: Color = PharmacyColor.primarySoft

    var body: some View {
        HStack(spacing: PharmacySpacing.xxs) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 13))
            }
            Text(text)
                .font(PharmacyColor.sans(13, .medium))
        }
        .foregroundStyle(tint)
        .padding(.horizontal, PharmacySpacing.sm)
        .padding(.vertical, PharmacySpacing.xxs + 2)
        .background(tintSoft)
        .clipShape(Capsule())
    }
}
