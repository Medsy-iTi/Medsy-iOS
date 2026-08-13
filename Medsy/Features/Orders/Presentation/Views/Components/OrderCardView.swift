//
//  OrderCardView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import SwiftUI

struct OrderCardView: View {
    let order: OrderPresentationModel
    let onTap: () -> Void
    var onPaymentTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            Button(action: onTap) {
                content
            }
            .buttonStyle(.plain)

            if let paymentAction = order.paymentAction {
                PaymentOrderActionView(
                    action: paymentAction,
                    onTap: { onPaymentTap?() }
                )
            }
        }
        .padding(MedsySpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
        .medsyCardShadow()
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.xs) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("#\(order.orderNumber)")
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.textPrim)

                    Text(dateLabel)
                        .font(AppColor.sans(12))
                        .foregroundStyle(AppColor.textSec)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.forward")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColor.textSec)
            }

            Text(order.status.labelKey.localized)
                .font(AppColor.sans(14, .semibold))
                .foregroundStyle(order.status.color)

            pharmacyNames

            fulfillmentBadge

            HStack(alignment: .bottom) {
                HStack(spacing: -MedsySpacing.xxs) {
                    ForEach(0..<min(order.itemCount, 3), id: \.self) { index in
                        OrderProductImageView(imageURL: imageURL(at: index), size: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                                    .stroke(AppColor.card, lineWidth: 2)
                            )
                    }
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "orders.price_format".localized, order.totalPrice))
                        .font(MedsyFont.price(15))
                        .foregroundStyle(AppColor.textPrim)

                    Text(itemCountText)
                        .font(AppColor.sans(12))
                        .foregroundStyle(AppColor.textSec)
                }
            }
        }
    }

    private var pharmacyNames: some View {
        HStack(spacing: MedsySpacing.xxs) {
            Image(systemName: "cross.case.fill")
                .font(.system(size: 11))
                .foregroundStyle(AppColor.green)
            Text(order.displayedPharmacyNames.joined(separator: " • "))
                .font(AppColor.sans(12, .medium))
                .foregroundStyle(AppColor.textSec)
                .lineLimit(2)
        }
        .accessibilityElement(children: .combine)
    }

    private var dateLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(order.date) {
            return "orders.section.today".localized
        } else if calendar.isDateInYesterday(order.date) {
            return "orders.section.yesterday".localized
        } else {
            return order.date.formatted(.dateTime.day().month(.abbreviated))
        }
    }

    private var itemCountText: String {
        let key = order.itemCount == 1 ? "orders.item_count" : "orders.items_count"
        return String(format: key.localized, order.itemCount)
    }

    private var fulfillmentBadge: some View {
        Label(
            fulfillmentLabel,
            systemImage: fulfillmentIcon
        )
        .font(AppColor.sans(12, .medium))
        .foregroundStyle(AppColor.green)
    }

    private var fulfillmentLabel: String {
        switch order.fulfillmentType {
        case .delivery:
            return "orders.fulfillment.delivery".localized
        case .pickup:
            return "orders.fulfillment.pickup".localized
        case .notSelected:
            return "orders.fulfillment.not_selected".localized
        }
    }

    private var fulfillmentIcon: String {
        switch order.fulfillmentType {
        case .delivery: return "shippingbox.fill"
        case .pickup: return "bag.fill"
        case .notSelected: return "clock.fill"
        }
    }

    private func imageURL(at index: Int) -> String? {
        guard order.itemImageURLs.indices.contains(index) else { return nil }
        return order.itemImageURLs[index]
    }
}

#Preview {
    VStack(spacing: MedsySpacing.sm) {
        ForEach(OrderPresentationModel.mockOrders) { order in
            OrderCardView(order: order, onTap: {})
        }
    }
    .padding(MedsySpacing.md)
    .background(AppColor.bg)
    .environment(LanguageManager.shared)
}
