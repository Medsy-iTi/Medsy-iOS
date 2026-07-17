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
        page: Int,
        size: Int,
        sort: [ProductSort]
    ) async throws -> PagedResult<Product>
}

final class SearchProductsUseCase: SearchProductsUseCaseProtocol {

    private let repository: ProductRepositoryProtocol

    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        keyword: String,
        page: Int,
        size: Int,
        sort: [ProductSort]
    ) async throws -> PagedResult<Product> {
        try await repository.searchProducts(
            keyword: keyword,
            page: page,
            size: size,
            sort: sort
        )
    }
}
