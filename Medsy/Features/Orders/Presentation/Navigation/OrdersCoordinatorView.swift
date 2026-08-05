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
    private let onReorderCompleted: () -> Void
    private let onGoToCart: () -> Void

    init(
        onReorderCompleted: @escaping () -> Void = {},
        onGoToCart: @escaping () -> Void = {}
    ) {
        _historyViewModel = State(initialValue: DIContainer.shared.resolve(OrderHistoryViewModel.self))
        _detailViewModel = State(initialValue: DIContainer.shared.resolve(OrderDetailViewModel.self))
        self.onReorderCompleted = onReorderCompleted
        self.onGoToCart = onGoToCart
    }

    init(
        historyViewModel: OrderHistoryViewModel,
        detailViewModel: OrderDetailViewModel,
        onReorderCompleted: @escaping () -> Void = {},
        onGoToCart: @escaping () -> Void = {}
    ) {
        _historyViewModel = State(initialValue: historyViewModel)
        _detailViewModel = State(initialValue: detailViewModel)
        self.onReorderCompleted = onReorderCompleted
        self.onGoToCart = onGoToCart
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
                        reorderState: detailViewModel.reorderState,
                        onRetry: { detailViewModel.handle(.retry(orderId: orderId)) },
                        onBack: { coordinator.pop() },
                        onReorder: { detailViewModel.handle(.reorder) },
                        onSelectProduct: { productId in
                            coordinator.path.append(ProductDetailDestination(productId: String(productId)))
                        },
                        onDismissReorderFeedback: { detailViewModel.handle(.dismissReorderFeedback) },
                        onGoToCart: onGoToCart
                    )
                    .onChange(of: detailViewModel.reorderState) { _, state in
                        guard state.didAddItemsToCart else { return }
                        onReorderCompleted()
                    }
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
