//
//  HomeCoordinator.swift
//  Medsy
//
//  Created by Ehab Salah on 16/07/2026.
//

import Observation
import SwiftUI

enum HomeRoute: Hashable {
    case search(String)
    case prescription
}

@MainActor
@Observable
final class HomeCoordinator {
    var path = NavigationPath()

    func openSearch() {
        path.append(HomeRoute.search(""))
    }

    func showPrescription() {
        path.append(HomeRoute.prescription)
    }

    func open(_ route: HomeRoute) {
        path.append(route)
    }

    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}

struct HomeCoordinatorView: View {
    @State private var coordinator = HomeCoordinator()
    @Binding private var requestedRoute: HomeRoute?
    private let onTabBarHiddenChange: (Bool) -> Void

    init(
        requestedRoute: Binding<HomeRoute?> = .constant(nil),
        onTabBarHiddenChange: @escaping (Bool) -> Void = { _ in }
    ) {
        _requestedRoute = requestedRoute
        self.onTabBarHiddenChange = onTabBarHiddenChange
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            HomeView(onSearchTap: coordinator.openSearch, onPrescription: coordinator.showPrescription)
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case let .search(query):
                        SearchCoordinatorView(query: query, onBack: coordinator.goBack, onPush: { dest in
                            coordinator.path.append(dest)
                        })
                    case .prescription:
                        PrescriptionCoordinatorView(
                            onExit: coordinator.goBack
                        )
                    }
                }
                .navigationDestination(for: ProductDetailDestination.self) { destination in
                    ProductDetailView(productId: destination.productId)
                }
        }
        .onAppear {
            openRequestedRoute()
            onTabBarHiddenChange(!coordinator.path.isEmpty)
        }
        .onChange(of: requestedRoute) { _, _ in
            openRequestedRoute()
        }
        .onChange(of: coordinator.path.isEmpty) { _, isEmpty in
            onTabBarHiddenChange(!isEmpty)
        }
    }

    private func openRequestedRoute() {
        guard let requestedRoute else { return }
        coordinator.open(requestedRoute)
        self.requestedRoute = nil
    }
}
