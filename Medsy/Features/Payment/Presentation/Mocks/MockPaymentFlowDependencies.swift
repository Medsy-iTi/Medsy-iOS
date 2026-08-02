//
//  MockPaymentFlowDependencies.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import Foundation

struct MockPaymentPreparer: PaymentPreparingProtocol {
    var result: PaymentPreparationResult = .online(
        PaymentSheetPresentationRequest(
            orderId: 0,
            opaqueReference: "preview-payment"
        )
    )

    func prepare(orderId: Int) async throws -> PaymentPreparationResult {
        switch result {
        case .cash:
            return .cash
        case .online(let request):
            return .online(
                PaymentSheetPresentationRequest(
                    orderId: orderId,
                    opaqueReference: request.opaqueReference
                )
            )
        }
    }
}

struct MockPaymentSheetPresenter: PaymentSheetPresentingProtocol {
    var outcome: PaymentSheetPresentationOutcome = .completed

    func present(_ request: PaymentSheetPresentationRequest) async -> PaymentSheetPresentationOutcome {
        _ = request
        return outcome
    }
}

struct MockPaymentConfirmationRefresher: PaymentConfirmationRefreshingProtocol {
    var status: PaymentConfirmationPresentationStatus = .pending

    func refresh(orderId: Int) async throws -> PaymentConfirmationPresentationStatus {
        _ = orderId
        return status
    }
}
