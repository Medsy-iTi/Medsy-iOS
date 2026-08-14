//
//  PharmacyHomeSectionMessage.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PharmacyHomeSectionMessage: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: PharmacySpacing.xs) {
            PharmacyIconTile(systemImage: icon, size: 48, iconSize: 20)
            Text(title)
                .font(PharmacyColor.sans(14, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)
            Text(message)
                .font(PharmacyColor.sans(12))
                .foregroundStyle(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(PharmacySpacing.lg)
        .accessibilityElement(children: .combine)
    }
}
