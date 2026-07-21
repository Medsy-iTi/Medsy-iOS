//
//  OrdersCoordinatorView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import SwiftUI

struct OrdersCoordinatorView: View {
    @State private var coordinator = OrdersCoordinator()
    @State private var selectedFilter: OrderFilter = .all
    @State private var historyViewModel: OrderHistoryViewModel
    @State private var detailViewModel: OrderDetailViewModel

    init() {
        _historyViewModel = State(initialValue: DIContainer.shared.resolve(OrderHistoryViewModel.self))
        _detailViewModel = State(initialValue: DIContainer.shared.resolve(OrderDetailViewModel.self))
    }

    init(historyViewModel: OrderHistoryViewModel, detailViewModel: OrderDetailViewModel) {
        _historyViewModel = State(initialValue: historyViewModel)
        _detailViewModel = State(initialValue: detailViewModel)
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            OrderHistoryView(
                selectedFilter: $selectedFilter,
                state: historyViewModel.historyState,
                onSelectOrder: { order in coordinator.showDetail(orderId: order.id) },
                onRetry: { historyViewModel.handle(.retry) },
                onLoadNextPage: { historyViewModel.handle(.loadNextPage) }
            )
            .onChange(of: selectedFilter) { _, newFilter in
                historyViewModel.handle(.selectFilter(newFilter))
            }
            .task {
                historyViewModel.handle(.load)
            }
            .navigationDestination(for: OrdersRoute.self) { route in
                switch route {
                case .detail(let orderId):
                    OrderDetailView(
                        state: detailViewModel.detailState,
                        onRetry: { detailViewModel.handle(.retry(orderId: orderId)) },
                        onBack: { coordinator.pop() }
                    )
                    .task {
                        detailViewModel.handle(.load(orderId: orderId))
                    }
                }
            }
        }
    }
}

#Preview {
    OrdersCoordinatorView(
        historyViewModel: OrderHistoryViewModel(state: .loaded(OrderHistoryView.previewSections)),
        detailViewModel: OrderDetailViewModel(state: .loaded(.mock))
    )
    .environment(LanguageManager.shared)
}
