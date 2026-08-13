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
    @Published var selectedImageIndex: Int = 0

    private let productId: String
    private let useCase: FetchProductDetailUseCaseProtocol
    private let languageManager: LanguageManager
    private var loadTask: Task<Void, Never>?

    init(
        productId: String,
        useCase: FetchProductDetailUseCaseProtocol = DIContainer.shared.resolve(FetchProductDetailUseCaseProtocol.self),
        languageManager: LanguageManager = .shared
    ) {
        self.productId = productId
        self.useCase = useCase
        self.languageManager = languageManager
    }

    func load() {
        loadTask?.cancel()
        state = .loading
        loadTask = Task { await fetch() }
    }

    func toggleFavorite() {
        isFavorite.toggle()
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
            let entity = try await useCase.execute(
                id: id,
                lang: languageManager.currentLanguage.rawValue
            )
            guard !Task.isCancelled else { return }
            product = ProductDetailPresentationMapper.map(entity, isRTL: languageManager.isRTL)
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
