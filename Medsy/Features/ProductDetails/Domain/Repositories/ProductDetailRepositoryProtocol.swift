//
//  ProductDetailRepositoryProtocol.swift
//  Medsy
//  Created by Shahudaa on 16/07/2026.
//

import Foundation

protocol ProductDetailRepositoryProtocol {
    func fetchProduct(id: Int, lang: String?) async throws -> ProductDetailEntity
}
