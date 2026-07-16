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

    init(query: String, onBack: @escaping () -> Void) {
        self.query = query
        self.onBack = onBack
    }

    func goBack() {
        onBack()
    }
}

struct SearchCoordinatorView: View {
    @State private var coordinator: SearchCoordinator

    init(query: String, onBack: @escaping () -> Void) {
        _coordinator = State(initialValue: SearchCoordinator(query: query, onBack: onBack))
    }

    var body: some View {
        SearchResultsView(query: coordinator.query, onBack: coordinator.goBack)
            .navigationBarBackButtonHidden()
    }
}
