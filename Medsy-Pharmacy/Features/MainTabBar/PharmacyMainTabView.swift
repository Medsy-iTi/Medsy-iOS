//
//  PharmacyMainTabView.swift
//  Medsy-Pharmacy
//
//  Created by Ahmed Elkady on 17/07/2026.
//

import SwiftUI

@MainActor
struct PharmacyMainTabView: View {
    @State private var coordinator: PharmacyMainTabCoordinator
    private let homeFactory: PharmacyHomeFactory
    private let ordersFactory: PharmacyOrdersFactory
    @ObservedObject private var appSettings = PharmacyAppSettings.shared
	@ObservedObject private var identityProviding  = PharmacySessionSettings.shared
	private let onLoggedOut: () -> Void

    init(
        coordinator: PharmacyMainTabCoordinator,
        homeFactory: PharmacyHomeFactory,
        ordersFactory: PharmacyOrdersFactory,
        onLoggedOut : @escaping () -> Void
    ) {
        _coordinator = State(initialValue: coordinator)
        self.homeFactory = homeFactory
        self.ordersFactory = ordersFactory
        self.onLoggedOut = onLoggedOut
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .padding(.bottom, 82)

            tabBar
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch coordinator.selectedTab {
        case .home:
            homeFactory.makeView(onViewAllOrders: coordinator.showOrders)
			case .orders:
				OrdersTabRootView(factory: ordersFactory)
        case .more:
				ProfileTabRootView(
					container: PharmacyAppAssembler.shared.container,
					onLoggedOut: onLoggedOut
				)
        case .products, .customers:
            PharmacySetupPlaceholderView(tab: coordinator.selectedTab)
        }
    }

    private var tabBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(PharmacyColor.border)

            HStack(spacing: 0) {
                ForEach(PharmacyTab.allCases) { tab in
                    tabItem(tab)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 24)
            .background(PharmacyColor.surface)
        }
        .frame(height: 82)
        .ignoresSafeArea(edges: .bottom)
    }

    private func tabItem(_ tab: PharmacyTab) -> some View {
        let isSelected = coordinator.selectedTab == tab

        return Button {
            coordinator.select(tab)
        } label: {
            VStack(spacing: 5) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? PharmacyColor.primary : PharmacyColor.textSecondary)

                Text(tab.titleKey.localized)
                    .font(PharmacyColor.sans(10, isSelected ? .bold : .medium))
                    .foregroundStyle(isSelected ? PharmacyColor.primary : PharmacyColor.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
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
