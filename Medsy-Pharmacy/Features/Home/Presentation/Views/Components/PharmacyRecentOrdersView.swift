//
//  PharmacyRecentOrdersView.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PharmacyRecentOrdersView: View {
    let orders: [PharmacyHomeRecentOrder]
    let onSelectOrder: (PharmacyHomeRecentOrder) -> Void
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

            Group {
                if orders.isEmpty {
                    PharmacyHomeSectionMessage(
                        icon: "tray",
                        title: "pharmacy.home.orders_empty_title".localized,
                        message: "pharmacy.home.orders_empty_message".localized
                    )
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(orders.enumerated()), id: \.element.id) { index, order in
                            Button {
                                onSelectOrder(order)
                            } label: {
                                PharmacyRecentOrderItem(order: order)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(PharmacyPressableButtonStyle())

                            if index < orders.count - 1 {
                                Divider()
                                    .overlay(PharmacyColor.border)
                                    .padding(.leading, PharmacySpacing.md)
                            }
                        }
                    }
                }
            }
            .pharmacyCard(cornerRadius: PharmacyRadius.md, padding: nil, elevation: .subtle)
        }
    }
}
