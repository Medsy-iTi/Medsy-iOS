//
//  CompletedOrderCard.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import SwiftUI

struct CompletedOrderCard: View {
    let order: CompletedOrder
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            PharmacyOrderSummaryCardView(
                orderIdString: String(order.id),
                createdAtRelativeString: order.createdAt.relativeTimeString,
                statusPillText: "completed_order.status_completed".localized,
                statusPillColor: PharmacyColor.success,
                statusPillBgColor: PharmacyColor.successSoft,
                customerName: order.customerName,
                customerPhone: order.customerPhone,
                deliveryAddress: order.deliveryAddress,
				paymentMethodString: order.paymentMethod.localizedTitle,
                totalAmountString: String(Int(order.total))
            ) {
                EmptyView()
            }
        }
        .buttonStyle(.plain)
    }
}
