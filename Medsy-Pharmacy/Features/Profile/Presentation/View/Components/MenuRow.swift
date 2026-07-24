//
//  MenuRow.swift
//  Medsy-Pharmacy
//
//  Menu row component for profile menu items
//

import SwiftUI

struct MenuRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var tint: Color = PharmacyColor.primary
    var showsChevron: Bool = true
    var isDestructive: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PharmacySpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: PharmacyRadius.sm)
                        .fill(isDestructive ? PharmacyColor.danger.opacity(0.12) : tint.opacity(0.12))
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(isDestructive ? PharmacyColor.danger : tint)
                }
                .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(PharmacyColor.sans(14, .medium))
                        .foregroundStyle(isDestructive ? PharmacyColor.danger : PharmacyColor.textPrimary)
                    if let subtitle {
                        Text(subtitle)
                            .font(PharmacyColor.sans(12))
                            .foregroundStyle(PharmacyColor.textSecondary)
                    }
                }

                Spacer(minLength: 0)

                if showsChevron {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(PharmacyColor.textSecondary)
                        .flipsForRightToLeftLayoutDirection(true)
                }
            }
            .padding(.vertical, PharmacySpacing.sm)
            .padding(.horizontal, PharmacySpacing.md)
        }
        .buttonStyle(.plain)
        .background(PharmacyColor.card)
    }
}
