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
    var onSelectProduct: ((Int) -> Void)? = nil
    var onDismissReorderFeedback: (() -> Void)? = nil
    var onGoToCart: (() -> Void)? = nil
    var selectedPharmacyID: Int? = nil
    var deliveryLocation: OrderCoordinatePresentation? = nil
    var routeState: OrderRoutePresentationState = .idle
    var onSelectPharmacy: ((Int) -> Void)? = nil
    var onShowPharmacyLocation: ((Int) -> Void)? = nil
    var onOpenDirections: ((OrderPharmacyPresentationModel) -> Void)? = nil
    var paymentAction: PaymentOrderActionPresentation? = nil
    var onPaymentAction: (() -> Void)? = nil

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
                MedsyNavBarBackButton(action: onBack)
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
                    OrderStatusProgressView(order: order)
                    if !order.pharmacies.isEmpty {
                        pharmacyMap(order: order)
                        ForEach(order.pharmacies) { pharmacy in
                            OrderPharmacySectionView(
                                pharmacy: pharmacy,
                                onSelectProduct: { onSelectProduct?($0) }
                            )
                        }
                    } else {
                        itemsSection(order: order)
                    }
                    if order.paymentMethod != nil {
                        paymentCard(order: order)
                    }
                    summaryCard(order: order)
                }
                .padding(MedsySpacing.md)
                .padding(.bottom, paymentAction == nil ? 96 : 162)
            }

            bottomActions
                .padding(.horizontal, MedsySpacing.md)
                .padding(.bottom, MedsySpacing.lg)
                .background(
                    AppColor.bg
                        .ignoresSafeArea()
                        .frame(height: paymentAction == nil ? 96 : 162)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                )
        }
    }

    @ViewBuilder
    private func pharmacyMap(order: OrderDetailPresentationModel) -> some View {
        let mappedPharmacies = order.pharmacies.filter { $0.coordinate != nil }
        if !mappedPharmacies.isEmpty {
            OrderPharmacyMapView(
                pharmacies: mappedPharmacies,
                selectedPharmacyID: selectedPharmacyID ?? mappedPharmacies.first?.id,
                deliveryLocation: deliveryLocation,
                routeState: routeState,
                onSelectPharmacy: { onSelectPharmacy?($0) },
                onShowPharmacyLocation: { onShowPharmacyLocation?($0) },
                onOpenDirections: { onOpenDirections?($0) }
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

            if let requestID = order.requestID {
                Text(String(format: "orders.detail.request_number".localized, requestID))
                    .font(AppColor.sans(13))
                    .foregroundStyle(AppColor.textSec)
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

    private func fulfillmentBadge(for type: OrderFulfillmentType) -> some View {
        HStack(spacing: MedsySpacing.xxs) {
            Image(systemName: fulfillmentIcon(for: type))
                .font(.system(size: 13))
            Text(fulfillmentLabel(for: type))
            .font(AppColor.sans(13, .medium))
        }
        .foregroundStyle(AppColor.onPrimaryContainer)
        .padding(.horizontal, MedsySpacing.sm)
        .padding(.vertical, MedsySpacing.xxs + 2)
        .background(AppColor.lightGreen)
        .clipShape(Capsule())
    }

    private func fulfillmentLabel(for type: OrderFulfillmentType) -> String {
        switch type {
        case .delivery:
            return "orders.fulfillment.delivery".localized
        case .pickup:
            return "orders.fulfillment.pickup".localized
        case .notSelected:
            return "orders.fulfillment.not_selected".localized
        }
    }

    private func fulfillmentIcon(for type: OrderFulfillmentType) -> String {
        switch type {
        case .delivery: return "shippingbox.fill"
        case .pickup: return "bag.fill"
        case .notSelected: return "clock.fill"
        }
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
        Button {
            if let productId = item.productId {
                onSelectProduct?(productId)
            }
        } label: {
            HStack(alignment: .center, spacing: MedsySpacing.sm) {
                OrderProductImageView(imageURL: item.imageURL, size: 48)

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

                VStack(alignment: .trailing, spacing: MedsySpacing.xxs) {
                    Text(String(format: "orders.price_format".localized, item.unitPrice * Double(item.quantity)))
                        .font(AppColor.sans(14, .semibold))
                        .foregroundStyle(AppColor.textPrim)

                    if item.productId != nil {
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColor.textSec)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(item.productId == nil)
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

    private func paymentCard(order: OrderDetailPresentationModel) -> some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            Label("orders.detail.payment".localized, systemImage: "creditcard.fill")
                .font(AppColor.sans(15, .semibold))
                .foregroundStyle(AppColor.textPrim)

            if let paymentMethod = order.paymentMethod {
                detailTextRow(
                    label: "orders.detail.payment_method".localized,
                    value: paymentMethod.labelKey.localized
                )
            }

            if let paymentStatus = order.paymentStatus {
                Divider().background(AppColor.border)
                detailTextRow(
                    label: "orders.detail.payment_status".localized,
                    value: paymentStatus.labelKey.localized
                )
            }

            if let paidAt = order.paidAt {
                Divider().background(AppColor.border)
                detailTextRow(
                    label: "orders.detail.paid_at".localized,
                    value: paidAt.formatted(date: .abbreviated, time: .shortened)
                )
            } else if order.paymentStatus == .pending, let expiresAt = order.paymentExpiresAt {
                Divider().background(AppColor.border)
                detailTextRow(
                    label: "orders.detail.payment_expires_at".localized,
                    value: expiresAt.formatted(date: .abbreviated, time: .shortened)
                )
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

    private func detailTextRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(AppColor.sans(14))
                .foregroundStyle(AppColor.textSec)
            Spacer(minLength: MedsySpacing.sm)
            Text(value)
                .font(AppColor.sans(14, .semibold))
                .foregroundStyle(AppColor.textPrim)
                .multilineTextAlignment(.trailing)
        }
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

    private var bottomActions: some View {
        VStack(spacing: MedsySpacing.sm) {
            if let paymentAction {
                PaymentOrderActionView(
                    action: paymentAction,
                    onTap: { onPaymentAction?() }
                )
            }

            reorderButton
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

private struct OrderStatusProgressView: View {
    let order: OrderDetailPresentationModel

    private var stages: [String] {
        let firstStage = usesPaymentStage
            ? "orders.status.pending_payment"
            : "orders.status.pending"

        switch order.fulfillmentType {
        case .delivery:
            return [
                firstStage,
                "orders.status.preparing",
                "orders.status.ready_for_delivery",
                "orders.status.out_for_delivery",
                "orders.status.delivered"
            ]
        case .pickup:
            return [
                firstStage,
                "orders.status.preparing",
                "orders.status.ready_for_pickup",
                "orders.status.delivered"
            ]
        case .notSelected:
            return [
                firstStage,
                "orders.status.preparing",
                "orders.status.delivered"
            ]
        }
    }

    private var usesPaymentStage: Bool {
        guard order.paymentMethod == .card else { return false }
        if case .notSelected = order.fulfillmentType {
            if case .pendingPayment = order.status { return true }
            return false
        }
        return true
    }

    private var currentIndex: Int {
        switch order.status {
        case .pending, .pendingPayment, .confirmed, .unknown:
            return 0
        case .preparing:
            return min(1, stages.count - 1)
        case .readyForPickup, .readyForDelivery:
            return min(2, stages.count - 1)
        case .outForDelivery:
            return order.fulfillmentType == .delivery
                ? min(3, stages.count - 1)
                : min(2, stages.count - 1)
        case .delivered:
            return stages.count - 1
        case .cancelled:
            return 0
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            Text("orders.detail.delivery_status".localized)
                .font(AppColor.sans(15, .semibold))
                .foregroundStyle(AppColor.textPrim)

            if order.status.isCancelled {
                Label("orders.status.cancelled".localized, systemImage: "xmark.circle.fill")
                    .font(AppColor.sans(14, .semibold))
                    .foregroundStyle(AppColor.errorRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, MedsySpacing.xs)
            } else {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(stages.enumerated()), id: \.offset) { index, labelKey in
                        progressNode(labelKey: labelKey, index: index)

                        if index < stages.count - 1 {
                            Rectangle()
                                .fill(index < currentIndex ? AppColor.green : AppColor.border)
                                .frame(maxWidth: .infinity)
                                .frame(height: 2)
                                .padding(.top, 13)
                                .accessibilityHidden(true)
                        }
                    }
                }
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

    private func progressNode(labelKey: String, index: Int) -> some View {
        let isReached = index <= currentIndex
        let isCurrent = index == currentIndex

        return VStack(spacing: MedsySpacing.xxs) {
            ZStack {
                Circle()
                    .fill(isReached ? AppColor.green : AppColor.card)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(isReached ? AppColor.green : AppColor.border, lineWidth: isCurrent ? 3 : 2)
                    )

                if isReached {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            Text(labelKey.localized)
                .font(AppColor.sans(10, isCurrent ? .semibold : .regular))
                .foregroundStyle(isReached ? AppColor.textPrim : AppColor.textSec)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: 64)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isCurrent ? .isSelected : [])
    }
}

private extension OrderPaymentMethod {
    var labelKey: String {
        switch self {
        case .cash: "orders.payment_method.cash"
        case .card: "orders.payment_method.card"
        }
    }
}

private extension OrderPaymentStatus {
    var labelKey: String {
        switch self {
        case .unpaid: "orders.payment_status.unpaid"
        case .pending: "orders.payment_status.pending"
        case .paid: "orders.payment_status.paid"
        case .failed: "orders.payment_status.failed"
        case .canceled: "orders.payment_status.canceled"
        case .expired: "orders.payment_status.expired"
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
        onBack: {},
        selectedPharmacyID: 71,
        deliveryLocation: OrderCoordinatePresentation(latitude: 30.0400, longitude: 31.2250),
        routeState: .ready(points: [
            OrderCoordinatePresentation(latitude: 30.0400, longitude: 31.2250),
            OrderCoordinatePresentation(latitude: 30.0444, longitude: 31.2357)
        ])
    )
    .environment(LanguageManager.shared)
}
