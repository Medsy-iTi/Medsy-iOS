//
//  ProfileHeaderCard.swift
//  Medsy-Pharmacy
//
//  Profile header card with avatar and info
//

import SwiftUI

struct ProfileHeaderCard: View {
    let pharmacist: Pharmacist
    var trailing: AnyView? = nil

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            PharmacistAvatarView(pharmacist: pharmacist)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: PharmacySpacing.xxs) {
                    Text(pharmacist.fullName)
                        .font(PharmacyColor.sans(16, .semibold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                    if pharmacist.isVerified {
                        VerifiedBadgeIcon(size: 15)
                    }
                }
                Text("profile.role_pharmacist".localized)
                    .font(PharmacyColor.sans(13))
                    .foregroundStyle(PharmacyColor.textSecondary)
                Text("profile.experience_years".localized(pharmacist.yearsOfExperience))
                    .font(PharmacyColor.sans(12))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }

            Spacer(minLength: 0)

            if let trailing {
                trailing
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
