//
//  PaymentAssembly.swift
//  Medsy
//
//  Created by Ahmed Elkady on 02/08/2026.
//

import Foundation

struct PaymentAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(PaymentRemoteDataSourceProtocol.self) { container in
            PaymentRemoteDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(PaymentRepositoryProtocol.self) { container in
            PaymentRepository(
                remoteDataSource: container.resolve(PaymentRemoteDataSourceProtocol.self)
            )
        }

        container.register(CreatePaymentIntentUseCaseProtocol.self) { container in
            CreatePaymentIntentUseCase(
                repository: container.resolve(PaymentRepositoryProtocol.self)
            )
        }

        container.register(GetMasterOrderPaymentUseCaseProtocol.self) { container in
            GetMasterOrderPaymentUseCase(
                repository: container.resolve(PaymentRepositoryProtocol.self)
            )
        }

        container.register(PaymentPreparingProtocol.self) { container in
            LivePaymentPreparer(
                createPaymentIntentUseCase: container.resolve(CreatePaymentIntentUseCaseProtocol.self)
            )
        }

        container.register(PaymentSheetPresentingProtocol.self) { _ in
            StripePaymentSheetPresenter()
        }

        container.register(PaymentOrderRefreshingProtocol.self) { container in
            LivePaymentOrderRefresher(
                getMasterOrderPaymentUseCase: container.resolve(GetMasterOrderPaymentUseCaseProtocol.self)
            )
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
