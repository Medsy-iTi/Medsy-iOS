//
//  OrderHistoryView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import SwiftUI

struct OrderHistoryView: View {
    @Binding var selectedFilter: OrderFilter
    let state: OrderHistoryViewState
    let onSelectOrder: (OrderPresentationModel) -> Void
    let onRetry: () -> Void
    let onLoadNextPage: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("orders.title".localized)
                .font(AppColor.sans(17, .bold))
                .foregroundStyle(AppColor.textPrim)
                .frame(maxWidth: .infinity)
                .padding(.vertical, MedsySpacing.md)

            OrderFilterChipBar(filters: OrderFilter.allCases, selected: $selectedFilter)

            Divider().background(AppColor.border)

            content
        }
        .background(AppColor.bg)
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .loading:
            loadingView
        case .loaded(let sections):
            let orders = sections.flatMap(\.orders)
            if orders.isEmpty {
                OrdersEmptyView(filter: selectedFilter)
            } else {
                ordersListView(orders: orders)
            }
        case .error(let message):
            OrdersErrorView(message: message, onRetry: onRetry)
        case .idle:
            Color.clear
        }
    }

    private var loadingView: some View {
        VStack(spacing: MedsySpacing.lg) {
            ProgressView()
                .tint(AppColor.green)
            Text("orders.loading".localized)
                .font(MedsyFont.caption())
                .foregroundStyle(AppColor.textSec)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func ordersListView(orders: [OrderPresentationModel]) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: MedsySpacing.sm) {
                ForEach(orders) { order in
                    OrderCardView(order: order) {
                        onSelectOrder(order)
                    }
                }

                Color.clear
                    .frame(height: 1)
                    .onAppear { onLoadNextPage() }
            }
            .padding(.horizontal, MedsySpacing.md)
            .padding(.top, MedsySpacing.md)
            .padding(.bottom, MedsySpacing.xxl + 80)
        }
    }
}


enum OrderHistoryViewState {
    case idle
    case loading
    case loaded([OrderDateSection])
    case error(String)
}

struct OrderDateSection: Identifiable {
    let id: String
    let title: String
    let orders: [OrderPresentationModel]
}


#Preview {
    @Previewable @State var filter: OrderFilter = .all
    OrderHistoryView(
        selectedFilter: $filter,
        state: .loaded(OrderHistoryView.previewSections),
        onSelectOrder: { _ in },
        onRetry: {},
        onLoadNextPage: {}
    )
    .environment(LanguageManager.shared)
}

extension OrderHistoryView {
    static var previewSections: [OrderDateSection] {
        let orders = OrderPresentationModel.mockOrders
        return [
            OrderDateSection(id: "today", title: "orders.section.today".localized, orders: [orders[0]]),
            OrderDateSection(id: "yesterday", title: "orders.section.yesterday".localized, orders: [orders[1]]),
            OrderDateSection(id: "may", title: "12 مايو", orders: [orders[2], orders[3]])
        ]
    }
}
