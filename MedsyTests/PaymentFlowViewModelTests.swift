//
//  PaymentFlowViewModelTests.swift
//  MedsyTests
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import XCTest
@testable import Medsy

@MainActor
final class PaymentFlowViewModelTests: XCTestCase {
    func testCardPaymentRefreshesMasterOrderBeforePreparingSheet() async {
        let refresher = PaymentOrderRefresherSpy(statuses: [
            .cardPending(expiresAt: nil),
            .paid
        ])
        let preparer = PaymentPreparerSpy()
        let presenter = PaymentSheetPresenterSpy(outcome: .completed)
        let viewModel = makeViewModel(
            masterOrderId: 17,
            preparer: preparer,
            presenter: presenter,
            refresher: refresher
        )

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .success)
        let refreshedOrderIds = await refresher.masterOrderIds
        let preparedOrderIds = await preparer.masterOrderIds
        let presentedOrderIds = await presenter.masterOrderIds
        XCTAssertEqual(refreshedOrderIds, [17, 17])
        XCTAssertEqual(preparedOrderIds, [17])
        XCTAssertEqual(presentedOrderIds, [17])
    }

    func testExpiredOrderDoesNotCreatePaymentIntent() async {
        let now = Date(timeIntervalSince1970: 1_000)
        let preparer = PaymentPreparerSpy()
        let viewModel = makeViewModel(
            preparer: preparer,
            refresher: PaymentOrderRefresherSpy(
                statuses: [.cardPending(expiresAt: now.addingTimeInterval(-1))]
            ),
            now: { now }
        )

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .expired)
        let preparedOrderIds = await preparer.masterOrderIds
        XCTAssertEqual(preparedOrderIds, [])
    }

    func testBackendCancelledOrderDoesNotCreatePaymentIntent() async {
        let preparer = PaymentPreparerSpy()
        let viewModel = makeViewModel(
            preparer: preparer,
            refresher: PaymentOrderRefresherSpy(statuses: [.cancelled])
        )

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .expired)
        let preparedOrderIds = await preparer.masterOrderIds
        XCTAssertEqual(preparedOrderIds, [])
    }

    func testCashOrderBypassesIntentAndSheet() async {
        var cashCompletionCount = 0
        let preparer = PaymentPreparerSpy()
        let presenter = PaymentSheetPresenterSpy(outcome: .completed)
        let viewModel = makeViewModel(
            preparer: preparer,
            presenter: presenter,
            refresher: PaymentOrderRefresherSpy(statuses: [.cash]),
            onCashPayment: { cashCompletionCount += 1 }
        )

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(cashCompletionCount, 1)
        let preparedOrderIds = await preparer.masterOrderIds
        let presentedOrderIds = await presenter.masterOrderIds
        XCTAssertEqual(preparedOrderIds, [])
        XCTAssertEqual(presentedOrderIds, [])
    }

    func testCancelledSheetRefreshesOrderAndShowsBackendCancellation() async {
        let viewModel = makeViewModel(
            presenter: PaymentSheetPresenterSpy(outcome: .cancelled),
            refresher: PaymentOrderRefresherSpy(statuses: [
                .cardPending(expiresAt: nil),
                .cancelled
            ])
        )

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .expired)
    }

    func testCancelledSheetRemainsRetryableWhileOrderIsPending() async {
        let viewModel = makeViewModel(
            presenter: PaymentSheetPresenterSpy(outcome: .cancelled),
            refresher: PaymentOrderRefresherSpy(statuses: [
                .cardPending(expiresAt: nil),
                .cardPending(expiresAt: nil)
            ])
        )

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .cancelled)
    }

    func testBackendPaidStatusOverridesFailedSheetOutcome() async {
        let viewModel = makeViewModel(
            presenter: PaymentSheetPresenterSpy(outcome: .failed(message: "Sheet failed")),
            refresher: PaymentOrderRefresherSpy(statuses: [
                .cardPending(expiresAt: nil),
                .paid
            ])
        )

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .success)
    }

    func testCompletedSheetPollsUntilBackendConfirmsPayment() async {
        let refresher = PaymentOrderRefresherSpy(statuses: [
            .cardPending(expiresAt: nil),
            .cardPending(expiresAt: nil),
            .cardPending(expiresAt: nil),
            .paid
        ])
        let viewModel = makeViewModel(refresher: refresher)

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .success)
        let refreshCount = await refresher.masterOrderIds.count
        XCTAssertEqual(refreshCount, 4)
    }

    func testCompletedSheetStopsPollingAfterConfiguredLimit() async {
        let refresher = PaymentOrderRefresherSpy(
            statuses: [.cardPending(expiresAt: nil)]
        )
        let viewModel = makeViewModel(
            refresher: refresher,
            maxConfirmationAttempts: 3
        )

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .processing)
        let refreshCount = await refresher.masterOrderIds.count
        XCTAssertEqual(refreshCount, 4)
    }

    func testDuplicateStartIsIgnoredWhilePreflightIsRunning() async {
        let refresher = SuspendingPaymentOrderRefresher()
        let viewModel = makeViewModel(refresher: refresher)

        let firstStart = Task { await viewModel.handle(.start) }
        await refresher.waitUntilCalled()
        await viewModel.handle(.start)

        let refreshCount = await refresher.callCount
        XCTAssertEqual(refreshCount, 1)
        await refresher.resume(with: .cash)
        await firstStart.value
    }

    private func makeViewModel(
        masterOrderId: Int = 21,
        preparer: PaymentPreparingProtocol? = nil,
        presenter: PaymentSheetPresentingProtocol? = nil,
        refresher: PaymentOrderRefreshingProtocol? = nil,
        onCashPayment: @escaping () -> Void = {},
        now: @escaping () -> Date = Date.init,
        maxConfirmationAttempts: Int = 4
    ) -> PaymentFlowViewModel {
        PaymentFlowViewModel(
            masterOrderId: masterOrderId,
            paymentPreparer: preparer ?? PaymentPreparerSpy(),
            paymentSheetPresenter: presenter ?? PaymentSheetPresenterSpy(outcome: .completed),
            orderRefresher: refresher ?? PaymentOrderRefresherSpy(statuses: [
                .cardPending(expiresAt: nil),
                .paid
            ]),
            onCashPayment: onCashPayment,
            now: now,
            pollingIntervalNanoseconds: 0,
            maxConfirmationAttempts: maxConfirmationAttempts
        )
    }
}

