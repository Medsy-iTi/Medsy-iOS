//
//  OrdersCoordinatorView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import SwiftUI

struct OrdersCoordinatorView: View {
    @State private var coordinator = OrdersCoordinator()
    @State private var historyViewModel: OrderHistoryViewModel
    @State private var detailViewModel: OrderDetailViewModel
    private let onSelectPharmacy: (Int) -> Void

    init(
        onSelectPharmacy: @escaping (Int) -> Void = { _ in }
    ) {
        _historyViewModel = State(initialValue: DIContainer.shared.resolve(OrderHistoryViewModel.self))
        _detailViewModel = State(initialValue: DIContainer.shared.resolve(OrderDetailViewModel.self))
        self.onSelectPharmacy = onSelectPharmacy
    }

    init(
        historyViewModel: OrderHistoryViewModel,
        detailViewModel: OrderDetailViewModel,
        onSelectPharmacy: @escaping (Int) -> Void = { _ in }
    ) {
        _historyViewModel = State(initialValue: historyViewModel)
        _detailViewModel = State(initialValue: detailViewModel)
        self.onSelectPharmacy = onSelectPharmacy
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            OrderHistoryView(
                activeFilters: historyViewModel.activeFilters,
                state: historyViewModel.historyState,
                onApplyFilters: { historyViewModel.handle(.applyFilters($0)) },
                onSelectOrder: { order in coordinator.showDetail(orderId: order.id) },
                onRetry: { historyViewModel.handle(.retry) },
                onLoadNextPage: { historyViewModel.handle(.loadNextPage) },
                onSearch: { coordinator.showSearch() }
            )
            .task {
                historyViewModel.handle(.load)
            }
            .navigationDestination(for: OrdersRoute.self) { route in
                switch route {
                case .detail(let orderId):
                    OrderDetailView(
                        state: detailViewModel.detailState,
                        onRetry: { detailViewModel.handle(.retry(orderId: orderId)) },
                        onBack: { coordinator.pop() },
                        onSelectPharmacy: onSelectPharmacy
                    )
                    .task {
                        detailViewModel.handle(.load(orderId: orderId))
                    }
                case let .search(query):
                    SearchCoordinatorView(
                        query: query,
                        onBack: { coordinator.pop() },
                        onPush: { dest in coordinator.path.append(dest) }
                    )
                }
            }
            .navigationDestination(for: ProductDetailDestination.self) { destination in
                ProductDetailView(productId: destination.productId)
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
