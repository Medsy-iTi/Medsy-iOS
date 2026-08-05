//
//  PharmacyOrdersView.swift
//  Medsy-Pharmacy
//
//  Created by Ehab Salah on 20/07/2026.
//

import SwiftUI

struct PharmacyOrdersView: View {
	@State private var viewModel: PharmacyOrdersViewModel
	let coordinator: PharmacyOrdersCoordinator

	init(viewModel: PharmacyOrdersViewModel, coordinator: PharmacyOrdersCoordinator) {
		self._viewModel = State(initialValue: viewModel)
		self.coordinator = coordinator
	}

	var body: some View {
		ScrollView(showsIndicators: false) {
			LazyVStack(spacing: PharmacySpacing.sm) {
				PharmacyOrdersHeaderView()
				PharmacyOrdersFilterBar(
					selection: $viewModel.selectedFilter,
					allCount: viewModel.allOrdersCount,
					newCount: viewModel.newOrdersCount,
					pendingApprovalCount: viewModel.pendingApprovalOrdersCount,
					expiredCount: viewModel.expiredOrdersCount,
					completedCount: viewModel.completedOrdersCount
				)
				PharmacyOrderSearchField(text: $viewModel.searchText, onClear: viewModel.clearSearch)

				switch viewModel.loadState {
					case .idle, .loading:
						ProgressView()
							.padding(.top, PharmacySpacing.xl)

					case .failed(let message):
						VStack {
							Spacer()
							PharmacyEmptyStateView(
								lottieName: "no_data_found",
								title: "pharmacy.orders.error.title".localized,
								message: message,
								retryTitle: "common.retry".localized,
								onRetry: { Task { await viewModel.loadInitial() } }
							)
							Spacer()
						}
						.frame(minHeight: UIScreen.main.bounds.height * 0.6)

					case .loaded:
						if viewModel.orders.isEmpty {
							VStack {
								Spacer()
								PharmacyEmptyStateView(
									lottieName: "no_data_found",
									title: "pharmacy.orders.empty.title".localized,
									message: "pharmacy.orders.empty.message".localized,
									retryTitle: "common.retry".localized,
									onRetry: { Task { await viewModel.loadInitial() } }
								)
								Spacer()
							}
							.frame(minHeight: UIScreen.main.bounds.height * 0.6)
						} else if viewModel.visibleOrders.isEmpty {
								// Orders exist, but none match the current filter/search
							VStack {
								Spacer()
								PharmacyEmptyStateView(
									lottieName: "no_data_found",
									title: "pharmacy.orders.noResults.title".localized,
									message: "pharmacy.orders.noResults.message".localized
								)
								Spacer()
							}
							.frame(minHeight: UIScreen.main.bounds.height * 0.4)
						} else {
							ForEach(viewModel.visibleOrders) { order in
								PharmacyOrderCard(order: order, onAction: {
									if let origOrder = viewModel.originalOrder(for: order.id) {
										coordinator.showRequestDetails(order: origOrder)
									}
								})
								.onTapGesture {
									if let origOrder = viewModel.originalOrder(for: order.id) {
										coordinator.showRequestDetails(order: origOrder)
									}
								}
								.task { await viewModel.loadNextPageIfNeeded(currentItem: order) }
							}
							if viewModel.isLoadingNextPage {
								ProgressView().padding(.vertical, PharmacySpacing.sm)
							}
						}
				}
			}
			.padding(.horizontal, PharmacySpacing.md)
			.padding(.top, PharmacySpacing.sm)
			.padding(.bottom, PharmacySpacing.md)
		}
		.background(PharmacyColor.bg)
		.refreshable { await viewModel.refresh() }
		.task { await viewModel.loadInitial() }
	}
}
