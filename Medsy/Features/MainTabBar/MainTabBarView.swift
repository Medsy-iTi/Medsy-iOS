//  MainTabBarView.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.
//

import SwiftUI
import Observation

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
        ZStack(alignment: .bottom) {
            Group {
            switch coordinator.selectedTab {
                case .home:
                    HomeCoordinatorView(
                        requestedRoute: $requestedHomeRoute,
                        onTabBarHiddenChange: { isTabBarHidden = $0 },
                        onOpenCart: { coordinator.select(.cart) }
                    )
                case .profile:
                    ProfileCoordinatorView(onLogout: coordinator.logout)
                        .onAppear { isTabBarHidden = false }
                case .cart:
                    CartCoordinatorView(
                        viewModel: cartViewModel,
                        onSearch: openSearchFromCart,
                        onTabBarHiddenChange: { isTabBarHidden = $0 },
                        onRequestCompleted: {
                            isTabBarHidden = false
                            coordinator.select(.orders)
                        }
                    )
                    .onAppear { isTabBarHidden = false }
                case .orders:
                    OrdersCoordinatorView()
                        .onAppear { isTabBarHidden = false }
                case .favorites, .offers:
                    VStack {
                        Spacer()
                        Text("Tab \(coordinator.selectedTab.rawValue)")
                            .font(AppColor.sans(18, .medium))
                            .foregroundStyle(AppColor.textSec)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppColor.bg)
                    .onAppear { isTabBarHidden = false }
                }
            }
            .environment(cartViewModel)
            .padding(.bottom, isTabBarHidden ? 0 : 80)
            
            if !isTabBarHidden {
                VStack(spacing: 0) {
                    Divider()
                        .background(AppColor.border)
                    
                    HStack(spacing: 0) {
                        tabItem(tab: .home, labelKey: "tab.home", activeIcon: "house.fill", inactiveIcon: "house")
                        tabItem(tab: .favorites, labelKey: "tab.favorites", activeIcon: "heart.fill", inactiveIcon: "heart")
                        tabItem(tab: .cart, labelKey: "tab.cart", activeIcon: "cart.fill", inactiveIcon: "cart", badgeCount: cartViewModel.distinctProductCount)
                        tabItem(tab: .offers, labelKey: "tab.offers", activeIcon: "tag.fill", inactiveIcon: "tag")
                        tabItem(tab: .orders, labelKey: "tab.orders", activeIcon: "doc.text.fill", inactiveIcon: "doc.text")
                        tabItem(tab: .profile, labelKey: "tab.account", activeIcon: "person.fill", inactiveIcon: "person")
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                    .background(AppColor.card)
                }
                .frame(height: 80)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .ignoresSafeArea(edges: .bottom)
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

    private func openSearchFromCart() {
        openSearch()
    }

    private func openSearch() {
        requestedHomeRoute = .search("")
        coordinator.select(.home)
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
    
    private func tabItem(tab: AppTab, labelKey: String, activeIcon: String, inactiveIcon: String, badgeCount: Int? = nil) -> some View {
        let isActive = coordinator.selectedTab == tab
        return Button {
            isTabBarHidden = false
            coordinator.select(tab)
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: isActive ? activeIcon : inactiveIcon)
                        .font(.system(size: 20, weight: isActive ? .bold : .regular))
                        .foregroundStyle(isActive ? AppColor.green : AppColor.textSec)
                        .frame(width: 28, height: 24)

                    if let badgeCount, badgeCount > 0 {
                        Text("\(min(badgeCount, 99))")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 16, minHeight: 16)
                            .background(AppColor.danger)
                            .clipShape(Capsule())
                            .offset(x: 9, y: -7)
                    }
                }
                
                Text(labelKey.localized)
                    .font(AppColor.sans(10, isActive ? .bold : .medium))
                    .foregroundStyle(isActive ? AppColor.green : AppColor.textSec)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
