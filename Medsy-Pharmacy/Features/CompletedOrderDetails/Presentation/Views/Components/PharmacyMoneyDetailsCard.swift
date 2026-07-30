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
            Text("completed_order.order_summary".localized)
                .font(PharmacyColor.sans(15, .semibold))
                .foregroundStyle(PharmacyColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
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
                Text("\(Int(total)) \("pharmacy.request.currency_unit".localized)")
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.primary)
            }
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }

    private func summaryRow(label: String, amount: Double, isTotal: Bool) -> some View {
        HStack {
            Text(label)
                .font(PharmacyColor.sans(isTotal ? 16 : 14, isTotal ? .bold : .medium))
                .foregroundStyle(isTotal ? PharmacyColor.textPrimary : PharmacyColor.textSecondary)
            Spacer()
            Text("\(Int(amount)) \("pharmacy.request.currency_unit".localized)")
                .font(PharmacyColor.sans(isTotal ? 16 : 14, isTotal ? .bold : .medium))
                .foregroundStyle(isTotal ? PharmacyColor.primary : PharmacyColor.textSecondary)
        }
    }
}
