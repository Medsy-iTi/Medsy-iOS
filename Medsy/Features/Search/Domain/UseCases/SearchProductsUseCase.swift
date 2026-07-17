//
//  SearchProductsUseCaseProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//


import Foundation

protocol SearchProductsUseCaseProtocol {
    func execute(
        keyword: String,
        categoryId: Int?,
        page: Int,
        size: Int,
        sort: [ProductSort],
		lang: String?
    ) async throws -> PagedResult<Product>
}

final class SearchProductsUseCase: SearchProductsUseCaseProtocol {

    private let repository: ProductRepositoryProtocol

    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        keyword: String,
        categoryId: Int? = nil,
        page: Int,
        size: Int,
        sort: [ProductSort],
		lang: String? = nil
    ) async throws -> PagedResult<Product> {
        if let categoryId = categoryId, keyword.isEmpty {
            return try await repository.fetchProductsByCategory(
                categoryId: categoryId,
                page: page,
                size: size,
                sort: sort,
                lang: lang
            )
        } else {
            return try await repository.searchProducts(
                keyword: keyword,
                page: page,
                size: size,
                sort: sort,
                lang: lang
            )
        }
    }
}
