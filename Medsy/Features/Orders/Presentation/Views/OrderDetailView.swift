//
//  OrderDetailView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import SwiftUI

struct OrderDetailView: View {
    let state: OrderDetailViewState
    let onRetry: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            navBar
            Divider().background(AppColor.border)
            detailContent
        }
        .background(AppColor.bg)
        .navigationBarHidden(true)
    }


    private var navBar: some View {
        ZStack {
            Text("orders.detail.title".localized)
                .font(AppColor.sans(17, .bold))
                .foregroundStyle(AppColor.textPrim)
                .frame(maxWidth: .infinity)

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.textPrim)
                }
                .padding(.leading, MedsySpacing.md)
                Spacer()
            }
        }
        .frame(height: 52)
    }


    @ViewBuilder
    private var detailContent: some View {
        switch state {
        case .loading:
            loadingView
        case .loaded(let order):
            loadedView(order: order)
        case .error(let message):
            OrdersErrorView(message: message, onRetry: onRetry)
        case .notFound:
            notFoundView
        }
    }

    private var loadingView: some View {
        VStack(spacing: MedsySpacing.lg) {
            ProgressView().tint(AppColor.green)
            Text("orders.loading".localized)
                .font(MedsyFont.caption())
                .foregroundStyle(AppColor.textSec)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var notFoundView: some View {
        VStack(spacing: MedsySpacing.lg) {
            Image(systemName: "doc.questionmark")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(AppColor.textSec.opacity(0.5))
            Text("orders.detail.not_found".localized)
                .font(MedsyFont.title(17))
                .foregroundStyle(AppColor.textPrim)
            Button("common.back".localized, action: onBack)
                .font(AppColor.sans(15, .semibold))
                .foregroundStyle(AppColor.green)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func loadedView(order: OrderDetailPresentationModel) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: MedsySpacing.md) {
                // Header card — order number, status, date, pharmacy
                headerCard(order: order)
                // Items section
                itemsSection(order: order)
                // Pricing summary
                pricingCard(order: order)
            }
            .padding(MedsySpacing.md)
            .padding(.bottom, MedsySpacing.xxl)
        }
    }


    private func headerCard(order: OrderDetailPresentationModel) -> some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            HStack {
                Text(String(format: "orders.detail.order_number".localized, order.orderNumber))
                    .font(AppColor.sans(16, .bold))
                    .foregroundStyle(AppColor.textPrim)
                Spacer()
                Text(order.status.labelKey.localized)
                    .font(AppColor.sans(13, .semibold))
                    .foregroundStyle(order.status.color)
            }

            Divider().background(AppColor.border)

            detailRow(label: "orders.detail.pharmacy".localized, value: order.pharmacyName)
            detailRow(label: "orders.detail.date".localized, value: order.date.formatted(date: .long, time: .omitted))
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
        .medsyCardShadow()
    }

    private func itemsSection(order: OrderDetailPresentationModel) -> some View {
        VStack(alignment: .leading, spacing: MedsySpacing.xs) {
            Text("orders.detail.items".localized)
                .font(AppColor.sans(13, .semibold))
                .foregroundStyle(AppColor.textSec)
                .padding(.horizontal, MedsySpacing.xxs)

            VStack(spacing: 0) {
                ForEach(Array(order.items.enumerated()), id: \.element.id) { index, item in
                    itemRow(item: item)
                    if index < order.items.count - 1 {
                        Divider()
                            .background(AppColor.border)
                            .padding(.leading, MedsySpacing.md)
                    }
                }
            }
            .background(AppColor.card)
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                    .stroke(AppColor.border, lineWidth: 1)
            )
            .medsyCardShadow()
        }
    }

    private func itemRow(item: OrderDetailItemModel) -> some View {
        HStack(spacing: MedsySpacing.sm) {
            RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                .fill(AppColor.lightGreen)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "pills.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColor.green.opacity(0.7))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(item.productName)
                    .font(AppColor.sans(14, .semibold))
                    .foregroundStyle(AppColor.textPrim)
                    .lineLimit(2)

                Text(String(format: "orders.detail.item_unit_price".localized, item.unitPrice))
                    .font(AppColor.sans(12))
                    .foregroundStyle(AppColor.textSec)
            }

            Spacer(minLength: 0)

            Text("×\(item.quantity)")
                .font(AppColor.sans(15, .bold))
                .foregroundStyle(AppColor.textPrim)
        }
        .padding(MedsySpacing.md)
    }

    private func pricingCard(order: OrderDetailPresentationModel) -> some View {
        VStack(spacing: MedsySpacing.sm) {

            let itemsTotal = order.items.reduce(0.0) { $0 + ($1.unitPrice * Double($1.quantity)) }
            priceRow(label: "orders.detail.items".localized, amount: itemsTotal, style: .regular)

            if let fee = order.deliveryFee {
                Divider().background(AppColor.border)
                priceRow(label: "orders.detail.delivery_fee".localized, amount: fee, style: .regular)
            }

            Divider().background(AppColor.border)

            priceRow(label: "orders.detail.total".localized, amount: order.totalPrice, style: .total)
        }
        .padding(MedsySpacing.md)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                .stroke(AppColor.border, lineWidth: 1)
        )
        .medsyCardShadow()
    }

    private enum PriceRowStyle { case regular, total }

    private func priceRow(label: String, amount: Double, style: PriceRowStyle) -> some View {
        HStack {
            Text(label)
                .font(style == .total ? AppColor.sans(15, .bold) : AppColor.sans(14))
                .foregroundStyle(style == .total ? AppColor.textPrim : AppColor.textSec)

            Spacer()

            Text(String(format: "orders.price_format".localized, amount))
                .font(style == .total ? MedsyFont.price(16) : AppColor.sans(14, .medium))
                .foregroundStyle(style == .total ? AppColor.textPrim : AppColor.textSec)
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(AppColor.sans(13))
                .foregroundStyle(AppColor.textSec)
            Spacer()
            Text(value)
                .font(AppColor.sans(13, .semibold))
                .foregroundStyle(AppColor.textPrim)
                .multilineTextAlignment(.trailing)
        }
    }
}


enum OrderDetailViewState {
    case loading
    case loaded(OrderDetailPresentationModel)
    case error(String)
    case notFound
}


#Preview {
    OrderDetailView(
        state: .loaded(.mock),
        onRetry: {},
        onBack: {}
    )
    .environment(LanguageManager.shared)
}
