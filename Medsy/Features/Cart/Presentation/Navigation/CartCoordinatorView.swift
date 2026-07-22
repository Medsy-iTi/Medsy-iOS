//
//  CartCoordinatorView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 22/07/2026.
//

import Observation
import SwiftUI

enum CartRoute: Hashable {
    case productDetail(String)
}

@MainActor
@Observable
final class CartCoordinator {
    var path = NavigationPath()

    func showProductDetail(productID: String) {
        path.append(CartRoute.productDetail(productID))
    }
}

struct CartCoordinatorView: View {
    @State private var coordinator = CartCoordinator()
    let viewModel: CartViewModel
    let onSearch: () -> Void
    let onTabBarHiddenChange: (Bool) -> Void

    init(
        viewModel: CartViewModel,
        onSearch: @escaping () -> Void = {},
        onTabBarHiddenChange: @escaping (Bool) -> Void = { _ in }
    ) {
        self.viewModel = viewModel
        self.onSearch = onSearch
        self.onTabBarHiddenChange = onTabBarHiddenChange
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            CartView(
                viewModel: viewModel,
                onSearch: onSearch,
                onProductSelected: coordinator.showProductDetail
            )
            .navigationDestination(for: CartRoute.self) { route in
                switch route {
                case let .productDetail(productID):
                    ProductDetailView(productId: productID)
                }
            }
        }
        .onAppear {
            onTabBarHiddenChange(!coordinator.path.isEmpty)
        }
        .onChange(of: coordinator.path.isEmpty) { _, isEmpty in
            onTabBarHiddenChange(!isEmpty)
        }
    }
}
