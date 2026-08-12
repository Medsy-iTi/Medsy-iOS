//
//  OrderHistoryViewModel.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class OrderHistoryViewModel: OrderHistoryViewModelProtocol {

    private(set) var historyState: OrderHistoryViewState = .idle
    private(set) var activeFilters: ActiveOrderFilters = .default
    private(set) var isLoadingNextPage = false

    private let loadOrdersUseCase: LoadOrdersUseCaseProtocol?
    private var loadTask: Task<Void, Never>?
    private var currentPage = 0
    private var isLastPage = false
    private var loadedOrders: [OrderPresentationModel] = []

    private static let pageSize = 20

    init(loadOrdersUseCase: LoadOrdersUseCaseProtocol? = nil) {
        self.loadOrdersUseCase = loadOrdersUseCase
    }

    init(state: OrderHistoryViewState) {
        historyState = state
        loadOrdersUseCase = nil
    }

    func handle(_ event: OrderHistoryEvent) {
        switch event {
        case .load:
            load(reset: true)
        case .retry:
            load(reset: true)
        case .applyFilters(let filters):
            activeFilters = filters
            renderLoadedOrders()
        case .loadNextPage:
            guard !isLastPage, !isLoadingNextPage else { return }
            loadNextPage()
        }
    }

    private func load(reset: Bool) {
        loadTask?.cancel()
        if reset {
            currentPage = 0
            isLastPage = false
            isLoadingNextPage = false
            loadedOrders = []
        }
        historyState = .loading
        loadTask = Task {
            await fetchOrders(page: 0, appending: false)
        }
    }

    private func loadNextPage() {
        loadTask?.cancel()
        let nextPage = currentPage + 1
        isLoadingNextPage = true
        loadTask = Task {
            await fetchOrders(page: nextPage, appending: true)
            isLoadingNextPage = false
        }
    }

    private func fetchOrders(page: Int, appending: Bool) async {
        guard let useCase = loadOrdersUseCase else { return }
        do {
            let result = try await useCase.execute(
                filter: .empty,
                page: page,
                size: Self.pageSize
            )
            guard !Task.isCancelled else { return }

            let mapped = result.items.map(OrderEntityMapper.map)
            if appending {
                loadedOrders.append(contentsOf: mapped)
            } else {
                loadedOrders = mapped
            }

            currentPage = result.page
            isLastPage = result.isLast ?? (result.items.count < Self.pageSize)
            renderLoadedOrders()
        } catch {
            guard !Task.isCancelled else { return }
            if !appending {
                historyState = .error(error.localizedDescription)
            }
        }
    }

    private func renderLoadedOrders() {
        let filteredOrders = loadedOrders.filter(activeFilters.matches)
        let sections = buildSections(from: filteredOrders, filters: activeFilters)
        historyState = .loaded(sections)
    }

    private func buildSections(from orders: [OrderPresentationModel], filters: ActiveOrderFilters) -> [OrderDateSection] {
        if filters == .default {
            let activeOrders = orders.filter(\.status.isActive)
            let historyOrders = orders.filter { !$0.status.isActive }
            return [
                OrderDateSection(
                    id: "active",
                    title: "orders.section.active".localized,
                    orders: activeOrders
                ),
                OrderDateSection(
                    id: "history",
                    title: "orders.section.history".localized,
                    orders: historyOrders
                )
            ]
            .filter { !$0.orders.isEmpty }
        }

        let calendar = Calendar.current
        var todayOrders: [OrderPresentationModel] = []
        var yesterdayOrders: [OrderPresentationModel] = []
        var olderGroups: [String: [OrderPresentationModel]] = [:]
        var olderKeys: [String] = []

        for order in orders {
            if calendar.isDateInToday(order.date) {
                todayOrders.append(order)
            } else if calendar.isDateInYesterday(order.date) {
                yesterdayOrders.append(order)
            } else {
                let key = order.date.formatted(.dateTime.month().day())
                if olderGroups[key] == nil {
                    olderGroups[key] = []
                    olderKeys.append(key)
                }
                olderGroups[key]?.append(order)
            }
        }

        var sections: [OrderDateSection] = []
        if !todayOrders.isEmpty {
            sections.append(OrderDateSection(
                id: "today",
                title: "orders.section.today".localized,
                orders: todayOrders
            ))
        }
        if !yesterdayOrders.isEmpty {
            sections.append(OrderDateSection(
                id: "yesterday",
                title: "orders.section.yesterday".localized,
                orders: yesterdayOrders
            ))
        }
        for key in olderKeys {
            sections.append(OrderDateSection(
                id: key,
                title: key,
                orders: olderGroups[key] ?? []
            ))
        }
        return sections
    }
}
