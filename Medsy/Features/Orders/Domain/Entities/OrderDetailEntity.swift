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
    let requestID: Int?
    let pharmacies: [OrderPharmacyEntity]
    let paymentMethod: OrderPaymentMethod?
    let paymentStatus: OrderPaymentStatus?
    let paymentExpiresAt: Date?
    let paidAt: Date?

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
        requestID: Int? = nil,
        pharmacies: [OrderPharmacyEntity] = [],
        paymentMethod: OrderPaymentMethod? = nil,
        paymentStatus: OrderPaymentStatus? = nil,
        paymentExpiresAt: Date? = nil,
        paidAt: Date? = nil
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
        self.requestID = requestID
        self.pharmacies = pharmacies
        self.paymentMethod = paymentMethod
        self.paymentStatus = paymentStatus
        self.paymentExpiresAt = paymentExpiresAt
        self.paidAt = paidAt
    }
}

struct OrderDetailItemEntity: Identifiable {
    let id: Int
    let productId: Int?
    let productName: String
    let originalProductName: String?
    let quantity: Int
    let unitPrice: Double
    let imageURL: String?
    let product: OrderProductEntity?

    init(
        id: Int,
        productId: Int?,
        productName: String,
        originalProductName: String?,
        quantity: Int,
        unitPrice: Double,
        imageURL: String?,
        product: OrderProductEntity? = nil
    ) {
        self.id = id
        self.productId = productId
        self.productName = productName
        self.originalProductName = originalProductName
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.imageURL = imageURL
        self.product = product
    }
}

struct OrderPharmacyEntity: Identifiable {
    let id: Int
    let pharmacyId: Int
    let pharmacyName: String
    let coordinate: OrderCoordinateEntity?
    let items: [OrderDetailItemEntity]
}

struct OrderCoordinateEntity: Equatable {
    let latitude: Double
    let longitude: Double
}

struct OrderProductEntity: Identifiable {
    let id: Int
    let name: String?
    let productName: String?
    let strength: String?
    let packSize: String?
    let form: String?
    let price: Double?
    let scientificName: String?
    let company: String?
    let route: String?
    let description: String?
    let imageURL: String?
}
