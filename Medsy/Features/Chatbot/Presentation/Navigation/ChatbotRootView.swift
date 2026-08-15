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
    var onOpenReminders: (() -> Void)?
    @Binding private var pendingPrompt: String?
    private let promptSequence: Int
    private let onBackToProduct: (() -> Void)?

    init(
        viewModel: AiChatViewModel? = nil,
        onTabBarHiddenChange: @escaping (Bool) -> Void,
        onOpenCart: (() -> Void)? = nil,
        onOpenReminders: (() -> Void)? = nil,
        pendingPrompt: Binding<String?> = .constant(nil),
        promptSequence: Int = 0,
        onBackToProduct: (() -> Void)? = nil
    ) {
        self.onTabBarHiddenChange = onTabBarHiddenChange
        self.onOpenCart = onOpenCart
        self.onOpenReminders = onOpenReminders
        self._pendingPrompt = pendingPrompt
        self.promptSequence = promptSequence
        self.onBackToProduct = onBackToProduct
        self._viewModel = State(
            wrappedValue: viewModel ?? DIContainer.shared.resolve(AiChatViewModel.self)
        )
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            MedsyChatView(viewModel: viewModel, onBack: onBackToProduct.map { action in
                {
                    viewModel.clearDraftPrompt()
                    action()
                }
            })
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
            viewModel.onOpenCompleteRequest = { products in
                // Push completeRequest directly onto this coordinator's path!
                coordinator.push(.completeRequest(products))
            }
            viewModel.onOpenReminders = onOpenReminders
            viewModel.onCartNeedsRefresh = {
                cartViewModel.handle(.retry) // Silent background sync
            }
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
        case .medicineDetails(let medicineId):
            ProductDetailView(productId: medicineId)
        case .pharmacyMap:
            Text("Pharmacy Map")
        case .category(let id, let name):
            ProductsView(category: Category(id: id, name: name))
        case .completeRequest(let products):
            // Map AIChatProduct to CompleteRequestItem
            let items = products.map { p in
                CompleteRequestItem(
                    id: String(p.id),
                    name: p.productName ?? p.name,
                    dosageInfo: p.strength ?? "",
                    imageURL: p.imageURL,
                    unitPrice: p.price,
                    quantity: 1
                )
            }
            let draft = CompleteRequestDraft(items: items, prescriptionCount: 0)
            CompleteRequestCoordinatorView(
                draft: draft,
                clearCart: { return true },
                onBack: { coordinator.pop() },
                onCompleted: {
                    coordinator.pop()
                    cartViewModel.handle(.load) // optional refresh
                }
            )
        }
    }
}
