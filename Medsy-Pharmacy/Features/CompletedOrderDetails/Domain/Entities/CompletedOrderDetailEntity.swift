//
//  CompletedOrderDetailEntity.swift
//  Medsy
//

import Foundation

struct CompletedOrderDetailsEntity: Identifiable {
    let id: Int
    let customerId: Int
    let customerName: String
    let pharmacyId: Int
    let pharmacyName: String
    let pharmacyAddress: String
    let pharmacyPhone: String
    let pharmacistName: String
    let offerId: Int?
    let subTotal: Double
    let deliveryFee: Double
    let total: Double
    let deliveryLatitude: Double?
    let deliveryLongitude: Double?
    let createdAt: Date
    let items: [CompletedOrderDetailsItemEntity]
}

struct CompletedOrderDetailsItemEntity: Identifiable {
    let id: Int
    let productId: Int
    let productName: String
    let imageUrl: String?
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
}
