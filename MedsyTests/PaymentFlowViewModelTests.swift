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
    func testMultipleOrdersAreRejectedBeforePreparingPayment() async {
        let preparer = PaymentPreparerSpy(result: .online(request(orderId: 1)))
        let viewModel = makeViewModel(orderIds: [1, 2], preparer: preparer)

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .unsupportedCombinedOrder)
        XCTAssertNil(viewModel.orderId)
        let preparationCallCount = await preparer.callCount
        XCTAssertEqual(preparationCallCount, 0)
    }

    func testCompletedPaymentBecomesSuccessfulAfterConfirmation() async {
        let preparer = PaymentPreparerSpy(result: .online(request(orderId: 17)))
        let presenter = PaymentSheetPresenterSpy(outcome: .completed)
        let refresher = PaymentConfirmationRefresherSpy(status: .paid)
        let viewModel = makeViewModel(
            orderIds: [17],
            preparer: preparer,
            presenter: presenter,
            refresher: refresher
        )

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(viewModel.orderId, 17)
        let preparedOrderIds = await preparer.orderIds
        let presentedOrderIds = await presenter.orderIds
        let refreshedOrderIds = await refresher.orderIds
        XCTAssertEqual(preparedOrderIds, [17])
        XCTAssertEqual(presentedOrderIds, [17])
        XCTAssertEqual(refreshedOrderIds, [17])
    }

    func testPendingWebhookKeepsPaymentProcessing() async {
        let viewModel = makeViewModel(
            orderIds: [9],
            presenter: PaymentSheetPresenterSpy(outcome: .completed),
            refresher: PaymentConfirmationRefresherSpy(status: .pending)
        )

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .processing)
    }

    func testCancelledSheetKeepsOrderAvailableForRetry() async {
        let refresher = PaymentConfirmationRefresherSpy(status: .paid)
        let viewModel = makeViewModel(
            orderIds: [12],
            presenter: PaymentSheetPresenterSpy(outcome: .cancelled),
            refresher: refresher
        )

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .cancelled)
        let refreshedOrderIds = await refresher.orderIds
        XCTAssertEqual(refreshedOrderIds, [])
    }

    func testCashPaymentBypassesSheetAndEmitsCompletion() async {
        var cashCompletionCount = 0
        let presenter = PaymentSheetPresenterSpy(outcome: .completed)
        let viewModel = makeViewModel(
            orderIds: [4],
            preparer: PaymentPreparerSpy(result: .cash),
            presenter: presenter,
            onCashPayment: { cashCompletionCount += 1 }
        )

        await viewModel.handle(.start)

        XCTAssertEqual(viewModel.state, .success)
        XCTAssertEqual(cashCompletionCount, 1)
        let presentedOrderIds = await presenter.orderIds
        XCTAssertEqual(presentedOrderIds, [])
    }

    func testDuplicateStartIsIgnoredWhilePreparationIsRunning() async {
        let preparer = SuspendingPaymentPreparer()
        let viewModel = makeViewModel(orderIds: [21], preparer: preparer)

        let firstStart = Task { await viewModel.handle(.start) }
        await preparer.waitUntilCalled()
        await viewModel.handle(.start)

        let callCount = await preparer.callCount
        XCTAssertEqual(callCount, 1)
        await preparer.resume(with: .online(request(orderId: 21)))
        await firstStart.value
    }

    private func makeViewModel(
        orderIds: [Int],
        preparer: PaymentPreparingProtocol? = nil,
        presenter: PaymentSheetPresentingProtocol? = nil,
        refresher: PaymentConfirmationRefreshingProtocol? = nil,
        onCashPayment: @escaping () -> Void = {}
    ) -> PaymentFlowViewModel {
        PaymentFlowViewModel(
            orderIds: orderIds,
            paymentPreparer: preparer ?? PaymentPreparerSpy(result: .online(request(orderId: orderIds.first ?? 0))),
            paymentSheetPresenter: presenter ?? PaymentSheetPresenterSpy(outcome: .completed),
            confirmationRefresher: refresher ?? PaymentConfirmationRefresherSpy(status: .pending),
            onCashPayment: onCashPayment
        )
    }

    private func request(orderId: Int) -> PaymentSheetPresentationRequest {
        PaymentSheetPresentationRequest(
            orderId: orderId,
            opaqueReference: "test-reference"
        )
    }
}

private actor PaymentPreparerSpy: PaymentPreparingProtocol {
    private(set) var orderIds: [Int] = []
    let result: PaymentPreparationResult

    var callCount: Int { orderIds.count }

    init(result: PaymentPreparationResult) {
        self.result = result
    }

    func prepare(orderId: Int) async throws -> PaymentPreparationResult {
        orderIds.append(orderId)
        return result
    }
}

private actor PaymentSheetPresenterSpy: PaymentSheetPresentingProtocol {
    private(set) var orderIds: [Int] = []
    let outcome: PaymentSheetPresentationOutcome

    init(outcome: PaymentSheetPresentationOutcome) {
        self.outcome = outcome
    }

    func present(_ request: PaymentSheetPresentationRequest) async -> PaymentSheetPresentationOutcome {
        orderIds.append(request.orderId)
        return outcome
    }
}

private actor PaymentConfirmationRefresherSpy: PaymentConfirmationRefreshingProtocol {
    private(set) var orderIds: [Int] = []
    let status: PaymentConfirmationPresentationStatus

    init(status: PaymentConfirmationPresentationStatus) {
        self.status = status
    }

    func refresh(orderId: Int) async throws -> PaymentConfirmationPresentationStatus {
        orderIds.append(orderId)
        return status
    }
}

private actor SuspendingPaymentPreparer: PaymentPreparingProtocol {
    private(set) var callCount = 0
    private var continuation: CheckedContinuation<PaymentPreparationResult, Error>?

    func prepare(orderId: Int) async throws -> PaymentPreparationResult {
        _ = orderId
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

    func resume(with result: PaymentPreparationResult) {
        continuation?.resume(returning: result)
        continuation = nil
    }
}
