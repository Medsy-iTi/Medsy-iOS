//  PharmacyRecentOrdersView.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 19/07/2026.
//

import SwiftUI

struct PharmacyRecentOrdersView: View {
    let orders: [PharmacyHomeOrder]
    var onSelectOrder: ((PharmacyHomeOrder) -> Void)? = nil
    let onViewAllOrders: () -> Void

    
    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
            HStack {
                Text("pharmacy.home.recent_orders".localized)
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                Spacer()
                Button("pharmacy.home.view_all".localized, action: onViewAllOrders)
                    .font(PharmacyColor.sans(13, .semibold))
                    .foregroundStyle(PharmacyColor.primary)
            }

            VStack(spacing: 0) {
                ForEach(Array(orders.enumerated()), id: \.element.id) { index, order in
                    Button {
                        onSelectOrder?(order)
                    } label: {
                        PharmacyRecentOrderItem(order: order)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

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
