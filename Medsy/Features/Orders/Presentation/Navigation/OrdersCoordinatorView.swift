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

    private let mockListState: OrderHistoryViewState = .loaded(OrderHistoryView.previewSections)

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            OrderHistoryView(
                selectedFilter: $selectedFilter,
                state: mockListState,
                onSelectOrder: { order in coordinator.showDetail(orderId: order.id) },
                onRetry: {},
                onLoadNextPage: {}
            )
            .navigationDestination(for: OrdersRoute.self) { route in
                switch route {
                case .detail:
                    OrderDetailView(
                        state: .loaded(.mock),
                        onRetry: {},
                        onBack: { coordinator.pop() }
                    )
                }
            }
        }
    }
}

#Preview {
    OrdersCoordinatorView()
        .environment(LanguageManager.shared)
}
