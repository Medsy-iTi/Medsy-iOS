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
        Button(action: cardAction) {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(accentColor)
                    .frame(width: 5)
                    .frame(maxHeight: .infinity)

                content
                    .padding(MedsySpacing.md)
            }
        }
        .buttonStyle(OrderCardButtonStyle())
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppColor.outline.opacity(0.15), lineWidth: 1)
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text(String(format: "orders.detail.order_number".localized, order.orderNumber))
                    .font(AppColor.sans(16, .bold))
                    .foregroundStyle(AppColor.onSurface)

                Spacer(minLength: 0)

                Image(systemName: "chevron.forward")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColor.onSurfaceVariant)
            }

            Text(order.status.labelKey.localized)
                .font(AppColor.sans(12, .bold))
                .foregroundStyle(statusForegroundColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(statusBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding(.top, 12)

            pharmacyNames
                .padding(.top, MedsySpacing.xs)

            HStack(alignment: .center) {
                productThumbnails

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "orders.price_format".localized, order.totalPrice))
                        .font(MedsyFont.price(15))
                        .foregroundStyle(AppColor.onSurface)

                    Text(itemCountText)
                        .font(AppColor.sans(12))
                        .foregroundStyle(AppColor.onSurfaceVariant)
                }
            }
            .padding(.top, 14)
        }
    }

    @ViewBuilder
    private var pharmacyNames: some View {
        let names = order.displayedPharmacyNames
        if !names.isEmpty {
            Text(
                String(
                    format: "orders.from_pharmacy".localized,
                    names.joined(separator: ", ")
                )
            )
            .font(AppColor.sans(14))
            .foregroundStyle(AppColor.onSurfaceVariant)
            .lineLimit(2)
            .accessibilityElement(children: .combine)
        }
    }

    private var productThumbnails: some View {
        HStack(spacing: -12) {
            ForEach(0..<min(order.itemCount, 3), id: \.self) { index in
                OrderProductImageView(
                    imageURL: imageURL(at: index),
                    size: 40,
                    containerColor: AppColor.surfaceVariant
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppColor.surface, lineWidth: 2)
                )
                .zIndex(Double(3 - index))
            }

            if order.itemCount > 3 {
                Text("+\(order.itemCount - 3)")
                    .font(AppColor.sans(11, .bold))
                    .foregroundStyle(AppColor.onPrimaryContainer)
                    .frame(width: 40, height: 40)
                    .background(AppColor.primaryContainer)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppColor.surface, lineWidth: 2)
                    )
            }
        }
        .padding(.vertical, 4)
    }

    private var itemCountText: String {
        let key = order.itemCount == 1 ? "orders.item_count" : "orders.items_count"
        return String(format: key.localized, order.itemCount)
    }

    private var accentColor: Color {
        if order.status.isCompleted { return AppColor.success }
        if order.status.isCancelled { return AppColor.error }
        return AppColor.green
    }

    private var statusBackgroundColor: Color {
        order.status.isCancelled ? AppColor.errorContainer : AppColor.primaryContainer
    }

    private var statusForegroundColor: Color {
        order.status.isCancelled ? AppColor.error : AppColor.onPrimaryContainer
    }

    private func cardAction() {
        switch order.paymentAction {
        case .payNow, .retry:
            if let onPaymentTap {
                onPaymentTap()
            } else {
                onTap()
            }
        case .processing, .expired, .none:
            onTap()
        }
    }

    private func imageURL(at index: Int) -> String? {
        guard order.itemImageURLs.indices.contains(index) else { return nil }
        return order.itemImageURLs[index]
    }
}

private struct OrderCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
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
