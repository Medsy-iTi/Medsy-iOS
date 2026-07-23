import SwiftUI

struct PharmacyOrdersView: View {
	@State private var viewModel: PharmacyOrdersViewModel
	@State private var selectedOrder: PharmacyOrderListItem? = nil
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
						} else if viewModel.visibleOrders.isEmpty {
							PharmacyOrdersEmptyView()
						} else {
							ForEach(viewModel.visibleOrders) { order in
								PharmacyOrderCard(order: order, onAction: { selectedOrder = order })
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
		.fullScreenCover(item: $selectedOrder) { order in
			PharmacyRequestDetailsView(requestModel: PharmacyRequestDetailsModel(order: order))
		}
		.refreshable { await viewModel.refresh() }
		.task { await viewModel.loadInitial() }
	}
}
