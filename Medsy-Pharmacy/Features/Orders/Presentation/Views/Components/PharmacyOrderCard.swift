//
//  PharmacyOrderCard.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyOrderCard: View {
    let order: PharmacyOrderListItem
    let onAction: () -> Void

    var body: some View {
        VStack(spacing: PharmacySpacing.sm) {
            HStack {
                Text("pharmacy.orders.order_number".localized(order.id))
                    .font(PharmacyColor.sans(17, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
                    .environment(\.layoutDirection, .leftToRight)

                Spacer()

                Label("pharmacy.orders.minutes_ago".localized(order.minutesAgo), systemImage: "bag")
                    .font(PharmacyColor.sans(11, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
                    .labelStyle(PharmacyOrderTimeLabelStyle())
            }

            HStack(alignment: .top, spacing: PharmacySpacing.sm) {
                statusPill
                Spacer(minLength: PharmacySpacing.sm)

                VStack(alignment: .trailing, spacing: 5) {
                    Text(order.customerName)
                        .font(PharmacyColor.sans(16, .bold))
                        .foregroundStyle(PharmacyColor.textPrimary)

                    Text(order.phoneNumber)
                        .font(PharmacyColor.sans(13, .medium))
                        .foregroundStyle(PharmacyColor.primaryDark)
                        .environment(\.layoutDirection, .leftToRight)

                    Label(order.address, systemImage: "location.fill")
                        .font(PharmacyColor.sans(12))
                        .foregroundStyle(PharmacyColor.textSecondary)
                        .multilineTextAlignment(.trailing)
                }
            }

            HStack(spacing: PharmacySpacing.xs) {
                Text("pharmacy.orders.payment".localized + ":")
                    .foregroundStyle(PharmacyColor.textSecondary)
                Text(order.paymentMethod.localizedTitle)
                    .foregroundStyle(PharmacyColor.primaryDark)

                Spacer()

                Text("pharmacy.orders.currency".localized(String(order.amount)))
                    .font(PharmacyColor.sans(15, .bold))
                    .foregroundStyle(PharmacyColor.textPrimary)
            }
            .font(PharmacyColor.sans(12, .medium))

            PharmacyPrimaryButton(
                title: order.status.actionTitleKey.localized,
                style: order.status.buttonStyle,
                height: 44,
                action: onAction
            )
        }
        .padding(PharmacySpacing.md)
        .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: PharmacyRadius.lg, style: .continuous).stroke(PharmacyColor.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
        .accessibilityElement(children: .contain)
    }

    private var statusPill: some View {
        Text(order.status.titleKey.localized)
            .font(PharmacyColor.sans(11, .semibold))
            .foregroundStyle(order.status.tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(order.status.tint.opacity(0.12), in: Capsule())
    }
}

private struct PharmacyOrderTimeLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.title
            configuration.icon
                .foregroundStyle(PharmacyColor.primary)
        }
    }
}
