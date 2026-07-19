//
//  PharmacyInfoCardView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct PharmacyInfoCardView: View {
    let profile: PharmacyProfile
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PharmacySpacing.sm) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundStyle(PharmacyColor.primary)
                    .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(profile.fullName)
                            .font(PharmacyColor.sans(16, .bold))
                            .foregroundStyle(PharmacyColor.textPrimary)
                            .lineLimit(1)
                        if profile.isPharmacyAdmin {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(PharmacyColor.primary)
                        }
                    }

                    Text(profile.pharmacyName ?? "No Pharmacy Assigned".localized)
                        .font(PharmacyColor.sans(13))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }

                Spacer(minLength: PharmacySpacing.xs)

                Image(systemName: "chevron.forward")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PharmacyColor.textSecondary.opacity(0.6))
            }
            .padding(PharmacySpacing.md)
            .background(PharmacyColor.card)
            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}
