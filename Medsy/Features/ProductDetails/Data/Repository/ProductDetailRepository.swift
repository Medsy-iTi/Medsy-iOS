//
//  ProductDetailRepository.swift
//  Medsy
//  Created by Shahudaa on 16/07/2026.
//

import Foundation

final class ProductDetailRepository: ProductDetailRepositoryProtocol {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetchProduct(id: Int, lang: String?) async throws -> ProductDetailEntity {
        let endpoint = ProductDetailEndpoint.detail(id: id, lang: lang)
        let response: APIResponseDTO<ProductDTO> = try await networkService.request(endpoint: endpoint)
        return try Self.unwrap(response)
    }

    // MARK: – Private

    private static func unwrap(
        _ response: APIResponseDTO<ProductDTO>
    ) throws -> ProductDetailEntity {
        guard response.success, let data = response.data else {
            throw NetworkError.validationError(response.message)
        }
        return ProductDetailMapper.map(data)
    }
}
