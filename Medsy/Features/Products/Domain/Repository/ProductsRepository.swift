//  ProductsRepository.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.

import Foundation

protocol ProductsRepository {
    func getProductsByCategory(id: Int, page: Int, size: Int, language: String) async throws -> PagedResult<ProductItem>
}
