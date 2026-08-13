//
//  PaymentDomainTests.swift
//  MedsyTests
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import XCTest
@testable import Medsy

final class PaymentDomainTests: XCTestCase {
    func testGetMasterOrderPaymentDelegatesToRepository() async throws {
        let expected = MasterOrderPayment(
            id: 42,
            paymentMethod: .card,
            paymentStatus: .pending,
            orderStatus: .pendingPayment,
            paymentExpiresAt: Date(timeIntervalSince1970: 2_000),
            paidAt: nil
        )
        let repository = PaymentRepositorySpy(masterOrder: expected)
        let useCase = GetMasterOrderPaymentUseCase(repository: repository)

        let result = try await useCase.execute(masterOrderId: 42)

        XCTAssertEqual(result, expected)
        let fetchedIds = await repository.fetchedMasterOrderIds
        XCTAssertEqual(fetchedIds, [42])
    }

    func testCreatePaymentIntentDelegatesToRepository() async throws {
        let expected = PaymentIntent(id: "pi_test", clientSecret: "pi_test_secret")
        let repository = PaymentRepositorySpy(paymentIntent: expected)
        let useCase = CreatePaymentIntentUseCase(repository: repository)

        let result = try await useCase.execute(masterOrderId: 17)

        XCTAssertEqual(result, expected)
        let createdIds = await repository.createdIntentMasterOrderIds
        XCTAssertEqual(createdIds, [17])
    }
}

private actor PaymentRepositorySpy: PaymentRepositoryProtocol {
    private(set) var fetchedMasterOrderIds: [Int] = []
    private(set) var createdIntentMasterOrderIds: [Int] = []
    private let masterOrder: MasterOrderPayment
    private let paymentIntent: PaymentIntent

    init(
        masterOrder: MasterOrderPayment = MasterOrderPayment(
            id: 1,
            paymentMethod: .card,
            paymentStatus: .pending,
            orderStatus: .pendingPayment,
            paymentExpiresAt: nil,
            paidAt: nil
        ),
        paymentIntent: PaymentIntent = PaymentIntent(
            id: "pi_default",
            clientSecret: "pi_default_secret"
        )
    ) {
        self.masterOrder = masterOrder
        self.paymentIntent = paymentIntent
    }

    func fetchMasterOrderPayment(masterOrderId: Int) async throws -> MasterOrderPayment {
        fetchedMasterOrderIds.append(masterOrderId)
        return masterOrder
    }

    func createPaymentIntent(masterOrderId: Int) async throws -> PaymentIntent {
        createdIntentMasterOrderIds.append(masterOrderId)
        return paymentIntent
    }
}
