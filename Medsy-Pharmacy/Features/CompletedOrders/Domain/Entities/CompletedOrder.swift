//
//  CompletedOrder.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//


import Foundation

struct CompletedOrder: Identifiable, Equatable {
    let id: Int
    let customerId: Int
    let customerName: String
    let deliveryAddress: String
    let customerPhone: String
    let pharmacyId: Int
    let pharmacyName: String
    let pharmacyAddress: String
    let pharmacyPhone: String
    let pharmacistId: Int
    let pharmacistName: String
    let offerId: Int
    let subTotal: Double
    let deliveryFee: Double
    let total: Double
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let createdAt: Date
    let paymentMethod: PharmacyOrderPaymentMethod
    let status: PharmacyOrderAPIStatus
    let items: [CompletedOrderItem]
}
