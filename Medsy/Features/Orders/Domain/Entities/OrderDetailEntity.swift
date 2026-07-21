//
//  OrderDetailEntity.swift
//  Medsy
//
//  Created by Ahmed Elkady on 21/07/2026.
//

import Foundation

struct OrderDetailEntity: Identifiable {
    let id: Int
    let orderNumber: Int
    let pharmacyName: String
    let pharmacyId: Int
    let status: OrderStatus
    let fulfillmentType: OrderFulfillmentType
    let date: Date
    let items: [OrderDetailItemEntity]
    let itemsSubtotal: Double
    let deliveryFee: Double?
    let totalPrice: Double
}

struct OrderDetailItemEntity: Identifiable {
    let id: Int
    let productName: String
    let originalProductName: String?
    let quantity: Int
    let unitPrice: Double
}
