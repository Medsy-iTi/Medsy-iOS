//
//  ChatbotRootView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 12/08/2026.
//

import SwiftUI

struct ChatbotRootView: View {
    @State private var coordinator = ChatbotCoordinator()
    @State private var viewModel: AiChatViewModel
    @Environment(CartViewModel.self) private var cartViewModel
    var onTabBarHiddenChange: (Bool) -> Void
    var onOpenCart: (() -> Void)?
    var onOpenCompleteRequest: (() -> Void)?
    @Binding private var pendingPrompt: String?
    private let promptSequence: Int
    private let onBackToProduct: (() -> Void)?

    init(
        onTabBarHiddenChange: @escaping (Bool) -> Void,
        onOpenCart: (() -> Void)? = nil,
        onOpenCompleteRequest: (() -> Void)? = nil,
        pendingPrompt: Binding<String?> = .constant(nil),
        promptSequence: Int = 0,
        onBackToProduct: (() -> Void)? = nil
    ) {
        self.onTabBarHiddenChange = onTabBarHiddenChange
        self.onOpenCart = onOpenCart
        self.onOpenCompleteRequest = onOpenCompleteRequest
        self._pendingPrompt = pendingPrompt
        self.promptSequence = promptSequence
        self.onBackToProduct = onBackToProduct
        self._viewModel = State(
            wrappedValue: DIContainer.shared.resolve(AiChatViewModel.self)
        )
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            MedsyChatView(viewModel: viewModel, onBack: onBackToProduct)
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
        .onAppear { consumePendingPrompt() }
        .onChange(of: promptSequence) { _, _ in consumePendingPrompt() }
    }

    private func consumePendingPrompt() {
        guard let prompt = pendingPrompt else { return }
        viewModel.prefillPrompt(prompt)
        pendingPrompt = nil
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
