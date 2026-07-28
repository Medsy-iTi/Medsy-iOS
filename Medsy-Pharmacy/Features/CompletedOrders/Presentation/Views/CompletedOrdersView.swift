//
//  CompletedOrdersView.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import SwiftUI

struct CompletedOrdersView: View {
    @State private var viewModel: CompletedOrdersViewModel

    init(viewModel: CompletedOrdersViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: PharmacySpacing.md) {
            PharmacySearchField(
                text: $viewModel.searchText,
                placeholder: "orders_search_placeholder".localized
            )

            content
        }
        .padding(.horizontal, PharmacySpacing.md)
        .padding(.top, PharmacySpacing.sm)
        .background(PharmacyColor.bg.ignoresSafeArea())
        .navigationTitle("orders_title".localized)
        .task {
            await viewModel.onAppear()
        }
        .refreshable {
            await viewModel.reload()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            Spacer()
            ProgressView()
            Spacer()

        case .failed(let message):

            PharmacyEmptyStateView(
                lottieName: "no_data_found",
                title: "orders_error_title".localized,
                message: message
            )
            Button("orders_retry".localized) {
                Task { await viewModel.reload() }
            }
            .buttonStyle(.borderedProminent)
            Spacer()
				Spacer()
				Spacer()
				Spacer()

        case .empty(.noOrders):
            PharmacyEmptyStateView.noCompletedOrders

        case .empty(.noResults):
            PharmacyEmptyStateView.noSearchResults

        case .loaded:
            ScrollView {
                LazyVStack(spacing: PharmacySpacing.md) {
                    ForEach(viewModel.visibleOrders) { order in
                        CompletedOrderCard(order: order) {
                            viewModel.select(order)
                        }
                        .task {
                            await viewModel.loadNextPageIfNeeded(currentItem: order)
                        }
                    }

                    if viewModel.isLoadingNextPage {
                        ProgressView()
                            .padding(.vertical, PharmacySpacing.md)
                    }
                }
                .padding(.bottom, PharmacySpacing.lg)
            }
        }
    }
}
extension PharmacyEmptyStateView {

	static var noCompletedOrders: PharmacyEmptyStateView {
		PharmacyEmptyStateView(
			lottieName: "no_data_found",
			title: "orders_empty_none_title".localized,
			message: "orders_empty_none_message".localized
		)
	}


	static var noSearchResults: PharmacyEmptyStateView {
		PharmacyEmptyStateView(
			lottieName: "no_data_found",
			title: "orders_empty_filtered_title".localized,
			message: "orders_empty_filtered_message".localized
		)
	}
}
