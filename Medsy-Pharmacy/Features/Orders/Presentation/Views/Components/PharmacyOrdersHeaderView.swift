//
//  PharmacyOrdersHeaderView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyOrdersHeaderView: View {
    var body: some View {
        Text("pharmacy.orders.title".localized)
            .font(PharmacyColor.sans(22, .bold))
            .foregroundStyle(PharmacyColor.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .accessibilityAddTraits(.isHeader)
    }
}
