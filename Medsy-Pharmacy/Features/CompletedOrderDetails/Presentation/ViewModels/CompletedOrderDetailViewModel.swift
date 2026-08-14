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
    private(set) var isMarkingOutForDelivery: Bool = false
    private(set) var isMarkingDelivered: Bool = false
    var markReadyError: String?
    var markOutForDeliveryError: String?
    var markDeliveredError: String?

    private let getOrderDetailUseCase: GetCompletedOrderDetailUseCaseProtocol?
    private let markOrderReadyUseCase: MarkOrderReadyUseCaseProtocol?
    private let markOrderOutForDeliveryUseCase: MarkOrderOutForDeliveryUseCaseProtocol?
    private let markOrderDeliveredUseCase: MarkOrderDeliveredUseCaseProtocol?
    private var loadTask: Task<Void, Never>?

    init(
        getOrderDetailUseCase: GetCompletedOrderDetailUseCaseProtocol,
        markOrderReadyUseCase: MarkOrderReadyUseCaseProtocol,
        markOrderOutForDeliveryUseCase: MarkOrderOutForDeliveryUseCaseProtocol,
        markOrderDeliveredUseCase: MarkOrderDeliveredUseCaseProtocol
    ) {
        self.getOrderDetailUseCase = getOrderDetailUseCase
        self.markOrderReadyUseCase = markOrderReadyUseCase
        self.markOrderOutForDeliveryUseCase = markOrderOutForDeliveryUseCase
        self.markOrderDeliveredUseCase = markOrderDeliveredUseCase
    }

    /// Preview / test convenience init
    init(state: CompletedOrderDetailViewState) {
        viewState = state
        getOrderDetailUseCase = nil
        markOrderReadyUseCase = nil
        markOrderOutForDeliveryUseCase = nil
        markOrderDeliveredUseCase = nil
    }

    func handle(_ event: CompletedOrderDetailEvent) {
        switch event {
        case .load(let orderId):
            loadOrder(orderId: orderId)
        case .retry(let orderId):
            loadOrder(orderId: orderId)
        case .markReady(let orderId):
            markReady(orderId: orderId)
        case .markOutForDelivery(let orderId):
            markOutForDelivery(orderId: orderId)
        case .markDelivered(let orderId):
            markDelivered(orderId: orderId)
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
                loadOrder(orderId: orderId)
            } catch {
                markReadyError = error.localizedDescription
            }
        }
    }

    private func markOutForDelivery(orderId: Int) {
        guard !isMarkingOutForDelivery else { return }
        isMarkingOutForDelivery = true
        markOutForDeliveryError = nil
        Task {
            defer { isMarkingOutForDelivery = false }
            do {
                try await markOrderOutForDeliveryUseCase?.execute(id: orderId)
                loadOrder(orderId: orderId)
            } catch {
                markOutForDeliveryError = error.localizedDescription
            }
        }
    }

    private func markDelivered(orderId: Int) {
        guard !isMarkingDelivered else { return }
        isMarkingDelivered = true
        markDeliveredError = nil
        Task {
            defer { isMarkingDelivered = false }
            do {
                try await markOrderDeliveredUseCase?.execute(id: orderId)
                loadOrder(orderId: orderId)
            } catch {
                markDeliveredError = error.localizedDescription
            }
        }
    }
}
