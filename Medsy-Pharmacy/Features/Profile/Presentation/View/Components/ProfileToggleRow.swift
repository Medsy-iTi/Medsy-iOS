//
//  ProfileToggleRow.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct ProfileToggleRow: View {
    let icon: String
    let title: String
    let badgeText: String
    let isLoading: Bool
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            ZStack {
                Circle()
                    .fill(PharmacyColor.primary.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }

            Text(title)
                .font(PharmacyColor.sans(15, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Spacer(minLength: PharmacySpacing.xs)

            if isLoading {
                ProgressView()
                    .controlSize(.small)
                    .padding(.trailing, PharmacySpacing.xxs)
            } else {
                Text(badgeText)
                    .font(PharmacyColor.sans(12, .bold))
                    .foregroundStyle(isOn ? PharmacyColor.success : PharmacyColor.textSecondary)
                    .padding(.horizontal, PharmacySpacing.xs)
                    .padding(.vertical, 4)
                    .background(
                        (isOn ? PharmacyColor.successSoft : PharmacyColor.mutedSurface),
                        in: Capsule()
                    )
            }

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(PharmacyColor.primary)
                .disabled(isLoading)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm + 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(badgeText)
    }
}
