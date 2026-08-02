//
//  PaymentFlowViewModel.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class PaymentFlowViewModel: PaymentFlowViewModelProtocol {
    private(set) var state: PaymentFlowViewState = .idle
    private(set) var orderId: Int?

    private let orderIds: [Int]
    private let paymentPreparer: PaymentPreparingProtocol
    private let paymentSheetPresenter: PaymentSheetPresentingProtocol
    private let confirmationRefresher: PaymentConfirmationRefreshingProtocol
    private let onCashPayment: () -> Void

    init(
        orderIds: [Int],
        paymentPreparer: PaymentPreparingProtocol,
        paymentSheetPresenter: PaymentSheetPresentingProtocol,
        confirmationRefresher: PaymentConfirmationRefreshingProtocol,
        onCashPayment: @escaping () -> Void = {}
    ) {
        self.orderIds = orderIds
        self.paymentPreparer = paymentPreparer
        self.paymentSheetPresenter = paymentSheetPresenter
        self.confirmationRefresher = confirmationRefresher
        self.onCashPayment = onCashPayment
    }

    func handle(_ event: PaymentFlowEvent) async {
        switch event {
        case .start, .retry:
            await startPayment()
        case .refreshStatus:
            await refreshPaymentStatus()
        }
    }

    private func startPayment() async {
        guard !state.isBusy else { return }
        guard orderIds.count == 1, let selectedOrderId = orderIds.first else {
            orderId = nil
            state = .unsupportedCombinedOrder
            return
        }

        orderId = selectedOrderId
        state = .loading

        do {
            let preparation = try await paymentPreparer.prepare(orderId: selectedOrderId)
            guard !Task.isCancelled else { return }

            switch preparation {
            case .cash:
                state = .success
                onCashPayment()
            case .online(let request):
                state = .presenting
                let outcome = await paymentSheetPresenter.present(request)
                guard !Task.isCancelled else { return }
                await handlePresentationOutcome(outcome)
            }
        } catch {
            guard !Task.isCancelled else { return }
            state = .failure(message: error.localizedDescription)
        }
    }

    private func handlePresentationOutcome(_ outcome: PaymentSheetPresentationOutcome) async {
        switch outcome {
        case .completed:
            state = .processing
            await refreshPaymentStatus()
        case .cancelled:
            state = .cancelled
        case .failed(let message):
            state = .failure(message: message)
        }
    }

    private func refreshPaymentStatus() async {
        guard let orderId else { return }

        do {
            let confirmation = try await confirmationRefresher.refresh(orderId: orderId)
            guard !Task.isCancelled else { return }

            switch confirmation {
            case .pending:
                state = .processing
            case .paid:
                state = .success
            case .failed(let message):
                state = .failure(message: message)
            }
        } catch {
            guard !Task.isCancelled else { return }
            state = .failure(message: error.localizedDescription)
        }
    }
}
