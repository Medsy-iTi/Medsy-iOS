//
//  OrdersEmptyView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import SwiftUI

struct OrdersEmptyView: View {
    let activeFilters: ActiveOrderFilters
    var onSearch: () -> Void = {}
    var onClearFilters: () -> Void = {}

    var body: some View {
        VStack(spacing: MedsySpacing.lg) {
            Image(systemName: activeFilters.hasActiveFilters ? "line.3.horizontal.decrease.circle" : "doc.text")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(AppColor.green.opacity(0.4))

            VStack(spacing: MedsySpacing.xs) {
                Text(titleKey.localized)
                    .font(MedsyFont.title(17))
                    .foregroundStyle(AppColor.textPrim)
                    .multilineTextAlignment(.center)

                Text(subtitleKey.localized)
                    .font(MedsyFont.caption())
                    .foregroundStyle(AppColor.textSec)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, MedsySpacing.xl)
            }

            VStack(spacing: MedsySpacing.sm) {
                PrimaryButton(
                    title: "orders.empty.search".localized,
                    systemImage: "magnifyingglass",
                    action: onSearch
                )

                if activeFilters.hasActiveFilters {
                    Button("orders.empty.clear_filters".localized) {
                        onClearFilters()
                    }
                    .font(AppColor.sans(15, .medium))
                    .foregroundStyle(AppColor.green)
                }
            }
            .padding(.horizontal, MedsySpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, MedsySpacing.xxl)
    }

    private var titleKey: String {
        if activeFilters.hasActiveFilters { return "orders.empty.filtered.title" }
        switch activeFilters.statusFilter {
        case .all:       return "orders.empty.title"
        case .active:    return "orders.empty.active.title"
        case .completed: return "orders.empty.completed.title"
        case .cancelled: return "orders.empty.cancelled.title"
        }
    }

    private var subtitleKey: String {
        if activeFilters.hasActiveFilters { return "orders.empty.filtered.subtitle" }
        switch activeFilters.statusFilter {
        case .all:       return "orders.empty.subtitle"
        case .active:    return "orders.empty.active.subtitle"
        case .completed: return "orders.empty.completed.subtitle"
        case .cancelled: return "orders.empty.cancelled.subtitle"
        }
    }
}

#Preview {
    OrdersEmptyView(activeFilters: .default, onSearch: {})
        .background(AppColor.bg)
}
