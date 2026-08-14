//
//  CompletedOrderItemDTO.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//



import Foundation

struct CompletedOrderProductDTO: Decodable {
    let id: Int
    let name: String?
    let imageUrl: String?
}

struct CompletedOrderItemDTO: Decodable {
    let id: Int
    let productId: Int
    let product: CompletedOrderProductDTO?
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
}

struct CompletedOrderDTO: Decodable {
    let id: Int
    let customerId: Int
    let customerName: String?
    let deliveryAddress: String?
    let phoneNumber: String?
    let pharmacyId: Int
    let pharmacyName: String
    let pharmacyAddress: String
    let pharmacyPhone: String
    let pharmacistId: Int
    let pharmacistName: String
    let offerId: Int
    let subTotal: Double
    let deliveryFee: Double?
    let total: Double
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let createdAt: String
    let paymentMethod: String?
    let status: String?
    let items: [CompletedOrderItemDTO]
}



