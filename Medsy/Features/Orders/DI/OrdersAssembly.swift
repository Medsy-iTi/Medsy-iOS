//
//  OrdersAssembly.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

struct OrdersAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(OrdersRemoteDataSourceProtocol.self) { container in
            let languageManager = container.resolve(LanguageManager.self)
            return OrdersRemoteDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self),
                languageProvider: { languageManager.languageCode }
            )
        }

        container.register(OrdersRepositoryProtocol.self) { container in
            OrdersRepository(
                remoteDataSource: container.resolve(OrdersRemoteDataSourceProtocol.self)
            )
        }

        container.register(LoadOrdersUseCaseProtocol.self) { container in
            LoadOrdersUseCase(
                repository: container.resolve(OrdersRepositoryProtocol.self)
            )
        }

        container.register(GetOrderDetailUseCaseProtocol.self) { container in
            GetOrderDetailUseCase(
                repository: container.resolve(OrdersRepositoryProtocol.self)
            )
        }

        container.register(ReorderUseCaseProtocol.self) { container in
            ReorderUseCase(
                addCartItemUseCase: container.resolve(AddCartItemUseCaseProtocol.self)
            )
        }

        container.register(OrderCurrentLocationProviding.self) { _ in
            MainActor.assumeIsolated { OrderCurrentLocationProvider() }
        }

        container.register(OrderRouteProviding.self) { _ in
            MainActor.assumeIsolated { OrderRouteProvider() }
        }

        container.register(OrderDirectionsOpening.self) { _ in
            MainActor.assumeIsolated { OrderDirectionsOpener() }
        }

        container.register(OrderHistoryViewModel.self) { container in
            MainActor.assumeIsolated {
                OrderHistoryViewModel(
                    loadOrdersUseCase: container.resolve(LoadOrdersUseCaseProtocol.self)
                )
            }
        }

        container.register(OrderDetailViewModel.self) { container in
            MainActor.assumeIsolated {
                OrderDetailViewModel(
                    getOrderDetailUseCase: container.resolve(GetOrderDetailUseCaseProtocol.self),
                    reorderUseCase: container.resolve(ReorderUseCaseProtocol.self),
                    locationProvider: container.resolve(OrderCurrentLocationProviding.self),
                    routeProvider: container.resolve(OrderRouteProviding.self),
                    directionsOpener: container.resolve(OrderDirectionsOpening.self)
                )
            }
        }
    }
}
