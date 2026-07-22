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
    private(set) var isLoadingNextPage = false

    private let loadOrdersUseCase: LoadOrdersUseCaseProtocol?
    private var loadTask: Task<Void, Never>?
    private var currentFilter: OrderFilter = .all
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
            load(filter: currentFilter, reset: true)
        case .retry:
            load(filter: currentFilter, reset: true)
        case .selectFilter(let filter):
            currentFilter = filter
            load(filter: filter, reset: true)
        case .loadNextPage:
            guard !isLastPage, !isLoadingNextPage else { return }
            loadNextPage()
        }
    }

    private func load(filter: OrderFilter, reset: Bool) {
        loadTask?.cancel()
        if reset {
            currentPage = 0
            isLastPage = false
            isLoadingNextPage = false
            loadedOrders = []
        }
        historyState = .loading
        loadTask = Task {
            await fetchOrders(filter: filter, page: 0, appending: false)
        }
    }

    private func loadNextPage() {
        loadTask?.cancel()
        let nextPage = currentPage + 1
        isLoadingNextPage = true
        loadTask = Task {
            await fetchOrders(filter: currentFilter, page: nextPage, appending: true)
            isLoadingNextPage = false
        }
    }

    private func fetchOrders(filter: OrderFilter, page: Int, appending: Bool) async {
        guard let useCase = loadOrdersUseCase else { return }
        do {
            var requestedPage = page
            var shouldReplace = !appending

            while true {
                let result = try await useCase.execute(
                    statuses: filter.domainStatuses,
                    page: requestedPage,
                    size: Self.pageSize
                )
                guard !Task.isCancelled else { return }

                // The deployed endpoint currently ignores the optional status query.
                // Keep filtering locally as a compatibility fallback while paging past
                // empty filtered pages so a later match is never hidden.
                let mapped = result.items
                    .filter { filter.matches($0.status) }
                    .map(OrderEntityMapper.map)

                if shouldReplace {
                    loadedOrders = mapped
                    shouldReplace = false
                } else {
                    loadedOrders.append(contentsOf: mapped)
                }

                currentPage = result.page
                isLastPage = result.isLast ?? (result.items.count < Self.pageSize)

                if !mapped.isEmpty || isLastPage || filter == .all {
                    break
                }
                requestedPage += 1
            }

            let sections = buildSections(from: loadedOrders)
            historyState = sections.isEmpty ? .loaded([]) : .loaded(sections)
        } catch {
            guard !Task.isCancelled else { return }
            if !appending {
                historyState = .error(error.localizedDescription)
            }
        }
    }

    private func buildSections(from orders: [OrderPresentationModel]) -> [OrderDateSection] {
        if currentFilter == .all {
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
