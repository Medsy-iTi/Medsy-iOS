//
//  FetchProductDetailUseCase.swift
//  Medsy
//  Created by Shahudaa on 16/07/2026.
//

import Foundation

protocol FetchProductDetailUseCaseProtocol {
    func execute(id: Int, lang: String?) async throws -> ProductDetailEntity
}

final class FetchProductDetailUseCase: FetchProductDetailUseCaseProtocol {

    private let repository: ProductDetailRepositoryProtocol

    init(repository: ProductDetailRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int, lang: String?) async throws -> ProductDetailEntity {
        try await repository.fetchProduct(id: id, lang: lang)
    }
}
