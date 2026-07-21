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
            break
        }
    }

    private func load(filter: OrderFilter, reset: Bool) {
        loadTask?.cancel()
        loadMockData(filter: filter)
    }

    private func loadMockData(filter: OrderFilter) {
        historyState = .loading
        loadTask = Task {
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled else { return }
            historyState = .loaded(buildSections(from: filtered(by: filter)))
        }
    }

    private func filtered(by filter: OrderFilter) -> [OrderPresentationModel] {
        let all = OrderPresentationModel.mockOrders
        switch filter {
        case .all:       return all
        case .active:    return all.filter { $0.status.isActive }
        case .completed: return all.filter { $0.status.isCompleted }
        case .cancelled: return all.filter { $0.status.isCancelled }
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
