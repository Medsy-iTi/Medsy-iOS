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
    @State private var cartBadgeCount = CartSampleData.items.reduce(0) { $0 + $1.quantity }
    @ObservedObject private var appSettings = AppSettings.shared

    init(coordinator: MainTabCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch coordinator.selectedTab {
                case .home:
                    HomeCoordinatorView { isTabBarHidden = $0 }
                case .profile:
                    ProfileCoordinatorView(onLogout: coordinator.logout)
                        .onAppear { isTabBarHidden = false }
                case .cart:
                    CartView(
                        onSearch: { coordinator.select(.home) },
                        onUploadPrescription: { coordinator.select(.home) },
                        onItemCountChange: { cartBadgeCount = $0 }
                    )
                    .onAppear { isTabBarHidden = false }
                case .favorites, .offers, .orders:
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
            .padding(.bottom, isTabBarHidden ? 0 : 80)
            
            if !isTabBarHidden {
                VStack(spacing: 0) {
                    Divider()
                        .background(AppColor.border)
                    
                    HStack(spacing: 0) {
                        tabItem(tab: .home, labelKey: "tab.home", activeIcon: "house.fill", inactiveIcon: "house")
                        tabItem(tab: .favorites, labelKey: "tab.favorites", activeIcon: "heart.fill", inactiveIcon: "heart")
                        tabItem(tab: .cart, labelKey: "tab.cart", activeIcon: "cart.fill", inactiveIcon: "cart", badgeCount: cartBadgeCount)
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
