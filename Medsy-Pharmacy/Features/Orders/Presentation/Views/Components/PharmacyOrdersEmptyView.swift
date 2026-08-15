//
//  PharmacyOrdersEmptyView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyOrdersEmptyView: View {
    var body: some View {
        VStack(spacing: PharmacySpacing.sm) {
            PharmacyIconTile(
                systemImage: "doc.text.magnifyingglass",
                size: 64,
                iconSize: 26
            )

            Text("pharmacy.orders.empty.title".localized)
                .font(PharmacyColor.sans(16, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Text("pharmacy.orders.empty.message".localized)
                .font(PharmacyColor.sans(13))
                .foregroundStyle(PharmacyColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PharmacySpacing.xl)
        .pharmacyCard(elevation: .subtle)
    }
}
