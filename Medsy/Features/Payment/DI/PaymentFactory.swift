//
//  PaymentFactory.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import Foundation

struct PaymentFactory {
    private let paymentPreparer: PaymentPreparingProtocol
    private let paymentSheetPresenter: PaymentSheetPresentingProtocol
    private let orderRefresher: PaymentOrderRefreshingProtocol

    init(
        paymentPreparer: PaymentPreparingProtocol,
        paymentSheetPresenter: PaymentSheetPresentingProtocol,
        orderRefresher: PaymentOrderRefreshingProtocol
    ) {
        self.paymentPreparer = paymentPreparer
        self.paymentSheetPresenter = paymentSheetPresenter
        self.orderRefresher = orderRefresher
    }

    @MainActor
    func makeViewModel(
        masterOrderId: Int,
        onCashPayment: @escaping () -> Void = {}
    ) -> PaymentFlowViewModel {
        PaymentFlowViewModel(
            masterOrderId: masterOrderId,
            paymentPreparer: paymentPreparer,
            paymentSheetPresenter: paymentSheetPresenter,
            orderRefresher: orderRefresher,
            onCashPayment: onCashPayment
        )
    }
}
