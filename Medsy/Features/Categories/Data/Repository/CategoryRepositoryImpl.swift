//  CategoryRepositoryImpl.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.

import Foundation

final class CategoryRepositoryImpl: CategoryRepository {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func getCategories(page: Int, size: Int) async throws -> PagedResult<Category> {
        let response: APIResponseDTO<PageDTO<CategoryDTO>> = try await networkService.request(
            endpoint: CategoryEndpoint.fetch(page: page, size: size)
        )
        guard response.success, let data = response.data else {
            throw NetworkError.validationError(response.message)
        }
        return CategoryMapper.map(data)
    }
}
