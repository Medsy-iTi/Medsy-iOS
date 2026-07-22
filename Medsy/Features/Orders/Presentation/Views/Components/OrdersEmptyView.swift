//
//  OrdersEmptyView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import SwiftUI

struct OrdersEmptyView: View {
    let filter: OrderFilter
    var onSearch: () -> Void = {}

    var body: some View {
        VStack(spacing: MedsySpacing.lg) {
            Image(systemName: "doc.text")
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

            if filter == .all {
                PrimaryButton(
                    title: "orders.empty.search".localized,
                    systemImage: "magnifyingglass",
                    action: onSearch
                )
                .padding(.horizontal, MedsySpacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, MedsySpacing.xxl)
    }

    private var titleKey: String {
        switch filter {
        case .all:       "orders.empty.title"
        case .active:    "orders.empty.active.title"
        case .completed: "orders.empty.completed.title"
        case .cancelled: "orders.empty.cancelled.title"
        }
    }

    private var subtitleKey: String {
        switch filter {
        case .all:       "orders.empty.subtitle"
        case .active:    "orders.empty.active.subtitle"
        case .completed: "orders.empty.completed.subtitle"
        case .cancelled: "orders.empty.cancelled.subtitle"
        }
    }
}

#Preview {
    OrdersEmptyView(filter: .all, onSearch: {})
        .background(AppColor.bg)
}
