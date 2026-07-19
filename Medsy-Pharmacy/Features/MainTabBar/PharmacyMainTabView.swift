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
    @State private var pharmacyManagementCoordinator: PharmacyManagementCoordinator
    @ObservedObject private var appSettings = PharmacyAppSettings.shared

    init(
        coordinator: PharmacyMainTabCoordinator,
        pharmacyManagementFactory: PharmacyManagementFactory
    ) {
        _coordinator = State(initialValue: coordinator)
        _pharmacyManagementCoordinator = State(
            initialValue: pharmacyManagementFactory.makeCoordinator()
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            tabContent
                .padding(.bottom, showsTabBar ? 82 : 0)

            if showsTabBar {
                tabBar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(PharmacyColor.bg.ignoresSafeArea())
        .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
        .animation(.easeInOut(duration: 0.2), value: showsTabBar)
    }

    @ViewBuilder
    private var tabContent: some View {
        if coordinator.selectedTab == .home {
            PharmacyHomeView()
        } else if coordinator.selectedTab == .pharmacy {
            PharmacyManagementCoordinatorView(coordinator: pharmacyManagementCoordinator)
        } else {
            PharmacySetupPlaceholderView(tab: coordinator.selectedTab)
        }
    }

    private var showsTabBar: Bool {
        coordinator.selectedTab != .pharmacy || pharmacyManagementCoordinator.path.isEmpty
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
