//
//  ProductPresentationMapper.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//

import SwiftUI

struct MedsyProduct: Identifiable, Equatable {
	let id: String
	let name: String
	let subtitle: String
	let price: Double
	let imageUrl: String?
	let badgeText: String
	let badgeColor: Color
	var isFavorite: Bool = false
	var quantity: Int = 0
}
enum ProductPresentationMapper {

    static func map(_ product: Product, isRTL: Bool) -> MedsyProduct {
        MedsyProduct(
            id: String(product.id),
            name: product.displayName(isRTL: isRTL),
            subtitle: product.scientificName,
            price: product.price,
            imageUrl: product.imageUrl,
            badgeText: product.company,
            badgeColor: AppColor.green
        )
    }
}
