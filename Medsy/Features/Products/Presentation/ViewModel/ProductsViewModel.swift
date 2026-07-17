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
    let category: Category

    private var currentPage = 0
    private var isLastPage = false
    private let getProductsUseCase: GetProductsByCategoryUseCase

    init(category: Category, getProductsUseCase: GetProductsByCategoryUseCase = DIContainer.shared.resolve(GetProductsByCategoryUseCase.self)) {
        self.category = category
        self.getProductsUseCase = getProductsUseCase
    }

    func loadProducts() async {
        state = .loading
        currentPage = 0
        isLastPage = false
        isFetchingNextPage = false
        do {
            let data = try await getProductsUseCase.execute(id: category.id, page: currentPage, size: 20)
            products = data.items.map { ProductItemPresentationMapper.map($0, isRTL: LanguageManager.shared.isRTL) }
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
            let newProducts = data.items.map { ProductItemPresentationMapper.map($0, isRTL: LanguageManager.shared.isRTL) }
            products.append(contentsOf: newProducts)
            isLastPage = data.isLast ?? true
            currentPage = nextPage
        } catch {
        }
        isFetchingNextPage = false
    }
}

enum ProductsUIState {
    case loading
    case success
    case error
}
