//
//  PharmacyRecentOrderRow.swift
//  Medsy
//
//  Created by Ehab Salah on 18/07/2026.
//

import SwiftUI

struct PharmacyRecentOrderItem: View {
    let order: PharmacyHomeOrder

    var body: some View {
        HStack(spacing: PharmacySpacing.sm) {
            VStack(alignment: .leading, spacing: 4) {
                Text("pharmacy.home.order_number".localized(order.id))
                    .font(PharmacyColor.sans(13, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                Text("pharmacy.home.minutes_ago".localized(order.minutesAgo))
                    .font(PharmacyColor.sans(10, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(order.customerNameKey.localized)
                    .font(PharmacyColor.sans(13, .semibold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                Text(order.addressKey.localized)
                    .font(PharmacyColor.sans(10, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }

            Text(order.status.titleKey.localized)
                .font(PharmacyColor.sans(10, .semibold))
                .foregroundStyle(order.status.tint)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(order.status.tint.opacity(0.12), in: Capsule())
        }
        .padding(PharmacySpacing.sm)
    }
}
