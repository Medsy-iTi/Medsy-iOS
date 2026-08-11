//
//  OrderDetailViewModel.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class OrderDetailViewModel: OrderDetailViewModelProtocol {

    private(set) var detailState: OrderDetailViewState = .loading
    private(set) var reorderState: ReorderState = .idle
    private(set) var paymentAction: PaymentOrderActionPresentation?

    private let getOrderDetailUseCase: GetOrderDetailUseCaseProtocol?
    private let reorderUseCase: ReorderUseCaseProtocol?
    private let now: () -> Date
    private var loadTask: Task<Void, Never>?
    private var reorderTask: Task<Void, Never>?

    init(
        getOrderDetailUseCase: GetOrderDetailUseCaseProtocol? = nil,
        reorderUseCase: ReorderUseCaseProtocol? = nil,
        paymentAction: PaymentOrderActionPresentation? = nil,
        now: @escaping () -> Date = Date.init
    ) {
        self.getOrderDetailUseCase = getOrderDetailUseCase
        self.reorderUseCase = reorderUseCase
        self.paymentAction = paymentAction
        self.now = now
    }

    init(
        state: OrderDetailViewState,
        reorderState: ReorderState = .idle,
        paymentAction: PaymentOrderActionPresentation? = nil
    ) {
        detailState = state
        self.reorderState = reorderState
        self.paymentAction = paymentAction
        getOrderDetailUseCase = nil
        reorderUseCase = nil
        now = Date.init
    }



    func handle(_ event: OrderDetailEvent) {
        switch event {
        case .load(let orderId):
            loadDetail(orderId: orderId)
        case .retry(let orderId):
            loadDetail(orderId: orderId)
        case .reorder:
            handleReorder()
        case .dismissReorderFeedback:
            reorderState = .idle
        }
    }

    private func loadDetail(orderId: Int) {
        loadTask?.cancel()
        detailState = .loading
        reorderState = .idle
        paymentAction = nil
        loadTask = Task {
            guard let useCase = getOrderDetailUseCase else { return }
            do {
                let entity = try await useCase.execute(id: orderId)
                guard !Task.isCancelled else { return }
                detailState = .loaded(OrderEntityMapper.mapDetail(entity))
                paymentAction = paymentAction(for: entity)
            } catch {
                guard !Task.isCancelled else { return }
                detailState = .error(error.localizedDescription)
            }
        }
    }

    private func paymentAction(for order: OrderDetailEntity) -> PaymentOrderActionPresentation? {
        guard order.paymentMethod == .card else { return nil }
        guard order.status != .cancelled else { return nil }
        guard order.paymentStatus != .paid else { return nil }

        if order.paymentStatus == .expired || order.paymentExpiresAt.map({ $0 <= now() }) == true {
            return .expired
        }

        guard order.status == .pending else { return nil }

        switch order.paymentStatus {
        case .unpaid, .pending:
            return .payNow
        case .failed, .cancelled:
            return .retry
        case .paid, .expired, .unknown:
            return nil
        }
    }

    private func handleReorder() {

        guard case .loaded(let order) = detailState, !order.items.isEmpty else { return }
        guard reorderState != .loading else { return }

        let items = order.items.map { ReorderItem(productId: $0.productId, quantity: $0.quantity) }

        reorderTask?.cancel()
        reorderState = .loading
        reorderTask = Task {
            guard let useCase = reorderUseCase else {
                reorderState = .success
                return
            }
            let result = await useCase.execute(items: items)
            guard !Task.isCancelled else { return }
            switch result {
            case .success:
                reorderState = .success
            case .partial(let added, let total):
                reorderState = .partial(added: added, total: total)
            case .failure:
                reorderState = .failed
            }
        }
    }
}
