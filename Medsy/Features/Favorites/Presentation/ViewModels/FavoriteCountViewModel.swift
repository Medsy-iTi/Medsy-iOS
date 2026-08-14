//
//  FavoriteCountViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

import Observation

@MainActor
@Observable
final class FavoriteCountViewModel {
    private(set) var count = 0

    @ObservationIgnored private let fetchFavoritesUseCase: FetchFavoritesUseCaseProtocol

    init(fetchFavoritesUseCase: FetchFavoritesUseCaseProtocol) {
        self.fetchFavoritesUseCase = fetchFavoritesUseCase
    }

    func refresh() async {
        guard let favorites = try? await fetchFavoritesUseCase.execute() else { return }
        guard !Task.isCancelled else { return }
        count = favorites.count
    }
}
