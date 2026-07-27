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
		self.viewModel = viewModel
		self.coordinator = coordinator
	}

	var body: some View {
		ScrollView(showsIndicators: false) {
			LazyVStack(spacing: PharmacySpacing.sm) {
				PharmacyOrdersHeaderView()
				PharmacyOrdersFilterBar(
					selection: $viewModel.selectedFilter, allCount: viewModel.allOrdersCount,
					newCount: viewModel.deliveredOrdersCount,
					preparingCount: viewModel.newOrdersCount,
					deliveredCount: viewModel.preparingOrdersCount
				)
				PharmacyOrderSearchField(text: $viewModel.searchText, onClear: viewModel.clearSearch)

				switch viewModel.loadState {
					case .idle, .loading:
						ProgressView()
							.padding(.top, PharmacySpacing.xl)

					case .failed(let message):
						VStack {
							Spacer()
							ErrorStateView(
								icon: "exclamationmark.triangle",
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
								ErrorStateView(
									icon: "tray",
									message: "pharmacy.orders.noData".localized,
									retryTitle: "common.retry".localized,
									onRetry: { Task { await viewModel.loadInitial() } }
								)
								Spacer()
							}
							.frame(minHeight: UIScreen.main.bounds.height * 0.6)
						}else if viewModel.visibleOrders.isEmpty {
								// Orders exist, but none match the current filter/search
							PharmacyOrdersEmptyView()
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
