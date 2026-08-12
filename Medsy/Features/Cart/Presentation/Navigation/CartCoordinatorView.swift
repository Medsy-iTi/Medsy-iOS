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
    case completeRequest
    case search(String)
    case prescription
}

@MainActor
@Observable
final class CartCoordinator {
    var path = NavigationPath()
    private(set) var requestDraft: CompleteRequestDraft?

    func showProductDetail(productID: String) {
        path.append(CartRoute.productDetail(productID))
    }

    func showCompleteRequest(draft: CartRequestDraft) {
        requestDraft = CompleteRequestDraftMapper.map(draft)
        path.append(CartRoute.completeRequest)
    }

    func showSearch(query: String = "") {
        path.append(CartRoute.search(query))
    }

    func showPrescription() {
        path.append(CartRoute.prescription)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func finishCompleteRequest() {
        requestDraft = nil
        path = NavigationPath()
    }
}

struct CartCoordinatorView: View {
    @State private var coordinator = CartCoordinator()
    let viewModel: CartViewModel
    let onTabBarHiddenChange: (Bool) -> Void
    let onRequestCompleted: () -> Void

    init(
        viewModel: CartViewModel,
        onTabBarHiddenChange: @escaping (Bool) -> Void = { _ in },
        onRequestCompleted: @escaping () -> Void = {}
    ) {
        self.viewModel = viewModel
        self.onTabBarHiddenChange = onTabBarHiddenChange
        self.onRequestCompleted = onRequestCompleted
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            CartView(
                viewModel: viewModel,
                onSearch: { coordinator.showSearch() },
                onScanPrescription: coordinator.showPrescription,
                onContinue: coordinator.showCompleteRequest,
                onProductSelected: coordinator.showProductDetail
            )
            .navigationDestination(for: CartRoute.self) { route in
                switch route {
                case let .productDetail(productID):
                    ProductDetailView(productId: productID)
                case .completeRequest:
                    if let draft = coordinator.requestDraft {
                        CompleteRequestCoordinatorView(
                            draft: draft,
                            clearCart: viewModel.clearAfterCompletedRequest,
                            onBack: coordinator.pop,
                            onCompleted: {
                                coordinator.finishCompleteRequest()
                                onRequestCompleted()
                            }
                        )
                    }
                case let .search(query):
                    SearchCoordinatorView(
                        query: query,
                        onBack: { coordinator.pop() },
                        onPush: { dest in coordinator.path.append(dest) }
                    )
                case .prescription:
                    PrescriptionCoordinatorView(
                        onExit: coordinator.pop,
                        onViewCart: coordinator.pop
                    )
                }
            }
            .navigationDestination(for: ProductDetailDestination.self) { destination in
                ProductDetailView(productId: destination.productId)
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
