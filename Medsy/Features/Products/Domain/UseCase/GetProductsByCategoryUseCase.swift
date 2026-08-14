//  GetProductsByCategoryUseCase.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

struct GetProductsByCategoryUseCase {
    private let repository: ProductsRepository

    init(repository: ProductsRepository) {
        self.repository = repository
    }

    func execute(id: Int, page: Int = 0, size: Int = 20, language: String) async throws -> PagedResult<ProductItem> {
        try await repository.getProductsByCategory(id: id, page: page, size: size, language: language)
    }
}