private actor PaymentPreparerSpy: PaymentPreparingProtocol {
    private(set) var masterOrderIds: [Int] = []

    func prepare(masterOrderId: Int) async throws -> PaymentSheetPresentationRequest {
        masterOrderIds.append(masterOrderId)
        return PaymentSheetPresentationRequest(
            masterOrderId: masterOrderId,
            opaqueReference: "test-reference"
        )
    }
}

private actor PaymentSheetPresenterSpy: PaymentSheetPresentingProtocol {
    private(set) var masterOrderIds: [Int] = []
    let outcome: PaymentSheetPresentationOutcome

    init(outcome: PaymentSheetPresentationOutcome) {
        self.outcome = outcome
    }

    func present(_ request: PaymentSheetPresentationRequest) async -> PaymentSheetPresentationOutcome {
        masterOrderIds.append(request.masterOrderId)
        return outcome
    }
}

private actor PaymentOrderRefresherSpy: PaymentOrderRefreshingProtocol {
    private(set) var masterOrderIds: [Int] = []
    private var statuses: [PaymentOrderPresentationStatus]

    init(statuses: [PaymentOrderPresentationStatus]) {
        self.statuses = statuses
    }

    func refresh(masterOrderId: Int) async throws -> PaymentOrderPresentationStatus {
        masterOrderIds.append(masterOrderId)
        guard let status = statuses.first else {
            return .cardPending(expiresAt: nil)
        }
        if statuses.count > 1 {
            statuses.removeFirst()
        }
        return status
    }
}

private actor SuspendingPaymentOrderRefresher: PaymentOrderRefreshingProtocol {
    private(set) var callCount = 0
    private var continuation: CheckedContinuation<PaymentOrderPresentationStatus, Error>?

    func refresh(masterOrderId: Int) async throws -> PaymentOrderPresentationStatus {
        _ = masterOrderId
        callCount += 1
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func waitUntilCalled() async {
        while callCount == 0 {
            await Task.yield()
        }
    }

    func resume(with status: PaymentOrderPresentationStatus) {
        continuation?.resume(returning: status)
        continuation = nil
    }
}
