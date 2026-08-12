//
//  FetchFavoritesUseCase.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

protocol FetchFavoritesUseCaseProtocol {
    func execute() async throws -> [FavoriteMedicine]
}

final class FetchFavoritesUseCase: FetchFavoritesUseCaseProtocol {
    private let repository: FavoriteRepositoryProtocol

    init(repository: FavoriteRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [FavoriteMedicine] {
        try await repository.fetchAll()
    }
}
