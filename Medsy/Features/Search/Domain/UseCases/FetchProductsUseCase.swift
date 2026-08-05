//
//  FetchProductsUseCaseProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//


import Foundation

protocol FetchProductsUseCaseProtocol {
    func execute(
        page: Int,
        size: Int,
        sort: [ProductSort],
		lang: String?
    ) async throws -> PagedResult<Product>
}

final class FetchProductsUseCase: FetchProductsUseCaseProtocol {

    private let repository: ProductRepositoryProtocol

    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        page: Int,
        size: Int,
        sort: [ProductSort],
		lang: String? = nil
    ) async throws -> PagedResult<Product> {
		try await repository
			.fetchProducts(page: page, size: size, sort: sort, lang: lang, company: nil)
    }
}
