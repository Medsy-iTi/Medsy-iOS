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
            let result = try await useCase.execute(
                statuses: filter.domainStatuses,
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
            currentPage = page
            isLastPage = result.isLast ?? mapped.count < Self.pageSize
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
