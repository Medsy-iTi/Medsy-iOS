//
//  PharmacyOrderStatusHeaderView.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//



import SwiftUI

struct PharmacyOrderStatusHeaderView: View {
    let customerName: String
    let createdAt: Date
    let hasDelivery: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: PharmacySpacing.xs) {
            HStack(alignment: .center) {
                Text(String(format: "%@: %@", "completed_order.customer".localized, customerName))
                    .font(PharmacyColor.sans(16, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Spacer(minLength: 0)

                PharmacyBadge(
                    text: hasDelivery
                        ? "completed_order.fulfillment.delivery".localized
                        : "completed_order.fulfillment.pickup".localized,
                    systemImage: hasDelivery ? "shippingbox.fill" : "bag.fill",
                    tint: PharmacyColor.primary,
                    tintSoft: PharmacyColor.primarySoft
                )
            }

            Text(createdAt.formatted(.dateTime.day().month(.wide).year()))
                .font(PharmacyColor.sans(13))
                .foregroundStyle(PharmacyColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .pharmacyCard()
    }
}

#Preview {
    PharmacyOrderStatusHeaderView(
        customerName: "Ahmed Elkady",
        createdAt: .now,
        hasDelivery: true
    )
    .padding()
    .background(PharmacyColor.bg)
}
