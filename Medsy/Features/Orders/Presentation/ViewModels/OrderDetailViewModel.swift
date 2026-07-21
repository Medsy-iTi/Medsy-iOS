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

    private let getOrderDetailUseCase: GetOrderDetailUseCaseProtocol?
    private var loadTask: Task<Void, Never>?

    init(getOrderDetailUseCase: GetOrderDetailUseCaseProtocol? = nil) {
        self.getOrderDetailUseCase = getOrderDetailUseCase
    }

    init(state: OrderDetailViewState) {
        detailState = state
        getOrderDetailUseCase = nil
    }

    func handle(_ event: OrderDetailEvent) {
        switch event {
        case .load(let orderId):
            loadDetail(orderId: orderId)
        case .retry(let orderId):
            loadDetail(orderId: orderId)
        }
    }

    private func loadDetail(orderId: Int) {
        loadTask?.cancel()
        detailState = .loading
        loadTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            detailState = .loaded(.mock)
        }
    }
}
