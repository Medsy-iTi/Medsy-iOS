//
//  SearchCoordinator.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import Observation
import SwiftUI

@MainActor
@Observable
final class SearchCoordinator {
    let query: String
    private let onBack: () -> Void
    private let onPush: (ProductDetailDestination) -> Void

    init(query: String, onBack: @escaping () -> Void, onPush: @escaping (ProductDetailDestination) -> Void) {
        self.query = query
        self.onBack = onBack
        self.onPush = onPush
    }

    func goBack() {
        onBack()
    }

    func showProductDetail(productId: String) {
        onPush(ProductDetailDestination(productId: productId))
    }
}

struct ProductDetailDestination: Hashable, Equatable {
    let productId: String

    static func == (lhs: ProductDetailDestination, rhs: ProductDetailDestination) -> Bool {
        lhs.productId == rhs.productId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(productId)
    }
}

struct SearchCoordinatorView: View {
    @State private var coordinator: SearchCoordinator

    init(query: String, onBack: @escaping () -> Void, onPush: @escaping (ProductDetailDestination) -> Void) {
        _coordinator = State(initialValue: SearchCoordinator(query: query, onBack: onBack, onPush: onPush))
    }

    var body: some View {
        SearchResultsView(
            query: coordinator.query,
            onBack: coordinator.goBack,
            coordinator: coordinator
        )
        .navigationBarHidden(true)
    }
}
