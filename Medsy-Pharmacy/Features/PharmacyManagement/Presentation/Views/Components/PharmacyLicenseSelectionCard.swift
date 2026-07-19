//
//  PharmacyLicenseSelectionCard.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftUI

struct PharmacyLicenseSelectionCard: View {
    let fileName: String?
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: PharmacySpacing.md) {
                Image(systemName: fileName == nil ? "doc.badge.plus" : "doc.text.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
                    .frame(width: 48, height: 48)
                    .background(PharmacyColor.primarySoft, in: RoundedRectangle(cornerRadius: PharmacyRadius.md))

                VStack(alignment: .leading, spacing: PharmacySpacing.xxs) {
                    Text(fileName ?? "pharmacy.management.form.license.select".localized)
                        .font(PharmacyColor.sans(14, .semibold))
                        .foregroundStyle(PharmacyColor.textPrimary)
                        .lineLimit(1)

                    Text("pharmacy.management.form.license.help".localized)
                        .font(PharmacyColor.sans(12))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.forward")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }
            .padding(PharmacySpacing.md)
            .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg))
            .overlay(RoundedRectangle(cornerRadius: PharmacyRadius.lg).stroke(PharmacyColor.border))
        }
        .buttonStyle(.plain)
    }
}
