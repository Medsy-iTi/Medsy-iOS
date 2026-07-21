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
            HStack(alignment: .center, spacing: MedsySpacing.md) {

                VStack(alignment: .leading, spacing: MedsySpacing.xxs + 2) {
                    Text(String(format: "orders.detail.order_number".localized, order.orderNumber))
                        .font(AppColor.sans(13, .semibold))
                        .foregroundStyle(AppColor.textSec)

                    Text(order.status.labelKey.localized)
                        .font(AppColor.sans(14, .bold))
                        .foregroundStyle(order.status.color)

                    Text(String(format: "orders.from_pharmacy".localized, order.pharmacyName))
                        .font(AppColor.sans(13))
                        .foregroundStyle(AppColor.textSec)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    HStack(spacing: MedsySpacing.xs) {
                        Text(String(format: "orders.price_format".localized, order.totalPrice))
                            .font(MedsyFont.price(14))
                            .foregroundStyle(AppColor.textPrim)

                        Text("·")
                            .foregroundStyle(AppColor.textSec)

                        Text(itemCountText)
                            .font(AppColor.sans(12))
                            .foregroundStyle(AppColor.textSec)
                    }
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: MedsySpacing.xs) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColor.textSec)

                    Spacer(minLength: 0)

                    HStack(spacing: -MedsySpacing.xxs) {
                        ForEach(0..<min(order.itemCount, 3), id: \.self) { _ in
                            RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                                .fill(AppColor.lightGreen)
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Image(systemName: "pills.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(AppColor.green.opacity(0.6))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                                        .stroke(AppColor.card, lineWidth: 2)
                                )
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .topTrailing)
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
}
