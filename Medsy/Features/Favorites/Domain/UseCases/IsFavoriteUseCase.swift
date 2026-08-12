//
//  IsFavoriteUseCase.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

protocol IsFavoriteUseCaseProtocol {
    func execute(productID: Int) async throws -> Bool
}

final class IsFavoriteUseCase: IsFavoriteUseCaseProtocol {
    private let repository: FavoriteRepositoryProtocol

    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }

    func execute(productID: Int) async throws -> Bool {
        try await repository.isFavorite(productID: productID)
    }
}
