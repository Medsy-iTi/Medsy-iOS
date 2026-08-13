//
//  ChatbotRootView.swift
//  Medsy
//

import SwiftUI

struct ChatbotRootView: View {
    @State private var coordinator = ChatbotCoordinator()
    @State private var viewModel: AiChatViewModel
    @Environment(CartViewModel.self) private var cartViewModel
    var onTabBarHiddenChange: (Bool) -> Void
    var onOpenCart: (() -> Void)?
    var onOpenCompleteRequest: (() -> Void)?

    init(
        viewModel: AiChatViewModel? = nil,
        onTabBarHiddenChange: @escaping (Bool) -> Void,
        onOpenCart: (() -> Void)? = nil,
        onOpenCompleteRequest: (() -> Void)? = nil
    ) {
        self.onTabBarHiddenChange = onTabBarHiddenChange
        self.onOpenCart = onOpenCart
        self.onOpenCompleteRequest = onOpenCompleteRequest
        self._viewModel = State(
            wrappedValue: viewModel ?? DIContainer.shared.resolve(AiChatViewModel.self)
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
            viewModel.onOpenProductDetails = { id in
                coordinator.push(.medicineDetails(medicineId: String(id)))
            }
            viewModel.onOpenCategory = { id, name in
                coordinator.push(.category(id: id, name: name))
            }
            viewModel.onOpenCart = onOpenCart
            viewModel.onOpenCompleteRequest = onOpenCompleteRequest
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
        case .category(let id, let name):
            ProductsView(category: Category(id: id, name: name))
        case .completeRequest:
            Text("Complete Request View Placeholder")
        }
    }
}
