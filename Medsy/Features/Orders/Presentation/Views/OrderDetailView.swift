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
                    let namedPharmacies = namedPharmacies(for: order)
                    if namedPharmacies.count > 1 {
                        sectionTitle("orders.detail.pharmacies".localized)
                    }
                    ForEach(namedPharmacies) { pharmacy in
                        OrderPharmacySectionView(
                            pharmacy: pharmacy,
                            onSelect: { onSelectPharmacy?(pharmacy.pharmacyId) }
                        )
                    }
                    allocatedItemsSection(order: order)
                    summaryCard(order: order)
                }
                .padding(MedsySpacing.md)
                .padding(.bottom, bottomInset(for: order))
            }

            if showsBottomActions(for: order) {
                bottomActions(for: order)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        AppColor.bg
                            .ignoresSafeArea()
                            .frame(height: bottomInset(for: order))
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    )
            }
        }
    }

    private func namedPharmacies(for order: OrderDetailPresentationModel) -> [OrderPharmacyPresentationModel] {
        order.pharmacies.filter {
            !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private func showsBottomActions(for order: OrderDetailPresentationModel) -> Bool {
        paymentAction != nil || shouldShowReorder(for: order)
    }

    private func shouldShowReorder(for order: OrderDetailPresentationModel) -> Bool {
        order.status == .delivered && !order.items.compactMap(\.productId).isEmpty
    }

    private func bottomInset(for order: OrderDetailPresentationModel) -> CGFloat {
        guard showsBottomActions(for: order) else { return MedsySpacing.md }
        return paymentAction == nil || !shouldShowReorder(for: order) ? 96 : 162
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
        VStack(alignment: .leading, spacing: MedsySpacing.sm) {
            HStack(alignment: .center) {
                Text(order.status.labelKey.localized)
                    .font(AppColor.sans(18, .bold))
                    .foregroundStyle(statusHeaderColor(for: order.status))

                Spacer(minLength: 0)

                fulfillmentBadge(for: order.fulfillmentType)
            }

            Divider()
                .background(AppColor.outlineVariant.opacity(0.4))
                .padding(.vertical, MedsySpacing.sm)

            OrderStatusProgressView(order: order)
        }
        .padding(MedsySpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColor.outline.opacity(0.15), lineWidth: 1)
        )
    }

    private func fulfillmentBadge(for type: OrderFulfillmentType) -> some View {
        HStack(spacing: MedsySpacing.xxs) {
            Image(systemName: fulfillmentIcon(for: type))
                .font(.system(size: 13))
            Text(fulfillmentLabel(for: type))
                .font(AppColor.sans(13, .bold))
        }
        .foregroundStyle(AppColor.onSecondaryContainer)
        .padding(.horizontal, MedsySpacing.sm)
        .padding(.vertical, MedsySpacing.xxs + 2)
        .background(AppColor.secondaryContainer)
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
        case .delivery: return "truck.box.fill"
        case .pickup: return "storefront.fill"
        case .notSelected: return "clock.fill"
        }
    }

    private func statusHeaderColor(for status: OrderStatusPresentation) -> Color {
        if status.isCancelled {
            return AppColor.error
        }
        if status.isCompleted {
            return AppColor.success
        }
        return AppColor.green
    }

    private func allocatedItemsSection(order: OrderDetailPresentationModel) -> some View {
        let displayedItems = displayedItems(for: order)

        return VStack(alignment: .leading, spacing: MedsySpacing.xs) {
            sectionTitle("orders.detail.items_label".localized)

            VStack(spacing: 0) {
                if displayedItems.isEmpty {
                    Text("orders.detail.items_unavailable".localized)
                        .font(AppColor.sans(13))
                        .foregroundStyle(AppColor.textSec)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(MedsySpacing.md)
                } else {
                    ForEach(Array(displayedItems.enumerated()), id: \.offset) { index, allocation in
                        itemRow(item: allocation.item, suppliedBy: allocation.pharmacyName)
                        if index < displayedItems.count - 1 {
                            Divider()
                                .background(AppColor.outlineVariant.opacity(0.4))
                                .padding(.horizontal, MedsySpacing.md)
                        }
                    }
                }
            }
            .background(AppColor.card)
            .clipShape(RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: MedsyRadius.lg, style: .continuous)
                    .stroke(AppColor.outline.opacity(0.15), lineWidth: 1)
            )
        }
    }

    private func displayedItems(
        for order: OrderDetailPresentationModel
    ) -> [(pharmacyName: String?, item: OrderDetailItemModel)] {
        let allocatedItems: [(pharmacyName: String?, item: OrderDetailItemModel)] = order.pharmacies.flatMap { pharmacy in
            pharmacy.items.map { (pharmacy.name, $0) }
        }
        return allocatedItems.isEmpty
            ? order.items.map { (pharmacyName: nil, item: $0) }
            : allocatedItems
    }

    private func itemRow(item: OrderDetailItemModel, suppliedBy pharmacyName: String?) -> some View {
        Button {
            if let productId = item.productId {
                onSelectProduct?(productId)
            }
        } label: {
            HStack(alignment: .center, spacing: MedsySpacing.sm) {
                OrderProductImageView(
                    imageURL: item.imageURL,
                    size: 48,
                    containerColor: AppColor.surfaceVariant
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.productName)
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.textPrim)
                        .lineLimit(2)

                    Text(String(format: "orders.detail.item_qty_price".localized, item.quantity, item.unitPrice))
                        .font(AppColor.sans(14))
                        .foregroundStyle(AppColor.textSec)

                    if let pharmacyName, !pharmacyName.isEmpty {
                        Text(String(format: "orders.detail.supplied_by".localized, pharmacyName))
                            .font(AppColor.sans(12, .medium))
                            .foregroundStyle(AppColor.green)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: MedsySpacing.xxs) {
                    Text(String(format: "orders.price_format".localized, item.unitPrice * Double(item.quantity)))
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.textPrim)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(item.productId == nil)
        .padding(.horizontal, MedsySpacing.md)
        .padding(.vertical, MedsySpacing.sm)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(AppColor.sans(17, .bold))
            .foregroundStyle(AppColor.textPrim)
    }

    private func summaryCard(order: OrderDetailPresentationModel) -> some View {
        return VStack(spacing: 10) {
            Text("orders.detail.order_summary".localized)
                .font(AppColor.sans(17, .bold))
                .foregroundStyle(AppColor.textPrim)
                .frame(maxWidth: .infinity, alignment: .leading)

            summaryRow(
                label: "orders.detail.items_subtotal".localized,
                amount: order.itemsSubtotal,
                isTotal: false
            )

            if order.fulfillmentType == .delivery,
               let deliveryFee = order.deliveryFee {
                summaryRow(
                    label: "orders.detail.delivery_fee".localized,
                    amount: deliveryFee,
                    isTotal: false
                )
            }

            Divider().background(AppColor.outlineVariant.opacity(0.4))

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
                .stroke(AppColor.outline.opacity(0.15), lineWidth: 1)
        )
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
                .stroke(AppColor.outline.opacity(0.15), lineWidth: 1)
        )
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

    private func bottomActions(for order: OrderDetailPresentationModel) -> some View {
        VStack(spacing: MedsySpacing.sm) {
            if let paymentAction {
                PaymentOrderActionView(
                    action: paymentAction,
                    onTap: { onPaymentAction?() }
                )
            }

            if shouldShowReorder(for: order) {
                reorderButton
            }
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

    private struct Stage {
        let labelKey: String
        let systemImage: String
    }

    private var isDelivery: Bool {
        order.fulfillmentType == .delivery
            || order.status == .readyForDelivery
            || order.status == .outForDelivery
    }

    private var stages: [Stage] {
        if order.status.isCancelled {
            return [
                Stage(labelKey: "orders.timeline.preparing", systemImage: "shippingbox"),
                Stage(labelKey: "orders.status.cancelled", systemImage: "xmark")
            ]
        }

        if isDelivery {
            return [
                Stage(labelKey: "orders.timeline.preparing", systemImage: "shippingbox"),
                Stage(labelKey: "orders.timeline.ready", systemImage: "truck.box"),
                Stage(labelKey: "orders.timeline.on_the_way", systemImage: "bicycle"),
                Stage(labelKey: "orders.timeline.delivered", systemImage: "checkmark")
            ]
        }

        return [
            Stage(labelKey: "orders.timeline.preparing", systemImage: "shippingbox"),
            Stage(labelKey: "orders.timeline.ready", systemImage: "storefront"),
            Stage(labelKey: "orders.timeline.delivered", systemImage: "checkmark")
        ]
    }

    private var currentIndex: Int? {
        switch order.status {
        case .pending, .pendingPayment, .confirmed, .unknown, .delivered:
            return nil
        case .preparing:
            return 0
        case .readyForPickup, .readyForDelivery:
            return min(1, stages.count - 1)
        case .outForDelivery:
            return isDelivery ? min(2, stages.count - 1) : min(1, stages.count - 1)
        case .cancelled:
            return min(1, stages.count - 1)
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(stages.enumerated()), id: \.offset) { index, stage in
                progressNode(stage: stage, index: index)

                if index < stages.count - 1 {
                    Rectangle()
                        .fill(connectorColor(destinationIndex: index + 1))
                        .frame(maxWidth: .infinity)
                        .frame(height: 2)
                        .padding(.top, 13)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    private func progressNode(stage: Stage, index: Int) -> some View {
        let appearance = appearance(for: index)

        return VStack(spacing: MedsySpacing.xs) {
            ZStack {
                Circle()
                    .fill(appearance.backgroundColor)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .stroke(appearance.color, lineWidth: 2)
                    )

                Image(systemName: stage.systemImage)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(appearance.color)
            }

            Text(stage.labelKey.localized)
                .font(AppColor.sans(10, appearance.isEmphasized ? .bold : .medium))
                .foregroundStyle(appearance.color)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: 72)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(appearance.isCurrent ? .isSelected : [])
    }

    private func appearance(for index: Int) -> StageAppearance {
        if order.status.isCancelled, index == stages.count - 1 {
            return StageAppearance(
                color: AppColor.error,
                backgroundColor: AppColor.errorContainer,
                isCurrent: true,
                isEmphasized: true
            )
        }

        if order.status.isCompleted {
            return StageAppearance(
                color: AppColor.success,
                backgroundColor: AppColor.successContainer,
                isCurrent: false,
                isEmphasized: true
            )
        }

        if let currentIndex {
            if index < currentIndex {
                return StageAppearance(
                    color: AppColor.success,
                    backgroundColor: AppColor.successContainer,
                    isCurrent: false,
                    isEmphasized: true
                )
            }

            if index == currentIndex {
                return StageAppearance(
                    color: AppColor.warning,
                    backgroundColor: AppColor.warningContainer,
                    isCurrent: true,
                    isEmphasized: true
                )
            }
        }

        return StageAppearance(
            color: AppColor.textSec.opacity(0.35),
            backgroundColor: AppColor.card,
            isCurrent: false,
            isEmphasized: false
        )
    }

    private func connectorColor(destinationIndex: Int) -> Color {
        if order.status.isCancelled, destinationIndex == stages.count - 1 {
            return AppColor.error
        }

        if order.status.isCompleted {
            return AppColor.success
        }

        if let currentIndex, destinationIndex <= currentIndex {
            return AppColor.success
        }

        return AppColor.outlineVariant.opacity(0.5)
    }

    private struct StageAppearance {
        let color: Color
        let backgroundColor: Color
        let isCurrent: Bool
        let isEmphasized: Bool
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
