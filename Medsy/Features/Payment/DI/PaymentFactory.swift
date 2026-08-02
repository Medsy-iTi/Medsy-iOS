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
    private let confirmationRefresher: PaymentConfirmationRefreshingProtocol

    init(
        paymentPreparer: PaymentPreparingProtocol,
        paymentSheetPresenter: PaymentSheetPresentingProtocol,
        confirmationRefresher: PaymentConfirmationRefreshingProtocol
    ) {
        self.paymentPreparer = paymentPreparer
        self.paymentSheetPresenter = paymentSheetPresenter
        self.confirmationRefresher = confirmationRefresher
    }

    @MainActor
    func makeViewModel(
        orderIds: [Int],
        onCashPayment: @escaping () -> Void = {}
    ) -> PaymentFlowViewModel {
        PaymentFlowViewModel(
            orderIds: orderIds,
            paymentPreparer: paymentPreparer,
            paymentSheetPresenter: paymentSheetPresenter,
            confirmationRefresher: confirmationRefresher,
            onCashPayment: onCashPayment
        )
    }
}
