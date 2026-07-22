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
            guard let useCase = getOrderDetailUseCase else { return }
            do {
                let entity = try await useCase.execute(id: orderId)
                guard !Task.isCancelled else { return }
                detailState = .loaded(OrderEntityMapper.mapDetail(entity))
            } catch {
                guard !Task.isCancelled else { return }
                detailState = .error(error.localizedDescription)
            }
        }
    }
}
