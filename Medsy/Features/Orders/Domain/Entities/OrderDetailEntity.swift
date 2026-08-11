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
    let paymentMethod: MasterOrderPaymentMethod
    let paymentStatus: MasterOrderPaymentStatus
    let paymentExpiresAt: Date?

    init(
        id: Int,
        orderNumber: Int,
        pharmacyName: String,
        pharmacyId: Int,
        status: OrderStatus,
        fulfillmentType: OrderFulfillmentType,
        date: Date,
        items: [OrderDetailItemEntity],
        itemsSubtotal: Double,
        deliveryFee: Double?,
        totalPrice: Double,
        paymentMethod: MasterOrderPaymentMethod = .unknown,
        paymentStatus: MasterOrderPaymentStatus = .unknown,
        paymentExpiresAt: Date? = nil
    ) {
        self.id = id
        self.orderNumber = orderNumber
        self.pharmacyName = pharmacyName
        self.pharmacyId = pharmacyId
        self.status = status
        self.fulfillmentType = fulfillmentType
        self.date = date
        self.items = items
        self.itemsSubtotal = itemsSubtotal
        self.deliveryFee = deliveryFee
        self.totalPrice = totalPrice
        self.paymentMethod = paymentMethod
        self.paymentStatus = paymentStatus
        self.paymentExpiresAt = paymentExpiresAt
    }
}

struct OrderDetailItemEntity: Identifiable {
    let id: Int
    let productId: Int
    let productName: String
    let originalProductName: String?
    let quantity: Int
    let unitPrice: Double
    let imageURL: String?
}
