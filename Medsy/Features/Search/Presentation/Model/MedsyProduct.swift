//
//  MedsyProduct.swift
//  Medsy
//
//  Created by Shahudaa on 16/07/2026.
//

import SwiftUI

struct MedsyProduct: Identifiable, Equatable {
	let id: String
	let name: String
	let dosageInfo: String
	let price: Double
	let imageUrl: String?
	let badgeText: String
	let badgeColor: Color
	let categoryName: String
	var isFavorite: Bool = false
	var quantity: Int = 0
}

enum ProductPresentationMapper {

    static func map(_ product: Product, isRTL: Bool) -> MedsyProduct {
        let (englishShortName, dosage) = ProductNameParser.parseName(product.name)

        let displayName: String
        if isRTL && !product.arabicName.isEmpty && product.arabicName != product.name {
            displayName = product.arabicName
        } else {
            displayName = englishShortName
        }

        return MedsyProduct(
            id: String(product.id),
            name: displayName,
            dosageInfo: dosage,
            price: product.price,
            imageUrl: product.imageUrl,
            badgeText: product.company,
            badgeColor: AppColor.green,
            categoryName: product.categoryName
        )
    }
}
