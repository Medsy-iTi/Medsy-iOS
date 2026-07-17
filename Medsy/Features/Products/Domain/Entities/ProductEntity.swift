//
//  ProductEntity.swift
//  Medsy
//
//  Created by Antoneos Philip on 17/07/2026.
//

import Foundation
struct ProductItem: Identifiable, Equatable {
    let id: Int
    let name: String
    let arabicName: String
    let scientificName: String
    let price: Double
    let imageUrl: String?
    let categoryId: Int
    let categoryName: String
    let company: String
    let route: String

    func displayName(isRTL: Bool) -> String {
        isRTL && !arabicName.isEmpty ? arabicName : name
    }
}
