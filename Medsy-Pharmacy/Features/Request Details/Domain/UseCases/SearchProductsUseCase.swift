// SearchProductsUseCase.swift

import Foundation

protocol SearchProductsUseCaseProtocol: Sendable {
    func execute(keyword: String, page: Int, size: Int) async throws -> [PharmacyProductDTO]
}

final class SearchProductsUseCase: SearchProductsUseCaseProtocol {
    private let repository: PharmacyRequestsRepositoryProtocol

    init(repository: PharmacyRequestsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(keyword: String, page: Int, size: Int) async throws -> [PharmacyProductDTO] {
        try await repository.searchProducts(keyword: keyword, page: page, size: size)
    }
}
