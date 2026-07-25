//
//  MainTabBarView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import Observation
import SwiftUI

@MainActor
struct MainTabBarView: View {
    @State private var coordinator: MainTabCoordinator
    @State private var isTabBarHidden = false
    @State private var cartViewModel: CartViewModel
    @State private var requestedHomeRoute: HomeRoute?
    @State private var cartFeedbackTask: Task<Void, Never>?
    @ObservedObject private var appSettings = AppSettings.shared

    init(coordinator: MainTabCoordinator) {
        _coordinator = State(initialValue: coordinator)
        _cartViewModel = State(
            initialValue: DIContainer.shared.resolve(CartViewModel.self)
        )
    }

    var body: some View {
        TabView(selection: selectedTabBinding) {
            HomeCoordinatorView(
                requestedRoute: $requestedHomeRoute,
                onTabBarHiddenChange: { isTabBarHidden = $0 },
                onOpenCart: { coordinator.select(.cart) }
            )
            .tabItem {
                Label("tab.home".localized, systemImage: "house")
            }
            .tag(AppTab.home)

            CartCoordinatorView(
                viewModel: cartViewModel,
                onTabBarHiddenChange: { isTabBarHidden = $0 },
                onRequestCompleted: {
                    isTabBarHidden = false
                    coordinator.select(.orders)
                }
            )
            .onAppear { isTabBarHidden = false }
            .tabItem {
                Label("tab.cart".localized, systemImage: "cart")
            }
            .badge(cartViewModel.distinctProductCount)
            .tag(AppTab.cart)

            ChatbotRootView { hidden in
                isTabBarHidden = hidden
            }
            .tabItem {
                Label("tab.medsy_chatbot".localized, systemImage: "sparkles")
            }
            .tag(AppTab.chatbot)

            OrdersCoordinatorView(
                onGoToCart: { coordinator.select(.cart) }
            )
            .onAppear { isTabBarHidden = false }
            .tabItem {
                Label("tab.orders".localized, systemImage: "doc.text")
            }
            .tag(AppTab.orders)

            ProfileCoordinatorView(
                onOrders: { coordinator.select(.orders) },
                onLogout: coordinator.logout
            )
            .onAppear { isTabBarHidden = false }
            .tabItem {
                Label("tab.account".localized, systemImage: "person")
            }
            .tag(AppTab.profile)
        }
        .environment(cartViewModel)
        .tint(AppColor.green)
        .toolbar(isTabBarHidden ? .hidden : .visible, for: .tabBar)
        .toolbarBackground(AppColor.card, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
        .animation(.easeInOut(duration: 0.2), value: isTabBarHidden)
        .overlay(alignment: .top) {
            if let productName = addedProductName {
                CartAddedBanner(productName: productName)
                    .padding(.horizontal, MedsySpacing.md)
                    .padding(.top, MedsySpacing.sm)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onChange(of: cartViewModel.feedbackSequence) { _, _ in
            scheduleFeedbackDismissal()
        }
        .onDisappear {
            cartFeedbackTask?.cancel()
        }
        .task {
            cartViewModel.handle(.load)
        }
        .animation(.easeInOut(duration: 0.25), value: cartViewModel.feedback)
    }

    private var selectedTabBinding: Binding<AppTab> {
        Binding(
            get: { coordinator.selectedTab },
            set: {
                isTabBarHidden = false
                coordinator.select($0)
            }
        )
    }

    private var addedProductName: String? {
        guard case let .itemAdded(productName) = cartViewModel.feedback else { return nil }
        return productName
    }

    private func scheduleFeedbackDismissal() {
        cartFeedbackTask?.cancel()
        guard case .itemAdded = cartViewModel.feedback else { return }

        cartFeedbackTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            cartViewModel.handle(.dismissFeedback)
        }
    }
}
