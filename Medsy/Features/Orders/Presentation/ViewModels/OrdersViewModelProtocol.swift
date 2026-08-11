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
    case reorder
    case dismissReorderFeedback
}


enum ReorderState: Equatable {
    case idle
    case loading
    case success
    case partial(added: Int, total: Int)
    case failed

    var didAddItemsToCart: Bool {
        switch self {
        case .success:
            return true
        case .partial(let added, _):
            return added > 0
        case .idle, .loading, .failed:
            return false
        }
    }
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
    var reorderState: ReorderState { get }
    var paymentAction: PaymentOrderActionPresentation? { get }
    func handle(_ event: OrderDetailEvent)
}
