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

    init(coordinator: MainTabCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch coordinator.selectedTab {
                case .home:
                    HomeCoordinatorView()
                case .profile:
                    ProfileCoordinatorView(onLogout: coordinator.logout)
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
                }
            }
            .padding(.bottom, 80)
            
            VStack(spacing: 0) {
                Divider()
                    .background(AppColor.border)
                
                HStack(spacing: 0) {
                    tabItem(tab: .home, labelKey: "tab.home", activeIcon: "house.fill", inactiveIcon: "house")
                    tabItem(tab: .favorites, labelKey: "tab.favorites", activeIcon: "heart.fill", inactiveIcon: "heart")
                    tabItem(tab: .offers, labelKey: "tab.offers", activeIcon: "tag.fill", inactiveIcon: "tag")
                    tabItem(tab: .orders, labelKey: "tab.orders", activeIcon: "doc.text.fill", inactiveIcon: "doc.text")
                    tabItem(tab: .profile, labelKey: "tab.account", activeIcon: "person.fill", inactiveIcon: "person")
                }
                .padding(.top, 10)
                .padding(.bottom, 24)
                .background(AppColor.card)
            }
            .frame(height: 80)
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func tabItem(tab: AppTab, labelKey: String, activeIcon: String, inactiveIcon: String) -> some View {
        let isActive = coordinator.selectedTab == tab
        return Button {
            coordinator.select(tab)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isActive ? activeIcon : inactiveIcon)
                    .font(.system(size: 20, weight: isActive ? .bold : .regular))
                    .foregroundStyle(isActive ? AppColor.green : AppColor.textSec)
                
                Text(labelKey.localized)
                    .font(AppColor.sans(10, isActive ? .bold : .medium))
                    .foregroundStyle(isActive ? AppColor.green : AppColor.textSec)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
