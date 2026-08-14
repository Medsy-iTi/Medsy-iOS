//
//  PharmacyMoneyDetailsCard.swift
//  Medsy-Pharmacy
//
//

import SwiftUI

struct PharmacyMoneyDetailsCard: View {
    let subTotal: Double
    let deliveryFee: Double
    let total: Double
    let hasDelivery: Bool

    var body: some View {
        VStack(spacing: 0) {
            PharmacySectionHeader(
                title: "completed_order.order_summary".localized,
                systemImage: "banknote.fill"
            )
                .padding(.bottom, PharmacySpacing.sm)

            summaryRow(
                label: "completed_order.subtotal".localized,
                amount: subTotal,
                isTotal: false
            )

            if hasDelivery {
                Divider().background(PharmacyColor.border).padding(.vertical, PharmacySpacing.xs)
                summaryRow(
                    label: "completed_order.delivery_fee".localized,
                    amount: deliveryFee,
                    isTotal: false
                )
            }

            Divider().background(PharmacyColor.border).padding(.vertical, PharmacySpacing.xs)

            HStack {
                Text("completed_order.total".localized)
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                Spacer()
                Text("pharmacy.orders.currency".localized(String(Int(total))))
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.primary)
            }
        }
        .pharmacyCard(elevation: .raised)
    }

    private func summaryRow(label: String, amount: Double, isTotal: Bool) -> some View {
        HStack {
            Text(label)
                .font(PharmacyColor.sans(isTotal ? 16 : 14, isTotal ? .bold : .medium))
                .foregroundStyle(isTotal ? PharmacyColor.textPrimary : PharmacyColor.textSecondary)
            Spacer()
            Text("pharmacy.orders.currency".localized(String(Int(amount))))
                .font(PharmacyColor.sans(isTotal ? 16 : 14, isTotal ? .bold : .medium))
                .foregroundStyle(isTotal ? PharmacyColor.primary : PharmacyColor.textSecondary)
        }
    }
}
