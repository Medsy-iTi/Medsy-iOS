//
//  ProfileValueRow.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct ProfileValueRow: View {
    let icon: String
    let title: String
    let value: String
    let actionTitle: String
    let action: () -> Void

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

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(PharmacyColor.sans(15, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                Text(value)
                    .font(PharmacyColor.sans(13))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .environment(\.layoutDirection, .leftToRight) 
            }

            Spacer(minLength: PharmacySpacing.xs)

            Button(action: action) {
                Text(actionTitle)
                    .font(PharmacyColor.sans(13, .bold))
                    .foregroundStyle(PharmacyColor.primary)
                    .padding(.horizontal, PharmacySpacing.sm)
                    .padding(.vertical, 6)
                    .background(PharmacyColor.primarySoft, in: Capsule())
            }
            .buttonStyle(PharmacyPressableButtonStyle())
            .accessibilityLabel(actionTitle + " " + title)
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.vertical, PharmacySpacing.sm + 2)
    }
}
