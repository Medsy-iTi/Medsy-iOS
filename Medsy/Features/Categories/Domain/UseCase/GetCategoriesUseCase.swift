//  GetCategoriesUseCase.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.

struct GetCategoriesUseCase {
    private let repository: CategoryRepository

    init(repository: CategoryRepository) {
        self.repository = repository
    }

    func execute(page: Int = 0, size: Int = 20, lang: String? = nil) async throws -> PagedResult<Category> {
        try await repository.getCategories(page: page, size: size, lang: lang)
    }
}
