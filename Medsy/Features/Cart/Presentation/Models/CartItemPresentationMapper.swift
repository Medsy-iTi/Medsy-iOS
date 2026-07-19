//
//  CartItemPresentationMapper.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

enum CartItemPresentationMapper {
    static func map(_ product: MedsyProduct, quantity: Int = 1) -> CartDisplayItem {
        CartDisplayItem(
            id: product.id,
            productID: Int64(product.id),
            name: product.name,
            dosageInfo: product.dosageInfo,
            unitPrice: product.price,
            quantity: quantity,
            imageUrl: product.imageUrl
        )
    }

    static func map(_ product: ProductDetailDisplayModel, quantity: Int = 1) -> CartDisplayItem {
        CartDisplayItem(
            id: product.id,
            productID: Int64(product.id),
            name: product.title,
            dosageInfo: product.subtitle,
            unitPrice: product.price,
            quantity: quantity,
            imageUrl: product.images.first
        )
    }
}
