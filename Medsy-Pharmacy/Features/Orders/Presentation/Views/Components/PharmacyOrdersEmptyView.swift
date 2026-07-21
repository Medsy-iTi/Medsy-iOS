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
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(PharmacyColor.primary)

            Text("pharmacy.orders.empty.title".localized)
                .font(PharmacyColor.sans(16, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Text("pharmacy.orders.empty.message".localized)
                .font(PharmacyColor.sans(13))
                .foregroundStyle(PharmacyColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PharmacySpacing.xl * 2)
    }
}
