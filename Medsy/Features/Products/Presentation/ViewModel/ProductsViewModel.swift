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
    let category: Category

    init(category: Category) {
        self.category = category
    }

    func loadProducts() async {
        state = .loading
        do {
            try await Task.sleep(nanoseconds: 800_000_000)
            products = ProductsViewModel.mockProducts(for: category)
            state = .success
        } catch {
            state = .error
        }
    }

    private static func mockProducts(for category: Category) -> [MedsyProduct] {
        let catName = category.name.lowercased()
        return [
            MedsyProduct(id: "1", name: "Adapalene Gel 0.1%", dosageInfo: "Apply once daily in the evening", price: 15.99, imageUrl: nil, badgeText: "Galderma", badgeColor: AppColor.green, categoryName: category.name),
        ]
    }
}

enum ProductsUIState {
    case loading
    case success
    case error
}
