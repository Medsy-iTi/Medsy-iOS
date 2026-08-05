//
//  ProfileNavigationRow.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct ProfileNavigationRow: View {
    let icon: String
    let iconTint: Color
    let title: String
    var subtitle: String? = nil
    var trailingText: String? = nil
    let action: () -> Void

    init(
        icon: String,
        iconTint: Color = PharmacyColor.primary,
        title: String,
        subtitle: String? = nil,
        trailingText: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.iconTint = iconTint
        self.title = title
        self.subtitle = subtitle
        self.trailingText = trailingText
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: PharmacySpacing.sm) {
                ZStack {
                    Circle()
                        .fill(iconTint.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(iconTint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(PharmacyColor.sans(15, .semibold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(PharmacyColor.sans(13))
                            .foregroundStyle(PharmacyColor.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: PharmacySpacing.xs)

                if let trailingText {
                    Text(trailingText)
                        .font(PharmacyColor.sans(13, .medium))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }

                Image(systemName: "chevron.forward")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PharmacyColor.textSecondary.opacity(0.6))
            }
            .padding(.horizontal, PharmacySpacing.md)
            .padding(.vertical, PharmacySpacing.sm + 2)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}
