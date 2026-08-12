//  ProductsViewModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class ProductsViewModel {
    var products: [MedsyProduct] = []
    private(set) var state: ProductsUIState = .loading
    private(set) var isFetchingNextPage = false
    var favoriteErrorMessage: String?
    let category: Category

    private var currentPage = 0
    private var isLastPage = false
    private let getProductsUseCase: GetProductsByCategoryUseCase
    private let fetchFavoritesUseCase: FetchFavoritesUseCaseProtocol
    private let setFavoriteUseCase: SetFavoriteUseCaseProtocol
    private var favoriteCandidates: [String: FavoriteMedicine] = [:]

    init(
        category: Category,
        getProductsUseCase: GetProductsByCategoryUseCase = DIContainer.shared.resolve(GetProductsByCategoryUseCase.self),
        fetchFavoritesUseCase: FetchFavoritesUseCaseProtocol = DIContainer.shared.resolve(FetchFavoritesUseCaseProtocol.self),
        setFavoriteUseCase: SetFavoriteUseCaseProtocol = DIContainer.shared.resolve(SetFavoriteUseCaseProtocol.self)
    ) {
        self.category = category
        self.getProductsUseCase = getProductsUseCase
        self.fetchFavoritesUseCase = fetchFavoritesUseCase
        self.setFavoriteUseCase = setFavoriteUseCase
    }

    func loadProducts() async {
        state = .loading
        currentPage = 0
        isLastPage = false
        isFetchingNextPage = false
        do {
            let data = try await getProductsUseCase.execute(id: category.id, page: currentPage, size: 20)
            let favoriteIDs = await loadFavoriteIDs()
            favoriteCandidates = [:]
            products = map(data.items, favoriteIDs: favoriteIDs)
            isLastPage = data.isLast ?? true
            state = .success
        } catch {
            state = .error
        }
    }

    func loadNextPage() async {
        guard !isLastPage && !isFetchingNextPage else { return }
        isFetchingNextPage = true
        do {
            let nextPage = currentPage + 1
            let data = try await getProductsUseCase.execute(id: category.id, page: nextPage, size: 20)
            let favoriteIDs = await loadFavoriteIDs()
            let newProducts = map(data.items, favoriteIDs: favoriteIDs)
            products.append(contentsOf: newProducts)
            isLastPage = data.isLast ?? true
            currentPage = nextPage
        } catch {
        }
        isFetchingNextPage = false
    }

    func toggleFavorite(productID: String) async {
        guard let index = products.firstIndex(where: { $0.id == productID }),
              let medicine = favoriteCandidates[productID] else { return }

        let targetValue = !products[index].isFavorite
        products[index].isFavorite = targetValue

        do {
            try await setFavoriteUseCase.execute(medicine, isFavorite: targetValue)
        } catch {
            guard !Task.isCancelled else { return }
            if let currentIndex = products.firstIndex(where: { $0.id == productID }),
               products[currentIndex].isFavorite == targetValue {
                products[currentIndex].isFavorite = !targetValue
            }
            favoriteErrorMessage = "favorites.persistence_error.subtitle".localized
        }
    }

    private func loadFavoriteIDs() async -> Set<Int> {
        let favorites = (try? await fetchFavoritesUseCase.execute()) ?? []
        return Set(favorites.map(\.id))
    }

    private func map(_ items: [ProductItem], favoriteIDs: Set<Int>) -> [MedsyProduct] {
        items.map { item in
            favoriteCandidates[String(item.id)] = ProductItemPresentationMapper.favorite(item)
            var product = ProductItemPresentationMapper.map(
                item,
                isRTL: LanguageManager.shared.isRTL
            )
            product.isFavorite = favoriteIDs.contains(item.id)
            return product
        }
    }
}

enum ProductsUIState {
    case loading
    case success
    case error
}
