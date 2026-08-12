//
//  CompletedOrderItemDTO.swift
//  Medsy
//
//  Created by Shahudaa on 26/07/2026.
//



import Foundation

struct CompletedOrderItemDTO: Decodable {
    let id: Int
    let productId: Int
    let productName: String
    let imageUrl: String
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
    let deliveryFee: Double
    let total: Double
    let deliveryLatitude: Double
    let deliveryLongitude: Double
    let createdAt: String
    let items: [CompletedOrderItemDTO]
    
    
}



