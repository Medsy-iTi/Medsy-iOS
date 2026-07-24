//
//  OrdersViewModelProtocol.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

enum OrderHistoryEvent {
    case load
    case retry
    case applyFilters(ActiveOrderFilters)
    case loadNextPage
}

enum OrderDetailEvent {
    case load(orderId: Int)
    case retry(orderId: Int)
}

@MainActor
protocol OrderHistoryViewModelProtocol: AnyObject {
    var historyState: OrderHistoryViewState { get }
    var activeFilters: ActiveOrderFilters { get }
    var isLoadingNextPage: Bool { get }

    func handle(_ event: OrderHistoryEvent)
}

@MainActor
protocol OrderDetailViewModelProtocol: AnyObject {
    var detailState: OrderDetailViewState { get }

    func handle(_ event: OrderDetailEvent)
}
