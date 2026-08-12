//
//  PharmacyOrderTotalCard.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 23/07/2026.
//

import SwiftUI

struct PharmacyOrderTotalCard: View {
    let total: Double
    var onViewPaymentSummary: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("pharmacy.request.order_total_header".localized)
                    .font(PharmacyColor.sans(14, .medium))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Button(action: {
                    onViewPaymentSummary?()
                }) {
                    Text("pharmacy.request.view_payment_summary".localized)
                        .font(PharmacyColor.sans(12, .semibold))
                        .foregroundStyle(PharmacyColor.primary)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Text("\(Int(total)) \("pharmacy.request.currency_unit".localized)")
                .font(PharmacyColor.sans(20, .bold))
                .foregroundStyle(PharmacyColor.primary)
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                .stroke(PharmacyColor.border, lineWidth: 1)
        )
    }
}
