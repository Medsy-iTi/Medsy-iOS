//
//  PaymentAssembly.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import Foundation

struct PaymentAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(PaymentPreparingProtocol.self) { _ in
            MockPaymentPreparer()
        }

        container.register(PaymentSheetPresentingProtocol.self) { _ in
            MockPaymentSheetPresenter()
        }

        container.register(PaymentOrderRefreshingProtocol.self) { _ in
            MockPaymentOrderRefresher()
        }

        container.register(PaymentFactory.self) { container in
            PaymentFactory(
                paymentPreparer: container.resolve(PaymentPreparingProtocol.self),
                paymentSheetPresenter: container.resolve(PaymentSheetPresentingProtocol.self),
                orderRefresher: container.resolve(PaymentOrderRefreshingProtocol.self)
            )
        }
    }
}
