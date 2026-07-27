//
//  PharmacyCardContainer.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import SwiftUI


struct PharmacyCardContainer: ViewModifier {
    var cornerRadius: CGFloat = PharmacyRadius.lg
    var padding: CGFloat? = PharmacySpacing.md

    func body(content: Content) -> some View {
        content
            .padding(padding ?? 0)
            .background(PharmacyColor.card)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            )
            .pharmacyCardShadow()
    }
}

struct PharmacyCardShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(
            color: Color.black.opacity(PharmacyAppSettings.shared.isDarkMode ? 0.35 : 0.06),
            radius: 10,
            x: 0,
            y: 4
        )
    }
}

extension View {


    func pharmacyCard(cornerRadius: CGFloat = PharmacyRadius.lg, padding: CGFloat? = PharmacySpacing.md) -> some View {
        modifier(PharmacyCardContainer(cornerRadius: cornerRadius, padding: padding))
    }


    func pharmacyCardShadow() -> some View {
        modifier(PharmacyCardShadow())
    }
}



// MARK: - Error state

/// Reusable full-screen error state with a retry action.
struct PharmacyErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: PharmacySpacing.lg) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(PharmacyColor.warning)

            Text(message)
                .font(PharmacyColor.sans(15))
                .foregroundStyle(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, PharmacySpacing.lg)

            Button(action: onRetry) {
                Text("common.retry".localized)
                    .font(PharmacyColor.sans(15, .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, PharmacySpacing.lg)
                    .padding(.vertical, PharmacySpacing.sm)
                    .background(PharmacyColor.primary)
                    .clipShape(Capsule())
            }
        }
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
