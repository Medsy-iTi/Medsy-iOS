//
//  MockPaymentFlowDependencies.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import Foundation

struct MockPaymentPreparer: PaymentPreparingProtocol {
    var request =
        PaymentSheetPresentationRequest(
            masterOrderId: 0,
            opaqueReference: "preview-payment"
        )

    func prepare(masterOrderId: Int) async throws -> PaymentSheetPresentationRequest {
        PaymentSheetPresentationRequest(
            masterOrderId: masterOrderId,
            opaqueReference: request.opaqueReference
        )
    }
}

struct MockPaymentSheetPresenter: PaymentSheetPresentingProtocol {
    var outcome: PaymentSheetPresentationOutcome = .completed

    func present(_ request: PaymentSheetPresentationRequest) async -> PaymentSheetPresentationOutcome {
        _ = request
        return outcome
    }
}

struct MockPaymentOrderRefresher: PaymentOrderRefreshingProtocol {
    var status: PaymentOrderPresentationStatus = .cardPending(expiresAt: nil)

    func refresh(masterOrderId: Int) async throws -> PaymentOrderPresentationStatus {
        _ = masterOrderId
        return status
    }
}
