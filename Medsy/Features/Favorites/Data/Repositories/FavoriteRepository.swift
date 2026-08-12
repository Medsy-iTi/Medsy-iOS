//
//  FavoriteRepository.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

final class FavoriteRepository: FavoriteRepositoryProtocol {
    private let localDataSource: FavoriteLocalDataSourceProtocol
    private let accountScopeProvider: AccountScopeProviderProtocol

    init(localDataSource: FavoriteLocalDataSourceProtocol, accountScopeProvider: AccountScopeProviderProtocol) {
        self.localDataSource = localDataSource
        self.accountScopeProvider = accountScopeProvider
    }

    func fetchAll() async throws -> [FavoriteMedicine] {
        let accountID = try accountScopeProvider.currentIdentifier()
        return try await localDataSource.fetchAll(accountID: accountID).map(FavoriteMedicineMapper.map)
    }

    func isFavorite(productID: Int) async throws -> Bool {
        let accountID = try accountScopeProvider.currentIdentifier()
        return try await localDataSource.contains(productID: productID, accountID: accountID)
    }

    func setFavorite(_ medicine: FavoriteMedicine, isFavorite: Bool) async throws {
        let accountID = try accountScopeProvider.currentIdentifier()
        if isFavorite {
            try await localDataSource.upsert(FavoriteMedicineMapper.map(medicine), accountID: accountID)
        } else {
            try await localDataSource.remove(productID: medicine.id, accountID: accountID)
        }
    }
}
