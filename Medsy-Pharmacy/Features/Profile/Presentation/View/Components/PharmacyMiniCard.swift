//
//  PharmacyMiniCard.swift
//  Medsy-Pharmacy
//
//  Mini pharmacy card for profile view
//

import SwiftUI

struct PharmacyMiniCard: View {
    let pharmacy: PharmacySummary
    var showsChevron: Bool = true

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            ZStack {
                Circle().fill(PharmacyColor.primary)
                Image(systemName: "cross.case.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .semibold))
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: PharmacySpacing.xxs) {
                    Text(pharmacy.name)
                        .font(PharmacyColor.sans(15, .semibold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                    if pharmacy.isVerified {
                        VerifiedBadgeIcon(size: 14)
                    }
                }
                Text(pharmacy.address)
                    .font(PharmacyColor.sans(12))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }

            Spacer(minLength: 0)

            if showsChevron {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .flipsForRightToLeftLayoutDirection(true)
            }
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }
}
