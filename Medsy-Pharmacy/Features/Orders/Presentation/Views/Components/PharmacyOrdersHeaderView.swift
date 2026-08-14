//
//  PharmacyOrdersHeaderView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyOrdersHeaderView: View {
    var body: some View {
        PharmacySectionHeader(
            title: "pharmacy.orders.title".localized,
            systemImage: "shippingbox.fill"
        )
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 44)
            .accessibilityAddTraits(.isHeader)
    }
}
