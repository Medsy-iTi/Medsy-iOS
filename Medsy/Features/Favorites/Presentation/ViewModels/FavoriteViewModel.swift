//
//  FavoriteViewModel.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

import Foundation
import Observation

enum FavoriteViewState: Equatable {
    case loading
    case loaded([FavoriteMedicineDisplayModel])
    case empty
    case failed(String)
}

@MainActor
protocol FavoriteViewModelProtocol: AnyObject {
    var state: FavoriteViewState { get }
    var isShowingOfflineAlert: Bool { get set }
    var persistenceErrorMessage: String? { get set }

    func load() async
    func remove(_ product: FavoriteMedicineDisplayModel) async
    func detailDestination(for productID: String) -> String?
}

@MainActor
@Observable
final class FavoriteViewModel: FavoriteViewModelProtocol {
    private(set) var state: FavoriteViewState = .loading
    var isShowingOfflineAlert = false
    var persistenceErrorMessage: String?

    @ObservationIgnored private let fetchFavoritesUseCase: FetchFavoritesUseCaseProtocol
    @ObservationIgnored private let setFavoriteUseCase: SetFavoriteUseCaseProtocol
    @ObservationIgnored private let connectivity: NetworkConnectivityProviding
    @ObservationIgnored private let languageManager: LanguageManager

    init(
        fetchFavoritesUseCase: FetchFavoritesUseCaseProtocol,
        setFavoriteUseCase: SetFavoriteUseCaseProtocol,
        connectivity: NetworkConnectivityProviding,
        languageManager: LanguageManager = .shared
    ) {
        self.fetchFavoritesUseCase = fetchFavoritesUseCase
        self.setFavoriteUseCase = setFavoriteUseCase
        self.connectivity = connectivity
        self.languageManager = languageManager
    }

    func load() async {
        state = .loading
        do {
            let medicines = try await fetchFavoritesUseCase.execute()
            guard !Task.isCancelled else { return }
            let products = medicines.map {
                FavoriteMedicinePresentationMapper.map($0, isRTL: languageManager.isRTL)
            }
            state = products.isEmpty ? .empty : .loaded(products)
        } catch is CancellationError {
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed("favorites.error.subtitle".localized)
        }
    }

    func remove(_ product: FavoriteMedicineDisplayModel) async {
        guard case let .loaded(products) = state else { return }
        let updatedProducts = products.filter { $0.id != product.id }
        state = updatedProducts.isEmpty ? .empty : .loaded(updatedProducts)

        do {
            try await setFavoriteUseCase.execute(product.medicine, isFavorite: false)
        } catch {
            state = .loaded(products)
            persistenceErrorMessage = "favorites.persistence_error.subtitle".localized
        }
    }

    func detailDestination(for productID: String) -> String? {
        guard connectivity.status != .disconnected else {
            isShowingOfflineAlert = true
            return nil
        }
        return productID
    }
}
