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

    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}

struct HomeCoordinatorView: View {
    @State private var coordinator = HomeCoordinator()
    private let onTabBarHiddenChange: (Bool) -> Void

    init(onTabBarHiddenChange: @escaping (Bool) -> Void = { _ in }) {
        self.onTabBarHiddenChange = onTabBarHiddenChange
    }

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            HomeView(onSearchTap: coordinator.openSearch, onPrescription: coordinator.showPrescription)
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case let .search(query):
                        SearchCoordinatorView(query: query, onBack: coordinator.goBack) { dest in
                            coordinator.path.append(dest)
                        }
                    case .prescription:
                        PrescriptionUploadView(
                            onCamera: {},
                            onGallery: {}
                        )
                        .localizedNavigationBackButton(action: coordinator.goBack)
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
