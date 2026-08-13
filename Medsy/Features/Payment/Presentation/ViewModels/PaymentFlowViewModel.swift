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
    let masterOrderId: Int

    private let paymentPreparer: PaymentPreparingProtocol
    private let paymentSheetPresenter: PaymentSheetPresentingProtocol
    private let orderRefresher: PaymentOrderRefreshingProtocol
    private let onCashPayment: () -> Void
    private let now: () -> Date
    private let pollingIntervalNanoseconds: UInt64
    private let maxConfirmationAttempts: Int
    private var flowTask: Task<Void, Never>?

    init(
        masterOrderId: Int,
        paymentPreparer: PaymentPreparingProtocol,
        paymentSheetPresenter: PaymentSheetPresentingProtocol,
        orderRefresher: PaymentOrderRefreshingProtocol,
        onCashPayment: @escaping () -> Void = {},
        now: @escaping () -> Date = Date.init,
        pollingIntervalNanoseconds: UInt64 = 2_000_000_000,
        maxConfirmationAttempts: Int = 60
    ) {
        self.masterOrderId = masterOrderId
        self.paymentPreparer = paymentPreparer
        self.paymentSheetPresenter = paymentSheetPresenter
        self.orderRefresher = orderRefresher
        self.onCashPayment = onCashPayment
        self.now = now
        self.pollingIntervalNanoseconds = pollingIntervalNanoseconds
        self.maxConfirmationAttempts = max(1, maxConfirmationAttempts)
    }

    func handle(_ event: PaymentFlowEvent) async {
        switch event {
        case .start:
            guard state == .idle else { return }
            await runFlow { [weak self] in
                await self?.startPayment(isRetry: false)
            }
        case .retry:
            switch state {
            case .failure, .cancelled:
                break
            case .idle, .loading, .presenting, .processing, .success, .expired:
                return
            }
            await runFlow { [weak self] in
                await self?.startPayment(isRetry: true)
            }
        case .refreshStatus:
            await runFlow { [weak self] in
                await self?.refreshPaymentStatus()
            }
        case .stop:
            flowTask?.cancel()
            flowTask = nil
        }
    }

    private func runFlow(_ operation: @escaping @MainActor () async -> Void) async {
        flowTask?.cancel()
        let task = Task { @MainActor in
            await operation()
        }
        flowTask = task
        await task.value
        if !task.isCancelled {
            flowTask = nil
        }
    }

    private func startPayment(isRetry: Bool) async {
        if isRetry {
            switch state {
            case .failure, .cancelled:
                break
            case .idle, .loading, .presenting, .processing, .success, .expired:
                return
            }
        } else {
            guard state == .idle else { return }
        }
        state = .loading

        do {
            let orderStatus = try await orderRefresher.refresh(masterOrderId: masterOrderId)
            guard !Task.isCancelled else { return }
            guard handleOrderStatus(orderStatus, pendingFallback: nil) else { return }

            let request = try await paymentPreparer.prepare(masterOrderId: masterOrderId)
            guard !Task.isCancelled else { return }
            state = .presenting
            let outcome = await paymentSheetPresenter.present(request)
            guard !Task.isCancelled else { return }
            await handlePresentationOutcome(outcome)
        } catch {
            guard !Task.isCancelled else { return }
            state = .failure(message: error.localizedDescription)
        }
    }

    @discardableResult
    private func handleOrderStatus(
        _ status: PaymentOrderPresentationStatus,
        pendingFallback: PaymentFlowViewState?
    ) -> Bool {
        switch status {
        case .cash:
            state = .success
            onCashPayment()
            return false
        case .cardPending(let expiresAt):
            guard !isExpired(expiresAt) else {
                state = .expired
                return false
            }
            if let pendingFallback {
                state = pendingFallback
                return false
            }
            return true
        case .paid:
            state = .success
            return false
        case .expired, .cancelled:
            state = .expired
            return false
        case .failed(let message):
            state = .failure(message: message)
            return false
        }
    }

    private func handlePresentationOutcome(_ outcome: PaymentSheetPresentationOutcome) async {
        switch outcome {
        case .completed:
            state = .processing
            await pollPaymentStatus()
        case .cancelled:
            await refreshPaymentStatus(pendingFallback: .cancelled)
        case .failed(let message):
            await refreshPaymentStatus(pendingFallback: .failure(message: message))
        }
    }

    private func refreshPaymentStatus(
        pendingFallback: PaymentFlowViewState = .processing
    ) async {
        do {
            let status = try await orderRefresher.refresh(masterOrderId: masterOrderId)
            guard !Task.isCancelled else { return }
            _ = handleOrderStatus(status, pendingFallback: pendingFallback)
        } catch {
            guard !Task.isCancelled else { return }
            state = .failure(message: error.localizedDescription)
        }
    }

    private func pollPaymentStatus() async {
        for attempt in 0..<maxConfirmationAttempts {
            do {
                let status = try await orderRefresher.refresh(masterOrderId: masterOrderId)
                guard !Task.isCancelled else { return }

                let remainsPending = handleOrderStatus(status, pendingFallback: nil)
                guard remainsPending else { return }
                state = .processing

                guard attempt < maxConfirmationAttempts - 1 else {
                    state = .processing
                    return
                }
                try await Task.sleep(nanoseconds: pollingIntervalNanoseconds)
            } catch is CancellationError {
                return
            } catch {
                guard !Task.isCancelled else { return }
                state = .failure(message: error.localizedDescription)
                return
            }
        }
    }

    private func isExpired(_ expiresAt: Date?) -> Bool {
        guard let expiresAt else { return false }
        return expiresAt <= now()
    }
}
