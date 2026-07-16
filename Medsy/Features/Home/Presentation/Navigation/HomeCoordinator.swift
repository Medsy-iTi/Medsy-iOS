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
}

@MainActor
@Observable
final class HomeCoordinator {
    var path = NavigationPath()

    func openSearch() {
        path.append(HomeRoute.search(""))
    }

    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}

struct HomeCoordinatorView: View {
    @State private var coordinator = HomeCoordinator()

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            HomeView(onSearchTap: coordinator.openSearch)
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case let .search(query):
                        SearchCoordinatorView(query: query, onBack: coordinator.goBack) { dest in
                            coordinator.path.append(dest)
                        }
                    }
                }
        }
    }
}
