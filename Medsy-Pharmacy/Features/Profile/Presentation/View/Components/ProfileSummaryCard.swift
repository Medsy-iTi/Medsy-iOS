//
//  ProfileSummaryCard.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct ProfileSummaryCard: View {
    let profile: PharmacyProfile
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: PharmacySpacing.md) {
                PharmacistAvatarView(pharmacist: profile.toPharmacist(), diameter: 64)

                VStack(alignment: .leading, spacing: PharmacySpacing.xxs) {
                    HStack(spacing: PharmacySpacing.xxs) {
                        Text(profile.fullName)
                            .font(.headline)
                            .foregroundStyle(PharmacyColor.textPrimary)
                            .lineLimit(1)

                        VerifiedBadgeIcon(size: 15)
                    }

                    Text("profile.role_pharmacist".localized)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(PharmacyColor.primary)

                    Text(profile.email)
                        .font(.caption)
                        .foregroundStyle(PharmacyColor.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .pharmacyCard(cornerRadius: PharmacyRadius.xl, elevation: .raised)
        }
        .buttonStyle(PharmacyPressableButtonStyle())
    }
}
