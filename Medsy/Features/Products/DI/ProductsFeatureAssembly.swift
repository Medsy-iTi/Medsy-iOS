//  ProductsFeatureAssembly.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

struct ProductsFeatureAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(ProductsRepository.self) { c in
            ProductsRepositoryImpl(
                networkService: c.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(GetProductsByCategoryUseCase.self) { c in
            GetProductsByCategoryUseCase(
                repository: c.resolve(ProductsRepository.self)
            )
        }
    }
}
