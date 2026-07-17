//
//  ProductRepository.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//


import Foundation

final class ProductRepository: ProductRepositoryProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchProducts(
        page: Int,
        size: Int,
        sort: [ProductSort]
    ) async throws -> PagedResult<Product> {
        let endpoint = ProductEndpoint.list(page: page, size: size, sort: sort)
        let response: APIResponseDTO<PageDTO<ProductDTO>> = try await networkService.request(endpoint: endpoint)
        return try Self.unwrap(response)
    }

    func searchProducts(
        keyword: String,
        page: Int,
        size: Int,
        sort: [ProductSort]
    ) async throws -> PagedResult<Product> {
        let endpoint = ProductEndpoint.search(keyword: keyword, page: page, size: size, sort: sort)
        let response: APIResponseDTO<PageDTO<ProductDTO>> = try await networkService.request(endpoint: endpoint)
        return try Self.unwrap(response)
    }

   
    private static func unwrap(
        _ response: APIResponseDTO<PageDTO<ProductDTO>>
    ) throws -> PagedResult<Product> {
        guard response.success, let data = response.data else {
            throw NetworkError.validationError(response.message)
        }
        return ProductMapper.map(data)
    }
}
