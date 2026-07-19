//
//  PharmacyInformationCard.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftUI

struct PharmacyInformationCard: View {
    let pharmacy: PharmacyManagementDisplayModel

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.md) {
            HStack(spacing: PharmacySpacing.sm) {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(PharmacyColor.primary, in: RoundedRectangle(cornerRadius: PharmacyRadius.md))

                VStack(alignment: .leading, spacing: PharmacySpacing.xxs) {
                    Text(pharmacy.name)
                        .font(PharmacyColor.sans(18, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)

                    Text(pharmacy.isAdmin ? "pharmacy.management.role.admin".localized : "pharmacy.management.role.member".localized)
                        .font(PharmacyColor.sans(12, .semibold))
                        .foregroundStyle(PharmacyColor.primary)
                        .padding(.horizontal, PharmacySpacing.sm)
                        .padding(.vertical, PharmacySpacing.xxs)
                        .background(PharmacyColor.primarySoft, in: Capsule())
                }

                Spacer()
            }

            Divider()
                .overlay(PharmacyColor.border)

            PharmacyInformationRow(icon: "phone.fill", title: "pharmacy.management.phone".localized, value: pharmacy.phoneNumber)
            PharmacyInformationRow(icon: "mappin.and.ellipse", title: "pharmacy.management.address".localized, value: pharmacy.address)
            PharmacyInformationRow(
                icon: "location.fill",
                title: "pharmacy.management.location".localized,
                value: String(format: "%.5f, %.5f", pharmacy.latitude, pharmacy.longitude)
            )
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous).stroke(PharmacyColor.border))
    }
}

private struct PharmacyInformationRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: PharmacySpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(PharmacyColor.primary)
                .frame(width: 34, height: 34)
                .background(PharmacyColor.primarySoft, in: RoundedRectangle(cornerRadius: PharmacyRadius.sm))

            VStack(alignment: .leading, spacing: PharmacySpacing.xxs) {
                Text(title)
                    .font(PharmacyColor.sans(12, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)

                Text(value)
                    .font(PharmacyColor.sans(14, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}
