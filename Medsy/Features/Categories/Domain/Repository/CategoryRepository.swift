//  CategoryRepository.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.

protocol CategoryRepository {
    func getCategories(page: Int, size: Int, lang: String?) async throws -> PagedResult<Category>
}
