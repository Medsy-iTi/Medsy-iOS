//
//  PharmacyHomeView.swift
//  Medsy-Pharmacy
//

import SwiftUI

struct PharmacyHomeView: View {
    @State private var viewModel: PharmacyHomeViewModel
    @ObservedObject private var sessionSettings: PharmacySessionSettings
    let onSelectRecentOrder: (Int) -> Void
    let onViewAllCompletedOrders: () -> Void

    init(
        viewModel: PharmacyHomeViewModel,
        sessionSettings: PharmacySessionSettings,
        onSelectRecentOrder: @escaping (Int) -> Void,
        onViewAllCompletedOrders: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: viewModel)
        _sessionSettings = ObservedObject(wrappedValue: sessionSettings)
        self.onSelectRecentOrder = onSelectRecentOrder
        self.onViewAllCompletedOrders = onViewAllCompletedOrders
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
                    pharmacyId: sessionSettings.currentPharmacyId,
                    isOpen: sessionSettings.isOnDuty
                )
                profileErrorView
                if viewModel.dashboardState != .restricted {
                    PharmacyDashboardPeriodHeader(
                        selectedPeriod: viewModel.selectedPeriod,
                        isLoading: viewModel.dashboardState == .loading,
                        onSelect: { period in
                            Task { await viewModel.selectPeriod(period) }
                        }
                    )
                }
                dashboardContent
            }
            .padding(.horizontal, PharmacySpacing.md)
            .padding(.top, PharmacySpacing.sm)
            .padding(.bottom, PharmacySpacing.md)
        }
        .background(PharmacyColor.bg)
        .refreshable { await viewModel.refresh() }
        .task { await viewModel.loadIfNeeded() }
    }

    @ViewBuilder
    private var dashboardContent: some View {
        switch viewModel.dashboardState {
        case .idle, .loading:
            VStack(spacing: PharmacySpacing.sm) {
                ProgressView()
                Text("pharmacy.home.dashboard_loading".localized)
                    .font(PharmacyColor.sans(12))
                    .foregroundStyle(PharmacyColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PharmacySpacing.xl)
            .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.md))

        case .restricted:
            PharmacyHomeSectionMessage(
                icon: "lock.shield",
                title: "pharmacy.home.admin_only_title".localized,
                message: "pharmacy.home.admin_only_message".localized
            )
            .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: PharmacyRadius.md)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            )

        case .failed(let message):
            ErrorStateView(
                icon: "exclamationmark.triangle",
                message: message,
                retryTitle: "common.retry".localized,
                onRetry: { Task { await viewModel.retryDashboard() } }
            )
            .background(PharmacyColor.card, in: RoundedRectangle(cornerRadius: PharmacyRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: PharmacyRadius.md)
                    .stroke(PharmacyColor.border, lineWidth: 1)
            )

        case .loaded:
            PharmacyMetricsGrid(metrics: viewModel.metrics)
            PharmacyTopSellingProductsView(products: viewModel.topSellingProducts)
            PharmacyRecentOrdersView(
                orders: viewModel.recentOrders,
                onSelectOrder: { onSelectRecentOrder($0.id) },
                onViewAllOrders: onViewAllCompletedOrders
            )
            PharmacyPrimaryButton(
                title: "pharmacy.home.view_all_completed_orders".localized,
                action: onViewAllCompletedOrders
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
            .background(
                PharmacyColor.warning.opacity(0.1),
                in: RoundedRectangle(cornerRadius: PharmacyRadius.md)
            )
        }
    }
}
