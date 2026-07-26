//
//  PharmacyMainTabView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

@MainActor
struct PharmacyMainTabView: View {
    var coordinator: PharmacyMainTabCoordinator
    private let homeFactory: PharmacyHomeFactory
    private let ordersFactory: PharmacyOrdersFactory
    @ObservedObject private var appSettings = PharmacyAppSettings.shared
    @ObservedObject private var identityProviding = PharmacySessionSettings.shared
    private let onLoggedOut: () -> Void

    init(
        coordinator: PharmacyMainTabCoordinator,
        homeFactory: PharmacyHomeFactory,
        ordersFactory: PharmacyOrdersFactory,
        onLoggedOut: @escaping () -> Void
    ) {
        self.coordinator = coordinator
        self.homeFactory = homeFactory
        self.ordersFactory = ordersFactory
        self.onLoggedOut = onLoggedOut
    }

    var body: some View {
        TabView(selection: selectedTabBinding) {
            homeFactory.makeView(onViewAllOrders: coordinator.showOrders)
                .tabItem {
                    tabLabel(for: .home)
                }
                .tag(PharmacyTab.home)

            OrdersTabRootView(factory: ordersFactory)
                .tabItem {
                    tabLabel(for: .orders)
                }
                .tag(PharmacyTab.orders)

            PharmacySetupPlaceholderView(tab: .products)
                .tabItem {
                    tabLabel(for: .products)
                }
                .tag(PharmacyTab.products)

            PharmacySetupPlaceholderView(tab: .customers)
                .tabItem {
                    tabLabel(for: .customers)
                }
                .tag(PharmacyTab.customers)

            ProfileTabRootView(
                coordinator: coordinator.profileCoordinator,
                onLoggedOut: onLoggedOut
            )
            .tabItem {
                tabLabel(for: .more)
            }
            .tag(PharmacyTab.more)
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .tint(PharmacyColor.primary)
        .toolbarBackground(PharmacyColor.surface, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
    }

    private var selectedTabBinding: Binding<PharmacyTab> {
        Binding(
            get: { coordinator.selectedTab },
            set: { coordinator.select($0) }
        )
    }

    private func tabLabel(for tab: PharmacyTab) -> some View {
        let isSelected = coordinator.selectedTab == tab

        return Label(
            tab.titleKey.localized,
            systemImage: isSelected ? tab.selectedIcon : tab.icon
        )
    }
}

private struct PharmacySetupPlaceholderView: View {
    let tab: PharmacyTab

    var body: some View {
        VStack(spacing: PharmacySpacing.md) {
            Image(systemName: "cross.case.fill")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(PharmacyColor.primary)

            Text(titleKey.localized)
                .font(PharmacyColor.sans(20, .bold))
                .foregroundStyle(PharmacyColor.textPrimary)

            Text(subtitleKey.localized)
                .font(PharmacyColor.sans(14))
                .foregroundStyle(PharmacyColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(PharmacySpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PharmacyColor.bg)
    }

    private var titleKey: String {
        tab == .home ? "pharmacy.dashboard.title" : tab.titleKey
    }

    private var subtitleKey: String {
        tab == .home
            ? "pharmacy.dashboard.placeholder"
            : "pharmacy.setup.placeholder"
    }
}
