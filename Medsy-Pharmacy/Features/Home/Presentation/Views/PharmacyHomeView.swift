//  PharmacyHomeView.swift
//  Medsy-Pharmacy
//
//  Created by Antoneos Philip on 19/07/2026.
//

import SwiftUI

struct PharmacyHomeView: View {
    @State private var viewModel: PharmacyHomeViewModel
    @ObservedObject private var sessionSettings: PharmacySessionSettings
    @State private var selectedOrder: PharmacyOrder?
    let onViewAllOrders: () -> Void

    private let metrics = [
        PharmacyHomeMetric(titleKey: "pharmacy.home.new_orders", value: "23", icon: "bag.fill", tint: PharmacyColor.primary),
        PharmacyHomeMetric(titleKey: "pharmacy.home.preparing", value: "18", icon: "shippingbox.fill", tint: PharmacyColor.secondary),
        PharmacyHomeMetric(titleKey: "pharmacy.home.delivered_today", value: "45", icon: "cross.case.fill", tint: PharmacyColor.success),
        PharmacyHomeMetric(titleKey: "pharmacy.home.sales", value: "3,240", icon: "chart.pie.fill", tint: PharmacyColor.warning)
    ]

    init(
        viewModel: PharmacyHomeViewModel,
        sessionSettings: PharmacySessionSettings,
        onViewAllOrders: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        _sessionSettings = ObservedObject(wrappedValue: sessionSettings)
        self.onViewAllOrders = onViewAllOrders
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: PharmacySpacing.lg) {
                PharmacyHomeHeaderView()
                PharmacyHeroCard(
                    pharmacyName: sessionSettings.pharmacyName
                        ?? "pharmacy.home.pharmacy_unavailable".localized,
                    address: sessionSettings.pharmacyAddress
                        ?? "pharmacy.home.address_unavailable".localized,
                    isOpen: sessionSettings.isOnDuty
                )
                profileErrorView
                PharmacyMetricsGrid(metrics: metrics)
                PharmacyRecentOrdersView(
                    state: viewModel.ordersState,
                    orders: viewModel.recentOrders,
                    onSelectOrder: { order in
                        selectedOrder = order.sourceOrder
                    },
                    onRetry: { Task { await viewModel.retryOrders() } },
                    onViewAllOrders: onViewAllOrders
                )
                PharmacyPrimaryButton(
                    title: "pharmacy.home.view_all_orders".localized,
                    action: onViewAllOrders
                )
            }
            .padding(.horizontal, PharmacySpacing.md)
            .padding(.top, PharmacySpacing.sm)
            .padding(.bottom, PharmacySpacing.md)
        }
        .background(PharmacyColor.bg)
        .refreshable { await viewModel.refresh() }
        .task { await viewModel.loadIfNeeded() }
        .fullScreenCover(item: $selectedOrder) { order in
            PharmacyRequestDetailsView(
                viewModel: PharmacyRequestDetailsViewModel(order: order)
            )
        }
    }

    @ViewBuilder
    private var profileErrorView: some View {
        if case .failed(let message) = viewModel.profileState {
            HStack(spacing: PharmacySpacing.sm) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(PharmacyColor.warning)
                Text(message)
                    .font(PharmacyColor.sans(12))
                    .foregroundStyle(PharmacyColor.textSecondary)
                Spacer()
                Button("common.retry".localized) {
                    Task { await viewModel.retryProfile() }
                }
                .font(PharmacyColor.sans(12, .semibold))
                .foregroundStyle(PharmacyColor.primary)
            }
            .padding(PharmacySpacing.sm)
            .background(PharmacyColor.warning.opacity(0.1), in: RoundedRectangle(cornerRadius: PharmacyRadius.md))
        }
    }
}
