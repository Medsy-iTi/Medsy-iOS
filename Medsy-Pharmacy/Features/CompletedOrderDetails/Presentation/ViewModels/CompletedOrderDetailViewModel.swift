//
//  CompletedOrderDetailViewModel.swift
//  Medsy
//

import Foundation
import Observation

@MainActor
@Observable
final class CompletedOrderDetailViewModel: CompletedOrderDetailViewModelProtocol {

    private(set) var viewState: CompletedOrderDetailViewState = .loading

    private let getOrderDetailUseCase: GetCompletedOrderDetailUseCaseProtocol?
    private var loadTask: Task<Void, Never>?



    init(getOrderDetailUseCase: GetCompletedOrderDetailUseCaseProtocol) {
        self.getOrderDetailUseCase = getOrderDetailUseCase
    }



    init(state: CompletedOrderDetailViewState) {
        viewState = state
        getOrderDetailUseCase = nil
    }


    func handle(_ event: CompletedOrderDetailEvent) {
        switch event {
        case .load(let orderId):
            loadOrder(orderId: orderId)
        case .retry(let orderId):
            loadOrder(orderId: orderId)
        }
    }


    private func loadOrder(orderId: Int) {
        loadTask?.cancel()
        viewState = .loading
        loadTask = Task {
            guard let useCase = getOrderDetailUseCase else { return }
            do {
                let entity = try await useCase.execute(id: orderId)
                guard !Task.isCancelled else { return }
                viewState = .loaded(CompletedOrderDetailsEntityMapper.map(entity))
            } catch let error as NetworkError {
                guard !Task.isCancelled else { return }
                if case .notFound = error {
                    viewState = .notFound
                } else {
                    viewState = .error(error.localizedDescription)
                }
            } catch {
                guard !Task.isCancelled else { return }
                viewState = .error(error.localizedDescription)
            }
        }
    }
}
