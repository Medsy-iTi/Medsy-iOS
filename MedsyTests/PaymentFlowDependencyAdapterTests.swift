//
//  PaymentFlowDependencyAdapterTests.swift
//  MedsyTests
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import XCTest
@testable import Medsy

final class PaymentFlowDependencyAdapterTests: XCTestCase {
    func testPreparerExposesBackendClientSecretToPaymentSheet() async throws {
        let preparer = LivePaymentPreparer(
            createPaymentIntentUseCase: CreatePaymentIntentUseCaseStub(
                intent: PaymentIntent(id: "pi_7", clientSecret: "pi_7_secret")
            )
        )

        let result = try await preparer.prepare(masterOrderId: 7)

        XCTAssertEqual(
            result,
            PaymentSheetPresentationRequest(
                masterOrderId: 7,
                clientSecret: "pi_7_secret"
            )
        )
    }

    func testCashOrderBypassesCardPayment() async throws {
        let refresher = makeRefresher(
            paymentMethod: .cash,
            paymentStatus: .unpaid,
            orderStatus: .preparing
        )

        let result = try await refresher.refresh(masterOrderId: 3)

        XCTAssertEqual(result, .cash)
    }

    func testFailedCardAttemptRemainsRetryableBeforeExpiry() async throws {
        let expiry = Date().addingTimeInterval(300)
        let refresher = makeRefresher(
            paymentMethod: .card,
            paymentStatus: .failed,
            orderStatus: .pendingPayment,
            paymentExpiresAt: expiry
        )

        let result = try await refresher.refresh(masterOrderId: 4)

        XCTAssertEqual(result, .cardPending(expiresAt: expiry))
    }

    func testCancelledOrderCannotReopenPaymentEvenIfMarkedPaid() async throws {
        let refresher = makeRefresher(
            paymentMethod: .card,
            paymentStatus: .paid,
            orderStatus: .cancelled
        )

        let result = try await refresher.refresh(masterOrderId: 5)

        XCTAssertEqual(result, .cancelled)
    }

    private func makeRefresher(
        paymentMethod: MasterOrderPaymentMethod,
        paymentStatus: MasterOrderPaymentStatus,
        orderStatus: MasterOrderStatus,
        paymentExpiresAt: Date? = nil
    ) -> LivePaymentOrderRefresher {
        LivePaymentOrderRefresher(
            getMasterOrderPaymentUseCase: GetMasterOrderPaymentUseCaseStub(
                order: MasterOrderPayment(
                    id: 1,
                    paymentMethod: paymentMethod,
                    paymentStatus: paymentStatus,
                    orderStatus: orderStatus,
                    paymentExpiresAt: paymentExpiresAt,
                    paidAt: nil
                )
            )
        )
    }
}

private struct CreatePaymentIntentUseCaseStub: CreatePaymentIntentUseCaseProtocol {
    let intent: PaymentIntent

    func execute(masterOrderId: Int) async throws -> PaymentIntent {
        intent
    }
}

private struct GetMasterOrderPaymentUseCaseStub: GetMasterOrderPaymentUseCaseProtocol {
    let order: MasterOrderPayment

    func execute(masterOrderId: Int) async throws -> MasterOrderPayment {
        order
    }
}
