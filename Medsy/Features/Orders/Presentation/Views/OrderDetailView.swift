//
//  OrderDetailView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import SwiftUI

struct OrderDetailView: View {
    let state: OrderDetailViewState
    let reorderState: ReorderState
    let onRetry: () -> Void
    let onBack: () -> Void
    var onReorder: (() -> Void)? = nil
    var onSelectPharmacy: ((Int) -> Void)? = nil
    var onDismissReorderFeedback: (() -> Void)? = nil
    var onGoToCart: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            navBar
            Divider().background(AppColor.border)
            detailContent
        }
        .background(AppColor.bg)
        .navigationBarHidden(true)
        .overlay(alignment: .bottom) {
            if reorderState.showsFeedback {
                ReorderToastView(
                    state: reorderState,
                    onGoToCart: {
                        onDismissReorderFeedback?()
                        onGoToCart?()
                    },
                    onDismiss: {
                        onDismissReorderFeedback?()
                    }
                )
                .padding(.horizontal, MedsySpacing.md)
                .padding(.bottom, 104)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: reorderState)
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        ZStack {
            Text(navTitle)
                .font(AppColor.sans(17, .bold))
                .foregroundStyle(AppColor.textPrim)
                .frame(maxWidth: .infinity)

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.textPrim)
                }
                .padding(.leading, MedsySpacing.md)
                Spacer()
            }
        }
        .frame(height: 52)
    }

    private var navTitle: String {
        if case .loaded(let order) = state {
            return String(format: "orders.detail.order_number".localized, order.orderNumber)
        }
        return "orders.detail.title".localized
    }

    // MARK: - Detail Content

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
        OrderDetailLoadingSkeleton()
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
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: MedsySpacing.md) {
                    statusHeader(order: order)
                    pharmacyCard(order: order)
                    itemsSection(order: order)
                    summaryCard(order: order)
                }
                .padding(MedsySpacing.md)
                .padding(.bottom, 96)
            }

            reorderButton
                .padding(.horizontal, MedsySpacing.md)
                .padding(.bottom, MedsySpacing.lg)
                .background(
                    AppColor.bg
                        .ignoresSafeArea()
                        .frame(height: 96)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                )
        }
    }

    // MARK: - Status Header

    private func statusHeader(order: OrderDetailPresentationModel) -> some View {
        VStack(alignment: .leading, spacing: MedsySpacing.xs) {
            HStack(alignment: .center) {
                Text(order.status.labelKey.localized)
                    .font(AppColor.sans(18, .bold))
                    .foregroundStyle(order.status.color)

                Spacer(minLength: 0)

                fulfillmentBadge(for: order.fulfillmentType)
            }

            Text(dateLabel(for: order.date))
                .font(AppColor.sans(13))
                .foregroundStyle(AppColor.textSec)
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

    private func fulfillmentBadge(for type: OrderFulfillmentType) -> some View {
        HStack(spacing: MedsySpacing.xxs) {
            Image(systemName: type == .delivery ? "shippingbox.fill" : "bag.fill")
                .font(.system(size: 13))
            Text(
                type == .delivery
                    ? "orders.fulfillment.delivery".localized
                    : "orders.fulfillment.pickup".localized
            )
            .font(AppColor.sans(13, .medium))
        }
        .foregroundStyle(AppColor.green)
        .padding(.horizontal, MedsySpacing.sm)
        .padding(.vertical, MedsySpacing.xxs + 2)
        .background(AppColor.lightGreen)
        .clipShape(Capsule())
    }

    private func pharmacyCard(order: OrderDetailPresentationModel) -> some View {
        Button {
            onSelectPharmacy?(order.pharmacyId)
        } label: {
            HStack(spacing: MedsySpacing.sm) {
            ZStack {
                Circle()
                    .fill(AppColor.lightGreen)
                    .frame(width: 44, height: 44)
                Image(systemName: "cross.vial.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColor.green)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("orders.detail.pharmacy".localized)
                    .font(AppColor.sans(12))
                    .foregroundStyle(AppColor.textSec)
                Text(order.pharmacyName)
                    .font(AppColor.sans(15, .semibold))
                    .foregroundStyle(AppColor.textPrim)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.forward")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColor.textSec)
            }
        }
        .buttonStyle(.plain)
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
            Text("orders.detail.items_label".localized)
                .font(AppColor.sans(15, .semibold))
                .foregroundStyle(AppColor.textPrim)

            VStack(spacing: 0) {
                ForEach(Array(order.items.enumerated()), id: \.element.id) { index, item in
                    itemRow(item: item)
                    if index < order.items.count - 1 {
                        Divider()
                            .background(AppColor.border)
                            .padding(.leading, 56 + MedsySpacing.md)
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
        HStack(alignment: .center, spacing: MedsySpacing.sm) {
            RoundedRectangle(cornerRadius: MedsyRadius.sm, style: .continuous)
                .fill(AppColor.lightGreen)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "pills.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(AppColor.green.opacity(0.7))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(item.productName)
                    .font(AppColor.sans(14, .semibold))
                    .foregroundStyle(AppColor.textPrim)
                    .lineLimit(2)

                if let originalName = item.originalProductName {
                    Text(String(format: "orders.detail.alternative_to".localized, originalName))
                        .font(AppColor.sans(12, .medium))
                        .foregroundStyle(AppColor.green)
                        .lineLimit(2)
                }

                Text(String(format: "orders.detail.item_qty_price".localized, item.quantity, item.unitPrice))
                    .font(AppColor.sans(12))
                    .foregroundStyle(AppColor.textSec)
            }

            Spacer(minLength: 0)

            Text(String(format: "orders.price_format".localized, item.unitPrice * Double(item.quantity)))
                .font(AppColor.sans(14, .semibold))
                .foregroundStyle(AppColor.textPrim)
        }
        .padding(.horizontal, MedsySpacing.md)
        .padding(.vertical, MedsySpacing.sm)
    }

    private func summaryCard(order: OrderDetailPresentationModel) -> some View {
        return VStack(spacing: 0) {
            Text("orders.detail.order_summary".localized)
                .font(AppColor.sans(15, .semibold))
                .foregroundStyle(AppColor.textPrim)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, MedsySpacing.sm)

            summaryRow(
                label: "orders.detail.items_subtotal".localized,
                amount: order.itemsSubtotal,
                isTotal: false
            )

            if order.fulfillmentType == .delivery, let fee = order.deliveryFee {
                Divider().background(AppColor.border).padding(.vertical, MedsySpacing.xs)
                summaryRow(
                    label: "orders.detail.delivery_fee".localized,
                    amount: fee,
                    isTotal: false
                )
            }

            Divider().background(AppColor.border).padding(.vertical, MedsySpacing.xs)

            HStack {
                Text("orders.detail.total".localized)
                    .font(AppColor.sans(16, .bold))
                    .foregroundStyle(AppColor.textPrim)
                Spacer()
                Text(String(format: "orders.price_format".localized, order.totalPrice))
                    .font(MedsyFont.price(16))
                    .foregroundStyle(AppColor.green)
            }
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

    private func summaryRow(label: String, amount: Double, isTotal: Bool) -> some View {
        HStack {
            Text(label)
                .font(AppColor.sans(isTotal ? 16 : 14, isTotal ? .bold : .regular))
                .foregroundStyle(isTotal ? AppColor.textPrim : AppColor.textSec)
            Spacer()
            Text(String(format: "orders.price_format".localized, amount))
                .font(isTotal ? MedsyFont.price(16) : AppColor.sans(14, .medium))
                .foregroundStyle(isTotal ? AppColor.green : AppColor.textSec)
        }
    }

    private var reorderButton: some View {
        PrimaryButton(
            title: "orders.detail.reorder".localized,
            systemImage: reorderState == .loading ? nil : "arrow.counterclockwise",
            isLoading: reorderState == .loading,
            isDisabled: reorderState == .loading
        ) {
            onReorder?()
        }
    }


    private func dateLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "orders.section.today".localized
        } else if calendar.isDateInYesterday(date) {
            return "orders.section.yesterday".localized
        } else {
            return date.formatted(.dateTime.day().month(.wide).year())
        }
    }
}


enum OrderDetailViewState {
    case loading
    case loaded(OrderDetailPresentationModel)
    case error(String)
    case notFound
}


extension ReorderState {
    var showsFeedback: Bool {
        switch self {
        case .success, .partial, .failed:
            return true
        case .idle, .loading:
            return false
        }
    }
}


#Preview {
    OrderDetailView(
        state: .loaded(.mock),
        reorderState: .idle,
        onRetry: {},
        onBack: {}
    )
    .environment(LanguageManager.shared)
}
