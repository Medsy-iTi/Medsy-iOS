//
//  PharmacyInfoCardView.swift
//  Medsy
//
//  Created by Shahudaa on 18/07/2026.
//


import SwiftUI

struct PharmacyInfoCardView: View {
    let profile: PharmacyProfile
    var onEdit: (() -> Void)? = nil
    
    var body: some View {
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

                    Text(profile.pharmacyName ?? "pharmacy_card.not_assigned".localized)
                        .font(PharmacyColor.sans(13))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
                
                
                Spacer(minLength: 0)

                if let onEdit {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(PharmacyColor.primary)
                            .frame(width: 36, height: 36)
                            .background(PharmacyColor.primary.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("profile.edit.title".localized)
                }
            }
            .pharmacyCard(elevation: .subtle)
            .accessibilityElement(children: .combine)
    }
}
