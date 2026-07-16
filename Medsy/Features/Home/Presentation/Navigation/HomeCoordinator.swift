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
    var path: [HomeRoute] = []

    func openSearch() {
        path.append(.search(""))
    }

    func showPrescription() {
        path.append(.prescription)
    }

    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
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
                        SearchCoordinatorView(query: query, onBack: coordinator.goBack)
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
