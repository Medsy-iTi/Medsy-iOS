//  ProductsRepositoryImpl.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation

final class ProductsRepositoryImpl: ProductsRepository {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getProductsByCategory(id: Int, page: Int, size: Int) async throws -> PagedResult<ProductItem> {
        let response: APIResponseDTO<PageDTO<ProductDTO>> = try await networkService.request(
            endpoint: ProductsEndpoint.fetchByCategory(id: id, page: page, size: size)
        )
        guard response.success, let data = response.data else {
            throw NetworkError.validationError(response.message)
        }
        return ProductItemMapper.map(data)
    }
}
