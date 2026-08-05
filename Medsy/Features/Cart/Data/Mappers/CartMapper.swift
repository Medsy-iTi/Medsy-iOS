//
//  CartMapper.swift
//  Medsy
//
//  Created by Ahmed Elkady on 19/07/2026.
//

enum CartMapper {
    static func map(_ dto: CartDTO) -> Cart {
        Cart(
            id: dto.id,
            items: dto.items.map {
                CartItem(
                    id: $0.id,
                    productID: $0.productId,
                    productName: $0.productName,
                    dosageInfo: $0.dosageInfo,
                    imageURL: $0.imageUrl,
                    unitPrice: $0.unitPrice,
                    quantity: $0.quantity,
                    subtotal: $0.subtotal
                )
            },
            totalPrice: dto.totalPrice
        )
    }

    static func map(_ dto: CachedCartDTO) -> Cart {
        Cart(
            id: dto.id,
            items: dto.items.map {
                CartItem(
                    id: $0.id,
                    productID: $0.productId,
                    productName: $0.productName,
                    dosageInfo: $0.dosageInfo,
                    imageURL: $0.imageUrl,
                    unitPrice: $0.unitPrice,
                    quantity: $0.quantity,
                    subtotal: $0.subtotal
                )
            },
            totalPrice: dto.totalPrice
        )
    }
}
