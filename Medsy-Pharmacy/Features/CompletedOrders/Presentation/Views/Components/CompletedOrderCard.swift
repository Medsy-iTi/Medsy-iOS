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
            VStack(alignment: .leading, spacing: PharmacySpacing.sm) {
                header
                Text(order.customerName)
                    .font(PharmacyColor.sans(17, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)

                Label(order.pharmacyAddress, systemImage: "location.fill")
                    .font(PharmacyColor.sans(13))
                    .foregroundStyle(PharmacyColor.textSecondary)

                Divider().background(PharmacyColor.border)

                HStack {
                    Text(String(format: "orders_price_format".localized, Int(order.total)))
                        .font(PharmacyColor.sans(17, .bold))
                        .foregroundStyle(PharmacyColor.primary)

                    Spacer()

                    Image(systemName: LanguageManager.shared.isRTL ? "chevron.left" : "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(PharmacyColor.textSecondary)
                }
            }
            .padding(PharmacySpacing.md)
            .background(PharmacyColor.card)
            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var header: some View {
        HStack {
            Text("#\(order.id)")
                .font(PharmacyColor.sans(15, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Spacer()

            Text(order.createdAt.relativeTimeAgo)
                .font(PharmacyColor.sans(12))
                .foregroundStyle(PharmacyColor.textSecondary)
        }
    }
}

private extension Date {
    var relativeTimeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: LanguageManager.shared.languageCode)
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
