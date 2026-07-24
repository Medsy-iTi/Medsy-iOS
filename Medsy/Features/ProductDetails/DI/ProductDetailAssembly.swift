//
//  ProductDetailAssembly.swift
//  Medsy
//

import Foundation

struct ProductDetailAssembly: ModuleAssembly {
    func register(in container: DIContainer) {

        container.register(ProductDetailRepositoryProtocol.self) { c in
            ProductDetailRepository(networkService: c.resolve(NetworkServiceProtocol.self))
        }

        container.register(FetchProductDetailUseCaseProtocol.self) { c in
            FetchProductDetailUseCase(repository: c.resolve(ProductDetailRepositoryProtocol.self))
        }
    }
}
