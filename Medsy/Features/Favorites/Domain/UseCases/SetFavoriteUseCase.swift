//
//  SetFavoriteUseCase.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

protocol SetFavoriteUseCaseProtocol {
    func execute(_ medicine: FavoriteMedicine, isFavorite: Bool) async throws
}

final class SetFavoriteUseCase: SetFavoriteUseCaseProtocol {
    private let repository: FavoriteRepositoryProtocol

    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ medicine: FavoriteMedicine, isFavorite: Bool) async throws {
        try await repository.setFavorite(medicine, isFavorite: isFavorite)
    }
}
