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
    private(set) var isMarkingReady: Bool = false
    var markReadyError: String?

    private let getOrderDetailUseCase: GetCompletedOrderDetailUseCaseProtocol?
    private let markOrderReadyUseCase: MarkOrderReadyUseCaseProtocol?
    private var loadTask: Task<Void, Never>?

    init(
        getOrderDetailUseCase: GetCompletedOrderDetailUseCaseProtocol,
        markOrderReadyUseCase: MarkOrderReadyUseCaseProtocol
    ) {
        self.getOrderDetailUseCase = getOrderDetailUseCase
        self.markOrderReadyUseCase = markOrderReadyUseCase
    }

    init(state: CompletedOrderDetailViewState) {
        viewState = state
        getOrderDetailUseCase = nil
        markOrderReadyUseCase = nil
    }

    func handle(_ event: CompletedOrderDetailEvent) {
        switch event {
        case .load(let orderId):
            loadOrder(orderId: orderId)
        case .retry(let orderId):
            loadOrder(orderId: orderId)
        case .markReady(let orderId):
            markReady(orderId: orderId)
        }
    }

    // MARK: - Private

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

    private func markReady(orderId: Int) {
        guard !isMarkingReady else { return }
        isMarkingReady = true
        markReadyError = nil
        Task {
            defer { isMarkingReady = false }
            do {
                try await markOrderReadyUseCase?.execute(id: orderId)
                // Refresh order so status tracker animates to the new state
                loadOrder(orderId: orderId)
            } catch {
                markReadyError = error.localizedDescription
            }
        }
    }
}
