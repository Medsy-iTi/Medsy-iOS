//
//  CompletedOrderDetailsAssembly.swift
//  Medsy
//

import Foundation

struct CompletedOrderDetailsAssembly: PharmacyModuleAssembly {
    func register(in container: PharmacyDIContainer) {
        container.register(CompletedOrderDetailsRemoteDataSourceProtocol.self) { container in
            CompletedOrderDetailsRemoteDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(CompletedOrderDetailsRepositoryProtocol.self) { container in
            CompletedOrderDetailsRepository(
                remoteDataSource: container.resolve(CompletedOrderDetailsRemoteDataSourceProtocol.self)
            )
        }

        container.register(GetCompletedOrderDetailUseCaseProtocol.self) { container in
            GetCompletedOrderDetailUseCase(
                repository: container.resolve(CompletedOrderDetailsRepositoryProtocol.self)
            )
        }

        container.register(MarkOrderReadyUseCaseProtocol.self) { container in
            MarkOrderReadyUseCase(
                repository: container.resolve(CompletedOrderDetailsRepositoryProtocol.self)
            )
        }

        container.register(CompletedOrderDetailViewModel.self) { container in
            MainActor.assumeIsolated {
                CompletedOrderDetailViewModel(
                    getOrderDetailUseCase: container.resolve(GetCompletedOrderDetailUseCaseProtocol.self),
                    markOrderReadyUseCase: container.resolve(MarkOrderReadyUseCaseProtocol.self)
                )
            }
        }
    }
}
