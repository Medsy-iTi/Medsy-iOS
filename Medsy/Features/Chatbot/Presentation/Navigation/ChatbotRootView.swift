
//
//  ChatbotRootView.swift
//  Medsy
//

import SwiftUI

struct ChatbotRootView: View {

    @State private var coordinator = ChatbotCoordinator()
    @State private var viewModel: ChatViewModel

    var onTabBarHiddenChange: (Bool) -> Void

    init(onTabBarHiddenChange: @escaping (Bool) -> Void) {
        self.onTabBarHiddenChange = onTabBarHiddenChange
        self._viewModel = State(
            wrappedValue: DIContainer.shared.resolve(ChatViewModel.self)
        )
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            MedsyChatView(viewModel: viewModel)
                .navigationBarHidden(true)
                .navigationDestination(for: ChatbotRoute.self) { route in
                    destination(for: route)
                }
        }
        .onAppear {
            onTabBarHiddenChange(false)
            viewModel.onNavigateToDetails = { id in
                coordinator.push(.medicineDetails(medicineId: id))
            }
        }
        .onChange(of: coordinator.path.isEmpty) { _, isEmpty in
            onTabBarHiddenChange(!isEmpty)
        }
    }

    @ViewBuilder
    private func destination(for route: ChatbotRoute) -> some View {
        switch route {
        case .chatDetail:
            MedsyChatView(viewModel: viewModel)
                .navigationBarHidden(true)

        case .medicineDetails(let medicineId):
            ProductDetailView(productId: medicineId)
        case .pharmacyMap:
            Text("Pharmacy Map")
        }
    }
}
