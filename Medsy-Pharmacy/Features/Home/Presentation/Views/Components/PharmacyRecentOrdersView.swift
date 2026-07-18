//
//  PharmacyRecentOrdersView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 18/07/2026.
//

import SwiftUI

struct PharmacyRecentOrdersView: View {
    let orders: [PharmacyHomeOrder]

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            HStack {
                Text("pharmacy.home.recent_orders".localized)
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                Spacer()
                Button("pharmacy.home.view_all".localized, action: {})
                    .font(PharmacyColor.sans(13, .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }

            VStack(spacing: 0) {
                ForEach(Array(orders.enumerated()), id: \.element.id) { index, order in
                    PharmacyRecentOrderItem(order: order)

                    if index < orders.count - 1 {
                        Divider()
                            .overlay(PharmacyColor.border)
                            .padding(.leading, PharmacySpacing.md)
                    }
                }
            }
            .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: PharmacyRadius.md, style: .continuous).stroke(PharmacyColor.border, lineWidth: 1))
        }
    }
}

