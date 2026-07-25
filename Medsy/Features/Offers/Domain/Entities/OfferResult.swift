//
//  OfferResult.swift
//  Medsy
//
//  Created by Antoneos Philip on 25/07/2026.
//

import Foundation

struct OfferResultItem: Identifiable, Equatable, Hashable {
    var id: Int { requestItemId }
    let requestItemId: Int
    let productId: Int?
    let productName: String
    let imageUrl: String?
    let unitPrice: Double
    let isAlternative: Bool
    let isAvailable: Bool
}

struct OfferResult: Equatable, Hashable {
    let items: [OfferResultItem]
    let totalPrice: Double

    var isAvailable: Bool {
        !items.isEmpty && items.contains(where: { $0.isAvailable })
    }
}

