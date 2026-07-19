//
//  PharmacyReadOnlyLocationField.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftUI

struct PharmacyReadOnlyLocationField: View {
    let location: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PharmacySpacing.sm) {
                Image(systemName: "location")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .frame(width: 20)

                Text(location.isEmpty ? "pharmacy.management.form.location.select".localized : location)
                    .font(PharmacyColor.sans(15))
                    .foregroundStyle(location.isEmpty ? PharmacyColor.textSecondary : PharmacyColor.textPrimary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.forward")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }
            .padding(.horizontal, PharmacySpacing.md)
            .frame(height: 56)
            .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("pharmacy.management.form.location.title".localized)
        .accessibilityValue(location)
    }
}
