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
                statusPillText: pillTitle,
                statusPillColor: pillColor,
                statusPillBgColor: pillBgColor,
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

    private var pillTitle: String {
        switch order.status {
        case .pending, .accepted, .preparing:
            return "pharmacy.status.preparing".localized
        case .readyForPickup:
            return "pharmacy.status.ready".localized
        case .readyForDelivery, .outForDelivery:
            return "pharmacy.status.on_the_way".localized
        case .delivered, .completed:
            return "pharmacy.status.delivered".localized
        case .cancelled, .expired:
            return "pharmacy.orders.status.expired".localized
        case .unknown:
            return "pharmacy.status.preparing".localized
        }
    }

    private var pillColor: Color {
        switch order.status {
        case .pending, .accepted, .preparing, .readyForPickup, .readyForDelivery, .outForDelivery:
            return PharmacyColor.secondary
        case .delivered, .completed:
            return PharmacyColor.success
        case .cancelled, .expired:
            return PharmacyColor.danger
        case .unknown:
            return PharmacyColor.secondary
        }
    }

    private var pillBgColor: Color {
        switch order.status {
        case .pending, .accepted, .preparing, .readyForPickup, .readyForDelivery, .outForDelivery:
            return PharmacyColor.secondarySoft
        case .delivered, .completed:
            return PharmacyColor.successSoft
        case .cancelled, .expired:
            return PharmacyColor.danger.opacity(0.15)
        case .unknown:
            return PharmacyColor.secondarySoft
        }
    }
}
