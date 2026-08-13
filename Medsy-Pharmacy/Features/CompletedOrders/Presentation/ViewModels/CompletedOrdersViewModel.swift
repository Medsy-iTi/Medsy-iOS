//
//  CompletedOrdersViewModel.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import Foundation
import Observation

@Observable
@MainActor
final class CompletedOrdersViewModel {

    enum ViewState: Equatable {
        case loading
        case loaded
        case empty(EmptyReason)
        case failed(String)

        enum EmptyReason: Equatable {
            case noOrders
            case noResults
        }
    }

    private(set) var orders: [CompletedOrder] = []
    private(set) var state: ViewState = .loading
    private(set) var isLoadingNextPage = false

    var searchText: String = "" {
        didSet { recomputeVisibleState() }
    }

    var selectedFilter: CompletedOrdersListFilter = .all {
        didSet {
            guard selectedFilter != oldValue else { return }
            Task { await reload() }
        }
    }

    private(set) var visibleOrders: [CompletedOrder] = []

    private let pharmacyId: Int
    private let getCompletedOrdersUseCase: GetCompletedOrdersUseCaseProtocol
    private let coordinator: CompletedOrdersCoordinatorProtocol

    private var currentPage = 0
    private let pageSize = 20
    private var isLastPage = false

    init(
        pharmacyId: Int,
        getCompletedOrdersUseCase: GetCompletedOrdersUseCaseProtocol,
        coordinator: CompletedOrdersCoordinatorProtocol
    ) {
        self.pharmacyId = pharmacyId
        self.getCompletedOrdersUseCase = getCompletedOrdersUseCase
        self.coordinator = coordinator
    }

    func onAppear() async {
        guard orders.isEmpty else { return }
        await reload()
    }

    func reload() async {
        state = .loading
        currentPage = 0
        isLastPage = false
        do {
            let result = try await getCompletedOrdersUseCase.execute(
                pharmacyId: pharmacyId,
                status: selectedFilter.apiStatusValue,
                page: currentPage,
                size: pageSize,
                sort: ["date,desc"]
            )
            orders = result.content
            isLastPage = result.isLast
            recomputeVisibleState()
        } catch {
            state = .failed("orders_load_error".localized)
        }
    }

    func loadNextPageIfNeeded(currentItem: CompletedOrder) async {
        guard !isLastPage, !isLoadingNextPage else { return }
        guard let index = visibleOrders.firstIndex(where: { $0.id == currentItem.id }) else { return }

        guard searchText.isEmpty else { return }
        guard index >= visibleOrders.count - 5 else { return }

        isLoadingNextPage = true
        defer { isLoadingNextPage = false }

        do {
            let nextPage = currentPage + 1
            let result = try await getCompletedOrdersUseCase.execute(
                pharmacyId: pharmacyId,
                status: selectedFilter.apiStatusValue,
                page: nextPage,
                size: pageSize,
                sort: ["date,desc"]
            )
            orders.append(contentsOf: result.content)
            currentPage = nextPage
            isLastPage = result.isLast
            recomputeVisibleState()
        } catch {
          
        }
    }

    func select(_ order: CompletedOrder) {
        coordinator.showDetails(for: order)
    }

    private func matchesSearch(_ order: CompletedOrder) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return true }
        return order.customerName.lowercased().contains(query)
            || order.customerPhone.contains(query)
            || String(order.id).contains(query)
    }

    func recomputeVisibleState() {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            visibleOrders = orders
        } else {
            visibleOrders = orders.filter(matchesSearch)
        }

        if orders.isEmpty {
            state = .empty(.noOrders)
        } else if visibleOrders.isEmpty {
            state = .empty(.noResults)
        } else {
            state = .loaded
        }
    }
}
