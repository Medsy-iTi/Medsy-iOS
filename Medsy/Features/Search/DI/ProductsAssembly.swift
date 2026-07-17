//
//  ProductsAssembly.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//

import Foundation

struct ProductsAssembly: ModuleAssembly {
    func register(in container: DIContainer) {

        container.register(ProductRepositoryProtocol.self) { c in
            ProductRepository(networkService: c.resolve(NetworkServiceProtocol.self))
        }

        container.register(SearchProductsUseCaseProtocol.self) { c in
            SearchProductsUseCase(repository: c.resolve(ProductRepositoryProtocol.self))
        }

        container.register(FetchProductsUseCaseProtocol.self) { c in
            FetchProductsUseCase(repository: c.resolve(ProductRepositoryProtocol.self))
        }
    }
}
