//
//  ProductDetailViewModel.swift
//  Medsy
//
//  Created by Shahudaa on 15/07/2026.
//

import Foundation
import Combine


@MainActor
final class ProductDetailViewModel: ObservableObject {
    @Published var state: MedsyLoadState = .loading
    @Published var product: ProductDetail?
    @Published var isFavorite: Bool = false
    @Published var selectedImageIndex: Int = 0

    private let productId: String

    init(productId: String) {
        self.productId = productId
    }

    func load() {
        state = .loading

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self else { return }
            self.product = .sample
            self.state = .loaded
        }
    }

    func toggleFavorite() {
        isFavorite.toggle()

    }

    func addToCart() {

    }

    func consultPharmacist() {

    }
}
