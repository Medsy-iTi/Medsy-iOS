//
//  PharmacyCompletedOrderDetailView.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import SwiftUI

struct PharmacyCompletedOrderDetailView: View {
    let state: CompletedOrderDetailViewState
    let onRetry: () -> Void
    let onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            PharmacyDivider()
            detailContent
        }
        .background(PharmacyColor.bg)
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .pharmacyLocalizedEnvironment()
    }

    private var navTitle: String {
        if case .loaded(let order) = state {
            return String(format: "completed_order.order_number".localized, order.orderNumber)
        }
        return "completed_order.title".localized
    }

    @ViewBuilder
    private var detailContent: some View {
        switch state {
        case .loading:
            PharmacyCompletedOrderDetailLoadingSkeleton()
        case .loaded(let order):
            loadedView(order: order)
        case .error(let message):
            PharmacyErrorView(message: message, onRetry: onRetry)
        case .notFound:
            PharmacyOrderNotFoundView(onBack: onBack)
        }
    }

    private func loadedView(order: CompletedOrderDetailPresentationModel) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: PharmacySpacing.md) {
                PharmacyOrderStatusHeaderView(
                    customerName: order.customerName,
                    createdAt: order.createdAt,
                    hasDelivery: order.hasDelivery
                )
                PharmacyOrderPharmacyInfoCard(
                    pharmacyName: order.pharmacyName,
                    pharmacyAddress: order.pharmacyAddress,
                    pharmacyPhone: order.pharmacyPhone,
                    pharmacistName: order.pharmacistName
                )
                PharmacyOrderItemsSection(items: order.items)
                PharmacyOrderSummaryCard(
                    subTotal: order.subTotal,
                    deliveryFee: order.deliveryFee,
                    total: order.total,
                    hasDelivery: order.hasDelivery
                )
            }
            .padding(PharmacySpacing.md)
        }
        .background(PharmacyColor.bg)
    }
}

#Preview {
    PharmacyCompletedOrderDetailView(
        state: .loaded(.mock),
        onRetry: {},
        onBack: {}
    )
    .environment(LanguageManager.shared)
}
