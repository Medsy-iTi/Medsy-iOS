//
//  CartItemPresentationMapper.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

import Foundation

enum CartItemPresentationMapper {
    static func map(_ item: CartItem) -> CartDisplayItem {
        CartDisplayItem(
            id: String(item.id),
            productID: item.productID,
            cartItemID: item.id,
            name: item.productName,
            dosageInfo: item.dosageInfo,
            unitPrice: item.unitPrice,
            quantity: item.quantity,
            imageUrl: item.imageURL
        )
    }

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

enum CartPrescriptionPresentationMapper {
    static func map(_ prescription: CartPrescription) -> CartPrescriptionAttachment {
        CartPrescriptionAttachment(
            id: prescription.id,
            imageData: prescription.data,
            source: prescription.source,
            createdAt: prescription.createdAt
        )
    }

    static func map(_ attachment: CartPrescriptionAttachment) -> CartPrescription {
        CartPrescription(
            id: attachment.id,
            data: attachment.imageData,
            source: attachment.source,
            createdAt: attachment.createdAt
        )
    }
}
