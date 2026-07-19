//
//  PharmacyLocationSelectionCard.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftUI

struct PharmacyLocationSelectionCard: View {
    let latitude: Double?
    let longitude: Double?
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: PharmacySpacing.md) {
                Image(systemName: "map.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(PharmacyColor.primary)
                    .frame(width: 48, height: 48)
                    .background(PharmacyColor.primarySoft, in: RoundedRectangle(cornerRadius: PharmacyRadius.md))

                VStack(alignment: .leading, spacing: PharmacySpacing.xxs) {
                    Text(hasLocation ? "pharmacy.management.form.location.change".localized : "pharmacy.management.form.location.select".localized)
                        .font(PharmacyColor.sans(14, .semibold))
                        .foregroundStyle(PharmacyColor.textPrimary)

                    Text(locationDescription)
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

    private var hasLocation: Bool {
        latitude != nil && longitude != nil
    }

    private var locationDescription: String {
        guard let latitude, let longitude else {
            return "pharmacy.management.form.location.help".localized
        }
        return String(format: "%.5f, %.5f", latitude, longitude)
    }
}
