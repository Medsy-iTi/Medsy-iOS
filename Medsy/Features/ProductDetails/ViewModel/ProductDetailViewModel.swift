//
//  ProductDetailViewModel.swift
//  Medsy
//  Created by Shahudaa on 15/07/2026.
//

import Foundation
import Combine

extension Notification.Name {
    static let openChatbotTab = Notification.Name("com.medsy.openChatbotTab")
}

@MainActor
final class ProductDetailViewModel: ObservableObject {

    @Published var state: MedsyLoadState = .loading
    @Published var product: ProductDetailDisplayModel?
    @Published var isFavorite: Bool = false
    @Published var favoriteErrorMessage: String?
    @Published var selectedImageIndex: Int = 0

    private let productId: String
    private let useCase: FetchProductDetailUseCaseProtocol
    private let languageManager: LanguageManager
    private let isFavoriteUseCase: IsFavoriteUseCaseProtocol
    private let setFavoriteUseCase: SetFavoriteUseCaseProtocol
    private var loadTask: Task<Void, Never>?
    private var favoriteMedicine: FavoriteMedicine?

    init(
        productId: String,
        useCase: FetchProductDetailUseCaseProtocol = DIContainer.shared.resolve(FetchProductDetailUseCaseProtocol.self),
        isFavoriteUseCase: IsFavoriteUseCaseProtocol = DIContainer.shared.resolve(IsFavoriteUseCaseProtocol.self),
        setFavoriteUseCase: SetFavoriteUseCaseProtocol = DIContainer.shared.resolve(SetFavoriteUseCaseProtocol.self),
        languageManager: LanguageManager = .shared
    ) {
        self.productId = productId
        self.useCase = useCase
        self.isFavoriteUseCase = isFavoriteUseCase
        self.setFavoriteUseCase = setFavoriteUseCase
        self.languageManager = languageManager
    }

    func load() {
        loadTask?.cancel()
        state = .loading
        loadTask = Task { await fetch() }
    }

    func toggleFavorite() {
        guard let favoriteMedicine else { return }
        let targetValue = !isFavorite
        isFavorite = targetValue
        Task {
            do {
                try await setFavoriteUseCase.execute(
                    favoriteMedicine,
                    isFavorite: targetValue
                )
            } catch {
                guard !Task.isCancelled else { return }
                isFavorite = !targetValue
                favoriteErrorMessage = "favorites.persistence_error.subtitle".localized
            }
        }
    }

    func consultPharmacist() {
        let productName = product?.title ?? ""
        NotificationCenter.default.post(
            name: .openChatbotTab,
            object: nil,
            userInfo: ["productName": productName]
        )
    }

    // MARK: – Private

    private func fetch() async {
        guard let id = Int(productId) else {
            state = .error
            return
        }

        do {
            async let favoriteState = try? isFavoriteUseCase.execute(productID: id)
            let entity = try await useCase.execute(
                id: id,
                lang: languageManager.currentLanguage.rawValue
            )
            guard !Task.isCancelled else { return }
            product = ProductDetailPresentationMapper.map(entity, isRTL: languageManager.isRTL)
            favoriteMedicine = FavoriteMedicine(
                id: entity.id,
                name: entity.name,
                arabicName: entity.arabicName,
                scientificName: entity.scientificName,
                price: entity.price,
                imageURL: entity.imageUrl,
                categoryID: entity.categoryId,
                categoryName: entity.categoryName,
                company: entity.company,
                route: entity.route
            )
            isFavorite = await favoriteState ?? false
            state = .loaded

        } catch is CancellationError {
            

        } catch let error as NetworkError {
            guard !Task.isCancelled else { return }
            print("[ProductDetail] NetworkError: \(error.localizedDescription)")
            state = .noConnection

        } catch {
            guard !Task.isCancelled else { return }
            print("[ProductDetail] Error: \(error.localizedDescription)")
            state = .error
        }
    }
}
