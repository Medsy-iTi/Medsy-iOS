//
//  CompletedOrderDetailsCoordinatorView.swift
//  Medsy
//

import SwiftUI

struct CompletedOrderDetailsCoordinatorView: View {
    @State private var coordinator = CompletedOrderDetailsCoordinator()
    @State private var viewModel: CompletedOrderDetailViewModel


    var onTabBarHiddenChange: (Bool) -> Void

    // MARK: - Production init

    init(
        orderId: Int,
        onTabBarHiddenChange: @escaping (Bool) -> Void = { _ in }
    ) {
        _viewModel = State(
            initialValue: PharmacyAppAssembler.shared.container.resolve(CompletedOrderDetailViewModel.self)
        )
        self.onTabBarHiddenChange = onTabBarHiddenChange

        _ = orderId
        _coordinator = State(initialValue: CompletedOrderDetailsCoordinator())
    }


    init(
        viewModel: CompletedOrderDetailViewModel,
        onTabBarHiddenChange: @escaping (Bool) -> Void = { _ in }
    ) {
        _viewModel = State(initialValue: viewModel)
        self.onTabBarHiddenChange = onTabBarHiddenChange
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            Color.clear
                .navigationDestination(for: CompletedOrderDetailsRoute.self) { route in
                    switch route {
                    case .detail(let orderId):
                        PharmacyCompletedOrderDetailView(
                            state: viewModel.viewState,
                            onRetry: { viewModel.handle(.retry(orderId: orderId)) },
                            onBack: { coordinator.pop() }
                        )
                        .task {
                            viewModel.handle(.load(orderId: orderId))
                        }
                    }
                }
        }
        .onChange(of: coordinator.path.isEmpty) { _, isEmpty in
            onTabBarHiddenChange(!isEmpty)
        }
    }
}


extension CompletedOrderDetailsCoordinatorView {

    struct Embedded: View {
        let orderId: Int
        var onTabBarHiddenChange: (Bool) -> Void = { _ in }

        @State private var coordinator = CompletedOrderDetailsCoordinator()
        @State private var viewModel: CompletedOrderDetailViewModel
        @Environment(\.dismiss) private var dismiss

        init(
            orderId: Int,
            onTabBarHiddenChange: @escaping (Bool) -> Void = { _ in }
        ) {
            self.orderId = orderId
            self.onTabBarHiddenChange = onTabBarHiddenChange
            _viewModel = State(
                initialValue: PharmacyAppAssembler.shared.container.resolve(CompletedOrderDetailViewModel.self)
            )
        }

        var body: some View {
            PharmacyCompletedOrderDetailView(
                state: viewModel.viewState,
                onRetry: { viewModel.handle(.retry(orderId: orderId)) },
                onBack: { dismiss() }
            )
            .task {
                viewModel.handle(.load(orderId: orderId))
            }
            .onAppear { onTabBarHiddenChange(true) }
            .onDisappear { onTabBarHiddenChange(false) }
        }
    }
}

#Preview {
    CompletedOrderDetailsCoordinatorView(
        viewModel: CompletedOrderDetailViewModel(state: .loaded(.mock))
    )
    .environment(LanguageManager.shared)
}
