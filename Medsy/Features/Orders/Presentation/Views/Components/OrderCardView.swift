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

    var body: some View {
        Button(action: onTap) {
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

                Text(String(format: "orders.from_pharmacy".localized, order.pharmacyName))
                    .font(AppColor.sans(13))
                    .foregroundStyle(AppColor.textSec)
                    .lineLimit(1)

                HStack(alignment: .bottom) {
                    HStack(spacing: -MedsySpacing.xxs) {
                        ForEach(0..<min(order.itemCount, 3), id: \.self) { _ in
                            RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                                .fill(AppColor.lightGreen)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "pills.fill")
                                        .font(.system(size: 17))
                                        .foregroundStyle(AppColor.green.opacity(0.65))
                                )
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
        .buttonStyle(.plain)
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
