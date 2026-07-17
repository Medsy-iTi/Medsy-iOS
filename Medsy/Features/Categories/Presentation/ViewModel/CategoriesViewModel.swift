//  CategoriesViewModel.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.

import Foundation
import Observation

@MainActor
@Observable
final class CategoriesViewModel {
    private(set) var categories: [CategoryEntity] = []
    private(set) var state: CategoriesUIState = .loading
    private(set) var isFetchingNextPage = false

    private var currentPage = 0
    private var isLastPage = false
    private let getCategoriesUseCase: GetCategoriesUseCase

    nonisolated init(getCategoriesUseCase: GetCategoriesUseCase) {
        self.getCategoriesUseCase = getCategoriesUseCase
    }

    func loadCategories() async {
        state = .loading
        currentPage = 0
        isLastPage = false
        isFetchingNextPage = false
        do {
            let data = try await getCategoriesUseCase.execute(page: currentPage)
            categories = data.content
            isLastPage = data.last
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
            let data = try await getCategoriesUseCase.execute(page: nextPage)
            categories.append(contentsOf: data.content)
            isLastPage = data.last
            currentPage = nextPage
        } catch {
        }
        isFetchingNextPage = false
    }
}

enum CategoriesUIState {
    case loading
    case success
    case error
}
