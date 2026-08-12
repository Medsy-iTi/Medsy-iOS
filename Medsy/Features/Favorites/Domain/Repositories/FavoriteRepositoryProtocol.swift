//
//  FavoriteRepositoryProtocol.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

protocol FavoriteRepositoryProtocol {
    func fetchAll() async throws -> [FavoriteMedicine]
    func isFavorite(productID: Int) async throws -> Bool
    func setFavorite(_ medicine: FavoriteMedicine, isFavorite: Bool) async throws
}
