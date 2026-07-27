//
//  PharmacyOrderSummaryCard.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//




import SwiftUI

struct PharmacyOrderSummaryCard: View {
    let subTotal: Double
    let deliveryFee: Double
    let total: Double
    let hasDelivery: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text("completed_order.order_summary".localized)
                .font(PharmacyColor.sans(15, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, PharmacySpacing.sm)

            PharmacyOrderSummaryRow(
                label: "completed_order.subtotal".localized,
                amount: subTotal,
                isTotal: false
            )

            if hasDelivery {
                PharmacyDivider().padding(.vertical, PharmacySpacing.xs)
                PharmacyOrderSummaryRow(
                    label: "completed_order.delivery_fee".localized,
                    amount: deliveryFee,
                    isTotal: false
                )
            }

            PharmacyDivider().padding(.vertical, PharmacySpacing.xs)

            HStack {
                Text("completed_order.total".localized)
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                Spacer()
                Text(String(format: "completed_order.price_format".localized, total))
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.primary)
            }
        }
        .pharmacyCard()
    }
}


struct PharmacyOrderSummaryRow: View {
    let label: String
    let amount: Double
    let isTotal: Bool

    var body: some View {
        HStack {
            Text(label)
                .font(PharmacyColor.sans(isTotal ? 16 : 14, isTotal ? .bold : .regular))
                .foregroundStyle(isTotal ? PharmacyColor.textPrimary : PharmacyColor.textSecondary)
            Spacer()
            Text(String(format: "completed_order.price_format".localized, amount))
                .font(PharmacyColor.sans(isTotal ? 16 : 14, isTotal ? .bold : .medium))
                .foregroundStyle(isTotal ? PharmacyColor.primary : PharmacyColor.textSecondary)
        }
    }
}
