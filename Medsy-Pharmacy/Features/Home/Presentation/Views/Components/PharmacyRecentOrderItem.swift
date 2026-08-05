//
//  PharmacyRecentOrderItem.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PharmacyRecentOrderItem: View {
    let order: PharmacyHomeRecentOrder

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            VStack(alignment: .leading, spacing: 4) {
                Text("pharmacy.home.order_number".localized(String(order.id)))
                    .font(PharmacyColor.sans(13, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Text(order.createdAt?.relativeTimeString ?? "pharmacy.home.date_unavailable".localized)
                    .font(PharmacyColor.sans(10, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)

                Text(
                    order.total,
                    format: .currency(code: "EGP")
                        .precision(.fractionLength(0...2))
                )
                .font(PharmacyColor.sans(11, .bold))
                .foregroundStyle(PharmacyColor.success)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(order.customerName)
                    .font(PharmacyColor.sans(13, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .lineLimit(1)
                Text(order.address)
                    .font(PharmacyColor.sans(10, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.trailing)
            }

            Text("pharmacy.orders.status.completed".localized)
                .font(PharmacyColor.sans(10, .semibold))
                .foregroundStyle(PharmacyColor.success)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(PharmacyColor.success.opacity(0.12), in: Capsule())
        }
        .padding(PharmacySpacing.sm)
        .accessibilityElement(children: .combine)
    }
}
