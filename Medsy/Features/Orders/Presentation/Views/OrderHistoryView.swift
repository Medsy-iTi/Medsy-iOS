//
//  OrderHistoryView.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import SwiftUI

struct OrderHistoryView: View {
    let activeFilters: ActiveOrderFilters
    let state: OrderHistoryViewState
    let onApplyFilters: (ActiveOrderFilters) -> Void
    let onSelectOrder: (OrderPresentationModel) -> Void
    let onRetry: () -> Void
    let onLoadNextPage: () -> Void
    var onSearch: () -> Void = {}
    var onPaymentAction: (Int) -> Void = { _ in }

    @State private var isFilterSheetPresented = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().background(AppColor.border)
            content
        }
        .background(AppColor.bg)
        .sheet(isPresented: $isFilterSheetPresented) {
            OrderFilterSheetView(current: activeFilters) { updated in
                isFilterSheetPresented = false
                onApplyFilters(updated)
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var header: some View {
        ZStack {
            Text("orders.title".localized)
                .font(AppColor.sans(17, .bold))
                .foregroundStyle(AppColor.textPrim)
                .frame(maxWidth: .infinity)

            HStack {
                Spacer()
                Button {
                    isFilterSheetPresented = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 22))
                            .foregroundStyle(activeFilters.hasActiveFilters ? AppColor.green : AppColor.textPrim)
                        if activeFilters.hasActiveFilters {
                            Circle()
                                .fill(AppColor.green)
                                .frame(width: 8, height: 8)
                                .offset(x: 2, y: -2)
                        }
                    }
                }
                .accessibilityLabel("orders.filter.button.accessibility".localized)
            }
            .padding(.trailing, MedsySpacing.md)
        }
        .padding(.vertical, MedsySpacing.md)
    }

    @ViewBuilder
    private var content: some View {
        switch state {
        case .loading:
            loadingView
        case .loaded(let sections):
            let orders = sections.flatMap(\.orders)
            if orders.isEmpty {
                OrdersEmptyView(
                    activeFilters: activeFilters,
                    onSearch: onSearch,
                    onClearFilters: { onApplyFilters(.default) }
                )
            } else {
                ordersListView(sections: sections)
            }
        case .error(let message):
            OrdersErrorView(message: message, onRetry: onRetry)
        case .idle:
            Color.clear
        }
    }

    private var loadingView: some View {
        OrderHistoryLoadingSkeleton()
    }

    private func ordersListView(sections: [OrderDateSection]) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: MedsySpacing.md) {
                ForEach(sections) { section in
                    Section {
                        ForEach(section.orders) { order in
                            OrderCardView(
                                order: order,
                                onTap: { onSelectOrder(order) },
                                onPaymentTap: { onPaymentAction(order.id) }
                            )
                        }
                    } header: {
                        Text(section.title)
                            .font(AppColor.sans(14, .semibold))
                            .foregroundStyle(AppColor.textSec)
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
    OrderHistoryView(
        activeFilters: .default,
        state: .loaded(OrderHistoryView.previewSections),
        onApplyFilters: { _ in },
        onSelectOrder: { _ in },
        onRetry: {},
        onLoadNextPage: {},
        onSearch: {}
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
