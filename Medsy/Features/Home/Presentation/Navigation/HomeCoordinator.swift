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

    func search(for query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        path.append(.search(trimmedQuery))
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

    var body: some View {
        @Bindable var coordinator = coordinator

        NavigationStack(path: $coordinator.path) {
            HomeView(onSearch: coordinator.search, onPrescription: coordinator.showPrescription)
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
    }
}
