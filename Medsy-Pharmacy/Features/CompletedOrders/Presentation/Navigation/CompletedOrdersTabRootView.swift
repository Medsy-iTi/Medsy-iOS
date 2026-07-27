//
//  CompletedOrdersTabRootView.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import SwiftUI

struct CompletedOrdersTabRootView: View {
    private let factory: PharmacyCompletedOrdersFactory
    @State private var coordinator: CompletedOrdersCoordinator
    @State private var viewModel: CompletedOrdersViewModel

    init(factory: PharmacyCompletedOrdersFactory) {
        self.factory = factory
        let coordinator = CompletedOrdersCoordinator()
        _coordinator = State(initialValue: coordinator)
        _viewModel = State(initialValue: factory.makeViewModel(coordinator: coordinator))
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            CompletedOrdersView(viewModel: viewModel)
                .navigationDestination(for: CompletedOrdersRoute.self) { route in
                    switch route {
                    case .detail(let orderId):
                        CompletedOrderDetailsCoordinatorView.Embedded(
                            orderId: orderId,
                            onTabBarHiddenChange: { _ in } // Tab bar hiding handled at higher level or unused in Pharmacy app
                        )
                    }
                }
        }
    }
}
