//
//  ProductRepositoryProtocol.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//

import Foundation

protocol ProductRepositoryProtocol {
    func fetchProducts(
        page: Int,
        size: Int,
        sort: [ProductSort],
		lang: String? 
    ) async throws -> PagedResult<Product>

    func searchProducts(
        keyword: String,
        page: Int,
        size: Int,
        sort: [ProductSort],
		lang: String?
    ) async throws -> PagedResult<Product>

    func fetchProductsByCategory(
        categoryId: Int,
        page: Int,
        size: Int,
        sort: [ProductSort],
        lang: String?
    ) async throws -> PagedResult<Product>
}
