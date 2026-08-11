//
//  LivePaymentFlowDependencies.swift
//  Medsy
//
//  Created by Ahmed Elkady on 11/08/2026.
//

import Foundation

struct LivePaymentPreparer: PaymentPreparingProtocol {
    private let createPaymentIntentUseCase: CreatePaymentIntentUseCaseProtocol

    init(createPaymentIntentUseCase: CreatePaymentIntentUseCaseProtocol) {
        self.createPaymentIntentUseCase = createPaymentIntentUseCase
    }

    func prepare(masterOrderId: Int) async throws -> PaymentSheetPresentationRequest {
        let intent = try await createPaymentIntentUseCase.execute(masterOrderId: masterOrderId)
        return PaymentSheetPresentationRequest(
            masterOrderId: masterOrderId,
            clientSecret: intent.clientSecret
        )
    }
}

struct LivePaymentOrderRefresher: PaymentOrderRefreshingProtocol {
    private let getMasterOrderPaymentUseCase: GetMasterOrderPaymentUseCaseProtocol

    init(getMasterOrderPaymentUseCase: GetMasterOrderPaymentUseCaseProtocol) {
        self.getMasterOrderPaymentUseCase = getMasterOrderPaymentUseCase
    }

    func refresh(masterOrderId: Int) async throws -> PaymentOrderPresentationStatus {
        let order = try await getMasterOrderPaymentUseCase.execute(masterOrderId: masterOrderId)

        if order.orderStatus == .cancelled {
            return .cancelled
        }
        if order.paymentStatus == .paid {
            return .paid
        }
        if order.paymentMethod == .cash {
            return .cash
        }
        if order.paymentStatus == .expired {
            return .expired
        }

        guard order.paymentMethod == .card else {
            return .failed(message: "payment.error.unsupported_method".localized)
        }
        guard order.orderStatus == .pendingPayment else {
            return .cancelled
        }

        switch order.paymentStatus {
        case .unpaid, .pending, .failed, .cancelled:
            return .cardPending(expiresAt: order.paymentExpiresAt)
        case .paid:
            return .paid
        case .expired:
            return .expired
        case .unknown:
            return .failed(message: "payment.error.unknown_status".localized)
        }
    }
}
