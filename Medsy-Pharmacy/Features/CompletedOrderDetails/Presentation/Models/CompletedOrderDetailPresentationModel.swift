//
//  CompletedOrderDetailPresentationModel.swift
//  Medsy
//

import Foundation

struct CompletedOrderDetailPresentationModel: Identifiable {
    let id: Int
    let orderNumber: Int
    let customerName: String
    let customerNotes: String
    let pharmacistNotes: String
    let deliveryAddress: String
    let customerPhone: String
    let prescriptionImage: String?
    let pharmacistName: String
    let pharmacistPhone: String
    let createdAt: Date
    let items: [CompletedOrderItemPresentationModel]
    let subTotal: Double
    let deliveryFee: Double
    let total: Double
    let hasDelivery: Bool
    let deliveryLatitude: Double?
    let deliveryLongitude: Double?
    let status: PharmacyOrderAPIStatus
}

struct CompletedOrderItemPresentationModel: Identifiable {
    let id: Int
    let productId: Int
    let productName: String
    let imageUrl: String?
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
}


