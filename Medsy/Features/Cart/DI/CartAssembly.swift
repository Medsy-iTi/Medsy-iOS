//
//  CartAssembly.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import SwiftData

struct CartAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        let modelContainer = CartModelContainerFactory.make()

        container.register(ModelContainer.self) { _ in
            modelContainer
        }

        container.register(CartLocalDataSourceProtocol.self) { container in
            CartLocalDataSource(
                modelContainer: container.resolve(ModelContainer.self),
                accountScopeProvider: container.resolve(AccountScopeProviderProtocol.self)
            )
        }

        container.register(CartRemoteDataSourceProtocol.self) { container in
            CartRemoteDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(CartRepositoryProtocol.self) { container in
            CartRepository(
                remoteDataSource: container.resolve(CartRemoteDataSourceProtocol.self),
                localDataSource: container.resolve(CartLocalDataSourceProtocol.self)
            )
        }

        container.register(CartPrescriptionRepositoryProtocol.self) { container in
            CartPrescriptionRepository(
                localDataSource: container.resolve(CartLocalDataSourceProtocol.self)
            )
        }

        container.register(LoadCartUseCaseProtocol.self) { container in
            LoadCartUseCase(
                cartRepository: container.resolve(CartRepositoryProtocol.self),
                prescriptionRepository: container.resolve(CartPrescriptionRepositoryProtocol.self)
            )
        }

        container.register(AddCartItemUseCaseProtocol.self) { container in
            AddCartItemUseCase(
                cartRepository: container.resolve(CartRepositoryProtocol.self),
                prescriptionRepository: container.resolve(CartPrescriptionRepositoryProtocol.self)
            )
        }

        container.register(UpdateCartItemQuantityUseCaseProtocol.self) { container in
            UpdateCartItemQuantityUseCase(
                cartRepository: container.resolve(CartRepositoryProtocol.self),
                prescriptionRepository: container.resolve(CartPrescriptionRepositoryProtocol.self)
            )
        }

        container.register(RemoveCartItemUseCaseProtocol.self) { container in
            RemoveCartItemUseCase(
                cartRepository: container.resolve(CartRepositoryProtocol.self),
                prescriptionRepository: container.resolve(CartPrescriptionRepositoryProtocol.self)
            )
        }

        container.register(ClearCartUseCaseProtocol.self) { container in
            ClearCartUseCase(
                cartRepository: container.resolve(CartRepositoryProtocol.self),
                prescriptionRepository: container.resolve(CartPrescriptionRepositoryProtocol.self)
            )
        }

        container.register(ManageCartPrescriptionsUseCaseProtocol.self) { container in
            ManageCartPrescriptionsUseCase(
                repository: container.resolve(CartPrescriptionRepositoryProtocol.self)
            )
        }

        container.register(GetCartInteractionsUseCaseProtocol.self) { container in
            GetCartInteractionsUseCase(
                repository: container.resolve(CartRepositoryProtocol.self)
            )
        }

        container.register(CartViewModel.self) { container in
            MainActor.assumeIsolated {
                CartViewModel(
                    loadCartUseCase: container.resolve(LoadCartUseCaseProtocol.self),
                    addCartItemUseCase: container.resolve(AddCartItemUseCaseProtocol.self),
                    updateCartItemQuantityUseCase: container.resolve(UpdateCartItemQuantityUseCaseProtocol.self),
                    removeCartItemUseCase: container.resolve(RemoveCartItemUseCaseProtocol.self),
                    clearCartUseCase: container.resolve(ClearCartUseCaseProtocol.self),
                    manageCartPrescriptionsUseCase: container.resolve(ManageCartPrescriptionsUseCaseProtocol.self),
                    getCartInteractionsUseCase: container.resolve(GetCartInteractionsUseCaseProtocol.self),
                    interactionLanguage: LanguageManager.shared.languageCode
                )
            }
        }
    }
}
